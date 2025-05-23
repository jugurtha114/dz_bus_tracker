// lib/core/network/api_client.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/api_utils.dart';
import 'interceptors.dart';

class ApiClient {
  final http.Client _client;
  final List<Interceptor> _interceptors;

  ApiClient({
    http.Client? client,
    List<Interceptor>? interceptors,
  })
      : _client = client ?? http.Client(),
        _interceptors = interceptors ?? [AuthInterceptor(), LoggingInterceptor()];

  // Add an interceptor
  void addInterceptor(Interceptor interceptor) {
    _interceptors.add(interceptor);
  }

  // HTTP GET request
  Future<dynamic> get(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
        bool forceRefresh = false,
      }) async {
    try {
      final Uri uri = _buildUri(url, queryParameters);
      final requestHeaders = await _prepareHeaders(headers);

      // Apply request interceptors
      final interceptedRequest = await _applyRequestInterceptors(
        uri,
        requestHeaders,
        null,
      );

      // Send request
      final response = await _client
          .get(interceptedRequest.uri, headers: interceptedRequest.headers)
          .timeout(Duration(milliseconds: ApiConstants.connectTimeout));

      // Apply response interceptors
      final interceptedResponse = await _applyResponseInterceptors(response);

      // Process response
      return _processResponse(interceptedResponse);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on TimeoutException {
      throw NetworkException('Connection timeout');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // HTTP POST request
  Future<dynamic> post(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
        dynamic body,
      }) async {
    try {
      final Uri uri = _buildUri(url, queryParameters);
      final requestHeaders = await _prepareHeaders(headers);
      final encodedBody = _encodeBody(body);

      // Apply request interceptors
      final interceptedRequest = await _applyRequestInterceptors(
        uri,
        requestHeaders,
        encodedBody,
      );

      // Send request
      final response = await _client
          .post(
        interceptedRequest.uri,
        headers: interceptedRequest.headers,
        body: interceptedRequest.body,
      )
          .timeout(Duration(milliseconds: ApiConstants.connectTimeout));

      // Apply response interceptors
      final interceptedResponse = await _applyResponseInterceptors(response);

      // Process response
      return _processResponse(interceptedResponse);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on TimeoutException {
      throw NetworkException('Connection timeout');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // HTTP PUT request
  Future<dynamic> put(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
        dynamic body,
      }) async {
    try {
      final Uri uri = _buildUri(url, queryParameters);
      final requestHeaders = await _prepareHeaders(headers);
      final encodedBody = _encodeBody(body);

      // Apply request interceptors
      final interceptedRequest = await _applyRequestInterceptors(
        uri,
        requestHeaders,
        encodedBody,
      );

      // Send request
      final response = await _client
          .put(
        interceptedRequest.uri,
        headers: interceptedRequest.headers,
        body: interceptedRequest.body,
      )
          .timeout(Duration(milliseconds: ApiConstants.connectTimeout));

      // Apply response interceptors
      final interceptedResponse = await _applyResponseInterceptors(response);

      // Process response
      return _processResponse(interceptedResponse);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on TimeoutException {
      throw NetworkException('Connection timeout');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // HTTP DELETE request
  Future<dynamic> delete(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
        dynamic body,
      }) async {
    try {
      final Uri uri = _buildUri(url, queryParameters);
      final requestHeaders = await _prepareHeaders(headers);
      final encodedBody = _encodeBody(body);

      // Apply request interceptors
      final interceptedRequest = await _applyRequestInterceptors(
        uri,
        requestHeaders,
        encodedBody,
      );

      // Send request
      final response = await _client
          .delete(
        interceptedRequest.uri,
        headers: interceptedRequest.headers,
        body: interceptedRequest.body,
      )
          .timeout(Duration(milliseconds: ApiConstants.connectTimeout));

      // Apply response interceptors
      final interceptedResponse = await _applyResponseInterceptors(response);

      // Process response
      return _processResponse(interceptedResponse);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on TimeoutException {
      throw NetworkException('Connection timeout');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // HTTP PATCH request
  Future<dynamic> patch(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
        dynamic body,
      }) async {
    try {
      final Uri uri = _buildUri(url, queryParameters);
      final requestHeaders = await _prepareHeaders(headers);
      final encodedBody = _encodeBody(body);

      // Apply request interceptors
      final interceptedRequest = await _applyRequestInterceptors(
        uri,
        requestHeaders,
        encodedBody,
      );

      // Send request
      final response = await _client
          .patch(
        interceptedRequest.uri,
        headers: interceptedRequest.headers,
        body: interceptedRequest.body,
      )
          .timeout(Duration(milliseconds: ApiConstants.connectTimeout));

      // Apply response interceptors
      final interceptedResponse = await _applyResponseInterceptors(response);

      // Process response
      return _processResponse(interceptedResponse);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on TimeoutException {
      throw NetworkException('Connection timeout');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Multipart request for file uploads
// lib/core/network/api_client.dart - just the multipartRequest method

  Future<dynamic> multipartRequest(
      String url, {
        required String method,
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? fields,
        Map<String, dynamic>? files,
      }) async {
    try {
      final Uri uri = _buildUri(url, queryParameters);
      final requestHeaders = await _prepareHeaders(headers);

      // Remove content-type header as it will be set by the multipart request
      requestHeaders.remove(ApiConstants.contentTypeKey);

      // Create multipart request
      final request = http.MultipartRequest(method, uri);

      // Add headers
      request.headers.addAll(requestHeaders);

      // Add text fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final fileKey = entry.key;
          final fileValue = entry.value;

          if (fileValue != null) {
            // Handle different file types based on runtime type
            try {
              if (kIsWeb) {
                // For web
                if (fileValue is Uint8List) {
                  final fileName = '$fileKey.jpg';
                  request.files.add(
                    http.MultipartFile.fromBytes(
                      fileKey,
                      fileValue,
                      filename: fileName,
                      contentType: MediaType('image', 'jpeg'),
                    ),
                  );
                } else if (fileValue is XFile) {
                  final bytes = await fileValue.readAsBytes();
                  final fileName = fileValue.name;
                  request.files.add(
                    http.MultipartFile.fromBytes(
                      fileKey,
                      bytes,
                      filename: fileName,
                      contentType: MediaType('image', 'jpeg'),
                    ),
                  );
                }
              } else {
                // For mobile
                if (fileValue is File) {
                  final fileName = fileValue.path.split('/').last;
                  request.files.add(
                    await http.MultipartFile.fromPath(
                      fileKey,
                      fileValue.path,
                      filename: fileName,
                      contentType: MediaType('image', 'jpeg'),
                    ),
                  );
                } else if (fileValue is XFile) {
                  final fileName = fileValue.path.split('/').last;
                  request.files.add(
                    await http.MultipartFile.fromPath(
                      fileKey,
                      fileValue.path,
                      filename: fileName,
                      contentType: MediaType('image', 'jpeg'),
                    ),
                  );
                }
              }
            } catch (e) {
              debugPrint('Error adding file to multipart request: $e');
              // Continue with other files if one fails
            }
          }
        }
      }

      // Log the request for debugging
      debugPrint('Multipart request to: ${request.url}');
      debugPrint('Fields: ${request.fields}');
      debugPrint('Files: ${request.files.length}');

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
          Duration(milliseconds: ApiConstants.connectTimeout)
      );

      // Convert to regular response
      final response = await http.Response.fromStream(streamedResponse);

      // Apply response interceptors
      final interceptedResponse = await _applyResponseInterceptors(response);

      // Process response
      return _processResponse(interceptedResponse);
    } catch (e) {
      debugPrint('Multipart request error: $e');
      if (e is SocketException) {
        throw NetworkException('No internet connection');
      } else if (e is http.ClientException) {
        throw NetworkException('Network error: ${e.message}');
      } else if (e is TimeoutException) {
        throw NetworkException('Connection timeout');
      } else if (e is AppException) {
        rethrow;
      } else {
        throw NetworkException('An unexpected error occurred: ${e.toString()}');
      }
    }
  }


  // Build URI with query parameters
  Uri _buildUri(String url, Map<String, dynamic>? queryParameters) {
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final formattedParams = ApiUtils.formatQueryParameters(queryParameters);
      return Uri.parse(url).replace(queryParameters: formattedParams);
    }
    return Uri.parse(url);
  }

  // Prepare default headers
  Future<Map<String, String>> _prepareHeaders(Map<String, String>? headers) async {
    final defaultHeaders = {
      ApiConstants.contentTypeKey: ApiConstants.contentTypeJson,
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return defaultHeaders;
  }

  // Encode request body
  dynamic _encodeBody(dynamic body) {
    if (body == null) return null;

    if (body is String) return body;
    if (body is Map) return json.encode(body);
    if (body is List) return json.encode(body);

    try {
      return json.encode(body);
    } catch (e) {
      throw ApiException('Failed to encode request body: ${e.toString()}');
    }
  }

  // Apply request interceptors
  Future<InterceptedRequest> _applyRequestInterceptors(
      Uri uri,
      Map<String, String> headers,
      dynamic body,
      ) async {
    var interceptedRequest = InterceptedRequest(uri, headers, body);

    for (final interceptor in _interceptors) {
      interceptedRequest = await interceptor.onRequest(interceptedRequest);
    }

    return interceptedRequest;
  }

  // Apply response interceptors
  Future<http.Response> _applyResponseInterceptors(http.Response response) async {
    var interceptedResponse = response;

    for (final interceptor in _interceptors) {
      interceptedResponse = await interceptor.onResponse(interceptedResponse);
    }

    return interceptedResponse;
  }

  // Process response
  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    debugPrint('Response status: $statusCode');
    debugPrint('Response body: $responseBody');

    if (statusCode >= 200 && statusCode < 300) {
      // Success response
      if (responseBody.isEmpty) {
        return null;
      }

      try {
        return json.decode(responseBody);
      } catch (e) {
        return responseBody;
      }
    } else {
      // Error response
      String errorMessage = 'Request failed with status: $statusCode';

      try {
        final errorJson = json.decode(responseBody);

        if (errorJson is Map<String, dynamic>) {
          throw ApiUtils.handleApiError(errorJson, defaultMessage: errorMessage);
        }
      } catch (e) {
        if (e is AppException) {
          throw e;
        }
      }

      throw ApiException.fromStatusCode(statusCode, message: errorMessage);
    }
  }
}