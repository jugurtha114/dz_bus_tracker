// lib/providers/location_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/location/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService;

  LocationProvider({LocationService? locationService})
    : _locationService = locationService ?? LocationService.instance;

  // State
  Position? _currentLocation;
  bool _locationPermissionGranted = false;
  bool _isTracking = false;
  List<Position> _locationHistory = [];
  String? _error;

  // Stream subscription
  StreamSubscription<Position>? _positionStreamSubscription;

  // Getters
  Position? get currentLocation => _currentLocation;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get isTracking => _isTracking;
  List<Position> get locationHistory => _locationHistory;
  String? get error => _error;
  bool get isLoading => _isTracking; // Use tracking state as loading indicator

  // Coordinate getters
  double get latitude =>
      _currentLocation?.latitude ?? AppConstants.defaultLatitude;
  double get longitude =>
      _currentLocation?.longitude ?? AppConstants.defaultLongitude;

  // Dispose
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // Request location permission (alias method)
  Future<bool> requestLocationPermission() async {
    return await requestPermission();
  }

  // Request location permission
  Future<bool> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();

      _locationPermissionGranted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      notifyListeners();

      return _locationPermissionGranted;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      if (!_locationPermissionGranted) {
        final permissionGranted = await requestPermission();
        if (!permissionGranted) {
          throw LocationException('Location permission denied');
        }
      }

      _currentLocation = await _locationService.getCurrentLocation();
      notifyListeners();

      return _currentLocation;
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  // Start location tracking
  Future<bool> startTracking({
    int distanceFilter = 10,
    int intervalInSeconds = 5,
  }) async {
    if (_isTracking) {
      return true; // Already tracking
    }

    try {
      if (!_locationPermissionGranted) {
        final permissionGranted = await requestPermission();
        if (!permissionGranted) {
          throw LocationException('Location permission denied');
        }
      }

      // Clear previous history
      _locationHistory = [];

      // Start location updates
      await _locationService.startLocationUpdates(
        distanceFilter: distanceFilter,
        intervalInSeconds: intervalInSeconds,
      );

      // Subscribe to location stream
      _positionStreamSubscription = _locationService.locationStream.listen(
        (position) {
          _currentLocation = position;
          _locationHistory.add(position);
          notifyListeners();
        },
        onError: (error) {
          _setError(error);
        },
      );

      _isTracking = true;
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Stop location tracking
  Future<bool> stopTracking() async {
    if (!_isTracking) {
      return true; // Already stopped
    }

    try {
      // Cancel subscription
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      // Stop location updates
      await _locationService.stopLocationUpdates();

      _isTracking = false;
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _locationService.isLocationServiceEnabled();
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    try {
      await _locationService.openLocationSettings();
    } catch (e) {
      _setError(e);
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    try {
      await _locationService.openAppSettings();
    } catch (e) {
      _setError(e);
    }
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
