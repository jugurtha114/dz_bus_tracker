/// lib/data/data_sources/remote/user_remote_data_source.dart

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../models/notification_preferences_model.dart';
import '../../models/user_model.dart';

/// Abstract interface for remote data operations related to user management
/// (profile, settings, verification), excluding core authentication.
abstract class UserRemoteDataSource {
  /// Fetches the profile of the currently authenticated user from the API.
  Future<UserModel> getUserProfile(); // This already existed, no change needed

  /// Updates the profile of the currently authenticated user using a PATCH request.
  Future<UserModel> updateUserProfile(Map<String, dynamic> updateData);

  /// Calls the API endpoint to change the current user's password.
  Future<void> changePassword({ required String oldPassword, required String newPassword, required String confirmNewPassword, });

  /// Sends the user's FCM token to the backend API.
  Future<void> updateFcmToken(String token);

  /// Updates the user's notification preferences via the API.
  Future<NotificationPreferencesModel> updateNotificationPreferences( Map<String, bool> preferences);

  /// Calls the API endpoint to trigger sending a phone verification code.
  Future<void> sendPhoneVerification();

  /// Calls the API endpoint to submit a phone verification code.
  Future<void> verifyPhone(String code);

  /// Calls the API endpoint to request resending the email verification instructions.
  Future<void> resendVerificationEmail();
}

/// Implementation of [UserRemoteDataSource] using the core [ApiClient].
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;
  const UserRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<UserModel> getUserProfile() async { // Implementation already existed
    Log.d('UserRemoteDataSource: Calling get user profile API.');
    final response = await _apiClient.get(ApiConstants.userProfile);
    return UserModel.fromJson(response.data);
  }

  @override Future<UserModel> updateUserProfile(Map<String, dynamic> updateData) async { /* ... same implementation ... */ final response = await _apiClient.patch( ApiConstants.userProfile, data: updateData, ); return UserModel.fromJson(response.data); }
  @override Future<void> changePassword({required String oldPassword, required String newPassword, required String confirmNewPassword, }) async { /* ... same implementation ... */ await _apiClient.post( ApiConstants.changePassword, data: { 'old_password': oldPassword, 'new_password': newPassword, 'confirm_new_password': confirmNewPassword, }, ); }
  @override Future<void> updateFcmToken(String token) async { /* ... same implementation ... */ await _apiClient.post( ApiConstants.userFcmToken, data: {'fcm_token': token}, ); }
  @override Future<NotificationPreferencesModel> updateNotificationPreferences( Map<String, bool> preferences) async { /* ... same implementation ... */ final response = await _apiClient.patch( ApiConstants.userNotificationPreferences, data: preferences, ); return NotificationPreferencesModel.fromJson(response.data); }
  @override Future<void> sendPhoneVerification() async { /* ... same implementation ... */ await _apiClient.post(ApiConstants.sendPhoneVerification); }
  @override Future<void> verifyPhone(String code) async { /* ... same implementation ... */ await _apiClient.post( ApiConstants.verifyPhone, data: {'code': code}, ); }
  @override Future<void> resendVerificationEmail() async { /* ... same implementation ... */ await _apiClient.post(ApiConstants.resendVerificationEmail); }
}


// /// lib/data/data_sources/remote/user_remote_data_source.dart
//
// import '../../../core/constants/api_constants.dart';
// import '../../../core/network/api_client.dart';
// import '../../../core/utils/logger.dart';
// import '../../models/notification_preferences_model.dart';
// import '../../models/user_model.dart';
//
// /// Abstract interface for remote data operations related to user management
// /// (profile, settings, verification), excluding core authentication.
// abstract class UserRemoteDataSource {
//   /// Fetches the profile of the currently authenticated user from the API. <-- ADDED
//   /// Returns the user's [UserModel] on success.
//   Future<UserModel> getUserProfile(); // <-- ADDED Method Signature
//
//   /// Updates the profile of the currently authenticated user using a PATCH request.
//   /// [updateData] should be a map containing only the fields to be updated
//   /// (e.g., {'first_name': 'New Name', 'language': 'en'}).
//   /// Returns the updated [UserModel] on success.
//   Future<UserModel> updateUserProfile(Map<String, dynamic> updateData);
//
//   /// Calls the API endpoint to change the current user's password.
//   Future<void> changePassword({
//     required String oldPassword,
//     required String newPassword,
//     required String confirmNewPassword,
//   });
//
//   /// Sends the user's FCM token to the backend API.
//   Future<void> updateFcmToken(String token);
//
//   /// Updates the user's notification preferences via the API.
//   /// [preferences] map contains keys like 'favorite_line_updates', 'service_disruptions'.
//   /// Returns the updated [NotificationPreferencesModel] on success.
//   Future<NotificationPreferencesModel> updateNotificationPreferences(
//       Map<String, bool> preferences);
//
//   /// Calls the API endpoint to trigger sending a phone verification code.
//   Future<void> sendPhoneVerification();
//
//   /// Calls the API endpoint to submit a phone verification code.
//   Future<void> verifyPhone(String code);
//
//   /// Calls the API endpoint to request resending the email verification instructions.
//   Future<void> resendVerificationEmail();
// }
//
// /// Implementation of [UserRemoteDataSource] using the core [ApiClient].
// /// Makes specific API calls for user management tasks.
// class UserRemoteDataSourceImpl implements UserRemoteDataSource {
//   final ApiClient _apiClient;
//
//   /// Creates an instance of [UserRemoteDataSourceImpl].
//   /// Requires an instance of [ApiClient] to make HTTP requests.
//   const UserRemoteDataSourceImpl({required ApiClient apiClient})
//       : _apiClient = apiClient;
//
//   // <-- ADDED Method Implementation -->
//   @override
//   Future<UserModel> getUserProfile() async {
//     Log.d('UserRemoteDataSource: Calling get user profile API.');
//     final response = await _apiClient.get(ApiConstants.userProfile);
//     return UserModel.fromJson(response.data);
//   }
//   // <-- End Added Method -->
//
//   @override
//   Future<UserModel> updateUserProfile(Map<String, dynamic> updateData) async {
//     Log.d('UserRemoteDataSource: Calling update user profile API (PATCH).');
//     final response = await _apiClient.patch(
//       ApiConstants.userProfile,
//       data: updateData,
//     );
//     return UserModel.fromJson(response.data);
//   }
//
//   @override
//   Future<void> changePassword({
//     required String oldPassword,
//     required String newPassword,
//     required String confirmNewPassword,
//   }) async {
//     Log.d('UserRemoteDataSource: Calling change password API.');
//     await _apiClient.post(
//       ApiConstants.changePassword,
//       data: {
//         'old_password': oldPassword,
//         'new_password': newPassword,
//         'confirm_new_password': confirmNewPassword,
//       },
//     );
//   }
//
//   @override
//   Future<void> updateFcmToken(String token) async {
//     Log.d('UserRemoteDataSource: Calling update FCM token API.');
//     await _apiClient.post(
//       ApiConstants.userFcmToken,
//       data: {'fcm_token': token},
//     );
//   }
//
//   @override
//   Future<NotificationPreferencesModel> updateNotificationPreferences(
//       Map<String, bool> preferences) async {
//     Log.d('UserRemoteDataSource: Calling update notification preferences API (PATCH).');
//     final response = await _apiClient.patch(
//       ApiConstants.userNotificationPreferences,
//       data: preferences,
//     );
//     return NotificationPreferencesModel.fromJson(response.data);
//   }
//
//   @override
//   Future<void> sendPhoneVerification() async {
//     Log.d('UserRemoteDataSource: Calling send phone verification API.');
//     await _apiClient.post(ApiConstants.sendPhoneVerification);
//   }
//
//   @override
//   Future<void> verifyPhone(String code) async {
//     Log.d('UserRemoteDataSource: Calling verify phone API.');
//     await _apiClient.post(
//       ApiConstants.verifyPhone,
//       data: {'code': code},
//     );
//   }
//
//   @override
//   Future<void> resendVerificationEmail() async {
//     Log.d('UserRemoteDataSource: Calling resend verification email API.');
//     await _apiClient.post(ApiConstants.resendVerificationEmail);
//   }
// }