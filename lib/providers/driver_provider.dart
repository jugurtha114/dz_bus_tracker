// lib/providers/driver_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/driver_model.dart';
// import '../models/schedule_model.dart'; // TODO: Create schedule model
import '../models/tracking_model.dart' show Trip, TripQueryParameters;
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
  }) : _driverService = driverService ?? DriverService(),
       _scheduleService = scheduleService ?? ScheduleService(),
       _trackingService = trackingService ?? TrackingService();

  // State
  Driver? _driverProfile;
  List<DriverRating> _ratings = [];
  PaginatedResponse<DriverRating>? _ratingsResponse;
  List<Map<String, dynamic>> _schedules =
      []; // TODO: Replace with Schedule model
  List<Trip> _trips = [];
  PaginatedResponse<Trip>? _tripsResponse;
  Bus? _currentBus;
  bool _isAvailable = false;
  bool _isLoading = false;
  String? _error;

  // Admin state
  List<Driver> _allDrivers = [];
  PaginatedResponse<Driver>? _driversResponse;
  
  // UI compatibility state
  Driver? _selectedDriver;
  List<Driver> _drivers = [];

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
  
  // UI compatibility getters
  Driver? get selectedDriver => _selectedDriver;
  List<Driver> get drivers => _drivers;

  // Trip getters
  List<Trip> get activeTrips => _trips.where((t) => !t.isCompleted).toList();
  List<Trip> get completedTrips => _trips.where((t) => t.isCompleted).toList();
  List<Trip> get scheduledTrips =>
      _trips.where((t) => t.startTime.isAfter(DateTime.now())).toList();

  // Get driver info like id, rating, etc.
  String get driverId => _driverProfile?.id ?? '';
  double get rating => _driverProfile?.rating ?? 0.0;

  // Fetch drivers (for admin screens)
  Future<void> fetchDrivers({DriverQueryParameters? queryParams}) async {
    _setLoading(true);

    try {
      final response = await _driverService.getDrivers(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        _driversResponse = response.data!;
        _allDrivers = response.data!.results;
        _drivers = _allDrivers; // UI compatibility
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
      final response = await _driverService.updateProfile(
        _driverProfile!.id,
        request,
      );

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

  // Update driver availability with specific value
  Future<bool> updateAvailability(bool isAvailable) async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return false;
    }

    _setLoading(true);

    try {
      final request = DriverAvailabilityRequest(isAvailable: isAvailable);
      final response = await _driverService.updateAvailability(
        _driverProfile!.id,
        request,
      );

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

  // Toggle driver availability
  Future<bool> toggleAvailability() async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return false;
    }

    _setLoading(true);

    try {
      final request = DriverAvailabilityRequest(isAvailable: !_isAvailable);
      final response = await _driverService.updateAvailability(
        _driverProfile!.id,
        request,
      );

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
  Future<void> fetchRatings({
    bool append = false,
    DriverRatingQueryParameters? queryParams,
  }) async {
    if (_driverProfile == null) {
      _setError('Driver profile not loaded');
      return;
    }

    _setLoading(true);

    try {
      final effectiveQueryParams =
          queryParams ??
          DriverRatingQueryParameters(driverId: _driverProfile!.id);

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
  Future<bool> rateDriver(
    String driverId,
    DriverRatingCreateRequest request,
  ) async {
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
  Future<void> fetchAllDrivers({
    DriverQueryParameters? queryParams,
    bool append = false,
  }) async {
    _setLoading(true);

    try {
      final response = await _driverService.getDrivers(
        queryParams: queryParams,
      );

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

  Future<bool> approveDriver(
    String driverId,
    DriverApprovalRequest request,
  ) async {
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

  Future<bool> rejectDriver(
    String driverId,
    DriverApprovalRequest request,
  ) async {
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
    final index = _allDrivers.indexWhere(
      (driver) => driver.id == updatedDriver.id,
    );
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

  /// Driver home screen specific methods
  
  /// Load driver profile for home screen
  Future<void> loadDriverProfile() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual driver profile loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load assigned buses for driver
  Future<void> loadAssignedBuses() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual bus loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load current trips for driver
  Future<void> loadCurrentTrips() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual trips loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get assigned buses for driver
  List<Bus> get assignedBuses => []; // Mock - should return actual assigned buses

  /// Get today's statistics for driver
  Map<String, dynamic> get todayStats => {
    'tripsCompleted': 5,
    'totalPassengers': 120,
    'distanceTraveled': 85.5,
    'averageRating': 4.2,
  };

  /// Get recent trips for driver
  List<Trip> get recentTrips => _trips.take(5).toList(); // Last 5 trips

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadDriverProfile(),
        loadAssignedBuses(),
        loadCurrentTrips(),
      ]);
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle driver duty status
  Future<void> toggleDutyStatus() async {
    _setLoading(true);
    try {
      // Mock implementation - toggle availability status
      _isAvailable = !_isAvailable;
      if (_driverProfile != null) {
        // In real implementation, update via API
        await Future.delayed(const Duration(seconds: 1));
      }
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle location sharing
  Future<void> toggleLocationSharing() async {
    _setLoading(true);
    try {
      // Mock implementation - toggle location sharing
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Compatibility methods and getters for enhanced driver screens
  Future<void> loadCurrentTrip() => fetchDriverTrips();
  Map<String, dynamic> get todayStatistics => todayStats;
  Driver? get driver => _driverProfile;
  Trip? get currentTrip => _trips.isEmpty ? null : _trips.first;
  List<Bus> get buses => assignedBuses;
  bool get hasAssignedBuses => assignedBuses.isNotEmpty;
  bool get hasActiveTrip => currentTrip != null;

  /// Update bus status
  Future<void> updateBusStatus(String busId, String status) async {
    _setLoading(true);
    try {
      // Mock implementation - update bus status
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// End current trip
  Future<void> endCurrentTrip() async {
    _setLoading(true);
    try {
      // Mock implementation - end current trip
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// End specific trip
  Future<void> endTrip(String tripId) async {
    _setLoading(true);
    try {
      // Mock implementation - end specific trip
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Start new trip
  Future<void> startTrip() async {
    _setLoading(true);
    try {
      // Mock implementation - start new trip
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get performance data for driver
  Map<String, dynamic> get performanceData => {
    'totalTrips': 120,
    'totalDistance': 2500.5,
    'averageRating': 4.3,
    'onTimePercentage': 85.5,
    'customerFeedback': 4.2,
  };

  /// Get performance metrics (alias for performanceData)
  Map<String, dynamic> get performanceMetrics => performanceData;

  /// Get achievements for driver
  List<Map<String, dynamic>> get achievements => [
    {
      'id': '1',
      'title': 'Safe Driver',
      'description': 'Completed 100 trips without incidents',
      'icon': 'shield',
      'earned': true,
    },
    {
      'id': '2',
      'title': 'Punctual Pro',
      'description': 'On-time for 95% of trips this month',
      'icon': 'clock',
      'earned': true,
    },
  ];

  /// Load performance data for dashboard
  Future<void> loadPerformanceData() async {
    _setLoading(true);
    try {
      // Mock implementation - load performance data
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get current driver (alias for driverProfile or selectedDriver)
  Driver? get currentDriver => _selectedDriver ?? _driverProfile;

  /// Update driver profile
  Future<bool> updateDriverProfile(Driver updatedDriver) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update the selected driver if it's the same one
      if (_selectedDriver?.id == updatedDriver.id) {
        _selectedDriver = updatedDriver;
      }
      
      // Update in drivers list
      final index = _drivers.indexWhere((d) => d.id == updatedDriver.id);
      if (index != -1) {
        _drivers[index] = updatedDriver;
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Missing getters for UI compatibility
  List<Map<String, dynamic>> get todaySchedules => []; // Mock
  List<Map<String, dynamic>> get weekSchedules => []; // Mock
  Map<String, dynamic>? get activeSchedule => null; // Mock
  List<Trip> get todayTrips => []; // Mock - requires Trip import
  Trip? get activeTrip => null; // Mock
  Map<String, dynamic> get tripStats => {}; // Mock
  double get overallRating => 4.2; // Mock
  List<Map<String, dynamic>> get recentRatings => []; // Mock
  Map<String, dynamic> get ratingBreakdown => {}; // Mock
  List<String> get topFeedbackTags => ['Professional', 'On-time']; // Mock

  /// Missing methods for UI compatibility
  Future<void> loadSchedules() async {
    // Mock implementation
  }

  Future<void> loadTrips() async {
    // Mock implementation
  }

  Future<void> loadDriverRatings() async {
    // Mock implementation
  }

  Future<void> fetchAvailableLines() async {
    // Mock implementation
  }

  Future<void> getCurrentAssignment() async {
    // Mock implementation
  }

  Future<void> selectLine(String lineId) async {
    // Mock implementation
  }

  Future<void> endShift() async {
    // Mock implementation
  }

  String? get currentLine => null; // Mock

  // Compatibility aliases for enhanced screens
  Future<void> loadTodayStatistics() => refreshDashboard();
  Future<void> getCurrentLocation() async {
    // Mock implementation for location loading
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
}
