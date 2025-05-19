// lib/providers/driver_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/driver_service.dart';

class DriverProvider with ChangeNotifier {
  final DriverService _driverService;

  DriverProvider({DriverService? driverService})
      : _driverService = driverService ?? DriverService();

  // State
  Map<String, dynamic>? _driverProfile;
  List<Map<String, dynamic>> _ratings = [];
  bool _isAvailable = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get driverProfile => _driverProfile;
  List<Map<String, dynamic>> get ratings => _ratings;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get driver info like id, rating, etc.
  String get driverId => _driverProfile?['id'] ?? '';
  double get rating => _driverProfile != null && _driverProfile!.containsKey('rating')
      ? double.tryParse(_driverProfile!['rating'].toString()) ?? 0.0
      : 0.0;

  // Fetch driver profile
  Future<void> fetchProfile() async {
    _setLoading(true);

    try {
      _driverProfile = await _driverService.getDriverProfile();

      // Update availability state
      if (_driverProfile != null && _driverProfile!.containsKey('is_available')) {
        _isAvailable = _driverProfile!['is_available'] == true;
      }

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Update driver profile
  Future<bool> updateProfile({
    String? phoneNumber,
    int? yearsOfExperience,
  }) async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return false;
    }

    _setLoading(true);

    try {
      final updatedProfile = await _driverService.updateProfile(
        driverId: _driverProfile!['id'],
        phoneNumber: phoneNumber,
        yearsOfExperience: yearsOfExperience,
      );

      _driverProfile = updatedProfile;
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle driver availability
  Future<bool> toggleAvailability() async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return false;
    }

    _setLoading(true);

    try {
      await _driverService.updateAvailability(
        driverId: _driverProfile!['id'],
        isAvailable: !_isAvailable,
      );

      _isAvailable = !_isAvailable;
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch driver ratings
  Future<void> fetchRatings() async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return;
    }

    _setLoading(true);

    try {
      _ratings = await _driverService.getRatings(_driverProfile!['id']);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
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
  void clearError() {
    _error = null;
    notifyListeners();
  }
}