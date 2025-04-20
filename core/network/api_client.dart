/// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import '../exceptions/app_exceptions.dart'; // Import custom exceptions
import '../constants/api_constants.dart'; // For content types, potentially
import '../utils/logger.dart'; // For logging errors

/// Abstract interface for the API client.
/// Defines the standard HTTP methods used to interact with the backend API.
abstract class ApiClient {
  /// Performs a GET request.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  /// Performs a POST request.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Performs a PUT request.
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Performs a PATCH request.
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Performs a DELETE request.
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Performs a POST request with multipart/form-data (for file uploads).
  Future<Response> postMultipart(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });
}


/// Concrete implementation of the [ApiClient] using the Dio package.
/// Relies on Dio interceptors (configured separately) to handle concerns like
/// authentication, logging, dynamic serialization, and offline handling/retries.
class ApiClientImpl implements ApiClient {
  final Dio _dio;

  ApiClientImpl(this._dio);

  /// Handles GET requests.
  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Interceptors handle pre-request logic (auth, content-type, connectivity check etc.)
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      // Interceptors handle post-response logic (parsing, potential errors)
      return response;
    } on DioException catch (e) {
      // Handle errors *after* interceptors have done their work (e.g., retries)
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Log.e('Unexpected GET error', error: e, stackTrace: stackTrace);
      throw UnexpectedException(message: 'An unexpected error occurred during GET request.', details: e);
    }
  }

  /// Handles POST requests.
  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Interceptors handle pre-request logic
      final response = await _dio.post(
        path,
        data: data, // Interceptor might serialize this (e.g., to Msgpack)
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      // Interceptors handle post-response logic
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      Log.e('Unexpected POST error', error: e, stackTrace: stackTrace);
      throw UnexpectedException(message: 'An unexpected error occurred during POST request.', details: e);
    }
  }

  /// Handles PUT requests.
  @override
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stackTrace) {
       Log.e('Unexpected PUT error', error: e, stackTrace: stackTrace);
      throw UnexpectedException(message: 'An unexpected error occurred during PUT request.', details: e);
    }
  }

  /// Handles PATCH requests.
  @override
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stackTrace) {
       Log.e('Unexpected PATCH error', error: e, stackTrace: stackTrace);
      throw UnexpectedException(message: 'An unexpected error occurred during PATCH request.', details: e);
    }
  }

  /// Handles DELETE requests.
  @override
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stackTrace) {
       Log.e('Unexpected DELETE error', error: e, stackTrace: stackTrace);
      throw UnexpectedException(message: 'An unexpected error occurred during DELETE request.', details: e);
    }
  }

  /// Handles multipart POST requests (for file uploads).
  @override
  Future<Response> postMultipart(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Ensure Content-Type is set correctly for multipart requests
      final multipartOptions = (options ?? Options()).copyWith(
         contentType: ApiConstants.multipartFormDataContentType,
      );

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: multipartOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e, stackTrace) {
       Log.e('Unexpected multipart POST error', error: e, stackTrace: stackTrace);
      throw UnexpectedException(message: 'An unexpected error occurred during multipart POST request.', details: e);
    }
  }


  /// Centralized handler to convert [DioException] into custom [AppException] types.
  /// This is called *after* interceptors have potentially handled retries or offline queueing.
  AppException _handleDioError(DioException error) {
    Log.w('DioException caught by ApiClient', error: error, stackTrace: error.stackTrace);
    Log.w('DioException type: ${error.type}');
    Log.w('DioException path: ${error.requestOptions.path}');
    Log.w('DioException response status: ${error.response?.statusCode}');
    Log.w('DioException response data: ${error.response?.data}');


    // Check for specific DioException types first
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timeout. Please try again.'); // TODO: Localize
      case DioExceptionType.connectionError:
       // This often indicates DNS issues or no internet connection *before* request is sent
       // Interceptor should ideally prevent request if offline, but handle here just in case.
        return const NetworkException(message: 'Connection error. Please check your internet.'); // TODO: Localize
      case DioExceptionType.cancel:
        return const AppException(message: 'Request was cancelled.'); // TODO: Localize
      case DioExceptionType.badCertificate:
         return const NetworkException(message: 'Bad certificate error.'); // TODO: Localize
      case DioExceptionType.badResponse:
       // Handle errors based on HTTP status codes from the response
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String serverMessage = 'Server error occurred.'; // Default server error message

        // Try to extract a more specific message from the response body
        if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('detail')) {
              serverMessage = responseData['detail'].toString();
            } else if (responseData.isNotEmpty) {
              // Combine multiple field errors if present
              serverMessage = responseData.entries
                  .map((e) => '${e.key}: ${e.value is List ? e.value.join(', ') : e.value}')
                  .join('; ');
            }
        } else if (responseData is String && responseData.isNotEmpty) {
            serverMessage = responseData;
        }

        if (statusCode == 401) {
          return AuthenticationException(message: serverMessage, code: '401', details: responseData);
        }
        if (statusCode == 403) {
          return AuthorizationException(message: serverMessage, code: '403', details: responseData);
        }
        // Handle other specific status codes (400 Bad Request, 404 Not Found, 5xx Server Errors)
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
             return ServerException(message: serverMessage, code: statusCode.toString(), statusCode: statusCode, details: responseData);
        }
        if (statusCode != null && statusCode >= 500) {
             return ServerException(message: 'Server error occurred. Please try again later.', code: statusCode.toString(), statusCode: statusCode, details: responseData); // TODO: Localize generic 5xx
        }
        // Fallback for unknown bad response errors
        return ServerException(message: serverMessage, code: statusCode?.toString(), statusCode: statusCode, details: responseData);

      case DioExceptionType.unknown:
      default:
       // Handle cases where the error type is unknown or doesn't fit other categories
       // Could be a parsing error within Dio or other network issues.
        if (error.error is FormatException || error.message?.contains('Deserialization error') == true) {
           return DataParsingException(message: 'Error parsing server response.', details: error.error); // TODO: Localize
        }
        return UnexpectedException(message: 'An unknown network error occurred.', details: error.error); // TODO: Localize
    }
  }
}
