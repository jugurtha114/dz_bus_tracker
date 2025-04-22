/// lib/core/exceptions/app_exceptions.dart

/// Base class for all custom exceptions within the DZ Bus Tracker application.
/// Provides a consistent structure for error handling.
class AppException implements Exception {
  /// A user-friendly message describing the error.
  final String message;

  /// An optional error code, potentially from an API response or internal system.
  final String? code;

  /// Optional additional details or context about the error.
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    final detailsStr = details != null ? '\nDetails: $details' : '';
    return 'AppException: $message$codeStr$detailsStr';
  }
}

// --- Network Related Exceptions ---

/// Exception indicating a network-related error occurred (e.g., connectivity, timeout).
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.details});

  @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'NetworkException: $message$codeStr';
  }
}

/// Exception indicating an error response from the server (e.g., 4xx, 5xx status codes).
class ServerException extends AppException {
  /// The HTTP status code received from the server, if available.
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    this.statusCode,
    super.details, // Often contains the raw response body
  });

  @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    final statusStr = statusCode != null ? ' (Status: $statusCode)' : '';
    final detailsStr = details != null ? '\nDetails: $details' : '';
    return 'ServerException: $message$statusStr$codeStr$detailsStr';
  }
}

// --- Data Related Exceptions ---

/// Exception indicating an error related to local data caching or storage.
class CacheException extends AppException {
  const CacheException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'CacheException: $message$codeStr';
  }
}

/// Exception indicating an error during data parsing or serialization (e.g., JSON, Msgpack).
class DataParsingException extends AppException {
  const DataParsingException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'DataParsingException: $message$codeStr';
  }
}

// --- Authentication & Authorization Exceptions ---

/// Exception indicating an authentication failure (e.g., invalid credentials, expired token).
class AuthenticationException extends AppException {
  const AuthenticationException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'AuthenticationException: $message$codeStr';
  }
}

/// Exception indicating that the user is not authorized to perform an action (e.g., forbidden access).
class AuthorizationException extends AppException {
  const AuthorizationException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'AuthorizationException: $message$codeStr';
  }
}


// --- Feature Specific Exceptions ---

/// Exception related to device permissions (e.g., location, notifications).
class PermissionException extends AppException {
  const PermissionException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'PermissionException: $message$codeStr';
  }
}

/// Exception related to location services (e.g., service disabled, cannot get location).
class LocationServiceException extends AppException {
  const LocationServiceException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'LocationServiceException: $message$codeStr';
  }
}

/// Exception related to processing or syncing offline data.
class OfflineQueueException extends AppException {
  const OfflineQueueException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'OfflineQueueException: $message$codeStr';
  }
}

// --- General Exceptions ---

/// Exception for invalid input provided by the user or system.
class InvalidInputException extends AppException {
  const InvalidInputException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return 'InvalidInputException: $message$codeStr';
  }
}

/// A catch-all exception for unexpected errors that don't fit other categories.
class UnexpectedException extends AppException {
  const UnexpectedException({required super.message, super.code, super.details});

   @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    final detailsStr = details != null ? '\nDetails: $details' : '';
    return 'UnexpectedException: $message$codeStr$detailsStr';
  }
}



/// Exception specifically related to notification handling (setup, scheduling, etc.).
class NotificationException extends AppException { // <-- ADDED EXCEPTION
  const NotificationException({required super.message, super.code, super.details});
  @override String toString() => 'NotificationException: $message${code != null ? " ($code)" : ""}';
}


