// lib/core/exceptions/app_exceptions.dart

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  AppException(this.message, {this.code, this.data});

  @override
  String toString() => message;
}

class ApiException extends AppException {
  final int? statusCode;

  ApiException(String message, {this.statusCode, String? code, dynamic data})
      : super(message, code: code, data: data);

  factory ApiException.fromStatusCode(int statusCode, {String? message, String? code, dynamic data}) {
    String errorMessage = message ?? 'An error occurred while communicating with the server.';

    switch (statusCode) {
      case 400:
        return ApiException(message ?? 'Bad request. Please check your input.',
            statusCode: statusCode, code: code, data: data);
      case 401:
        return AuthException('Unauthorized. Please log in again.',
            statusCode: statusCode, code: code, data: data);
      case 403:
        return ApiException(message ?? 'You do not have permission to access this resource.',
            statusCode: statusCode, code: code, data: data);
      case 404:
        return ApiException(message ?? 'The requested resource was not found.',
            statusCode: statusCode, code: code, data: data);
      case 500:
      case 502:
      case 503:
        return ApiException(message ?? 'A server error occurred. Please try again later.',
            statusCode: statusCode, code: code, data: data);
      default:
        return ApiException(errorMessage,
            statusCode: statusCode, code: code, data: data);
    }
  }
}

class AuthException extends ApiException {
  AuthException(String message, {int? statusCode, String? code, dynamic data})
      : super(message, statusCode: statusCode, code: code, data: data);
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  ValidationException(String message, {
    this.fieldErrors = const {},
    String? code,
    dynamic data,
  }) : super(message, code: code, data: data);

  factory ValidationException.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> fieldErrors = {};
    String generalMessage = 'Validation error';

    json.forEach((key, value) {
      if (key == 'non_field_errors' || key == 'detail') {
        if (value is List) {
          generalMessage = value.join('. ');
        } else if (value is String) {
          generalMessage = value;
        }
      } else {
        if (value is List) {
          fieldErrors[key] = List<String>.from(value.map((e) => e.toString()));
        } else if (value is String) {
          fieldErrors[key] = [value];
        }
      }
    });

    return ValidationException(
      generalMessage,
      fieldErrors: fieldErrors,
      data: json,
    );
  }
}

class LocationException extends AppException {
  LocationException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

class CacheException extends AppException {
  CacheException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}