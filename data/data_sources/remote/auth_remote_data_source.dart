/// lib/data/data_sources/remote/auth_remote_data_source.dart

import 'package:dio/dio.dart'; // For FormData

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../models/driver_model.dart';
import '../../models/login_response_model.dart';
import '../../models/user_model.dart';

/// Abstract interface for remote data operations related to authentication.
/// Defines methods for interacting with authentication-specific API endpoints.
abstract class AuthRemoteDataSource2 {
  /// Calls the login API endpoint with email and password.
  /// Returns [LoginResponseModel] containing access and refresh tokens on success.
  Future<LoginResponseModel> login(String email, String password);

  /// Calls the user registration API endpoint.
  /// [userData] should contain required fields like email, password, first_name, last_name etc.
  /// Returns the created [UserModel] on success.
  Future<UserModel> register(Map<String, dynamic> userData);

  /// Calls the endpoint to register/add driver-specific details (potentially including photos).
  /// Requires [FormData] containing driver details and potentially image files.
  /// Assumes this call happens after a base user is created.
  /// Returns the created or updated [DriverModel] on success.
  Future<DriverModel> registerDriverDetails(FormData driverData);

  /// Fetches the profile of the currently authenticated user from the API.
  /// Returns the user's [UserModel] on success.
  Future<UserModel> getUserProfile();

  /// Calls the API endpoint to request a password reset email/link for the given email.
  Future<void> requestPasswordReset(String email);

  /// Calls the API endpoint to finalize the password reset using a token.
  Future<void> resetPassword(String token, String newPassword);

  /// Calls a backend logout endpoint if one exists.
  /// Note: Often, logout primarily involves clearing local tokens and state.
  Future<void> logout();
}


/// Abstract interface for remote data operations related to authentication.
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String email, String password);
  Future<UserModel> register(Map<String, dynamic> userData);
  Future<DriverModel> registerDriverDetails(FormData driverData);
  // Added optional Options
  Future<UserModel> getUserProfile({Options? options});
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> logout();
}

/// Implementation of [AuthRemoteDataSource] using the core [ApiClient].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  const AuthRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override Future<LoginResponseModel> login(String email, String password) async { /* ... same implementation ... */ final response = await _apiClient.post( ApiConstants.login, data: {'email': email, 'password': password}, ); return LoginResponseModel.fromJson(response.data); }
  @override Future<UserModel> register(Map<String, dynamic> userData) async { /* ... same implementation ... */ final response = await _apiClient.post( ApiConstants.register, data: userData, ); return UserModel.fromJson(response.data); }
  @override Future<DriverModel> registerDriverDetails(FormData driverData) async { /* ... same implementation ... */ final response = await _apiClient.postMultipart( ApiConstants.drivers, data: driverData, ); return DriverModel.fromJson(response.data); }

  // CORRECTED: Added optional Options parameter
  @override
  Future<UserModel> getUserProfile({Options? options}) async {
    Log.d('AuthRemoteDataSource: Calling get user profile API.');
    final response = await _apiClient.get(
      ApiConstants.userProfile,
      options: options, // Pass options to ApiClient
    );
    return UserModel.fromJson(response.data);
  }

  @override Future<void> requestPasswordReset(String email) async { /* ... same implementation ... */ await _apiClient.post( ApiConstants.resetPasswordRequest, data: {'email': email}, ); }
  @override Future<void> resetPassword(String token, String newPassword) async { /* ... same implementation ... */ await _apiClient.post( ApiConstants.resetPassword, data: {'token': token, 'new_password': newPassword}, ); }
  @override Future<void> logout() async { /* ... same implementation ... */ Log.i('AuthRemoteDataSource: Logout called. No backend endpoint defined in spec; local token clearing is primary action.'); return Future.value(); }
}




