// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/utils/storage_utils.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

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
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _userProfile;
  String? _token;
  String? _userType;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _userData;
  Map<String, dynamic>? get profile => _userProfile;
  String? get token => _token;
  String? get userType => _userType;

  // Check if user is a driver
  bool get isDriver => _userType == AppConstants.userTypeDriver;

  // Check if user is a passenger
  bool get isPassenger => _userType == AppConstants.userTypePassenger;

  // Check if user is an admin
  bool get isAdmin => _userType == AppConstants.userTypeAdmin;

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

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      _isAuthenticated = true;
      await _fetchUserData();
      _token = await _authService.getAuthToken();

      return true;
    } catch (e) {
      _isAuthenticated = false;
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
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
      await _authService.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        userType: AppConstants.userTypePassenger,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register driver
// lib/providers/auth_provider.dart (updated registerDriver method)

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
      await _authService.registerDriver(
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

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _userData = null;
      _userProfile = null;
      _token = null;
      _userType = null;
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(
        email: email,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
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

      _userData = response;
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update password
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

  // Fetch user data
  Future<void> _fetchUserData() async {
    try {
      // Get user data
      _userData = await _userService.getUserProfile();

      // Extract user type
      if (_userData != null && _userData!.containsKey('user_type')) {
        _userType = _userData!['user_type'];
      }

      // Get profile
      _userProfile = await _userService.getProfileDetails();

      // Save user data for persistence
      await StorageUtils.saveToStorage(AppConstants.userKey, _userData);

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