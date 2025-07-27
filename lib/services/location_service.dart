// lib/services/location_service.dart

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  LatLng? _currentLocation;
  final StreamController<LatLng> _locationStreamController =
      StreamController<LatLng>.broadcast();

  Stream<LatLng> get locationStream => _locationStreamController.stream;
  LatLng? get currentLocation => _currentLocation;

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      return _currentLocation;
    } catch (e) {
      // Return mock location for Algiers if real location fails
      _currentLocation = const LatLng(36, 3);
      return _currentLocation;
    }
  }

  Future<void> startLocationTracking() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _currentLocation = LatLng(position.latitude, position.longitude);
            _locationStreamController.add(_currentLocation!);
          },
          onError: (error) {
            // Handle error
          },
        );
  }

  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
          start.latitude,
          start.longitude,
          end.latitude,
          end.longitude,
        ) /
        1000; // Convert to kilometers
  }

  void dispose() {
    stopLocationTracking();
    _locationStreamController.close();
  }
}
