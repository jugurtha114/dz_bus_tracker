// lib/core/exceptions/app_exceptions.dart

/// Base exception class for all app-specific exceptions
/// Provides a consistent interface for error handling throughout the app
abstract class AppException implements Exception {
  const AppException(this.message, {this.code, this.details});

  /// Human-readable error message
  final String message;

  /// Error code for programmatic handling
  final String? code;

  /// Additional error details
  final Map<String, dynamic>? details;

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when API requests fail
class ApiException extends AppException {
  const ApiException(
    super.message, {
    super.code,
    super.details,
    this.statusCode,
    this.endpoint,
  });

  /// HTTP status code
  final int? statusCode;

  /// API endpoint that failed
  final String? endpoint;

  /// Factory constructors for common API errors
  factory ApiException.unauthorized([String? message]) => ApiException(
    message ?? 'Authentication required. Please login again.',
    code: 'UNAUTHORIZED',
    statusCode: 401,
  );

  factory ApiException.forbidden([String? message]) => ApiException(
    message ??
        'Access denied. You don\'t have permission to perform this action.',
    code: 'FORBIDDEN',
    statusCode: 403,
  );

  factory ApiException.notFound([String? message]) => ApiException(
    message ?? 'The requested resource was not found.',
    code: 'NOT_FOUND',
    statusCode: 404,
  );

  factory ApiException.serverError([String? message]) => ApiException(
    message ?? 'Server error occurred. Please try again later.',
    code: 'SERVER_ERROR',
    statusCode: 500,
  );

  factory ApiException.badRequest(
    String message, {
    Map<String, dynamic>? details,
  }) => ApiException(
    message,
    code: 'BAD_REQUEST',
    statusCode: 400,
    details: details,
  );

  factory ApiException.validationError(Map<String, dynamic> errors) =>
      ApiException(
        'Validation failed. Please check your input.',
        code: 'VALIDATION_ERROR',
        statusCode: 400,
        details: {'validation_errors': errors},
      );

  /// Factory method to create exception from HTTP status code
  factory ApiException.fromStatusCode(
    int statusCode, {
    String? message,
    String? endpoint,
  }) {
    switch (statusCode) {
      case 400:
        return ApiException.badRequest(message ?? 'Bad request');
      case 401:
        return ApiException.unauthorized(message);
      case 403:
        return ApiException.forbidden(message);
      case 404:
        return ApiException.notFound(message);
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException.serverError(message);
      default:
        return ApiException(
          message ?? 'HTTP error occurred',
          code: 'HTTP_ERROR_$statusCode',
          statusCode: statusCode,
          endpoint: endpoint,
        );
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Exception thrown when network connectivity issues occur
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.details,
    this.isTimeout = false,
    this.isNoConnection = false,
  });

  /// Whether the error was due to timeout
  final bool isTimeout;

  /// Whether there's no internet connection
  final bool isNoConnection;

  /// Factory constructors for common network errors
  factory NetworkException.noConnection() => const NetworkException(
    'No internet connection. Please check your network settings.',
    code: 'NO_CONNECTION',
    isNoConnection: true,
  );

  factory NetworkException.timeout() => const NetworkException(
    'Request timed out. Please try again.',
    code: 'TIMEOUT',
    isTimeout: true,
  );

  factory NetworkException.connectionFailed() => const NetworkException(
    'Failed to connect to server. Please check your internet connection.',
    code: 'CONNECTION_FAILED',
  );

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.details,
    this.isTokenExpired = false,
    this.isInvalidCredentials = false,
  });

  /// Whether the auth token has expired
  final bool isTokenExpired;

  /// Whether the credentials are invalid
  final bool isInvalidCredentials;

  /// Factory constructors for common auth errors
  factory AuthException.tokenExpired() => const AuthException(
    'Your session has expired. Please login again.',
    code: 'TOKEN_EXPIRED',
    isTokenExpired: true,
  );

  factory AuthException.invalidCredentials() => const AuthException(
    'Invalid email or password. Please try again.',
    code: 'INVALID_CREDENTIALS',
    isInvalidCredentials: true,
  );

  factory AuthException.accountNotFound() => const AuthException(
    'Account not found. Please check your email.',
    code: 'ACCOUNT_NOT_FOUND',
  );

  factory AuthException.accountDisabled() => const AuthException(
    'Your account has been disabled. Please contact support.',
    code: 'ACCOUNT_DISABLED',
  );

  factory AuthException.emailNotVerified() => const AuthException(
    'Please verify your email address before logging in.',
    code: 'EMAIL_NOT_VERIFIED',
  );

  factory AuthException.tooManyAttempts() => const AuthException(
    'Too many login attempts. Please try again later.',
    code: 'TOO_MANY_ATTEMPTS',
  );

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.details,
    this.field,
    this.validationErrors = const {},
    this.fieldErrors = const {},
  });

  /// The field that failed validation (if applicable)
  final String? field;

  /// Map of field names to error messages
  final Map<String, String> validationErrors;

  /// Map of field names to list of error messages (for compatibility with error handlers)
  final Map<String, List<String>> fieldErrors;

  /// Factory constructors for common validation errors
  factory ValidationException.required(String field) => ValidationException(
    '$field is required.',
    code: 'REQUIRED_FIELD',
    field: field,
  );

  factory ValidationException.invalidFormat(String field, String format) =>
      ValidationException(
        '$field must be a valid $format.',
        code: 'INVALID_FORMAT',
        field: field,
      );

  factory ValidationException.tooShort(String field, int minLength) =>
      ValidationException(
        '$field must be at least $minLength characters long.',
        code: 'TOO_SHORT',
        field: field,
      );

  factory ValidationException.tooLong(String field, int maxLength) =>
      ValidationException(
        '$field must be no more than $maxLength characters long.',
        code: 'TOO_LONG',
        field: field,
      );

  factory ValidationException.multiple(Map<String, String> errors) =>
      ValidationException(
        'Multiple validation errors occurred.',
        code: 'MULTIPLE_ERRORS',
        validationErrors: errors,
        fieldErrors: errors.map((key, value) => MapEntry(key, [value])),
        details: {'field_errors': errors},
      );

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when location services fail
class LocationException extends AppException {
  const LocationException(
    super.message, {
    super.code,
    super.details,
    this.isPermissionDenied = false,
    this.isServiceDisabled = false,
  });

  /// Whether location permission was denied
  final bool isPermissionDenied;

  /// Whether location service is disabled
  final bool isServiceDisabled;

  /// Factory constructors for common location errors
  factory LocationException.permissionDenied() => const LocationException(
    'Location permission denied. Please enable location access in settings.',
    code: 'PERMISSION_DENIED',
    isPermissionDenied: true,
  );

  factory LocationException.serviceDisabled() => const LocationException(
    'Location service is disabled. Please enable location services.',
    code: 'SERVICE_DISABLED',
    isServiceDisabled: true,
  );

  factory LocationException.notAvailable() => const LocationException(
    'Location is not available at the moment.',
    code: 'NOT_AVAILABLE',
  );

  factory LocationException.timeout() => const LocationException(
    'Failed to get location within timeout period.',
    code: 'TIMEOUT',
  );

  @override
  String toString() => 'LocationException: $message';
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.details, this.key});

  /// The cache key that failed
  final String? key;

  /// Factory constructors for common cache errors
  factory CacheException.notFound(String key) => CacheException(
    'Cache entry not found for key: $key',
    code: 'NOT_FOUND',
    key: key,
  );

  factory CacheException.writeFailed(String key) => CacheException(
    'Failed to write to cache for key: $key',
    code: 'WRITE_FAILED',
    key: key,
  );

  factory CacheException.readFailed(String key) => CacheException(
    'Failed to read from cache for key: $key',
    code: 'READ_FAILED',
    key: key,
  );

  factory CacheException.corruptedData(String key) => CacheException(
    'Corrupted data found in cache for key: $key',
    code: 'CORRUPTED_DATA',
    key: key,
  );

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when business rules are violated
class BusinessException extends AppException {
  const BusinessException(
    super.message, {
    super.code,
    super.details,
    this.rule,
  });

  /// The business rule that was violated
  final String? rule;

  /// Factory constructors for common business rule violations
  factory BusinessException.driverNotApproved() => const BusinessException(
    'Driver must be approved before starting tracking.',
    code: 'DRIVER_NOT_APPROVED',
    rule: 'DRIVER_APPROVAL_REQUIRED',
  );

  factory BusinessException.busNotApproved() => const BusinessException(
    'Bus must be approved before use.',
    code: 'BUS_NOT_APPROVED',
    rule: 'BUS_APPROVAL_REQUIRED',
  );

  factory BusinessException.alreadyTracking() => const BusinessException(
    'Bus is already being tracked.',
    code: 'ALREADY_TRACKING',
    rule: 'SINGLE_TRACKING_SESSION',
  );

  factory BusinessException.notOnDuty() => const BusinessException(
    'Driver must be on duty to perform this action.',
    code: 'NOT_ON_DUTY',
    rule: 'DRIVER_AVAILABILITY_REQUIRED',
  );

  factory BusinessException.insufficientRating() => const BusinessException(
    'Driver rating is too low to continue service.',
    code: 'INSUFFICIENT_RATING',
    rule: 'MINIMUM_RATING_REQUIRED',
  );

  @override
  String toString() => 'BusinessException: $message';
}
