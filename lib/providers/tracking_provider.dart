// lib/providers/tracking_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/tracking_model.dart';
import '../models/api_response_models.dart';
import '../services/tracking_service.dart';

class TrackingProvider extends ChangeNotifier {
  final TrackingService _trackingService;

  TrackingProvider({TrackingService? trackingService})
      : _trackingService = trackingService ?? TrackingService();

  // State variables
  bool _isLoading = false;
  String? _error;

  // Anomalies state
  List<Anomaly> _anomalies = [];
  List<Anomaly> _unresolvedAnomalies = [];
  Anomaly? _selectedAnomaly;

  // Trips state
  List<Trip> _trips = [];
  Trip? _activeTrip;
  Trip? _selectedTrip;
  Map<String, dynamic>? _tripStatistics;

  // Location tracking state
  List<LocationUpdate> _locationUpdates = [];
  LocationUpdate? _currentLocation;
  Map<String, LocationUpdate> _busLocations = {};

  // Bus-line assignments state
  List<BusLine> _busLines = [];
  List<BusLine> _activeBusLines = [];
  BusLine? _selectedBusLine;

  // Active tracking state
  List<Map<String, dynamic>> _activeBuses = [];
  bool _isTrackingActive = false;

  // Route and visualization state
  Map<String, dynamic>? _routeData;
  List<Map<String, dynamic>> _routeArrivals = [];
  Map<String, dynamic>? _routeVisualization;

  // Pagination state
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  int _totalCount = 0;

  // Auto-refresh state
  Timer? _refreshTimer;
  bool _autoRefreshEnabled = false;
  Duration _refreshInterval = const Duration(seconds: 30);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Anomalies getters
  List<Anomaly> get anomalies => _anomalies;
  List<Anomaly> get unresolvedAnomalies => _unresolvedAnomalies;
  Anomaly? get selectedAnomaly => _selectedAnomaly;

  // Trips getters
  List<Trip> get trips => _trips;
  Trip? get activeTrip => _activeTrip;
  Trip? get selectedTrip => _selectedTrip;
  Map<String, dynamic>? get tripStatistics => _tripStatistics;

  // Location tracking getters
  List<LocationUpdate> get locationUpdates => _locationUpdates;
  LocationUpdate? get currentLocation => _currentLocation;
  Map<String, LocationUpdate> get busLocations => _busLocations;

  // Bus-line assignments getters
  List<BusLine> get busLines => _busLines;
  List<BusLine> get activeBusLines => _activeBusLines;
  BusLine? get selectedBusLine => _selectedBusLine;

  // Active tracking getters
  List<Map<String, dynamic>> get activeBuses => _activeBuses;
  bool get isTrackingActive => _isTrackingActive;

  // Route and visualization getters
  Map<String, dynamic>? get routeData => _routeData;
  List<Map<String, dynamic>> get routeArrivals => _routeArrivals;
  Map<String, dynamic>? get routeVisualization => _routeVisualization;

  // Pagination getters
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get totalCount => _totalCount;
  bool get hasMorePages => _hasNextPage;

  // Auto-refresh getters
  bool get autoRefreshEnabled => _autoRefreshEnabled;
  Duration get refreshInterval => _refreshInterval;

  // Helper getters
  bool get hasError => _error != null;
  bool get hasData => _anomalies.isNotEmpty || _trips.isNotEmpty;
  int get unresolvedAnomaliesCount => _unresolvedAnomalies.length;
  int get activeTripsCount => _trips.where((trip) => !trip.isCompleted).length;

  // Convenience getters for driver home screen compatibility
  bool get isTracking => _isTrackingActive;
  Trip? get currentTrip => _activeTrip;

  // Add missing methods for driver screens
  Future<bool> updatePassengers({
    required String busId,
    required int count,
  }) async {
    try {
      final response = await _trackingService.updatePassengerCount(
        busId: busId,
        count: count,
      );
      
      if (response.isSuccess) {
        // Update local state if tracking is active for this bus
        if (_activeTrip?.busId == busId) {
          _activeTrip = _activeTrip?.copyWith(maxPassengers: count);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to update passengers: $e');
      return false;
    }
  }

  Future<bool> reportAnomaly({
    required String busId,
    required String type,
    required String description,
    required String severity,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final request = AnomalyCreateRequest(
        type: AnomalyType.fromValue(type),
        description: description,
        severity: AnomalySeverity.fromValue(severity),
        locationLatitude: latitude,
        locationLongitude: longitude,
      );
      
      return await createAnomaly(request);
    } catch (e) {
      debugPrint('Failed to report anomaly: $e');
      return false;
    }
  }

  Future<bool> sendLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    try {
      final request = LocationUpdateCreateRequest(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        speed: speed,
        heading: heading,
      );
      
      return await createLocationUpdate(request);
    } catch (e) {
      debugPrint('Failed to send location: $e');
      return false;
    }
  }

  // Anomaly management methods

  /// Load anomalies with optional filtering
  Future<void> loadAnomalies({
    AnomalyQueryParameters? queryParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.getAnomalies(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        if (append) {
          _anomalies.addAll(response.data!.results);
        } else {
          _anomalies = response.data!.results;
        }
        _updatePaginationState(response.data!);
      } else {
        _setError(response.message ?? 'Failed to load anomalies');
      }
    } catch (e) {
      _setError('Failed to load anomalies: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load unresolved anomalies
  Future<void> loadUnresolvedAnomalies({int limit = 50}) async {
    try {
      final response = await _trackingService.getUnresolvedAnomalies(limit: limit);

      if (response.isSuccess && response.data != null) {
        _unresolvedAnomalies = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load unresolved anomalies: $e');
    }
  }

  /// Get anomaly by ID
  Future<void> getAnomalyById(String anomalyId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.getAnomalyById(anomalyId);

      if (response.isSuccess && response.data != null) {
        _selectedAnomaly = response.data!;
      } else {
        _setError(response.message ?? 'Failed to get anomaly details');
      }
    } catch (e) {
      _setError('Failed to get anomaly details: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new anomaly
  Future<bool> createAnomaly(AnomalyCreateRequest request) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.createAnomaly(request);

      if (response.isSuccess && response.data != null) {
        _anomalies.insert(0, response.data!);
        _unresolvedAnomalies.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create anomaly');
        return false;
      }
    } catch (e) {
      _setError('Failed to create anomaly: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resolve anomaly
  Future<bool> resolveAnomaly(String anomalyId, {String? resolutionNotes}) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.resolveAnomaly(anomalyId, resolutionNotes: resolutionNotes);

      if (response.isSuccess && response.data != null) {
        final resolvedAnomaly = response.data!;
        
        // Update in anomalies list
        final index = _anomalies.indexWhere((a) => a.id == anomalyId);
        if (index != -1) {
          _anomalies[index] = resolvedAnomaly;
        }

        // Remove from unresolved list
        _unresolvedAnomalies.removeWhere((a) => a.id == anomalyId);

        // Update selected anomaly if it's the same
        if (_selectedAnomaly?.id == anomalyId) {
          _selectedAnomaly = resolvedAnomaly;
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to resolve anomaly');
        return false;
      }
    } catch (e) {
      _setError('Failed to resolve anomaly: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Trip management methods

  /// Load trips with optional filtering
  Future<void> loadTrips({
    TripQueryParameters? queryParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.getTrips(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        if (append) {
          _trips.addAll(response.data!.results);
        } else {
          _trips = response.data!.results;
        }
        _updatePaginationState(response.data!);
      } else {
        _setError(response.message ?? 'Failed to load trips');
      }
    } catch (e) {
      _setError('Failed to load trips: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get trip by ID
  Future<void> getTripById(String tripId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.getTripById(tripId);

      if (response.isSuccess && response.data != null) {
        _selectedTrip = response.data!;
      } else {
        _setError(response.message ?? 'Failed to get trip details');
      }
    } catch (e) {
      _setError('Failed to get trip details: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new trip
  Future<bool> createTrip(TripCreateRequest request) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.createTrip(request);

      if (response.isSuccess && response.data != null) {
        _trips.insert(0, response.data!);
        _activeTrip = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create trip');
        return false;
      }
    } catch (e) {
      _setError('Failed to create trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// End trip
  Future<bool> endTrip(String tripId, {String? endStopId, String? notes}) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.endTrip(tripId, endStopId: endStopId, notes: notes);

      if (response.isSuccess && response.data != null) {
        final endedTrip = response.data!;
        
        // Update in trips list
        final index = _trips.indexWhere((t) => t.id == tripId);
        if (index != -1) {
          _trips[index] = endedTrip;
        }

        // Clear active trip if it's the same
        if (_activeTrip?.id == tripId) {
          _activeTrip = null;
        }

        // Update selected trip if it's the same
        if (_selectedTrip?.id == tripId) {
          _selectedTrip = endedTrip;
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to end trip');
        return false;
      }
    } catch (e) {
      _setError('Failed to end trip: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  /// Get trip statistics
  Future<void> getTripStatistics(String tripId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.getTripStatistics(tripId);

      if (response.isSuccess && response.data != null) {
        _tripStatistics = response.data!;
      } else {
        _setError(response.message ?? 'Failed to get trip statistics');
      }
    } catch (e) {
      _setError('Failed to get trip statistics: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Location tracking methods

  /// Load location updates
  Future<void> loadLocationUpdates({
    LocationUpdateQueryParameters? queryParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.getLocationUpdates(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        if (append) {
          _locationUpdates.addAll(response.data!.results);
        } else {
          _locationUpdates = response.data!.results;
        }
        _updatePaginationState(response.data!);
      } else {
        _setError(response.message ?? 'Failed to load location updates');
      }
    } catch (e) {
      _setError('Failed to load location updates: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create location update
  Future<bool> createLocationUpdate(LocationUpdateCreateRequest request) async {
    try {
      final response = await _trackingService.createLocationUpdate(request);

      if (response.isSuccess && response.data != null) {
        _locationUpdates.insert(0, response.data!);
        _currentLocation = response.data!;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Failed to create location update: $e');
    }
    return false;
  }

  /// Get current location for a bus
  Future<void> getCurrentBusLocation(String busId) async {
    try {
      final response = await _trackingService.getCurrentBusLocation(busId);

      if (response.isSuccess && response.data != null) {
        _busLocations[busId] = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to get current bus location: $e');
    }
  }

  /// Estimate arrival time
  Future<Map<String, dynamic>?> estimateArrival({
    required String busId,
    required String stopId,
  }) async {
    try {
      final response = await _trackingService.estimateArrival(busId: busId, stopId: stopId);

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      debugPrint('Failed to estimate arrival: $e');
    }
    return null;
  }

  // Bus-line assignment methods

  /// Load bus-line assignments
  Future<void> loadBusLines({
    BusLineQueryParameters? queryParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.getBusLines(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        if (append) {
          _busLines.addAll(response.data!.results);
        } else {
          _busLines = response.data!.results;
        }
        
        // Update active bus lines
        _activeBusLines = _busLines.where((bl) => bl.isActive).toList();
        
        _updatePaginationState(response.data!);
      } else {
        _setError(response.message ?? 'Failed to load bus-line assignments');
      }
    } catch (e) {
      _setError('Failed to load bus-line assignments: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create bus-line assignment
  Future<bool> createBusLine(BusLineCreateRequest request) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.createBusLine(request);

      if (response.isSuccess && response.data != null) {
        _busLines.insert(0, response.data!);
        if (response.data!.isActive) {
          _activeBusLines.insert(0, response.data!);
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create bus-line assignment');
        return false;
      }
    } catch (e) {
      _setError('Failed to create bus-line assignment: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Start tracking for bus-line assignment
  Future<bool> startTracking(String busLineId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.startTracking(busLineId);

      if (response.isSuccess && response.data != null) {
        final updatedBusLine = response.data!;
        
        // Update in bus lines list
        final index = _busLines.indexWhere((bl) => bl.id == busLineId);
        if (index != -1) {
          _busLines[index] = updatedBusLine;
        }

        // Update in active bus lines list
        final activeIndex = _activeBusLines.indexWhere((bl) => bl.id == busLineId);
        if (activeIndex != -1) {
          _activeBusLines[activeIndex] = updatedBusLine;
        } else if (updatedBusLine.isActive) {
          _activeBusLines.add(updatedBusLine);
        }

        // Update selected bus line if it's the same
        if (_selectedBusLine?.id == busLineId) {
          _selectedBusLine = updatedBusLine;
        }

        _isTrackingActive = true;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to start tracking');
        return false;
      }
    } catch (e) {
      _setError('Failed to start tracking: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Stop tracking for bus-line assignment
  Future<bool> stopTracking(String busLineId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.stopTracking(busLineId);

      if (response.isSuccess && response.data != null) {
        final updatedBusLine = response.data!;
        
        // Update in bus lines list
        final index = _busLines.indexWhere((bl) => bl.id == busLineId);
        if (index != -1) {
          _busLines[index] = updatedBusLine;
        }

        // Update in active bus lines list
        final activeIndex = _activeBusLines.indexWhere((bl) => bl.id == busLineId);
        if (activeIndex != -1) {
          _activeBusLines[activeIndex] = updatedBusLine;
        }

        // Update selected bus line if it's the same
        if (_selectedBusLine?.id == busLineId) {
          _selectedBusLine = updatedBusLine;
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to stop tracking');
        return false;
      }
    } catch (e) {
      _setError('Failed to stop tracking: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Active tracking methods

  /// Load active buses
  Future<void> loadActiveBuses() async {
    try {
      final response = await _trackingService.getActiveBuses();

      if (response.isSuccess && response.data != null) {
        _activeBuses = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load active buses: $e');
    }
  }

  /// Start bus tracking
  Future<bool> startBusTracking(String busId) async {
    try {
      final response = await _trackingService.startBusTracking(busId);
      return response.isSuccess;
    } catch (e) {
      debugPrint('Failed to start bus tracking: $e');
      return false;
    }
  }

  /// Stop bus tracking
  Future<bool> stopBusTracking(String busId) async {
    try {
      final response = await _trackingService.stopBusTracking(busId);
      return response.isSuccess;
    } catch (e) {
      debugPrint('Failed to stop bus tracking: $e');
      return false;
    }
  }

  // Route and visualization methods

  /// Get bus route
  Future<void> getBusRoute({required String busId, String? lineId}) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _trackingService.getBusRoute(busId: busId, lineId: lineId);

      if (response.isSuccess && response.data != null) {
        _routeData = response.data!;
      } else {
        _setError(response.message ?? 'Failed to get bus route');
      }
    } catch (e) {
      _setError('Failed to get bus route: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get route arrivals
  Future<void> getRouteArrivals({String? lineId, String? stopId}) async {
    try {
      final response = await _trackingService.getRouteArrivals(lineId: lineId, stopId: stopId);

      if (response.isSuccess && response.data != null) {
        _routeArrivals = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to get route arrivals: $e');
    }
  }

  /// Track user location
  Future<Map<String, dynamic>?> trackMe({
    required double latitude,
    required double longitude,
    String? lineId,
  }) async {
    try {
      final response = await _trackingService.trackMe(
        latitude: latitude,
        longitude: longitude,
        lineId: lineId,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      debugPrint('Failed to track location: $e');
    }
    return null;
  }

  /// Get route visualization
  Future<void> getRouteVisualization({String? lineId, String? busId}) async {
    try {
      final response = await _trackingService.getRouteVisualization(lineId: lineId, busId: busId);

      if (response.isSuccess && response.data != null) {
        _routeVisualization = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to get route visualization: $e');
    }
  }

  // Helper methods for bus management

  /// Get active trip for a bus
  Future<void> getActiveTripForBus(String busId) async {
    try {
      final response = await _trackingService.getActiveTripForBus(busId);

      if (response.isSuccess && response.data != null) {
        _activeTrip = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to get active trip for bus: $e');
    }
  }

  /// Get recent anomalies for a bus
  Future<List<Anomaly>> getRecentAnomaliesForBus(String busId, {int limit = 10}) async {
    try {
      final response = await _trackingService.getRecentAnomaliesForBus(busId, limit: limit);

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      debugPrint('Failed to get recent anomalies for bus: $e');
    }
    return [];
  }

  // Auto-refresh methods

  /// Start auto-refresh for real-time updates
  void startAutoRefresh() {
    if (_refreshTimer?.isActive == true) return;

    _autoRefreshEnabled = true;
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _performAutoRefresh();
    });
    notifyListeners();
  }

  /// Stop auto-refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _autoRefreshEnabled = false;
    notifyListeners();
  }

  /// Set refresh interval
  void setRefreshInterval(Duration interval) {
    _refreshInterval = interval;
    if (_autoRefreshEnabled) {
      stopAutoRefresh();
      startAutoRefresh();
    }
  }

  /// Perform auto-refresh
  Future<void> _performAutoRefresh() async {
    try {
      // Refresh active buses
      await loadActiveBuses();
      
      // Refresh unresolved anomalies
      await loadUnresolvedAnomalies();
      
      // Refresh active bus lines
      if (_activeBusLines.isNotEmpty) {
        await loadBusLines(queryParams: BusLineQueryParameters(isActive: true));
      }
    } catch (e) {
      debugPrint('Auto-refresh failed: $e');
    }
  }

  // Utility methods

  /// Clear error
  void clearError() {
    _clearError();
  }

  /// Clear all data
  void clearData() {
    _anomalies.clear();
    _unresolvedAnomalies.clear();
    _trips.clear();
    _locationUpdates.clear();
    _busLines.clear();
    _activeBusLines.clear();
    _activeBuses.clear();
    _busLocations.clear();
    _selectedAnomaly = null;
    _selectedTrip = null;
    _selectedBusLine = null;
    _activeTrip = null;
    _currentLocation = null;
    _tripStatistics = null;
    _routeData = null;
    _routeArrivals.clear();
    _routeVisualization = null;
    _currentPage = 1;
    _hasNextPage = false;
    _hasPreviousPage = false;
    _totalCount = 0;
    notifyListeners();
  }

  /// Set selected anomaly
  void setSelectedAnomaly(Anomaly? anomaly) {
    _selectedAnomaly = anomaly;
    notifyListeners();
  }

  /// Set selected trip
  void setSelectedTrip(Trip? trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  /// Set selected bus line
  void setSelectedBusLine(BusLine? busLine) {
    _selectedBusLine = busLine;
    notifyListeners();
  }

  // Pagination methods

  /// Load more bus lines (for pagination)
  Future<void> loadMoreBusLines() async {
    if (!_hasNextPage || _isLoading) return;

    _currentPage++;
    await loadBusLines(
      queryParams: BusLineQueryParameters(page: _currentPage),
      append: true,
    );
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (!_hasNextPage || _isLoading) return;

    _currentPage++;
    await loadAnomalies(
      queryParams: AnomalyQueryParameters(page: _currentPage),
      append: true,
    );
  }

  /// Load previous page
  Future<void> loadPreviousPage() async {
    if (!_hasPreviousPage || _isLoading || _currentPage <= 1) return;

    _currentPage--;
    await loadAnomalies(
      queryParams: AnomalyQueryParameters(page: _currentPage),
    );
  }

  /// Reset pagination
  void resetPagination() {
    _currentPage = 1;
    _hasNextPage = false;
    _hasPreviousPage = false;
    _totalCount = 0;
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _updatePaginationState<T>(PaginatedResponse<T> response) {
    _totalCount = response.count;
    _hasNextPage = response.hasNextPage;
    _hasPreviousPage = response.hasPreviousPage;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}