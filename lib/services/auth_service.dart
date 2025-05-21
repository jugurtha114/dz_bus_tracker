// lib/services/auth_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../core/utils/storage_utils.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response is Map<String, dynamic> &&
          response.containsKey(ApiConstants.accessKey) &&
          response.containsKey(ApiConstants.refreshKey)) {

        // Save auth tokens
        await _saveAuthData(
          token: response[ApiConstants.accessKey],
          refreshToken: response[ApiConstants.refreshKey],
        );

        return response;
      }

      throw ApiException('Invalid response from server');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Login failed: ${e.toString()}');
    }
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String userType = AppConstants.userTypePassenger,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.users,
        body: {
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'user_type': userType,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Registration failed: ${e.toString()}');
    }
  }

  // Register driver
  Future<Map<String, dynamic>> registerDriver({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCardNumber,
    required dynamic idCardPhoto,
    required String driverLicenseNumber,
    required dynamic driverLicensePhoto,
    required int yearsOfExperience,
  }) async {
    try {
      // Create multipart form data
      final Map<String, String> fields = {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'id_card_number': idCardNumber,
        'driver_license_number': driverLicenseNumber,
        'years_of_experience': yearsOfExperience.toString(),
      };

      // Prepare files map - don't cast the file objects to String
      final Map<String, dynamic> files = {
        'id_card_photo': idCardPhoto,
        'driver_license_photo': driverLicensePhoto,
      };

      final response = await _apiClient.multipartRequest(
        Endpoints.driverRegistration,
        method: 'POST',
        fields: fields,
        files: files,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Driver registration failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.resetPasswordRequest,
        body: {
          'email': email,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Password reset failed: ${e.toString()}');
    }
  }

  // Confirm password reset
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.resetPasswordConfirm,
        body: {
          'uid': uid,
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Password reset confirmation failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _clearAuthData();
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        Endpoints.refreshToken,
        body: {
          'refresh': refreshToken,
        },
      );

      if (response is Map<String, dynamic> &&
          response.containsKey(ApiConstants.accessKey)) {

        // Save new access token
        await StorageUtils.saveToStorage(AppConstants.tokenKey, response[ApiConstants.accessKey]);

        return response;
      }

      throw ApiException('Invalid response from server');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Token refresh failed: ${e.toString()}');
    }
  }

  // Verify token
  Future<bool> verifyToken(String token) async {
    try {
      await _apiClient.post(
        Endpoints.verifyToken,
        body: {
          'token': token,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await StorageUtils.getFromStorage<String>(AppConstants.tokenKey);

    if (token == null || token.isEmpty) {
      return false;
    }

    // Verify token validity
    return await verifyToken(token);
  }

  // Get current authentication token
  Future<String?> getAuthToken() async {
    return await StorageUtils.getFromStorage<String>(AppConstants.tokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await StorageUtils.getFromStorage<String>(AppConstants.refreshTokenKey);
  }

  // Save authentication data
  Future<void> _saveAuthData({
    required String token,
    required String refreshToken,
  }) async {
    await StorageUtils.saveToStorage(AppConstants.tokenKey, token);
    await StorageUtils.saveToStorage(AppConstants.refreshTokenKey, refreshToken);
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    await StorageUtils.removeFromStorage(AppConstants.tokenKey);
    await StorageUtils.removeFromStorage(AppConstants.refreshTokenKey);
    await StorageUtils.removeFromStorage(AppConstants.userKey);
  }
}