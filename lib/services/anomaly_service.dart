// lib/services/anomaly_service.dart

import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/utils/api_utils.dart';
import 'base_service.dart';

class AnomalyService extends BaseService {
  static const String _baseEndpoint = '/anomalies';

  // Get all anomalies
  Future<List<Map<String, dynamic>>> getAllAnomalies({
    Map<String, String>? filters,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (filters != null) {
        queryParams.addAll(filters);
      }

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get anomaly by ID
  Future<Map<String, dynamic>> getAnomalyById(String anomalyId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/$anomalyId/'),
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Report new anomaly
  Future<Map<String, dynamic>> reportAnomaly({
    required String type,
    required String title,
    required String description,
    required String severity,
    String? lineId,
    Map<String, double>? location,
    List<String>? affectedStops,
    int? estimatedDelay,
    int? affectedPassengers,
  }) async {
    try {
      final body = {
        'type': type,
        'title': title,
        'description': description,
        'severity': severity,
        'line_id': lineId,
        'location': location,
        'affected_stops': affectedStops,
        'estimated_delay': estimatedDelay,
        'affected_passengers': affectedPassengers,
      };

      final response = await apiClient.post(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        body: body,
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update anomaly
  Future<Map<String, dynamic>> updateAnomaly({
    required String anomalyId,
    String? status,
    String? assignedTo,
    String? resolutionNotes,
    int? estimatedDelay,
    int? affectedPassengers,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (status != null) body['status'] = status;
      if (assignedTo != null) body['assigned_to'] = assignedTo;
      if (resolutionNotes != null) body['resolution_notes'] = resolutionNotes;
      if (estimatedDelay != null) body['estimated_delay'] = estimatedDelay;
      if (affectedPassengers != null)
        body['affected_passengers'] = affectedPassengers;

      final response = await apiClient.patch(
        ApiEndpoints.buildUrl('$_baseEndpoint/$anomalyId/'),
        body: body,
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Assign anomaly to team
  Future<void> assignAnomalyToTeam({
    required String anomalyId,
    required String teamName,
    String? notes,
  }) async {
    try {
      final body = {
        'assigned_to': teamName,
        'status': 'in_progress',
        'resolution_notes': notes,
      };

      await apiClient.patch(
        ApiEndpoints.buildUrl('$_baseEndpoint/$anomalyId/assign/'),
        body: body,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Resolve anomaly
  Future<void> resolveAnomaly({
    required String anomalyId,
    required String resolutionNotes,
  }) async {
    try {
      final body = {
        'status': 'resolved',
        'resolution_notes': resolutionNotes,
        'resolved_at': DateTime.now().toIso8601String(),
      };

      await apiClient.patch(
        ApiEndpoints.buildUrl('$_baseEndpoint/$anomalyId/resolve/'),
        body: body,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get anomaly statistics
  Future<Map<String, dynamic>> getAnomalyStatistics({
    String? period, // 'today', 'week', 'month'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (period != null) queryParams['period'] = period;
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null)
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/statistics/'),
        queryParameters: queryParams,
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get anomalies by line
  Future<List<Map<String, dynamic>>> getAnomaliesByLine(String lineId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        queryParameters: {'line_id': lineId},
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get anomalies by status
  Future<List<Map<String, dynamic>>> getAnomaliesByStatus(String status) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        queryParameters: {'status': status},
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get anomalies by severity
  Future<List<Map<String, dynamic>>> getAnomaliesBySeverity(
    String severity,
  ) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        queryParameters: {'severity': severity},
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete anomaly
  Future<void> deleteAnomaly(String anomalyId) async {
    try {
      await apiClient.delete(
        ApiEndpoints.buildUrl('$_baseEndpoint/$anomalyId/'),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get recent anomalies
  Future<List<Map<String, dynamic>>> getRecentAnomalies({
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/recent/'),
        queryParameters: {'limit': limit.toString()},
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    return ApiException(
      'An error occurred while processing anomaly data',
      statusCode: 500,
    );
  }
}
