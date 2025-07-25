// lib/providers/driver_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/driver_model.dart';
// import '../models/schedule_model.dart'; // TODO: Create schedule model
import '../models/tracking_model.dart';
import '../models/bus_model.dart';
import '../models/api_response_models.dart' hide DriverRatingQueryParameters;
import '../models/api_response_models.dart' show PaginatedResponse, ApiResponse;
import '../services/driver_service.dart';
import '../services/schedule_service.dart';
import '../services/tracking_service.dart';

class DriverProvider with ChangeNotifier {
  final DriverService _driverService;
  final ScheduleService _scheduleService;
  final TrackingService _trackingService;

  DriverProvider({
    DriverService? driverService,
    ScheduleService? scheduleService,
    TrackingService? trackingService,
  })  : _driverService = driverService ?? DriverService(),
        _scheduleService = scheduleService ?? ScheduleService(),
        _trackingService = trackingService ?? TrackingService();

  // State
  Driver? _driverProfile;
  List<DriverRating> _ratings = [];
  PaginatedResponse<DriverRating>? _ratingsResponse;
  List<Map<String, dynamic>> _schedules = []; // TODO: Replace with Schedule model
  List<Trip> _trips = [];
  PaginatedResponse<Trip>? _tripsResponse;
  Bus? _currentBus;
  bool _isAvailable = false;
  bool _isLoading = false;
  String? _error;
  
  // Admin state
  List<Driver> _allDrivers = [];
  PaginatedResponse<Driver>? _driversResponse;

  // Getters
  Driver? get driverProfile => _driverProfile;
  List<DriverRating> get ratings => _ratings;
  List<Map<String, dynamic>> get schedules => _schedules;
  List<Trip> get trips => _trips;
  Bus? get currentBus => _currentBus;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Admin getters
  List<Driver> get allDrivers => _allDrivers;
  PaginatedResponse<Driver>? get driversResponse => _driversResponse;
  bool get hasMoreDrivers => _driversResponse?.hasNextPage ?? false;
  bool get hasMoreRatings => _ratingsResponse?.hasNextPage ?? false;
  
  // Trip getters
  List<Trip> get activeTrips => 
      _trips.where((t) => !t.isCompleted).toList();
  List<Trip> get completedTrips => 
      _trips.where((t) => t.isCompleted).toList();
  List<Trip> get scheduledTrips => 
      _trips.where((t) => t.startTime.isAfter(DateTime.now())).toList();

  // Get driver info like id, rating, etc.
  String get driverId => _driverProfile?.id ?? '';
  double get rating => _driverProfile?.rating ?? 0.0;

  // Fetch driver profile
  Future<void> fetchProfile() async {
    _setLoading(true);

    try {
      final response = await _driverService.getDriverProfile();
      
      if (response.isSuccess && response.data != null) {
        _driverProfile = response.data!;
        _isAvailable = _driverProfile!.isAvailable;
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch driver profile');
      }
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Update driver profile
  Future<bool> updateProfile(DriverUpdateRequest request) async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return false;
    }

    _setLoading(true);

    try {
      final response = await _driverService.updateProfile(_driverProfile!.id, request);
      
      if (response.isSuccess && response.data != null) {
        _driverProfile = response.data!;
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle driver availability
  Future<bool> toggleAvailability() async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return false;
    }

    _setLoading(true);

    try {
      final request = DriverAvailabilityRequest(isAvailable: !_isAvailable);
      final response = await _driverService.updateAvailability(_driverProfile!.id, request);
      
      if (response.isSuccess && response.data != null) {
        _driverProfile = response.data!;
        _isAvailable = _driverProfile!.isAvailable;
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update availability');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch driver ratings
  Future<void> fetchRatings({bool append = false, DriverRatingQueryParameters? queryParams}) async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return;
    }

    _setLoading(true);

    try {
      final effectiveQueryParams = queryParams ?? DriverRatingQueryParameters(
        driverId: _driverProfile!.id,
      );
      
      final response = await _driverService.getRatings(
        driverId: _driverProfile!.id,
        queryParams: effectiveQueryParams,
      );
      
      if (response.isSuccess && response.data != null) {
        _ratingsResponse = response.data!;
        if (append) {
          _ratings.addAll(response.data!.results);
        } else {
          _ratings = response.data!.results;
        }
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch ratings');
      }
    } catch (e) {
      _setError(e);
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

  // Fetch driver schedules
  Future<void> fetchDriverSchedules({int? dayOfWeek}) async {
    if (_driverProfile == null) {
      await fetchProfile();
    }

    _setLoading(true);

    try {
      _schedules = await _scheduleService.getDriverSchedules(
        driverId: driverId,
        dayOfWeek: dayOfWeek,
      );
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Fetch driver trips
  Future<void> fetchDriverTrips({bool? isCompleted}) async {
    if (_driverProfile == null) {
      await fetchProfile();
    }

    _setLoading(true);

    try {
      final queryParams = TripQueryParameters(
        driverId: driverId,
        isCompleted: isCompleted,
      );
      final response = await _trackingService.getTrips(
        queryParams: queryParams,
      );
      
      if (response.isSuccess && response.data != null) {
        _tripsResponse = response.data!;
        _trips = response.data!.results;
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch trips');
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void _clearError() {
    _error = null;
  }

  // Set current bus
  void setCurrentBus(Bus bus) {
    _currentBus = bus;
    notifyListeners();
  }
  
  // Rate a driver (for passengers)
  Future<bool> rateDriver(String driverId, DriverRatingCreateRequest request) async {
    try {
      final response = await _driverService.rateDriver(driverId, request);
      
      if (response.isSuccess) {
        // Refresh ratings if we're viewing this driver's ratings
        if (_driverProfile?.id == driverId) {
          await fetchRatings();
        }
        _clearError();
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
  
  // Admin functions
  Future<void> fetchAllDrivers({DriverQueryParameters? queryParams, bool append = false}) async {
    _setLoading(true);

    try {
      final response = await _driverService.getDrivers(queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        _driversResponse = response.data!;
        if (append) {
          _allDrivers.addAll(response.data!.results);
        } else {
          _allDrivers = response.data!.results;
        }
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch drivers');
      }
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> approveDriver(String driverId, DriverApprovalRequest request) async {
    try {
      final response = await _driverService.approveDriver(driverId, request);
      
      if (response.isSuccess && response.data != null) {
        _updateDriverInList(response.data!);
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to process driver approval');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }
  
  Future<bool> rejectDriver(String driverId, DriverApprovalRequest request) async {
    try {
      final response = await _driverService.rejectDriver(driverId, request);
      
      if (response.isSuccess && response.data != null) {
        _updateDriverInList(response.data!);
        _clearError();
        return true;
      } else {
        _setError(response.message ?? 'Failed to reject driver');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    }
  }
  
  // Helper method to update driver in the list
  void _updateDriverInList(Driver updatedDriver) {
    final index = _allDrivers.indexWhere((driver) => driver.id == updatedDriver.id);
    if (index != -1) {
      _allDrivers[index] = updatedDriver;
    }
    
    // Update current profile if it's the same driver
    if (_driverProfile?.id == updatedDriver.id) {
      _driverProfile = updatedDriver;
      _isAvailable = updatedDriver.isAvailable;
    }
    
    notifyListeners();
  }
  
  // Load more functions for pagination
  Future<void> loadMoreRatings() async {
    if (!hasMoreRatings || _isLoading) return;
    await fetchRatings(append: true);
  }
  
  Future<void> loadMoreDrivers() async {
    if (!hasMoreDrivers || _isLoading) return;
    await fetchAllDrivers(append: true);
  }
  
  // Fetch driver by ID
  Future<void> fetchDriverById(String driverId) async {
    _setLoading(true);

    try {
      final response = await _driverService.getDriverById(driverId);
      
      if (response.isSuccess && response.data != null) {
        // For admin or other users viewing a specific driver
        final driver = response.data!;
        // Update the list if this driver exists in it
        _updateDriverInList(driver);
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch driver details');
      }
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
}