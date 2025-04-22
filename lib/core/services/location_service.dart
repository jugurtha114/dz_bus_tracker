/// lib/core/services/location_service.dart

import 'dart:async';

import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:geolocator/geolocator.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart'; // For locationUpdateIntervalSeconds

/// Data class representing a single location update to be potentially sent to the backend.
/// Fields align with the expected API structure (e.g., LocationUpdateCreateRequest).
class LocationUpdateData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy;
  final double? speed; // meters per second
  final double? heading; // degrees
  final double? altitude; // meters

  LocationUpdateData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.speed,
    this.heading,
    this.altitude,
  });

  /// Converts this object to a JSON map suitable for API serialization.
  /// The 'session' ID needs to be added separately when sending to the API.
  Map<String, dynamic> toJson() => {
        // 'session' key is added by the repository/use case layer
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude.toString(), // API expects string decimal
        'longitude': longitude.toString(), // API expects string decimal
        if (accuracy != null) 'accuracy': accuracy,
        if (speed != null) 'speed': speed,
        if (heading != null) 'heading': heading,
        if (altitude != null) 'altitude': altitude,
        // 'metadata': {} // If needed in the future
      };

  @override
  String toString() {
    return 'LocationUpdateData(lat: $latitude, lon: $longitude, time: $timestamp, acc: $accuracy, spd: $speed)';
  }
}


/// Abstract interface for location services.
abstract class LocationService {
  /// Gets the current device position once.
  /// Throws [PermissionException] or [LocationServiceException].
  Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
  });

  /// A stream providing continuous location updates while the app is in the foreground.
  /// Use [locationUpdateStream] for the driver's specific background/periodic tracking.
  Stream<Position> get positionStream;

  /// Checks the current location permission status.
  Future<LocationPermission> checkPermission();

  /// Requests location permission from the user.
  Future<LocationPermission> requestPermission();

  /// Checks if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Starts the dedicated driver tracking stream.
  /// Emits [LocationUpdateData] on [locationUpdateStream] every ~20 seconds.
  /// Returns true if tracking started successfully, false otherwise (e.g., permissions denied).
  /// Requires appropriate background location permissions on Android/iOS.
  Future<bool> startTracking();

  /// Stops the dedicated driver tracking stream.
  Future<bool> stopTracking();

  /// A broadcast stream emitting [LocationUpdateData] at the configured interval
  /// (e.g., every 20 seconds) **only when driver tracking is active** via [startTracking].
  /// This stream is used by the tracking repository/use case to send updates.
  Stream<LocationUpdateData> get locationUpdateStream;
}


/// Implementation of [LocationService] using the `geolocator` package.
class LocationServiceImpl implements LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  Timer? _trackingTimer;
  Position? _lastPosition; // Store the latest position received

  // Stream controller for the dedicated 20-second tracking updates
  final StreamController<LocationUpdateData> _locationUpdateController = StreamController.broadcast();
  bool _isTrackingActive = false;

  // Define location settings for driver tracking (high accuracy)
  // Distance filter is 0 because we rely on the timer for the interval.
  static const LocationSettings _trackingLocationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0, // Report all movements, timer controls emission frequency
    // Android specific settings (optional but recommended for background)
    // timeLimit: Duration.zero, // No time limit for the stream
    // --- Android Foreground Service ---
    // This requires additional setup in AndroidManifest.xml and potentially native code
    // or using a dedicated background location package. Geolocator alone might not
    // guarantee continuous background execution on all Android versions/OEMs.
    // Consider packages like `flutter_background_geolocation` for robust background needs.
    // androidNotificationConfig: AndroidNotificationConfig(
    //     notificationId: 12345, // Unique ID for the notification
    //     channelName: 'DZ Bus Tracking Location',
    //     channelDescription: 'Tracking bus location in the background.',
    //     notificationTitle: 'DZ Bus Tracker',
    //     notificationText: 'Tracking active.',
    //     enableWakeLock: true, // Keep CPU awake
    //     enableWifiLock: true, // Keep WiFi awake
    // ),
  );

  LocationServiceImpl() {
     // Monitor location service status changes
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen(
      (ServiceStatus status) {
        Log.i('Location service status changed: $status');
        if (status == ServiceStatus.disabled && _isTrackingActive) {
          Log.w('Location service disabled while tracking was active. Stopping tracking.');
          stopTracking(); // Attempt to stop gracefully if service is disabled
        }
      },
      onError: (error) {
         Log.e('Error listening to location service status', error: error);
      },
    );
  }


  @override
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e, stackTrace) {
       Log.e('Error checking location permission', error: e, stackTrace: stackTrace);
       // Assuming failure means permission is likely denied or restricted
       return LocationPermission.denied;
    }
  }

  @override
  Future<LocationPermission> requestPermission() async {
    try {
       LocationPermission permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.deniedForever) {
         Log.w('Location permission denied forever.');
         // Optionally: Guide user to app settings
         // Geolocator.openAppSettings();
       }
       return permission;
    } catch (e, stackTrace) {
       Log.e('Error requesting location permission', error: e, stackTrace: stackTrace);
       throw PermissionException(message: 'Failed to request location permission.', details: e);
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e, stackTrace) {
      Log.e('Error checking location service status', error: e, stackTrace: stackTrace);
      return false; // Assume disabled on error
    }
  }

  @override
  Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
  }) async {
    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) {
      throw const PermissionException(message: 'Location permission denied.');
    }

    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) {
      // Optionally: Prompt user to enable location services
      // await Geolocator.openLocationSettings();
      throw const LocationServiceException(message: 'Location services are disabled.');
    }

    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);
    } catch (e, stackTrace) {
       Log.e('Error getting current position', error: e, stackTrace: stackTrace);
       throw LocationServiceException(message: 'Failed to get current location.', details: e);
    }
  }

  @override
  Stream<Position> get positionStream {
    // Note: This returns the raw geolocator stream. Permissions should be checked
    // by the caller before subscribing.
    return Geolocator.getPositionStream(locationSettings: _trackingLocationSettings);
  }

  @override
  Stream<LocationUpdateData> get locationUpdateStream => _locationUpdateController.stream;

  @override
  Future<bool> startTracking() async {
    if (_isTrackingActive) {
      Log.w('Tracking is already active.');
      return true; // Already running
    }

    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) {
      Log.e('Cannot start tracking: Location permission denied.');
      return false;
    }

    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) {
       Log.e('Cannot start tracking: Location services disabled.');
       // Optionally prompt user
       // await Geolocator.openLocationSettings();
      return false;
    }

    Log.i('Starting location tracking service...');
    _isTrackingActive = true;
    _lastPosition = null; // Reset last known position

    // Cancel any existing subscription or timer
    await _positionStreamSubscription?.cancel();
    _trackingTimer?.cancel();

    // Listen to the raw position stream
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: _trackingLocationSettings,
    ).handleError((error) {
        // Handle errors from the stream itself
        Log.e('Error in position stream', error: error);
        // Optionally stop tracking or notify UI
        stopTracking();
        _locationUpdateController.addError(
           LocationServiceException(message: 'Position stream error.', details: error),
           StackTrace.current // Add stack trace if available
        );
    }).listen((Position position) {
      _lastPosition = position; // Store the latest position immediately
      // Timer will handle emitting at the correct interval
    });

    // Start the timer to emit updates every N seconds
    _trackingTimer = Timer.periodic(
      const Duration(seconds: AppConstants.locationUpdateIntervalSeconds),
      (timer) {
        if (_isTrackingActive && _lastPosition != null) {
          Log.d('Timer tick: Emitting location update.');
          final updateData = LocationUpdateData(
            latitude: _lastPosition!.latitude,
            longitude: _lastPosition!.longitude,
            timestamp: _lastPosition!.timestamp ?? DateTime.now(), // Use timestamp from position if available
            accuracy: _lastPosition!.accuracy,
            speed: _lastPosition!.speed,
            heading: _lastPosition!.heading,
            altitude: _lastPosition!.altitude,
          );
          _locationUpdateController.add(updateData);
        } else if (!_isTrackingActive) {
           Log.w('Timer tick: Tracking is not active, cancelling timer.');
           timer.cancel(); // Cancel timer if tracking was stopped externally
        }
      },
    );

    Log.i('Location tracking service started successfully.');
    return true;
  }

  @override
  Future<bool> stopTracking() async {
    if (!_isTrackingActive) {
      Log.w('Tracking is not active, nothing to stop.');
      return true;
    }

    Log.i('Stopping location tracking service...');
    _isTrackingActive = false;
    await _positionStreamSubscription?.cancel();
    _trackingTimer?.cancel();
    _positionStreamSubscription = null;
    _trackingTimer = null;
    _lastPosition = null;

    Log.i('Location tracking service stopped.');
    return true;
  }

  /// Helper to check permissions and request if necessary. Returns true if granted.
  Future<bool> _checkAndRequestPermission() async {
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        Log.w('Location permission was denied.');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Log.e('Location permission denied forever.');
      // Consider guiding user to settings: await Geolocator.openAppSettings();
      return false;
    }
    // Consider checking for precise vs. approximate and background permissions if needed
    return true;
  }

  /// Dispose resources when the service is no longer needed.
  void dispose() {
    Log.d('Disposing LocationService...');
    _positionStreamSubscription?.cancel();
    _serviceStatusSubscription?.cancel();
    _trackingTimer?.cancel();
    _locationUpdateController.close();
  }
}
