/// lib/domain/repositories/user_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/enums/language.dart';
import '../../core/error/failures.dart'; // Import the Failure types
import '../entities/user_entity.dart';

/// Abstract interface defining the contract for user-related data operations,
/// excluding authentication which is handled by [AuthRepository].
///
/// This contract dictates the methods that the data layer must implement
/// to manage user profile information, settings, and verification processes.
/// Implementations will interact with remote data sources (API) and potentially
/// local caches. All methods return an [Either] type, representing success (Right)
/// or a [Failure] (Left).
abstract class UserRepository {
  /// Fetches the profile details of the currently authenticated user from the
  /// backend API (e.g., endpoint `/api/v1/users/profile/`).
  ///
  /// Returns a [UserEntity] containing the user's information on success.
  /// Returns a [Failure] (e.g., [NetworkFailure], [AuthenticationFailure], [ServerFailure])
  /// if the request fails or the user is not properly authenticated.
  Future<Either<Failure, UserEntity>> getUserProfile();

  /// Updates specific profile fields for the currently authenticated user via
  /// the backend API (e.g., PATCH to `/api/v1/users/profile/`).
  ///
  /// Only non-null parameters provided will be included in the update request.
  ///
  /// - [firstName]: The user's updated first name.
  /// - [lastName]: The user's updated last name.
  /// - [phoneNumber]: The user's updated phone number.
  /// - [language]: The user's updated language preference.
  ///
  /// Returns the updated [UserEntity] reflecting the changes on success.
  /// Returns a [Failure] (e.g., [NetworkFailure], [ServerFailure], [InvalidInputFailure])
  /// if the update fails.
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    Language? language,
    // Note: Updating email or password typically requires separate, dedicated flows.
  });

  /// Changes the password for the currently authenticated user via the backend API
  /// (e.g., endpoint `/api/v1/users/change_password/`).
  ///
  /// Requires the [oldPassword] for verification against the current password,
  /// the desired [newPassword], and confirmation [confirmNewPassword].
  ///
  /// Returns `void` represented as `Right(null)` on successful password change.
  /// Returns a [Failure] (e.g., [AuthenticationFailure] for incorrect old password,
  /// [InvalidInputFailure] if new passwords don't match or meet criteria,
  /// [NetworkFailure], [ServerFailure]) if the change fails.
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  /// Sends the user's current Firebase Cloud Messaging (FCM) device token to the
  /// backend API (e.g., endpoint `/api/v1/users/fcm_token/`) to enable push notifications.
  ///
  /// - [token]: The FCM registration token obtained from the NotificationService.
  ///
  /// Returns `void` represented as `Right(null)` on successful update.
  /// Returns a [Failure] (e.g., [NetworkFailure], [ServerFailure]) if the update fails.
  Future<Either<Failure, void>> updateFcmToken(String token);

  /// Updates the user's notification preferences on the backend API
  /// (e.g., endpoint `/api/v1/users/notification_preferences/`).
  ///
  /// - [preferences]: A map detailing the desired state for various notification types
  ///   (e.g., `{'line_eta_alerts': true, 'general_announcements': false}`). The exact
  ///   keys should match the backend's expected structure.
  ///
  /// Returns `void` represented as `Right(null)` on successful update.
  /// Returns a [Failure] (e.g., [NetworkFailure], [ServerFailure]) if the update fails.
  Future<Either<Failure, void>> updateNotificationPreferences({
    required Map<String, bool> preferences, // Or use a dedicated NotificationPreferencesEntity
  });

  /// Triggers the backend API to send a verification code to the user's
  /// registered phone number (e.g., via endpoint `/api/v1/users/send_phone_verification/`).
  ///
  /// Returns `void` represented as `Right(null)` on successful request.
  /// Returns a [Failure] (e.g., [NetworkFailure], [ServerFailure]) if the request fails.
  Future<Either<Failure, void>> sendPhoneVerification();

  /// Submits the verification [code] (received via SMS) to the backend API
  /// to verify the user's phone number (e.g., endpoint `/api/v1/users/verify_phone/`).
  ///
  /// Returns `void` represented as `Right(null)` if the code is correct and verification succeeds.
  /// Returns a [Failure] (e.g., [InvalidInputFailure] for incorrect code,
  /// [NetworkFailure], [ServerFailure]) if verification fails.
  Future<Either<Failure, void>> verifyPhone(String code);

  /// Triggers the backend API to resend the email verification instructions/link
  /// to the user's registered email address (e.g., endpoint `/api/v1/users/resend_verification_email/`).
  ///
  /// Returns `void` represented as `Right(null)` on successful request.
  /// Returns a [Failure] (e.g., [NetworkFailure], [ServerFailure]) if the request fails.
  Future<Either<Failure, void>> resendVerificationEmail();

}
