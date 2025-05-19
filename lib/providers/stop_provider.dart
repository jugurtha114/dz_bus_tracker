// lib/providers/stop_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/stop_service.dart';

class StopProvider with ChangeNotifier {
  final StopService _stopService;

  StopProvider({StopService? stopService})
      : _stopService = stopService ?? StopService();

  // State
  List<Map<String, dynamic>> _stops = [];
  List<Map<String, dynamic>> _nearbyStops = [];
  Map<String, dynamic>? _selectedStop;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get stops => _stops;
  List<Map<String, dynamic>> get nearbyStops => _nearbyStops;
  Map<String, dynamic>? get selectedStop => _selectedStop;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch stops
  Future<void> fetchStops({
    bool? isActive,
    String? lineId,
  }) async {
    _setLoading(true);

    try {
      _stops = await _stopService.getStops(
        isActive: isActive,
        lineId: lineId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Fetch stop by ID
  Future<void> fetchStopById(String stopId) async {
    _setLoading(true);

    try {
      final stop = await _stopService.getStopById(stopId);
      _selectedStop = stop;

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Select stop
  void selectStop(Map<String, dynamic> stop) {
    _selectedStop = stop;
    notifyListeners();
  }

  // Clear selected stop
  void clearSelectedStop() {
    _selectedStop = null;
    notifyListeners();
  }

  // Fetch nearby stops
  Future<void> fetchNearbyStops({
    required double latitude,
    required double longitude,
    double radius = 1000, // default 1km
  }) async {
    _setLoading(true);

    try {
      _nearbyStops = await _stopService.getNearbyStops(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Create new stop
  Future<bool> createStop({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String? description,
    String? photo,
  }) async {
    _setLoading(true);

    try {
      final newStop = await _stopService.createStop(
        name: name,
        latitude: latitude,
        longitude: longitude,
        address: address,
        description: description,
        photo: photo,
      );

      // Add to stops list
      _stops.add(newStop);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update stop
  Future<bool> updateStop({
    required String stopId,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? description,
    String? photo,
    bool? isActive,
  }) async {
    _setLoading(true);

    try {
      final updatedStop = await _stopService.updateStop(
        stopId: stopId,
        name: name,
        latitude: latitude,
        longitude: longitude,
        address: address,
        description: description,
        photo: photo,
        isActive: isActive,
      );

      // Update stops list
      final index = _stops.indexWhere((stop) => stop['id'] == stopId);
      if (index != -1) {
        _stops[index] = updatedStop;
      }

      // Update nearby stops list
      final nearbyIndex = _nearbyStops.indexWhere((stop) => stop['id'] == stopId);
      if (nearbyIndex != -1) {
        _nearbyStops[nearbyIndex] = updatedStop;
      }

      // Update selected stop if it's the same stop
      if (_selectedStop != null && _selectedStop!['id'] == stopId) {
        _selectedStop = updatedStop;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Report waiting passengers
  Future<bool> reportWaiting({
    required String stopId,
    required int count,
    String? lineId,
  }) async {
    try {
      await _stopService.reportWaitingPassengers(
        stopId: stopId,
        count: count,
        lineId: lineId,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
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