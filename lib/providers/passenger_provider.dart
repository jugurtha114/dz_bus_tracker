// lib/providers/passenger_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/api_response_models.dart';
import '../models/bus_model.dart';
import '../models/line_model.dart';
import '../models/stop_model.dart';
import '../models/driver_model.dart';
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
  })
      : _busService = busService ?? BusService(),
        _lineService = lineService ?? LineService(),
        _stopService = stopService ?? StopService(),
        _trackingService = trackingService ?? TrackingService(),
        _driverService = driverService ?? DriverService();

  // State
  List<Bus> _nearbyBuses = [];
  Bus? _selectedBus;
  Map<String, int> _estimatedArrival = {}; // Map stop ID to minutes
  List<Line> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Bus> get nearbyBuses => _nearbyBuses;
  Bus? get selectedBus => _selectedBus;
  Map<String, int> get estimatedArrival => _estimatedArrival;
  List<Line> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Search for lines
  Future<void> searchLines({
    String? query,
    String? stopId,
  }) async {
    _setLoading(true);

    try {
      final queryParams = LineQueryParameters(
        isActive: true,
        stopId: stopId,
        name: query,
      );
      
      final response = await _lineService.getLines(queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        _searchResults = response.data!.results;
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
      final queryParams = BusQueryParameters(
        isActive: true,
      );
      
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
      final response = await _trackingService.estimateArrival(
        busId: busId,
        stopId: stopId,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        if (data.containsKey('estimated_minutes')) {
          final minutes = int.tryParse(data['estimated_minutes'].toString()) ?? 0;
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
}