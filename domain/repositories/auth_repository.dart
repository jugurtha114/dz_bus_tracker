/// lib/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart'; // For Either type

// TODO: Create this Failure base class in lib/core/error/failures.dart
import '../../core/enums/language.dart';
import '../../core/error/failures.dart';
import '../../core/enums/user_type.dart';
import '../entities/user_entity.dart';

/// Abstract interface defining the contract for authentication-related data operations.
///
/// This interface is implemented by the Data layer (AuthRepositoryImpl) and used
/// by the Domain layer's Use Cases (e.g., LoginUseCase, RegisterUseCase).
abstract class AuthRepository {
  /// Attempts to log in a user with the given credentials.
  ///
  /// Returns [UserEntity] on success, or a [Failure] on error.
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Attempts to register a new user (and potentially driver details).
  ///
  /// Requires base user information. If [userType] is [UserType.driver],
  /// driver-specific fields like [idNumber], [idPhoto], etc., must also be provided.
  /// The [idPhoto] and [licensePhoto] should be platform-specific file representations
  /// (e.g., File from dart:io or Uint8List from web/memory) passed down from the
  /// presentation layer through the use case.
  ///
  /// Returns the created [UserEntity] on success, or a [Failure] on error.
  Future<Either<Failure, UserEntity>> register({
    // Base user info
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required UserType userType,
    Language? language, // Optional, backend might default

    // Driver specific fields (required if userType == UserType.driver)
    String? idNumber,
    dynamic idPhoto, // Expect File or Uint8List
    String? licenseNumber,
    dynamic licensePhoto, // Expect File or Uint8List
    int? experienceYears,
    DateTime? dateOfBirth,
    String? address,
    String? emergencyContact,
    String? driverNotes,
  });

  /// Logs out the currently authenticated user.
  ///
  /// Clears local authentication tokens. May also call a backend logout endpoint.
  /// Returns void on success, or a [Failure] on error (though errors during logout
  /// might often be ignored if local cleanup succeeds).
  Future<Either<Failure, void>> logout();

  /// Checks the current authentication status.
  ///
  /// Attempts to retrieve the current user's profile if a valid token exists.
  /// Returns [UserEntity] if authenticated, `null` if not authenticated,
  /// or a [Failure] if an error occurs during the check.
  Future<Either<Failure, UserEntity?>> checkAuthStatus();

  /// Initiates the password reset process for the given [email].
  ///
  /// Returns void on success, or a [Failure] on error.
  Future<Either<Failure, void>> requestPasswordReset(String email);

  /// Completes the password reset process using the provided [token] and [newPassword].
  ///
  /// Returns void on success, or a [Failure] on error (e.g., invalid token).
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);
}
