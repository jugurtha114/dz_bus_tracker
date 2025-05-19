// lib/providers/passenger_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
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
  List<Map<String, dynamic>> _nearbyBuses = [];
  Map<String, dynamic>? _selectedBus;
  Map<String, int> _estimatedArrival = {}; // Map stop ID to minutes
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get nearbyBuses => _nearbyBuses;
  Map<String, dynamic>? get selectedBus => _selectedBus;
  Map<String, int> get estimatedArrival => _estimatedArrival;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Search for lines
  Future<void> searchLines({
    String? query,
    String? stopId,
  }) async {
    _setLoading(true);

    try {
      final lines = await _lineService.getLines(
        isActive: true,
        stopId: stopId,
      );

      // Filter by query if provided
      if (query != null && query.isNotEmpty) {
        _searchResults = lines.where((line) {
          final name = line['name']?.toString().toLowerCase() ?? '';
          final code = line['code']?.toString().toLowerCase() ?? '';
          final description = line['description']?.toString().toLowerCase() ?? '';

          return name.contains(query.toLowerCase()) ||
              code.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase());
        }).toList();
      } else {
        _searchResults = lines;
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
      final bus = await _busService.getBusById(busId);
      _selectedBus = bus;

      // Get bus locations
      final locations = await _busService.getBusLocations(
        busId: busId,
        isTrackingActive: true,
      );

      if (locations.isNotEmpty) {
        // Update bus with latest location
        _selectedBus!['current_location'] = locations.first;
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
      // First get nearby stops
      final nearbyStops = await _stopService.getNearbyStops(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      // Then get buses for all nearby stops
      final allBuses = <Map<String, dynamic>>[];

      for (final stop in nearbyStops) {
        // Get lines that pass through this stop
        final lines = await _lineService.getLines(
          isActive: true,
          stopId: stop['id'],
        );

        for (final line in lines) {
          // Get buses tracking this line
          final busLocations = await _busService.getBusLocations(
            isTrackingActive: true,
          );

          for (final location in busLocations) {
            if (location['line'] == line['id']) {
              // Get the bus details
              final bus = await _busService.getBusById(location['bus']);

              // Add location to bus
              bus['current_location'] = location;

              // Add line info to bus
              bus['line'] = line;

              // Add to list if not already there
              if (!allBuses.any((b) => b['id'] == bus['id'])) {
                allBuses.add(bus);
              }
            }
          }
        }
      }

      _nearbyBuses = allBuses;
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
      final response = await _trackingService.estimateArrivalTime(
        busId: busId,
        stopId: stopId,
      );

      if (response.containsKey('estimated_minutes')) {
        final minutes = int.tryParse(response['estimated_minutes'].toString()) ?? 0;
        _estimatedArrival[stopId] = minutes;
        notifyListeners();
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
      await _driverService.rateDriver(
        driverId: driverId,
        rating: rating,
        comment: comment,
      );

      return true;
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
}