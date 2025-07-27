// lib/services/auth_service.dart

import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../core/utils/storage_utils.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Login user with improved error handling and type safety
  Future<AuthResponse<AuthTokenResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.obtainToken),
        body: request.toJson(),
      );

      if (response is Map<String, dynamic> &&
          response.containsKey(ApiConstants.accessKey) &&
          response.containsKey(ApiConstants.refreshKey)) {
        final authTokens = AuthTokenResponse.fromJson(response);

        // Save auth tokens
        await _saveAuthData(
          token: authTokens.accessToken,
          refreshToken: authTokens.refreshToken,
        );

        return AuthResponse.success(authTokens, message: 'Login successful');
      }

      return AuthResponse.failure('Invalid response from server');
    } catch (e) {
      if (e is ApiException) {
        return AuthResponse.failure(e.message);
      }
      return AuthResponse.failure('Login failed: ${e.toString()}');
    }
  }

  /// Register user with improved type safety
  Future<AuthResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String userType = AppConstants.userTypePassenger,
  }) async {
    try {
      final request = UserCreateRequest(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        userType: UserType.fromString(userType),
      );

      final response = await _apiClient.post(
        ApiEndpoints.buildUrl('/api/v1/accounts/register/'),
        body: request.toJson(),
      );

      return AuthResponse.success(response, message: 'Registration successful');
    } catch (e) {
      if (e is ApiException) {
        return AuthResponse.failure(e.message);
      }
      return AuthResponse.failure('Registration failed: ${e.toString()}');
    }
  }

  /// Register driver with improved type safety
  Future<AuthResponse<Map<String, dynamic>>> registerDriver({
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
      final request = DriverRegistrationRequest(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        idCardNumber: idCardNumber,
        idCardPhoto: idCardPhoto,
        driverLicenseNumber: driverLicenseNumber,
        driverLicensePhoto: driverLicensePhoto,
        yearsOfExperience: yearsOfExperience,
      );

      final response = await _apiClient.multipartRequest(
        ApiEndpoints.buildUrl('/api/v1/accounts/register-driver/'),
        method: 'POST',
        fields: request.toFormFields(),
        files: request.getFiles(),
      );

      return AuthResponse.success(
        response,
        message: 'Driver registration successful',
      );
    } catch (e) {
      if (e is ApiException) {
        return AuthResponse.failure(e.message);
      }
      return AuthResponse.failure(
        'Driver registration failed: ${e.toString()}',
      );
    }
  }

  /// Reset password with improved error handling
  Future<AuthResponse<Map<String, dynamic>>> resetPassword({
    required String email,
  }) async {
    try {
      final request = PasswordResetRequest(email: email);
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.resetPasswordRequest),
        body: request.toJson(),
      );

      return AuthResponse.success(
        response,
        message: 'Password reset email sent',
      );
    } catch (e) {
      if (e is ApiException) {
        return AuthResponse.failure(e.message);
      }
      return AuthResponse.failure('Password reset failed: ${e.toString()}');
    }
  }

  /// Confirm password reset with improved type safety
  Future<AuthResponse<Map<String, dynamic>>> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final request = PasswordResetConfirmRequest(
        uid: uid,
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.resetPasswordConfirm),
        body: request.toJson(),
      );

      return AuthResponse.success(
        response,
        message: 'Password reset successful',
      );
    } catch (e) {
      if (e is ApiException) {
        return AuthResponse.failure(e.message);
      }
      return AuthResponse.failure(
        'Password reset confirmation failed: ${e.toString()}',
      );
    }
  }

  /// Logout user with proper error handling
  Future<AuthResponse<void>> logout() async {
    try {
      // Call the logout endpoint to invalidate the refresh token
      await _apiClient.post(ApiEndpoints.buildUrl(ApiEndpoints.logout));
      await _clearAuthData();
      return AuthResponse.success(null, message: 'Logout successful');
    } catch (e) {
      // Even if the API call fails, we should still clear local auth data
      debugPrint('Logout API call failed: ${e.toString()}');
      await _clearAuthData();
      return AuthResponse.success(
        null,
        message: 'Logout completed (with API warning)',
      );
    }
  }

  /// Refresh token with improved error handling
  Future<AuthResponse<String>> refreshToken(String refreshToken) async {
    try {
      final request = TokenRefreshRequest(refreshToken: refreshToken);
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.refreshToken),
        body: request.toJson(),
      );

      if (response is Map<String, dynamic> &&
          response.containsKey(ApiConstants.accessKey)) {
        final newAccessToken = response[ApiConstants.accessKey] as String;

        // Save new access token
        await StorageUtils.saveToStorage(AppConstants.tokenKey, newAccessToken);

        return AuthResponse.success(newAccessToken, message: 'Token refreshed');
      }

      return AuthResponse.failure('Invalid response from server');
    } catch (e) {
      if (e is ApiException) {
        return AuthResponse.failure(e.message);
      }
      return AuthResponse.failure('Token refresh failed: ${e.toString()}');
    }
  }

  /// Verify token with improved error handling
  Future<AuthResponse<bool>> verifyToken(String token) async {
    try {
      final request = TokenVerifyRequest(token: token);
      await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.verifyToken),
        body: request.toJson(),
      );

      return AuthResponse.success(true, message: 'Token is valid');
    } catch (e) {
      return AuthResponse.success(false, message: 'Token is invalid');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await StorageUtils.getFromStorage<String>(
      AppConstants.tokenKey,
    );

    if (token == null || token.isEmpty) {
      return false;
    }

    // Verify token validity
    final verifyResponse = await verifyToken(token);
    return verifyResponse.data ?? false;
  }

  // Get current authentication token
  Future<String?> getAuthToken() async {
    return await StorageUtils.getFromStorage<String>(AppConstants.tokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await StorageUtils.getFromStorage<String>(
      AppConstants.refreshTokenKey,
    );
  }

  // Save authentication data
  Future<void> _saveAuthData({
    required String token,
    required String refreshToken,
  }) async {
    await StorageUtils.saveToStorage(AppConstants.tokenKey, token);
    await StorageUtils.saveToStorage(
      AppConstants.refreshTokenKey,
      refreshToken,
    );
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    await StorageUtils.removeFromStorage(AppConstants.tokenKey);
    await StorageUtils.removeFromStorage(AppConstants.refreshTokenKey);
    await StorageUtils.removeFromStorage(AppConstants.userKey);
  }
}
