// This file is implemented but content not copied to save space
// Fully implemented: lib/services/user_service.dart
// lib/services/user_service.dart

import '../config/api_config.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get(Endpoints.currentUser);
      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;

      if (body.isEmpty) {
        throw ApiException('No data provided for update');
      }

      final response = await _apiClient.patch(
        Endpoints.currentUser,
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update profile: ${e.toString()}');
    }
  }

  // Update user password
  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.changePassword,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update password: ${e.toString()}');
    }
  }

  // Get user profile details
  Future<Map<String, dynamic>> getProfileDetails() async {
    try {
      final response = await _apiClient.get(Endpoints.currentProfile);
      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get profile details: ${e.toString()}');
    }
  }

  // Update profile details
  Future<Map<String, dynamic>> updateProfileDetails({
    String? avatar,
    String? language,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (avatar != null) body['avatar'] = avatar;
      if (language != null) body['language'] = language;
      if (pushNotificationsEnabled != null) body['push_notifications_enabled'] = pushNotificationsEnabled;
      if (emailNotificationsEnabled != null) body['email_notifications_enabled'] = emailNotificationsEnabled;
      if (smsNotificationsEnabled != null) body['sms_notifications_enabled'] = smsNotificationsEnabled;

      if (body.isEmpty) {
        throw ApiException('No data provided for update');
      }

      final response = await _apiClient.patch(
        Endpoints.updateProfile,
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update profile details: ${e.toString()}');
    }
  }
}