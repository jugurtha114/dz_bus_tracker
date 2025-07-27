// lib/services/fleet_management_service.dart

import 'dart:async';
import '../core/network/api_client.dart';
import '../core/exceptions/app_exceptions.dart';

class FleetManagementService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getAllBuses() async {
    try {
      final response = await _apiClient.get('/admin/fleet/buses');
      return List<Map<String, dynamic>>.from(response['buses']);
    } catch (e) {
      // Return mock data for now
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockBuses();
    }
  }

  Future<List<Map<String, dynamic>>> getAllDrivers() async {
    try {
      final response = await _apiClient.get('/admin/fleet/drivers');
      return List<Map<String, dynamic>>.from(response['drivers']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockDrivers();
    }
  }

  Future<Map<String, dynamic>> getFleetStatistics() async {
    try {
      final response = await _apiClient.get('/admin/fleet/statistics');
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockFleetStats();
    }
  }

  Future<List<Map<String, dynamic>>> getMaintenanceSchedule() async {
    try {
      final response = await _apiClient.get(
        '/admin/fleet/maintenance/schedule',
      );
      return List<Map<String, dynamic>>.from(response['schedule']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _getMockMaintenanceSchedule();
    }
  }

  Future<Map<String, dynamic>> getBusDetails(String busId) async {
    try {
      final response = await _apiClient.get('/admin/fleet/buses/$busId');
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockBusDetails(busId);
    }
  }

  Future<Map<String, dynamic>> getDriverDetails(String driverId) async {
    try {
      final response = await _apiClient.get('/admin/fleet/drivers/$driverId');
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockDriverDetails(driverId);
    }
  }

  Future<bool> addBus(Map<String, dynamic> busData) async {
    try {
      final response = await _apiClient.post(
        '/admin/fleet/buses',
        body: busData,
      );
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return true; // Simulate success
    }
  }

  Future<bool> updateBus(String busId, Map<String, dynamic> busData) async {
    try {
      final response = await _apiClient.put(
        '/admin/fleet/buses/$busId',
        body: busData,
      );
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    }
  }

  Future<bool> deleteBus(String busId) async {
    try {
      final response = await _apiClient.delete('/admin/fleet/buses/$busId');
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
  }

  Future<bool> addDriver(Map<String, dynamic> driverData) async {
    try {
      final response = await _apiClient.post(
        '/admin/fleet/drivers',
        body: driverData,
      );
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
  }

  Future<bool> updateDriver(
    String driverId,
    Map<String, dynamic> driverData,
  ) async {
    try {
      final response = await _apiClient.put(
        '/admin/fleet/drivers/$driverId',
        body: driverData,
      );
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    }
  }

  Future<bool> assignDriverToBus(String driverId, String busId) async {
    try {
      final response = await _apiClient.post(
        '/admin/fleet/assignments',
        body: {'driver_id': driverId, 'bus_id': busId},
      );
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    }
  }

  Future<bool> scheduleMaintenance(Map<String, dynamic> maintenanceData) async {
    try {
      final response = await _apiClient.post(
        '/admin/fleet/maintenance/schedule',
        body: maintenanceData,
      );
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    }
  }

  Future<List<Map<String, dynamic>>> getMaintenanceHistory(String busId) async {
    try {
      final response = await _apiClient.get(
        '/admin/fleet/buses/$busId/maintenance/history',
      );
      return List<Map<String, dynamic>>.from(response['history']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockMaintenanceHistory(busId);
    }
  }

  Future<Map<String, dynamic>> getFleetAnalytics({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      final response = await _apiClient.get(
        '/admin/fleet/analytics',
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 700));
      return _getMockFleetAnalytics();
    }
  }

  Future<List<Map<String, dynamic>>> getVehiclesByStatus(String status) async {
    try {
      final response = await _apiClient.get(
        '/admin/fleet/buses',
        queryParameters: {'status': status},
      );
      return List<Map<String, dynamic>>.from(response['buses']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _getMockBuses().where((bus) => bus['status'] == status).toList();
    }
  }

  Future<bool> bulkImportVehicles(List<Map<String, dynamic>> vehicles) async {
    try {
      final response = await _apiClient.post(
        '/admin/fleet/buses/bulk-import',
        body: {'vehicles': vehicles},
      );
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }
  }

  Future<Map<String, dynamic>> exportFleetData({String format = 'csv'}) async {
    try {
      final response = await _apiClient.get(
        '/admin/fleet/export',
        queryParameters: {'format': format},
      );
      return response;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'download_url': 'mock_export_url',
        'filename':
            'fleet_data_${DateTime.now().millisecondsSinceEpoch}.$format',
      };
    }
  }

  // Mock data methods
  List<Map<String, dynamic>> _getMockBuses() {
    return [
      {
        'id': 'bus_001',
        'license_plate': 'DZ-001-AB',
        'make': 'Mercedes',
        'model': 'Citaro',
        'year': 2020,
        'capacity': 40,
        'mileage': 125000,
        'status': 'active',
        'driver_name': 'Ahmed Ben Ali',
        'driver_id': 'driver_001',
        'line_name': 'Line 1 - City Center - Airport',
        'line_id': 'line_001',
        'fuel_efficiency': 12,
        'last_maintenance': '2024-06-15T00:00:00Z',
        'next_maintenance': '2024-09-15T00:00:00Z',
      },
      {
        'id': 'bus_002',
        'license_plate': 'DZ-002-CD',
        'make': 'Volvo',
        'model': '7900',
        'year': 2019,
        'capacity': 35,
        'mileage': 98000,
        'status': 'maintenance',
        'driver_name': null,
        'driver_id': null,
        'line_name': null,
        'line_id': null,
        'fuel_efficiency': 11,
        'last_maintenance': '2024-07-20T00:00:00Z',
        'next_maintenance': '2024-07-25T00:00:00Z',
      },
      {
        'id': 'bus_003',
        'license_plate': 'DZ-003-EF',
        'make': 'Iveco',
        'model': 'Crossway',
        'year': 2021,
        'capacity': 45,
        'mileage': 75000,
        'status': 'active',
        'driver_name': 'Fatima Zohra',
        'driver_id': 'driver_002',
        'line_name': 'Line 2 - University - Shopping Mall',
        'line_id': 'line_002',
        'fuel_efficiency': 13,
        'last_maintenance': '2024-05-10T00:00:00Z',
        'next_maintenance': '2024-08-10T00:00:00Z',
      },
      {
        'id': 'bus_004',
        'license_plate': 'DZ-004-GH',
        'make': 'Scania',
        'model': 'Citywide',
        'year': 2018,
        'capacity': 38,
        'mileage': 145000,
        'status': 'offline',
        'driver_name': null,
        'driver_id': null,
        'line_name': null,
        'line_id': null,
        'fuel_efficiency': 10,
        'last_maintenance': '2024-07-01T00:00:00Z',
        'next_maintenance': '2024-10-01T00:00:00Z',
      },
      {
        'id': 'bus_005',
        'license_plate': 'DZ-005-IJ',
        'make': 'MAN',
        'model': 'Lion\'s City',
        'year': 2022,
        'capacity': 42,
        'mileage': 45000,
        'status': 'active',
        'driver_name': 'Mohammed Kassim',
        'driver_id': 'driver_003',
        'line_name': 'Line 3 - Residential - Business District',
        'line_id': 'line_003',
        'fuel_efficiency': 14,
        'last_maintenance': '2024-04-20T00:00:00Z',
        'next_maintenance': '2024-07-20T00:00:00Z',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockDrivers() {
    return [
      {
        'id': 'driver_001',
        'name': 'Ahmed Ben Ali',
        'license_number': 'DL123456789',
        'phone': '+213555123456',
        'email': 'ahmed.benali@dzbus.com',
        'status': 'on_duty',
        'rating': 4,
        'experience_years': 8,
        'assigned_bus': 'DZ-001-AB',
        'assigned_bus_id': 'bus_001',
        'total_trips': 2450,
        'total_distance': 125000,
        'hire_date': '2018-03-15T00:00:00Z',
        'last_active': '2024-07-24T08:30:00Z',
      },
      {
        'id': 'driver_002',
        'name': 'Fatima Zohra',
        'license_number': 'DL987654321',
        'phone': '+213555987654',
        'email': 'fatima.zohra@dzbus.com',
        'status': 'on_duty',
        'rating': 4,
        'experience_years': 12,
        'assigned_bus': 'DZ-003-EF',
        'assigned_bus_id': 'bus_003',
        'total_trips': 3200,
        'total_distance': 180000,
        'hire_date': '2015-09-20T00:00:00Z',
        'last_active': '2024-07-24T09:15:00Z',
      },
      {
        'id': 'driver_003',
        'name': 'Mohammed Kassim',
        'license_number': 'DL456789123',
        'phone': '+213555456789',
        'email': 'mohammed.kassim@dzbus.com',
        'status': 'break',
        'rating': 4,
        'experience_years': 5,
        'assigned_bus': 'DZ-005-IJ',
        'assigned_bus_id': 'bus_005',
        'total_trips': 1800,
        'total_distance': 95000,
        'hire_date': '2020-01-10T00:00:00Z',
        'last_active': '2024-07-24T10:45:00Z',
      },
      {
        'id': 'driver_004',
        'name': 'Omar Abdullah',
        'license_number': 'DL789123456',
        'phone': '+213555789123',
        'email': 'omar.abdullah@dzbus.com',
        'status': 'offline',
        'rating': 4,
        'experience_years': 3,
        'assigned_bus': null,
        'assigned_bus_id': null,
        'total_trips': 950,
        'total_distance': 48000,
        'hire_date': '2022-06-01T00:00:00Z',
        'last_active': '2024-07-23T18:30:00Z',
      },
      {
        'id': 'driver_005',
        'name': 'Aicha Mansouri',
        'license_number': 'DL321654987',
        'phone': '+213555321654',
        'email': 'aicha.mansouri@dzbus.com',
        'status': 'on_duty',
        'rating': 4,
        'experience_years': 7,
        'assigned_bus': null,
        'assigned_bus_id': null,
        'total_trips': 2100,
        'total_distance': 110000,
        'hire_date': '2019-02-14T00:00:00Z',
        'last_active': '2024-07-24T11:20:00Z',
      },
    ];
  }

  Map<String, dynamic> _getMockFleetStats() {
    return {
      'total_vehicles': 25,
      'active_vehicles': 18,
      'in_service': 4,
      'offline_vehicles': 3,
      'total_drivers': 32,
      'drivers_on_duty': 22,
      'fleet_utilization': 78,
      'fleet_efficiency': 85,
      'average_fuel_efficiency': 12,
      'total_mileage': 2450000,
      'maintenance_due': 6,
      'revenue_today': 125000,
      'trips_completed_today': 340,
    };
  }

  List<Map<String, dynamic>> _getMockMaintenanceSchedule() {
    return [
      {
        'id': 'maint_001',
        'vehicle_id': 'DZ-002-CD',
        'type': 'Engine Overhaul',
        'description':
            'Complete engine inspection and overhaul due to high mileage',
        'scheduled_date': '2024-07-25T09:00:00Z',
        'priority': 'high',
        'estimated_duration': '3 days',
        'cost_estimate': 25000,
        'mechanic_assigned': 'Hassan Boutella',
      },
      {
        'id': 'maint_002',
        'vehicle_id': 'DZ-005-IJ',
        'type': 'Brake System Check',
        'description': 'Routine brake system inspection and pad replacement',
        'scheduled_date': '2024-07-26T14:00:00Z',
        'priority': 'medium',
        'estimated_duration': '4 hours',
        'cost_estimate': 8000,
        'mechanic_assigned': 'Karim Benali',
      },
      {
        'id': 'maint_003',
        'vehicle_id': 'DZ-001-AB',
        'type': 'Oil Change',
        'description': 'Regular oil change and filter replacement',
        'scheduled_date': '2024-07-28T08:00:00Z',
        'priority': 'low',
        'estimated_duration': '2 hours',
        'cost_estimate': 3500,
        'mechanic_assigned': 'Youcef Rahimi',
      },
      {
        'id': 'maint_004',
        'vehicle_id': 'DZ-004-GH',
        'type': 'Transmission Repair',
        'description':
            'Transmission showing signs of wear, needs inspection and possible repair',
        'scheduled_date': '2024-07-30T10:00:00Z',
        'priority': 'high',
        'estimated_duration': '2 days',
        'cost_estimate': 18000,
        'mechanic_assigned': 'Abdel Rahman',
      },
    ];
  }

  Map<String, dynamic> _getMockBusDetails(String busId) {
    final buses = _getMockBuses();
    return buses.firstWhere(
      (bus) => bus['id'] == busId,
      orElse: () => buses.first,
    );
  }

  Map<String, dynamic> _getMockDriverDetails(String driverId) {
    final drivers = _getMockDrivers();
    return drivers.firstWhere(
      (driver) => driver['id'] == driverId,
      orElse: () => drivers.first,
    );
  }

  List<Map<String, dynamic>> _getMockMaintenanceHistory(String busId) {
    return [
      {
        'id': 'hist_001',
        'date': '2024-06-15T00:00:00Z',
        'type': 'Oil Change',
        'description': 'Regular oil change and filter replacement',
        'cost': 3500,
        'mechanic': 'Hassan Boutella',
        'duration_hours': 2,
      },
      {
        'id': 'hist_002',
        'date': '2024-05-20T00:00:00Z',
        'type': 'Brake Inspection',
        'description': 'Brake system inspection and minor adjustments',
        'cost': 5000,
        'mechanic': 'Karim Benali',
        'duration_hours': 3,
      },
      {
        'id': 'hist_003',
        'date': '2024-04-10T00:00:00Z',
        'type': 'AC Repair',
        'description': 'Air conditioning system repair and refrigerant refill',
        'cost': 12000,
        'mechanic': 'Youcef Rahimi',
        'duration_hours': 6,
      },
    ];
  }

  Map<String, dynamic> _getMockFleetAnalytics() {
    return {
      'efficiency_trend': [
        {'date': '2024-07-01', 'efficiency': 82},
        {'date': '2024-07-08', 'efficiency': 85},
        {'date': '2024-07-15', 'efficiency': 78},
        {'date': '2024-07-22', 'efficiency': 87},
      ],
      'utilization_breakdown': {'active': 65, 'maintenance': 20, 'offline': 15},
      'fuel_consumption': {
        'this_month': 15000,
        'last_month': 16200,
        'change_percentage': -7,
      },
      'maintenance_costs': {
        'this_month': 85000,
        'last_month': 72000,
        'change_percentage': 18,
      },
    };
  }
}
