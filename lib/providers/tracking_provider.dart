// lib/providers/tracking_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/tracking_service.dart';

class TrackingProvider with ChangeNotifier {
  final TrackingService _trackingService;

  TrackingProvider({TrackingService? trackingService})
      : _trackingService = trackingService ?? TrackingService();

  // State
  bool _isTracking = false;
  Map<String, dynamic>? _currentTrip;
  List<Map<String, dynamic>> _locationHistory = [];
  List<Map<String, dynamic>> _anomalies = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isTracking => _isTracking;
  Map<String, dynamic>? get currentTrip => _currentTrip;
  List<Map<String, dynamic>> get locationHistory => _locationHistory;
  List<Map<String, dynamic>> get anomalies => _anomalies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Start tracking
  Future<bool> startTracking({
    required String busId,
    required String driverId,
    required String lineId,
  }) async {
    if (_isTracking) {
      _setError('Already tracking');
      return false;
    }

    _setLoading(true);

    try {
      // Start tracking on server
      await _trackingService.startTracking(
        busId: busId,
        lineId: lineId,
      );

      // Create a new trip
      final trip = await _trackingService.createTrip(
        busId: busId,
        driverId: driverId,
        lineId: lineId,
        startTime: DateTime.now(),
      );

      _currentTrip = trip;
      _isTracking = true;
      _locationHistory = [];

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Stop tracking
  Future<bool> stopTracking() async {
    if (!_isTracking || _currentTrip == null) {
      _setError('Not tracking');
      return false;
    }

    _setLoading(true);

    try {
      // End the current trip
      await _trackingService.endTrip(
        tripId: _currentTrip!['id'],
      );

      // Stop tracking on server
      await _trackingService.stopTracking(
        busId: _currentTrip!['bus'],
      );

      _isTracking = false;
      _currentTrip = null;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send location update
  Future<bool> sendLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    if (!_isTracking || _currentTrip == null) {
      _setError('Not tracking');
      return false;
    }

    try {
      final locationUpdate = await _trackingService.sendLocationUpdate(
        busId: busId,
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        speed: speed,
        heading: heading,
        accuracy: accuracy,
        tripId: _currentTrip!['id'],
      );

      // Add to location history
      _locationHistory.add(locationUpdate);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Update passenger count
  Future<bool> updatePassengers({
    required String busId,
    required int count,
    String? stopId,
  }) async {
    if (!_isTracking || _currentTrip == null) {
      _setError('Not tracking');
      return false;
    }

    try {
      await _trackingService.reportPassengerCount(
        busId: busId,
        count: count,
        stopId: stopId,
        tripId: _currentTrip!['id'],
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Report anomaly
  Future<bool> reportAnomaly({
    required String busId,
    required String type,
    required String description,
    required String severity,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final anomaly = await _trackingService.reportAnomaly(
        busId: busId,
        type: type,
        description: description,
        severity: severity,
        latitude: latitude,
        longitude: longitude,
        tripId: _currentTrip?['id'],
      );

      // Add to anomalies list
      _anomalies.add(anomaly);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Resolve anomaly
  Future<bool> resolveAnomaly({
    required String anomalyId,
    required String resolutionNotes,
  }) async {
    try {
      final resolvedAnomaly = await _trackingService.resolveAnomaly(
        anomalyId: anomalyId,
        resolutionNotes: resolutionNotes,
      );

      // Update anomalies list
      final index = _anomalies.indexWhere((anomaly) => anomaly['id'] == anomalyId);
      if (index != -1) {
        _anomalies[index] = resolvedAnomaly;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Fetch trip history
  Future<List<Map<String, dynamic>>> fetchTripHistory({
    String? busId,
    String? driverId,
    String? lineId,
    bool isCompleted = true,
  }) async {
    _setLoading(true);

    try {
      final trips = await _trackingService.getTrips(
        busId: busId,
        driverId: driverId,
        lineId: lineId,
        isCompleted: isCompleted,
      );

      return trips;
    } catch (e) {
      _setError(e);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get trip statistics
  Future<Map<String, dynamic>?> getTripStatistics(String tripId) async {
    _setLoading(true);

    try {
      final statistics = await _trackingService.getTripStatistics(tripId);
      return statistics;
    } catch (e) {
      _setError(e);
      return null;
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