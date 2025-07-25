// lib/providers/bus_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/bus_service.dart';
import '../models/bus_model.dart';
import '../models/api_response_models.dart';

class BusProvider with ChangeNotifier {
  final BusService _busService;

  BusProvider({BusService? busService})
      : _busService = busService ?? BusService();

  // State
  List<Bus> _buses = [];
  Bus? _selectedBus;
  List<BusLocation> _busLocations = [];
  bool _isLoading = false;
  String? _error;
  PaginatedResponse<Bus>? _busesResponse;
  PaginatedResponse<BusLocation>? _locationsResponse;

  // Getters
  List<Bus> get buses => _buses;
  Bus? get selectedBus => _selectedBus;
  List<BusLocation> get busLocations => _busLocations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaginatedResponse<Bus>? get busesResponse => _busesResponse;
  PaginatedResponse<BusLocation>? get locationsResponse => _locationsResponse;
  
  // Helper getters
  bool get hasMoreBuses => _busesResponse?.hasNextPage ?? false;
  bool get hasMoreLocations => _locationsResponse?.hasNextPage ?? false;

  // Fetch buses
  Future<void> fetchBuses({
    BusQueryParameters? queryParams,
    bool append = false,
  }) async {
    _setLoading(true);

    try {
      final response = await _busService.getBuses(queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        _busesResponse = response.data!;
        if (append) {
          _buses.addAll(response.data!.results);
        } else {
          _buses = response.data!.results;
        }
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch buses');
      }
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
      final response = await _busService.getBusById(busId);
      
      if (response.isSuccess && response.data != null) {
        _selectedBus = response.data!;
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch bus details');
      }
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Select bus
  void selectBus(Bus bus) {
    _selectedBus = bus;
    notifyListeners();
  }

  // Clear selected bus
  void clearSelectedBus() {
    _selectedBus = null;
    notifyListeners();
  }

  // Track bus (get locations)
  Future<void> trackBus(String busId, {bool append = false}) async {
    _setLoading(true);

    try {
      final queryParams = BusLocationQueryParameters(
        busId: busId,
        isTrackingActive: true,
      );
      
      final response = await _busService.getBusLocations(queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        _locationsResponse = response.data!;
        if (append) {
          _busLocations.addAll(response.data!.results);
        } else {
          _busLocations = response.data!.results;
        }
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to track bus');
      }
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Update bus location
  Future<bool> updateLocation(String busId, BusLocationUpdateRequest request) async {
    try {
      final response = await _busService.updateLocation(busId, request);
      
      if (response.isSuccess) {
        // Update bus locations list if the bus is being tracked
        if (_selectedBus != null && _selectedBus!.id == busId) {
          await trackBus(busId);
        }
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update location');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Update passenger count
  Future<bool> updatePassengerCount(String busId, PassengerCountUpdateRequest request) async {
    try {
      final response = await _busService.updatePassengerCount(busId, request);
      
      if (response.isSuccess) {
        // Update selected bus if it's the same bus
        if (_selectedBus != null && _selectedBus!.id == busId) {
          await fetchBusById(busId);
        }
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update passenger count');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Register new bus
  Future<bool> registerBus(BusCreateRequest request) async {
    _setLoading(true);

    try {
      final response = await _busService.registerBus(request);
      
      if (response.isSuccess && response.data != null) {
        // Add to buses list
        _buses.add(response.data!);
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to register bus');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update bus details  
  Future<bool> updateBus(String busId, BusUpdateRequest request) async {
    _setLoading(true);

    try {
      final response = await _busService.updateBus(busId, request);
      
      if (response.isSuccess && response.data != null) {
        final updatedBus = response.data!;
        
        // Update buses list
        final index = _buses.indexWhere((bus) => bus.id == busId);
        if (index != -1) {
          _buses[index] = updatedBus;
        }

        // Update selected bus if it's the same bus
        if (_selectedBus != null && _selectedBus!.id == busId) {
          _selectedBus = updatedBus;
        }

        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update bus');
        return false;
      }
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
  
  void _clearError() {
    _error = null;
  }

  // Bus activation methods
  Future<bool> activateBus(String busId) async {
    try {
      final response = await _busService.activateBus(busId);
      
      if (response.isSuccess && response.data != null) {
        _updateBusInList(response.data!);
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to activate bus');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> deactivateBus(String busId) async {
    try {
      final response = await _busService.deactivateBus(busId);
      
      if (response.isSuccess && response.data != null) {
        _updateBusInList(response.data!);
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to deactivate bus');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Bus tracking methods
  Future<bool> startTracking(String busId) async {
    try {
      final response = await _busService.startTracking(busId);
      
      if (response.isSuccess) {
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to start tracking');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> stopTracking(String busId) async {
    try {
      final response = await _busService.stopTracking(busId);
      
      if (response.isSuccess) {
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to stop tracking');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Bus approval method
  Future<bool> approveBus(String busId, BusApprovalRequest request) async {
    try {
      final response = await _busService.approveBus(busId, request);
      
      if (response.isSuccess && response.data != null) {
        _updateBusInList(response.data!);
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to process bus approval');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Helper method to update bus in the list
  void _updateBusInList(Bus updatedBus) {
    final index = _buses.indexWhere((bus) => bus.id == updatedBus.id);
    if (index != -1) {
      _buses[index] = updatedBus;
    }
    
    // Update selected bus if it's the same bus
    if (_selectedBus != null && _selectedBus!.id == updatedBus.id) {
      _selectedBus = updatedBus;
    }
    
    notifyListeners();
  }

  // Load more buses for pagination
  Future<void> loadMoreBuses() async {
    if (!hasMoreBuses || _isLoading) return;
    
    // Extract next page parameters from the next URL if needed
    // For now, we'll implement basic pagination
    await fetchBuses(append: true);
  }

  // Load more locations for pagination
  Future<void> loadMoreLocations(String busId) async {
    if (!hasMoreLocations || _isLoading) return;
    
    await trackBus(busId, append: true);
  }
}