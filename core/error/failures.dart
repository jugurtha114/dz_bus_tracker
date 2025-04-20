/// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

/// Base class for all Failure types in the application.
/// Represents a failure state, typically returned in the Left side of an Either.
/// Base class for all Failure types in the application.
/// Represents a failure state, typically returned in the Left side of an Either.
abstract class Failure extends Equatable {
  /// An optional message describing the failure, intended for logging or debugging.
  final String? message;
  /// An optional code associated with the failure (e.g., HTTP status code, internal error code).
  final String? code;

  const Failure({this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() {
    final codeStr = code != null ? ' (Code: $code)' : '';
    return '${runtimeType}: ${message ?? 'An unspecified failure occurred.'}$codeStr';
  }
}

// --- Concrete Failure Types ---

/// Represents a failure originating from the backend server (e.g., 5xx errors, unexpected 4xx).
class ServerFailure extends Failure {
  const ServerFailure({super.message, super.code});
}

/// Represents a failure related to network connectivity (e.g., no connection, timeout).
class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.code});
}

/// Represents a failure related to local data caching (e.g., read/write error).
class CacheFailure extends Failure {
  const CacheFailure({super.message, super.code});
}

/// Represents a failure during authentication (e.g., invalid credentials, token expired).
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message, super.code});
}

/// Represents a failure due to lack of authorization (e.g., insufficient permissions, 403 Forbidden).
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({super.message, super.code});
}

/// Represents a failure due to missing or denied device permissions (e.g., location, notifications).
class PermissionFailure extends Failure {
  const PermissionFailure({super.message, super.code});
}

/// Represents a failure due to invalid input provided to a use case or repository.
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({super.message, super.code});
}

/// Represents a failure during data parsing or serialization (e.g., invalid JSON/Msgpack).
class DataParsingFailure extends Failure {
   const DataParsingFailure({super.message, super.code});
}

/// Represents an unexpected failure that doesn't fit into other categories.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message, super.code});
}

/// Represents a failure specifically during notification operations (scheduling, etc.).
class NotificationFailure extends Failure { // <-- ADDED FAILURE TYPE
  const NotificationFailure({super.message, super.code});
}

// --- Helper function to map Exceptions to Failures (optional, often used in RepositoryImpl) ---
// Failure mapExceptionToFailure(Exception exception) {
//   switch (exception.runtimeType) {
//     case ServerException:
//       final serverException = exception as ServerException;
//       return ServerFailure(message: serverException.message, code: serverException.statusCode?.toString());
//     case NetworkException:
//       return NetworkFailure(message: (exception as NetworkException).message);
//     case CacheException:
//       return CacheFailure(message: (exception as CacheException).message);
//     case AuthenticationException:
//       return AuthenticationFailure(message: (exception as AuthenticationException).message);
//      case AuthorizationException:
//        return AuthorizationFailure(message: (exception as AuthorizationException).message);
//      case PermissionException:
//        return PermissionFailure(message: (exception as PermissionException).message);
//     case InvalidInputException:
//       return InvalidInputFailure(message: (exception as InvalidInputException).message);
//      case DataParsingException:
//        return DataParsingFailure(message: (exception as DataParsingException).message);
//     default:
//       return UnexpectedFailure(message: exception.toString());
//   }
// }
