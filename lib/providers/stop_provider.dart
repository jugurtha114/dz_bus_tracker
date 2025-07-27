// lib/providers/stop_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/stop_service.dart';
import '../models/stop_model.dart';
import '../models/line_model.dart';

class StopProvider with ChangeNotifier {
  final StopService _stopService;

  StopProvider({StopService? stopService})
    : _stopService = stopService ?? StopService();

  // State
  List<Stop> _stops = [];
  List<Stop> _nearbyStops = [];
  Stop? _selectedStop;
  List<Line> _stopLines = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Stop> get stops => _stops;
  List<Stop> get nearbyStops => _nearbyStops;
  Stop? get selectedStop => _selectedStop;
  List<Line> get stopLines => _stopLines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch stops
  Future<void> fetchStops({bool? isActive, String? lineId}) async {
    _setLoading(true);

    try {
      _stops = await _stopService.getStops(isActive: isActive, lineId: lineId);

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
  void selectStop(Stop stop) {
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
      _stops.add(Stop.fromJson(newStop));
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
      final index = _stops.indexWhere((stop) => stop.id == stopId);
      if (index != -1) {
        _stops[index] = Stop.fromJson(updatedStop);
      }

      // Update nearby stops list
      final nearbyIndex = _nearbyStops.indexWhere(
        (stop) => stop.id == stopId,
      );
      if (nearbyIndex != -1) {
        _nearbyStops[nearbyIndex] = Stop.fromJson(updatedStop);
      }

      // Update selected stop if it's the same stop
      if (_selectedStop != null && _selectedStop!.id == stopId) {
        _selectedStop = Stop.fromJson(updatedStop);
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
  
  /// Additional methods for UI compatibility
  Future<void> loadRecentStops() async {
    // Mock implementation - load recent stops from local storage
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> loadPopularStops() async {
    // Mock implementation - load popular stops
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
  
  List<Stop> get recentStops => _stops.take(5).toList(); // Mock
  List<Stop> get popularStops => _stops.take(10).toList(); // Mock

  // Load stop details (alias for fetchStopById)
  Future<void> loadStopDetails(String stopId) => fetchStopById(stopId);
  
  // Load stop lines (Mock implementation)
  Future<void> loadStopLines(String stopId) async {
    _setLoading(true);
    try {
      // Mock implementation - in real app, fetch lines serving this stop
      await Future.delayed(const Duration(milliseconds: 500));
      _stopLines = []; // Empty list for now
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  // Get stop arrivals (Mock implementation)  
  Future<List<Map<String, dynamic>>> getStopArrivals(String stopId) async {
    _setLoading(true);
    try {
      // Mock implementation - in real app, fetch real-time arrivals
      await Future.delayed(const Duration(milliseconds: 500));
      _clearError();
      
      // Return mock arrival data
      final arrivals = [
        {
          'busNumber': '45A',
          'lineId': 'line_1',
          'lineName': 'City Center - Airport',
          'estimatedArrival': DateTime.now().add(const Duration(minutes: 5)),
          'isRealTime': true,
        },
        {
          'busNumber': '23B',
          'lineId': 'line_2', 
          'lineName': 'University - Downtown',  
          'estimatedArrival': DateTime.now().add(const Duration(minutes: 12)),
          'isRealTime': false,
        },
      ];
      
      notifyListeners();
      return arrivals;
    } catch (e) {
      _setError(e);
      notifyListeners();
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> searchStops(String query) async {
    _setLoading(true);
    try {
      // Mock search implementation
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
  
  List<Stop> get searchResults => _stops.where((stop) => 
      stop.name.toLowerCase().contains('search')).toList();
  
  void addToRecentStops(Stop stop) {
    // Mock implementation - add to recent stops
  }
  
  void clearRecentStops() {
    // Mock implementation - clear recent stops
  }
  
  Future<void> getPassengerReports(String stopId) async {
    // Mock implementation - get passenger reports
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
  
  void _clearError() {
    _error = null;
  }
}
