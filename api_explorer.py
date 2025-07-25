#!/usr/bin/env python3
"""
API Explorer - Enhanced OpenAPI Schema Query Tool
Provides comprehensive access to API endpoints with full schema resolution.
"""

import json
import sys
import argparse
import re
from typing import Dict, Any, List, Optional, Set
from pathlib import Path


class APIExplorer:
    def __init__(self, schema_file: str = "api_schema.json"):
        """Initialize the API Explorer with the schema file."""
        self.schema_file = Path(schema_file)
        self.schema = self._load_schema()
        self.components = self.schema.get("components", {})
        self.schemas = self.components.get("schemas", {})
    
    def _load_schema(self) -> Dict[str, Any]:
        """Load the OpenAPI schema from JSON file."""
        try:
            with open(self.schema_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Error: Schema file '{self.schema_file}' not found.")
            sys.exit(1)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in schema file: {e}")
            sys.exit(1)
    
    def _resolve_schema_ref(self, ref: str) -> Optional[Dict[str, Any]]:
        """
        Resolve a schema reference like '#/components/schemas/Client'.
        
        Args:
            ref: Reference string
            
        Returns:
            Resolved schema or None if not found
        """
        if not ref.startswith("#/components/schemas/"):
            return None
        
        schema_name = ref.split("/")[-1]
        return self.schemas.get(schema_name)
    
    def _extract_schema_refs(self, obj: Any, visited: Set[str] = None) -> Set[str]:
        """
        Recursively extract all schema references from an object.
        
        Args:
            obj: Object to search for references
            visited: Set of already visited references to avoid cycles
            
        Returns:
            Set of schema reference names
        """
        if visited is None:
            visited = set()
        
        refs = set()
        
        if isinstance(obj, dict):
            if "$ref" in obj:
                ref_name = obj["$ref"].split("/")[-1]
                if ref_name not in visited:
                    visited.add(ref_name)
                    refs.add(ref_name)
                    # Recursively resolve referenced schema
                    ref_schema = self._resolve_schema_ref(obj["$ref"])
                    if ref_schema:
                        refs.update(self._extract_schema_refs(ref_schema, visited))
            else:
                for value in obj.values():
                    refs.update(self._extract_schema_refs(value, visited))
        elif isinstance(obj, list):
            for item in obj:
                refs.update(self._extract_schema_refs(item, visited))
        
        return refs
    
    def _get_related_schemas(self, schema_names: Set[str]) -> Dict[str, Any]:
        """
        Get the complete definitions for a set of schema names.
        
        Args:
            schema_names: Set of schema names to resolve
            
        Returns:
            Dictionary of schema definitions
        """
        related_schemas = {}
        
        for schema_name in schema_names:
            schema_def = self.schemas.get(schema_name)
            if schema_def:
                related_schemas[schema_name] = schema_def
        
        return related_schemas
    
    def get_complete_endpoint(self, endpoint: str) -> Optional[Dict[str, Any]]:
        """
        Get complete endpoint information with all related schemas resolved.
        
        Args:
            endpoint: Endpoint path
            
        Returns:
            Complete endpoint information with resolved schemas
        """
        paths = self.schema.get("paths", {})
        endpoint_data = paths.get(endpoint)
        
        if not endpoint_data:
            return None
        
        # Extract all schema references from the endpoint
        all_refs = self._extract_schema_refs(endpoint_data)
        
        # Get all related schema definitions
        related_schemas = self._get_related_schemas(all_refs)
        
        return {
            "endpoint": endpoint,
            "definition": endpoint_data,
            "related_schemas": related_schemas,
            "schema_count": len(related_schemas)
        }
    
    def get_complete_endpoints_by_prefix(self, prefix: str) -> Dict[str, Any]:
        """
        Get all endpoints with prefix including complete schema information.
        
        Args:
            prefix: URL prefix to filter by
            
        Returns:
            Dictionary of complete endpoint information
        """
        paths = self.schema.get("paths", {})
        matching_endpoints = {}
        all_related_schemas = {}
        
        for endpoint, methods in paths.items():
            if endpoint.startswith(prefix):
                # Extract schema references for this endpoint
                endpoint_refs = self._extract_schema_refs(methods)
                endpoint_schemas = self._get_related_schemas(endpoint_refs)
                
                matching_endpoints[endpoint] = {
                    "definition": methods,
                    "related_schemas": list(endpoint_refs),
                    "schema_count": len(endpoint_refs)
                }
                
                # Collect all schemas
                all_related_schemas.update(endpoint_schemas)
        
        return {
            "endpoints": matching_endpoints,
            "all_related_schemas": all_related_schemas,
            "total_endpoints": len(matching_endpoints),
            "total_schemas": len(all_related_schemas)
        }
    
    def get_endpoint_with_full_schemas(self, endpoint: str) -> Optional[Dict[str, Any]]:
        """
        Get endpoint with fully resolved schemas (no $ref, actual definitions).
        
        Args:
            endpoint: Endpoint path
            
        Returns:
            Endpoint with fully resolved schemas
        """
        complete_info = self.get_complete_endpoint(endpoint)
        if not complete_info:
            return None
        
        # Create a copy of the endpoint definition and resolve all $ref
        resolved_definition = self._resolve_all_refs(complete_info["definition"])
        
        return {
            "endpoint": endpoint,
            "definition": resolved_definition,
            "related_schemas": complete_info["related_schemas"],
            "schema_count": complete_info["schema_count"]
        }
    
    def _resolve_all_refs(self, obj: Any, visited: Set[str] = None) -> Any:
        """
        Recursively resolve all $ref in an object.
        
        Args:
            obj: Object to resolve references in
            visited: Set of visited references to avoid cycles
            
        Returns:
            Object with resolved references
        """
        if visited is None:
            visited = set()
        
        if isinstance(obj, dict):
            if "$ref" in obj:
                ref_name = obj["$ref"].split("/")[-1]
                if ref_name in visited:
                    return {"$ref": obj["$ref"], "_resolved": "circular_reference"}
                
                visited.add(ref_name)
                resolved_schema = self._resolve_schema_ref(obj["$ref"])
                visited.remove(ref_name)
                
                if resolved_schema:
                    return self._resolve_all_refs(resolved_schema, visited)
                else:
                    return obj
            else:
                resolved_dict = {}
                for key, value in obj.items():
                    resolved_dict[key] = self._resolve_all_refs(value, visited)
                return resolved_dict
        elif isinstance(obj, list):
            return [self._resolve_all_refs(item, visited) for item in obj]
        else:
            return obj
    
    def get_schema_with_dependencies(self, schema_name: str) -> Dict[str, Any]:
        """
        Get a schema with all its dependencies resolved.
        
        Args:
            schema_name: Name of the schema
            
        Returns:
            Schema with all dependencies
        """
        schema_def = self.schemas.get(schema_name)
        if not schema_def:
            return {}
        
        # Extract all dependencies
        deps = self._extract_schema_refs(schema_def)
        related_schemas = self._get_related_schemas(deps)
        
        return {
            "schema_name": schema_name,
            "definition": schema_def,
            "dependencies": list(deps),
            "related_schemas": related_schemas,
            "dependency_count": len(deps)
        }
    
    def get_endpoint_analysis(self, endpoint: str) -> Dict[str, Any]:
        """
        Get comprehensive analysis of an endpoint.
        
        Args:
            endpoint: Endpoint path
            
        Returns:
            Detailed analysis including methods, schemas, security, etc.
        """
        endpoint_data = self.schema.get("paths", {}).get(endpoint)
        if not endpoint_data:
            return {}
        
        analysis = {
            "endpoint": endpoint,
            "methods": {},
            "all_schemas_used": set(),
            "security_schemes": set(),
            "parameters": {},
            "request_schemas": {},
            "response_schemas": {}
        }
        
        for method, method_data in endpoint_data.items():
            method_analysis = {
                "operation_id": method_data.get("operationId", ""),
                "description": method_data.get("description", ""),
                "tags": method_data.get("tags", []),
                "parameters": [],
                "request_body": None,
                "responses": {},
                "security": method_data.get("security", []),
                "schemas_used": set()
            }
            
            # Analyze parameters
            if "parameters" in method_data:
                for param in method_data["parameters"]:
                    param_info = {
                        "name": param.get("name", ""),
                        "in": param.get("in", ""),
                        "required": param.get("required", False),
                        "description": param.get("description", ""),
                        "schema": param.get("schema", {})
                    }
                    method_analysis["parameters"].append(param_info)
                    
                    # Extract schema refs from parameters
                    param_refs = self._extract_schema_refs(param)
                    method_analysis["schemas_used"].update(param_refs)
            
            # Analyze request body
            if "requestBody" in method_data:
                request_body = method_data["requestBody"]
                method_analysis["request_body"] = {
                    "required": request_body.get("required", False),
                    "content": {}
                }
                
                for content_type, content_data in request_body.get("content", {}).items():
                    schema_info = content_data.get("schema", {})
                    method_analysis["request_body"]["content"][content_type] = schema_info
                    
                    # Extract schema refs from request body
                    rb_refs = self._extract_schema_refs(schema_info)
                    method_analysis["schemas_used"].update(rb_refs)
            
            # Analyze responses
            if "responses" in method_data:
                for status_code, response_data in method_data["responses"].items():
                    response_info = {
                        "description": response_data.get("description", ""),
                        "content": {}
                    }
                    
                    for content_type, content_data in response_data.get("content", {}).items():
                        schema_info = content_data.get("schema", {})
                        response_info["content"][content_type] = schema_info
                        
                        # Extract schema refs from responses
                        resp_refs = self._extract_schema_refs(schema_info)
                        method_analysis["schemas_used"].update(resp_refs)
                    
                    method_analysis["responses"][status_code] = response_info
            
            # Collect security schemes
            for security_item in method_analysis["security"]:
                analysis["security_schemes"].update(security_item.keys())
            
            analysis["methods"][method.upper()] = method_analysis
            analysis["all_schemas_used"].update(method_analysis["schemas_used"])
        
        # Convert sets to lists for JSON serialization
        analysis["all_schemas_used"] = list(analysis["all_schemas_used"])
        analysis["security_schemes"] = list(analysis["security_schemes"])
        
        for method_data in analysis["methods"].values():
            method_data["schemas_used"] = list(method_data["schemas_used"])
        
        # Get all related schema definitions
        all_related_schemas = self._get_related_schemas(set(analysis["all_schemas_used"]))
        analysis["related_schemas"] = all_related_schemas
        analysis["schema_count"] = len(all_related_schemas)
        
        return analysis

    # Keep existing methods for backward compatibility
    def get_endpoints_by_prefix(self, prefix: str) -> Dict[str, Any]:
        """Get endpoints by prefix (legacy method)."""
        return self.get_complete_endpoints_by_prefix(prefix)
    
    def get_specific_endpoint(self, endpoint: str) -> Optional[Dict[str, Any]]:
        """Get specific endpoint (legacy method)."""
        result = self.get_complete_endpoint(endpoint)
        return result["definition"] if result else None
    
    def get_schema_component(self, component_name: str) -> Optional[Dict[str, Any]]:
        """Get schema component with dependencies."""
        return self.get_schema_with_dependencies(component_name)
    
    def list_all_endpoints(self, level: int = 1) -> List[str]:
        """List all available endpoints."""
        paths = self.schema.get("paths", {})
        results = []
        
        for endpoint, methods in paths.items():
            if level == 1:
                results.append(endpoint)
            elif level == 2:
                method_list = list(methods.keys())
                results.append(f"{endpoint} [{', '.join(method_list).upper()}]")
            else:  # level 3
                for method, details in methods.items():
                    operation_id = details.get("operationId", "")
                    description = details.get("description", "")
                    results.append(f"{endpoint} {method.upper()} - {operation_id}: {description}")
        
        return results
    
    def list_schema_components(self, level: int = 1) -> List[str]:
        """List all schema components."""
        results = []
        
        for name, schema_def in self.schemas.items():
            if level == 1:
                results.append(name)
            elif level == 2:
                schema_type = schema_def.get("type", "")
                if "enum" in schema_def:
                    schema_type = "enum"
                elif "properties" in schema_def:
                    schema_type = "object"
                results.append(f"{name} ({schema_type})")
            else:  # level 3
                results.append(f"{name}: {json.dumps(schema_def, indent=2)}")
        
        return results
    
    def search_endpoints(self, query: str) -> List[str]:
        """Search for endpoints containing the query string."""
        paths = self.schema.get("paths", {})
        results = []
        
        for endpoint, methods in paths.items():
            if query.lower() in endpoint.lower():
                results.append(endpoint)
            else:
                # Search in descriptions and operation IDs
                for method, details in methods.items():
                    description = details.get("description", "").lower()
                    operation_id = details.get("operationId", "").lower()
                    if query.lower() in description or query.lower() in operation_id:
                        results.append(f"{endpoint} ({method.upper()})")
                        break
        
        return results
    
    def get_endpoint_summary(self, endpoint: str) -> Dict[str, Any]:
        """Get endpoint summary (enhanced version)."""
        return self.get_endpoint_analysis(endpoint)
    
    def print_formatted_output(self, data: Any, title: str = ""):
        """Print formatted JSON output."""
        if title:
            print(f"\n=== {title} ===")
        print(json.dumps(data, indent=2, ensure_ascii=False))


def main():
    parser = argparse.ArgumentParser(
        description="Explore API endpoints and schemas from OpenAPI JSON file with complete schema resolution",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Get all client endpoints with complete schemas
  python api_explorer.py --prefix "/api/v1/clients"
  
  # Get specific endpoint with all related schemas
  python api_explorer.py --endpoint "/api/v1/clients/stats/"
  
  # Get complete endpoint analysis
  python api_explorer.py --analysis "/api/v1/invoices/{id}/"
  
  # Get schema with all dependencies
  python api_explorer.py --schema "AccessLevelEnum"
  
  # Get endpoint with fully resolved schemas (no $ref)
  python api_explorer.py --resolved "/api/v1/clients/"
        """
    )
    
    parser.add_argument(
        "--schema-file", 
        default="api_schema.json",
        help="Path to the OpenAPI schema JSON file"
    )
    
    parser.add_argument(
        "--prefix",
        help="Get all endpoints starting with this prefix with complete schemas"
    )
    
    parser.add_argument(
        "--endpoint",
        help="Get specific endpoint with all related schemas"
    )
    
    parser.add_argument(
        "--analysis",
        help="Get comprehensive endpoint analysis with all schemas"
    )
    
    parser.add_argument(
        "--resolved",
        help="Get endpoint with fully resolved schemas (no $ref)"
    )
    
    parser.add_argument(
        "--schema",
        help="Get specific schema component with dependencies"
    )
    
    parser.add_argument(
        "--list-endpoints",
        action="store_true",
        help="List all available endpoints"
    )
    
    parser.add_argument(
        "--list-schemas",
        action="store_true",
        help="List all schema components"
    )
    
    parser.add_argument(
        "--search",
        help="Search for endpoints containing this term"
    )
    
    parser.add_argument(
        "--summary",
        help="Get a formatted summary of an endpoint (alias for --analysis)"
    )
    
    parser.add_argument(
        "--level",
        type=int,
        choices=[1, 2, 3],
        default=1,
        help="Detail level for listings (1=basic, 2=medium, 3=detailed)"
    )
    
    args = parser.parse_args()
    
    # Initialize explorer
    explorer = APIExplorer(args.schema_file)
    
    # Handle different operations
    if args.prefix:
        result = explorer.get_complete_endpoints_by_prefix(args.prefix)
        explorer.print_formatted_output(result, f"Complete endpoints starting with '{args.prefix}'")
    
    elif args.endpoint:
        result = explorer.get_complete_endpoint(args.endpoint)
        if result:
            explorer.print_formatted_output(result, f"Complete endpoint: {args.endpoint}")
        else:
            print(f"Endpoint '{args.endpoint}' not found.")
    
    elif args.analysis:
        result = explorer.get_endpoint_analysis(args.analysis)
        if result:
            explorer.print_formatted_output(result, f"Endpoint analysis: {args.analysis}")
        else:
            print(f"Endpoint '{args.analysis}' not found.")
    
    elif args.resolved:
        result = explorer.get_endpoint_with_full_schemas(args.resolved)
        if result:
            explorer.print_formatted_output(result, f"Fully resolved endpoint: {args.resolved}")
        else:
            print(f"Endpoint '{args.resolved}' not found.")
    
    elif args.schema:
        result = explorer.get_schema_with_dependencies(args.schema)
        if result:
            explorer.print_formatted_output(result, f"Schema with dependencies: {args.schema}")
        else:
            print(f"Schema component '{args.schema}' not found.")
    
    elif args.summary:
        result = explorer.get_endpoint_analysis(args.summary)
        if result:
            explorer.print_formatted_output(result, f"Endpoint summary: {args.summary}")
        else:
            print(f"Endpoint '{args.summary}' not found.")
    
    elif args.list_endpoints:
        endpoints = explorer.list_all_endpoints(args.level)
        print(f"\n=== All Endpoints (Level {args.level}) ===")
        for endpoint in endpoints:
            print(endpoint)
    
    elif args.list_schemas:
        schemas = explorer.list_schema_components(args.level)
        print(f"\n=== All Schema Components (Level {args.level}) ===")
        for schema in schemas:
            print(schema)
    
    elif args.search:
        results = explorer.search_endpoints(args.search)
        print(f"\n=== Search Results for '{args.search}' ===")
        for result in results:
            print(result)
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()