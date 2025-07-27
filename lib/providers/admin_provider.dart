// lib/providers/admin_provider.dart

import 'package:flutter/foundation.dart';
import '../models/driver_model.dart';
import '../models/bus_model.dart';
import '../models/user_model.dart';
import '../models/line_model.dart';
import '../models/stop_model.dart';
import '../models/driver_application_model.dart';
import '../services/user_service.dart';
import '../services/bus_service.dart';
import '../services/driver_service.dart';
import '../services/line_service.dart';
import '../services/stop_service.dart';

/// Provider for admin-specific functionality
class AdminProvider extends ChangeNotifier {
  final UserService _userService;
  final BusService _busService;
  final DriverService _driverService;
  final LineService _lineService;
  final StopService _stopService;

  AdminProvider({
    required UserService userService,
    required BusService busService,
    required DriverService driverService,
    required LineService lineService,
    required StopService stopService,
  })  : _userService = userService,
        _busService = busService,
        _driverService = driverService,
        _lineService = lineService,
        _stopService = stopService;

  // State
  bool _isLoading = false;
  String? _error;
  
  // Driver management
  List<DriverApplication> _pendingDrivers = [];
  List<DriverApplication> _approvedDrivers = [];
  List<DriverApplication> _rejectedDrivers = [];
  
  // Bus management
  List<Bus> _pendingBuses = [];
  List<Bus> _activeBuses = [];
  List<Bus> _allBuses = [];
  
  // User management
  List<User> _allUsers = [];
  List<User> _drivers = [];
  List<User> _passengers = [];
  
  // Fleet management
  Map<String, dynamic> _fleetStats = {};
  
  // Line management
  List<Line> _allLines = [];
  
  // Stop management
  List<Stop> _allStops = [];
  
  // Schedule management
  List<Map<String, dynamic>> _allSchedules = [];
  List<Map<String, dynamic>> _todaySchedules = [];
  List<Map<String, dynamic>> _weeklySchedules = [];
  
  // Trip statistics
  Map<String, dynamic> _tripStats = {};
  
  // Anomaly management
  List<Map<String, dynamic>> _anomalies = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<DriverApplication> get pendingDrivers => _pendingDrivers;
  List<DriverApplication> get approvedDrivers => _approvedDrivers;
  List<DriverApplication> get rejectedDrivers => _rejectedDrivers;
  
  List<Bus> get pendingBuses => _pendingBuses;
  List<Bus> get activeBuses => _activeBuses;
  List<Bus> get allBuses => _allBuses;
  
  List<User> get allUsers => _allUsers;
  List<User> get drivers => _drivers;
  List<User> get passengers => _passengers;
  
  Map<String, dynamic> get fleetStats => _fleetStats;
  List<Line> get allLines => _allLines;
  List<Stop> get allStops => _allStops;
  
  List<Map<String, dynamic>> get allSchedules => _allSchedules;
  List<Map<String, dynamic>> get todaySchedules => _todaySchedules;
  List<Map<String, dynamic>> get weeklySchedules => _weeklySchedules;
  
  Map<String, dynamic> get tripStats => _tripStats;
  Map<String, dynamic> get tripStatistics => _tripStats;
  List<Map<String, dynamic>> get anomalies => _anomalies;
  
  List<Map<String, dynamic>> get allAnomalies => _anomalies;
  List<Map<String, dynamic>> get criticalAnomalies => 
      _anomalies.where((anomaly) => anomaly['severity'] == 'high').toList();
  List<Map<String, dynamic>> get resolvedAnomalies => 
      _anomalies.where((anomaly) => anomaly['status'] == 'resolved').toList();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Driver management methods
  Future<void> loadDriverApplications() async {
    _setLoading(true);
    try {
      final result = await _driverService.getDriverApplications();
      if (result.isSuccess) {
        final applications = result.data as List<DriverApplication>;
        _pendingDrivers = applications.where((app) => app.status == 'pending').toList();
        _approvedDrivers = applications.where((app) => app.status == 'approved').toList();
        _rejectedDrivers = applications.where((app) => app.status == 'rejected').toList();
        _setError(null);
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('Failed to load driver applications: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveDriver(String applicationId, String feedback) async {
    try {
      final result = await _driverService.approveDriverApplication(applicationId, feedback);
      if (result.isSuccess) {
        await loadDriverApplications();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to approve driver: $e');
      return false;
    }
  }

  Future<bool> rejectDriver(String applicationId, String reason) async {
    try {
      final result = await _driverService.rejectDriverApplication(applicationId, reason);
      if (result.isSuccess) {
        await loadDriverApplications();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to reject driver: $e');
      return false;
    }
  }

  // Bus management methods
  Future<void> loadBuses() async {
    _setLoading(true);
    try {
      final result = await _busService.getAllBuses();
      if (result.isSuccess) {
        _allBuses = result.data as List<Bus>;
        _activeBuses = _allBuses.where((bus) => bus.status == 'active').toList();
        _pendingBuses = _allBuses.where((bus) => bus.status == 'pending').toList();
        _setError(null);
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('Failed to load buses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveBus(String busId) async {
    try {
      final result = await _busService.approveBusSimple(busId);
      if (result.isSuccess) {
        await loadBuses();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to approve bus: $e');
      return false;
    }
  }

  Future<bool> rejectBus(String busId, String reason) async {
    try {
      final result = await _busService.rejectBus(busId, reason);
      if (result.isSuccess) {
        await loadBuses();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to reject bus: $e');
      return false;
    }
  }

  // User management methods
  Future<void> loadUsers() async {
    _setLoading(true);
    try {
      final result = await _userService.getAllUsers();
      if (result.isSuccess) {
        _allUsers = result.data as List<User>;
        _drivers = _allUsers.where((user) => user.userType == UserType.driver).toList();
        _passengers = _allUsers.where((user) => user.userType == UserType.passenger).toList();
        _setError(null);
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('Failed to load users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deactivateUser(String userId) async {
    try {
      final result = await _userService.deactivateUser(userId);
      if (result.isSuccess) {
        await loadUsers();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to deactivate user: $e');
      return false;
    }
  }

  // Fleet management methods
  Future<void> loadFleetStats() async {
    _setLoading(true);
    try {
      _fleetStats = {
        'totalBuses': _allBuses.length,
        'activeBuses': _activeBuses.length,
        'maintenanceBuses': _allBuses.where((b) => b.status == 'maintenance').length,
        'availableDrivers': _drivers.where((d) => d.isActive).length,
      };
      _setError(null);
    } catch (e) {
      _setError('Failed to load fleet stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Line management methods
  Future<void> loadLines() async {
    _setLoading(true);
    try {
      final result = await _lineService.getAllLines();
      if (result.isSuccess) {
        _allLines = result.data as List<Line>;
        _setError(null);
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('Failed to load lines: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Stop management methods
  Future<void> loadStops() async {
    _setLoading(true);
    try {
      final result = await _stopService.getAllStops();
      if (result.isSuccess) {
        _allStops = result.data as List<Stop>;
        _setError(null);
      } else {
        _setError(result.message);
      }
    } catch (e) {
      _setError('Failed to load stops: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Schedule management methods
  Future<void> loadSchedules() async {
    _setLoading(true);
    try {
      // Mock data for now
      _allSchedules = List.generate(50, (index) => {
        'id': 'schedule_$index',
        'lineId': 'line_${index % 10}',
        'busId': 'bus_${index % 20}',
        'departureTime': DateTime.now().add(Duration(hours: index)),
        'estimatedArrival': DateTime.now().add(Duration(hours: index + 2)),
        'status': ['scheduled', 'active', 'completed', 'cancelled'][index % 4],
      });
      
      final today = DateTime.now();
      _todaySchedules = _allSchedules.where((schedule) {
        final departure = schedule['departureTime'] as DateTime;
        return departure.day == today.day &&
               departure.month == today.month &&
               departure.year == today.year;
      }).toList();
      
      _weeklySchedules = _allSchedules.where((schedule) {
        final departure = schedule['departureTime'] as DateTime;
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return departure.isAfter(weekStart) && departure.isBefore(weekEnd);
      }).toList();
      
      _setError(null);
    } catch (e) {
      _setError('Failed to load schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Trip statistics methods
  Future<void> loadTripStats() async {
    _setLoading(true);
    try {
      _tripStats = {
        'totalTrips': 1250,
        'completedTrips': 1180,
        'cancelledTrips': 70,
        'averageDelay': 5.2,
        'onTimePerformance': 85.5,
        'customerSatisfaction': 4.2,
      };
      _setError(null);
    } catch (e) {
      _setError('Failed to load trip stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Anomaly management methods
  Future<void> loadAnomalies() async {
    _setLoading(true);
    try {
      _anomalies = List.generate(15, (index) => {
        'id': 'anomaly_$index',
        'type': ['delay', 'breakdown', 'route_deviation', 'overcrowding'][index % 4],
        'busId': 'bus_${index % 10}',
        'lineId': 'line_${index % 5}',
        'timestamp': DateTime.now().subtract(Duration(hours: index)),
        'severity': ['low', 'medium', 'high'][index % 3],
        'status': ['open', 'investigating', 'resolved'][index % 3],
        'description': 'Anomaly description for incident $index',
      });
      _setError(null);
    } catch (e) {
      _setError('Failed to load anomalies: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load trip statistics method alias
  Future<void> loadTripStatistics() async {
    return await loadTripStats();
  }

  /// Load all stops method alias
  Future<void> loadAllStops() async {
    return await loadStops();
  }

  /// Load all lines method alias  
  Future<void> loadAllLines() async {
    return await loadLines();
  }

  /// Get active lines
  List<Line> get activeLines => _allLines.where((line) => line.isActive).toList();
  
  /// Get inactive lines
  List<Line> get inactiveLines => _allLines.where((line) => !line.isActive).toList();

  /// Load bus registrations for approval screen
  Future<void> loadBusRegistrations() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      // Load bus registrations from service
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get approved buses
  List<Bus> get approvedBuses => _allBuses.where((bus) => bus.isApproved).toList();

  /// Get rejected buses (not approved and not active)
  List<Bus> get rejectedBuses => _allBuses.where((bus) => !bus.isApproved && !bus.isActive).toList();

  /// Get pending driver applications
  List<DriverApplication> get pendingDriverApplications => _pendingDrivers;

  /// Get approved driver applications  
  List<DriverApplication> get approvedDriverApplications => _approvedDrivers;

  /// Get rejected driver applications
  List<DriverApplication> get rejectedDriverApplications => _rejectedDrivers;

  // Error management methods
  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Approve driver application
  Future<bool> approveDriverApplication(String applicationId) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Move from pending to approved
      final application = _pendingDrivers.firstWhere((app) => app.id == applicationId);
      _pendingDrivers.removeWhere((app) => app.id == applicationId);
      _approvedDrivers.add(application);
      
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reject driver application
  Future<bool> rejectDriverApplication(String applicationId, String reason) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Move from pending to rejected
      final application = _pendingDrivers.firstWhere((app) => app.id == applicationId);
      _pendingDrivers.removeWhere((app) => app.id == applicationId);
      _rejectedDrivers.add(application);
      
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load fleet data for fleet management screen
  Future<void> loadFleetData() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API calls
      await Future.delayed(const Duration(seconds: 1));
      
      // Load fleet data
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get fleet vehicles (alias for all buses)
  List<Bus> get fleetVehicles => _allBuses;

  /// Get fleet drivers (mock implementation)
  List<Driver> get fleetDrivers => []; // Mock implementation

  /// Get fleet statistics (mock implementation)
  Map<String, dynamic> get fleetStatistics => {
    'totalVehicles': _allBuses.length,
    'activeVehicles': _allBuses.where((bus) => bus.isActive).length,
    'maintenanceVehicles': _allBuses.where((bus) => bus.status.value == 'maintenance').length,
  };

  /// Get maintenance records (mock implementation)
  List<Map<String, dynamic>> get maintenanceRecords => []; // Mock implementation

  /// Toggle line status (activate/deactivate)
  Future<bool> toggleLineStatus(String lineId) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Toggle the line status in local data
      final lineIndex = _allLines.indexWhere((line) => line.id == lineId);
      if (lineIndex != -1) {
        // Create updated line with toggled status - this is a simplified mock
        _clearError();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete line
  Future<bool> deleteLine(String lineId) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove line from local data
      _allLines.removeWhere((line) => line.id == lineId);
      
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load all users method alias
  Future<void> loadAllUsers() async {
    return await loadUsers();
  }

  /// Get passenger users (filtered by role)
  List<User> get passengerUsers => _allUsers.where((user) => user.role == 'passenger').toList();

  /// Get driver users (filtered by role)
  List<User> get driverUsers => _allUsers.where((user) => user.role == 'driver').toList();

  /// Get admin users (filtered by role)
  List<User> get adminUsers => _allUsers.where((user) => user.role == 'admin').toList();

  /// Toggle user status (activate/deactivate)
  Future<bool> toggleUserStatus(String userId) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Toggle user status in local data
      final userIndex = _allUsers.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        // This is a simplified mock - in real implementation, create new user with toggled status
        _clearError();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove user from local data
      _allUsers.removeWhere((user) => user.id == userId);
      
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

}