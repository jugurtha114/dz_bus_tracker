// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/utils/storage_utils.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  AuthProvider({
    AuthService? authService,
    UserService? userService,
  })
      : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService();

  // Authentication state
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  User? _user;
  Profile? _profile;
  String? _token;
  UserType? _userType;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  Profile? get profile => _profile;
  String? get token => _token;
  UserType? get userType => _userType;
  
  // Convenience getters for user data
  String get userDisplayName => _user?.fullName ?? 'Unknown User';
  String get userEmail => _user?.email ?? '';
  Language get userLanguage => _profile?.language ?? Language.french;

  // Check if user is a driver
  bool get isDriver => _userType == UserType.driver;

  // Check if user is a passenger
  bool get isPassenger => _userType == UserType.passenger;

  // Check if user is an admin
  bool get isAdmin => _userType == UserType.admin;

  // Initialize authentication state
  Future<void> checkAuth() async {
    _setLoading(true);

    try {
      final isAuthenticated = await _authService.isAuthenticated();
      _isAuthenticated = isAuthenticated;

      if (isAuthenticated) {
        await _fetchUserData();
        _token = await _authService.getAuthToken();
      }
    } catch (e) {
      _isAuthenticated = false;
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Login with improved error handling and type safety
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _isAuthenticated = true;
        _token = response.data!.accessToken;
        await _fetchUserData();
        return true;
      } else {
        _setError(response.message ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _isAuthenticated = false;
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register with improved error handling and type safety
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        userType: AppConstants.userTypePassenger,
      );

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register driver
  /// Register driver with improved error handling and type safety
  Future<bool> registerDriver({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCardNumber,
    required dynamic idCardPhoto, // Can be File or XFile or Uint8List
    required String driverLicenseNumber,
    required dynamic driverLicensePhoto, // Can be File or XFile or Uint8List
    required int yearsOfExperience,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.registerDriver(
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

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Driver registration failed');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout with improved error handling
  Future<void> logout() async {
    _setLoading(true);

    try {
      final response = await _authService.logout();
      
      // Always clear local state regardless of API response
      _isAuthenticated = false;
      _user = null;
      _profile = null;
      _token = null;
      _userType = null;
      _clearError();
      
      if (!response.success && response.message?.contains('warning') != true) {
        debugPrint('Logout warning: ${response.message}');
      }
    } catch (e) {
      // Clear local state even if logout API fails
      _isAuthenticated = false;
      _user = null;
      _profile = null;
      _token = null;
      _userType = null;
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password with improved error handling
  Future<bool> resetPassword({
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.resetPassword(
        email: email,
      );

      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Password reset failed');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update profile with improved type safety
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _userService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (response != null) {
        _user = User.fromJson(response);
        await StorageUtils.saveToStorage(AppConstants.userKey, _user!.toJson());
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update password with improved error handling
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _userService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch user data with improved type safety
  Future<void> _fetchUserData() async {
    try {
      // Get user data
      final userData = await _userService.getUserProfile();
      if (userData != null) {
        _user = User.fromJson(userData);
        _userType = _user?.userType;
      }

      // Get profile
      final profileData = await _userService.getProfileDetails();
      if (profileData != null) {
        _profile = Profile.fromJson(profileData);
      }

      // Save user data for persistence
      if (_user != null) {
        await StorageUtils.saveToStorage(AppConstants.userKey, _user!.toJson());
      }

      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(dynamic error) {
    if (error is AppException) {
      _error = error.message;
    } else {
      _error = error.toString();
    }
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}