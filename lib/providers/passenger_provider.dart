// lib/providers/passenger_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/api_response_models.dart';
import '../models/bus_model.dart';
import '../models/line_model.dart';
import '../models/stop_model.dart';
import '../models/driver_model.dart';
import '../models/tracking_model.dart' hide Trip;
import '../models/trip_model.dart';
import '../services/bus_service.dart';
import '../services/driver_service.dart';
import '../services/line_service.dart';
import '../services/stop_service.dart';
import '../services/tracking_service.dart';

class PassengerProvider with ChangeNotifier {
  final BusService _busService;
  final LineService _lineService;
  final StopService _stopService;
  final TrackingService _trackingService;
  final DriverService _driverService;

  PassengerProvider({
    BusService? busService,
    LineService? lineService,
    StopService? stopService,
    TrackingService? trackingService,
    DriverService? driverService,
  }) : _busService = busService ?? BusService(),
       _lineService = lineService ?? LineService(),
       _stopService = stopService ?? StopService(),
       _trackingService = trackingService ?? TrackingService(),
       _driverService = driverService ?? DriverService();

  // State
  List<Bus> _nearbyBuses = [];
  Bus? _selectedBus;
  Map<String, int> _estimatedArrival = {}; // Map stop ID to minutes
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Bus> get nearbyBuses => _nearbyBuses;
  Bus? get selectedBus => _selectedBus;
  Map<String, int> get estimatedArrival => _estimatedArrival;
  List<dynamic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadNotificationCount => 3; // Mock - should return actual unread count

  // Search for lines
  Future<void> searchLines({String? query, String? stopId}) async {
    _setLoading(true);

    try {
      final queryParams = LineQueryParameters(
        isActive: true,
        stopId: stopId,
        name: query,
      );

      final response = await _lineService.getLines(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        _searchResults = response.data!.results.cast<dynamic>();
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to search lines');
      }

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Track a specific bus
  Future<void> trackBus(String busId) async {
    _setLoading(true);

    try {
      // Get bus details
      final response = await _busService.getBusById(busId);

      if (response.isSuccess && response.data != null) {
        _selectedBus = response.data!;
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to get bus details');
      }

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Fetch nearby buses
  Future<void> fetchNearbyBuses({
    required double latitude,
    required double longitude,
    double radius = 1000, // default 1km
  }) async {
    _setLoading(true);

    try {
      // Simplified implementation - get active buses for now
      // TODO: Implement proper nearby logic with proper API calls
      final queryParams = BusQueryParameters(isActive: true);

      final response = await _busService.getBuses(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        _nearbyBuses = response.data!.results;
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch nearby buses');
      }

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Calculate estimated arrival time
  Future<void> calculateEta({
    required String busId,
    required String stopId,
  }) async {
    try {
      final response = await _trackingService.estimateArrival(busId, stopId);

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        if (data.containsKey('estimated_minutes')) {
          final minutes =
              int.tryParse(data['estimated_minutes'].toString()) ?? 0;
          _estimatedArrival[stopId] = minutes;
          notifyListeners();
        }
      }
    } catch (e) {
      _setError(e);
    }
  }

  // Rate a driver
  Future<bool> rateDriver({
    required String driverId,
    required int rating,
    String? comment,
  }) async {
    try {
      final request = DriverRatingCreateRequest(
        rating: Rating.values[rating - 1],
        comment: comment,
      );

      final response = await _driverService.rateDriver(driverId, request);

      if (response.isSuccess) {
        return true;
      } else {
        _setError(response.message ?? 'Failed to rate driver');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Report waiting passengers
  Future<bool> reportWaitingPassengers({
    required String stopId,
    required int count,
    String? lineId,
  }) async {
    try {
      final request = WaitingPassengersReportRequest(
        count: count,
        lineId: lineId,
      );

      // TODO: Fix service method signature
      // final response = await _stopService.reportWaitingPassengers(stopId, request);
      print('TODO: Implement reportWaitingPassengers');
      final response = ApiResponse.success(data: true);

      if (response.isSuccess) {
        return true;
      } else {
        _setError(response.message ?? 'Failed to report waiting passengers');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Clear selection
  void clearSelectedBus() {
    _selectedBus = null;
    notifyListeners();
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

  void _clearError() {
    _error = null;
  }

  /// Load nearby buses for passenger home screen
  Future<void> loadNearbyBuses() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual nearby bus loading
      await Future.delayed(const Duration(seconds: 1));
      // For now, just clear error and set loading false
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load nearby stops for passenger home screen
  Future<void> loadNearbyStops() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual nearby stops loading
      await Future.delayed(const Duration(seconds: 1));
      // For now, just clear error and set loading false
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get nearby stops getter
  List<dynamic> get nearbyStops => []; // Mock implementation

  /// Recent searches for search suggestions
  List<String> get recentSearches => []; // Mock implementation

  /// Load recent search history  
  Future<void> loadRecentSearches() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual recent searches loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Trip history for history tab
  List<dynamic> get tripHistory => []; // Mock implementation


  /// Add a recent search
  void addRecentSearch(String search) {
    // Mock implementation - add to recent searches
  }

  /// Remove a recent search
  void removeRecentSearch(String search) {
    // Mock implementation - remove from recent searches
  }

  /// Search for buses and stops
  Future<void> searchBusesAndStops(String query) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual search
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load trip history for passenger
  Future<void> loadTripHistory({
    String period = 'all',
    String? status,
    String sortBy = 'date_desc',
  }) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual trip history loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get recent trips
  List<Trip> get recentTrips => []; // Mock - should return actual recent trips

  /// Get completed trips
  List<Trip> get completedTrips => []; // Mock - should return actual completed trips
  
  /// Get filtered trips based on current filter settings
  List<Trip> get filteredTrips => []; // Mock - should return filtered trips

  /// Get cancelled trips
  List<Trip> get cancelledTrips => []; // Mock - should return actual cancelled trips

  /// Get trip statistics
  Map<String, dynamic> get tripStats => {
    'totalTrips': 0,
    'totalDistance': 0.0,
    'totalTime': 0,
    'totalAmount': 0.0,
    'averageRating': 0.0,
  }; // Mock - should return actual trip statistics
  
  /// Submit driver rating
  Future<void> submitDriverRating({
    required String driverId,
    required double rating,
    String? comment,
    List<String>? tags,
  }) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual rating submission
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }


  /// Load favorite lines for the passenger
  Future<void> loadFavoriteLines() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual favorite lines loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Remove a line from favorites
  Future<void> removeFavoriteLine(String lineId) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual favorite line removal
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }


  /// Get favorite lines
  List<Line> get favoriteLines => []; // Mock - should return actual favorite lines

  /// Add line to favorites
  Future<void> addFavoriteLine(String lineId) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual favorite line addition
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }


  /// Load recent trips for passenger
  Future<void> loadRecentTrips() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual recent trips loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
}
