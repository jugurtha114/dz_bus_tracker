// lib/core/location/location_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../exceptions/app_exceptions.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  LocationService._();

  StreamSubscription<Position>? _positionStreamSubscription;
  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();

  Stream<Position> get locationStream => _locationController.stream;
  bool get isTracking => _positionStreamSubscription != null;

  // Get current location once
  Future<Position> getCurrentLocation() async {
    try {
      final permission = await _checkAndRequestPermission();

      if (!permission) {
        throw LocationException('Location permission is denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      if (e is LocationException) {
        rethrow;
      }

      throw LocationException(
        'Failed to get current location: ${e.toString()}',
      );
    }
  }

  // Start periodic location updates
  Future<void> startLocationUpdates({
    int distanceFilter = 10, // in meters
    LocationAccuracy accuracy = LocationAccuracy.high,
    int intervalInSeconds = 5,
  }) async {
    try {
      final permission = await _checkAndRequestPermission();

      if (!permission) {
        throw LocationException('Location permission is denied');
      }

      // Stop any existing subscription
      await stopLocationUpdates();

      // Set up new subscription
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: AndroidSettings(
              accuracy: accuracy,
              distanceFilter: distanceFilter,
              intervalDuration: Duration(seconds: intervalInSeconds),
            ),
          ).listen(
            (Position position) {
              _locationController.add(position);
            },
            onError: (error) {
              debugPrint('Location stream error: $error');
              _locationController.addError(
                LocationException('Location stream error: ${error.toString()}'),
              );
            },
          );
    } catch (e) {
      if (e is LocationException) {
        rethrow;
      }

      throw LocationException(
        'Failed to start location updates: ${e.toString()}',
      );
    }
  }

  // Stop location updates
  Future<void> stopLocationUpdates() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Check and request location permission
  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled');
    }

    // Check permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permission is denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException('Location permission is permanently denied');
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // Dispose the service
  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }
}
