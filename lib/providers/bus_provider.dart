// lib/providers/bus_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/bus_service.dart';

class BusProvider with ChangeNotifier {
  final BusService _busService;

  BusProvider({BusService? busService})
      : _busService = busService ?? BusService();

  // State
  List<Map<String, dynamic>> _buses = [];
  Map<String, dynamic>? _selectedBus;
  List<Map<String, dynamic>> _busLocations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get buses => _buses;
  Map<String, dynamic>? get selectedBus => _selectedBus;
  List<Map<String, dynamic>> get busLocations => _busLocations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch buses
  Future<void> fetchBuses({
    bool? isActive,
    bool? isApproved,
    String? driverId,
  }) async {
    _setLoading(true);

    try {
      _buses = await _busService.getBuses(
        isActive: isActive,
        isApproved: isApproved,
        driverId: driverId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Fetch bus by ID
  Future<void> fetchBusById(String busId) async {
    _setLoading(true);

    try {
      final bus = await _busService.getBusById(busId);
      _selectedBus = bus;

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Select bus
  void selectBus(Map<String, dynamic> bus) {
    _selectedBus = bus;
    notifyListeners();
  }

  // Clear selected bus
  void clearSelectedBus() {
    _selectedBus = null;
    notifyListeners();
  }

  // Track bus (get locations)
  Future<void> trackBus(String busId) async {
    _setLoading(true);

    try {
      _busLocations = await _busService.getBusLocations(
        busId: busId,
        isTrackingActive: true,
      );

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Update bus location
  Future<void> updateLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
    int? passengerCount,
  }) async {
    try {
      await _busService.updateLocation(
        busId: busId,
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        speed: speed,
        heading: heading,
        accuracy: accuracy,
        passengerCount: passengerCount,
      );

      // Update bus locations list if the bus is being tracked
      if (_selectedBus != null && _selectedBus!['id'] == busId) {
        await trackBus(busId);
      }
    } catch (e) {
      _setError(e);
    }
  }

  // Update passenger count
  Future<void> updatePassengerCount({
    required String busId,
    required int count,
  }) async {
    try {
      await _busService.updatePassengerCount(
        busId: busId,
        count: count,
      );

      // Update selected bus if it's the same bus
      if (_selectedBus != null && _selectedBus!['id'] == busId) {
        await fetchBusById(busId);
      }
    } catch (e) {
      _setError(e);
    }
  }

  // Register new bus
  Future<bool> registerBus({
    required String licensePlate,
    required String driverId,
    required String model,
    required String manufacturer,
    required int year,
    required int capacity,
    required bool isAirConditioned,
  }) async {
    _setLoading(true);

    try {
      final newBus = await _busService.registerBus(
        licensePlate: licensePlate,
        driverId: driverId,
        model: model,
        manufacturer: manufacturer,
        year: year,
        capacity: capacity,
        isAirConditioned: isAirConditioned,
      );

      // Add to buses list
      _buses.add(newBus);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update bus details
  Future<bool> updateBus({
    required String busId,
    String? licensePlate,
    String? model,
    String? manufacturer,
    int? year,
    int? capacity,
    bool? isAirConditioned,
    String? status,
    String lineId='jugu_line_id_please_update', // todo add lineID
  }) async {
    _setLoading(true);

    try {
      final updatedBus = await _busService.updateBus(
        busId: busId,
        licensePlate: licensePlate,
        model: model,
        manufacturer: manufacturer,
        year: year,
        capacity: capacity,
        isAirConditioned: isAirConditioned,
        status: status,
      );

      // Update buses list
      final index = _buses.indexWhere((bus) => bus['id'] == busId);
      if (index != -1) {
        _buses[index] = updatedBus;
      }

      // Update selected bus if it's the same bus
      if (_selectedBus != null && _selectedBus!['id'] == busId) {
        _selectedBus = updatedBus;
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