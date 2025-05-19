// lib/services/bus_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class BusService {
  final ApiClient _apiClient;

  BusService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get all buses
  Future<List<Map<String, dynamic>>> getBuses({
    bool? isActive,
    bool? isApproved,
    String? driverId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (isActive != null) queryParams[ApiConstants.isActiveKey] = isActive;
      if (isApproved != null) queryParams[ApiConstants.isApprovedKey] = isApproved;
      if (driverId != null) queryParams[ApiConstants.driverIdKey] = driverId;

      final response = await _apiClient.get(
        Endpoints.buses,
        queryParameters: queryParams,
      );

      if (response is Map<String, dynamic> && response.containsKey(ApiConstants.resultsKey)) {
        return List<Map<String, dynamic>>.from(response[ApiConstants.resultsKey]);
      }

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }

      return [];
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get buses: ${e.toString()}');
    }
  }

  // Get bus by ID
  Future<Map<String, dynamic>> getBusById(String busId) async {
    try {
      final response = await _apiClient.get('${Endpoints.buses}$busId/');
      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get bus details: ${e.toString()}');
    }
  }

  // Register new bus
  Future<Map<String, dynamic>> registerBus({
    required String licensePlate,
    required String driverId,
    required String model,
    required String manufacturer,
    required int year,
    required int capacity,
    required bool isAirConditioned,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.buses,
        body: {
          'license_plate': licensePlate,
          'driver': driverId,
          'model': model,
          'manufacturer': manufacturer,
          'year': year,
          'capacity': capacity,
          'is_air_conditioned': isAirConditioned,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to register bus: ${e.toString()}');
    }
  }

  // Update bus details
  Future<Map<String, dynamic>> updateBus({
    required String busId,
    String? licensePlate,
    String? model,
    String? manufacturer,
    int? year,
    int? capacity,
    bool? isAirConditioned,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (licensePlate != null) body['license_plate'] = licensePlate;
      if (model != null) body['model'] = model;
      if (manufacturer != null) body['manufacturer'] = manufacturer;
      if (year != null) body['year'] = year;
      if (capacity != null) body['capacity'] = capacity;
      if (isAirConditioned != null) body['is_air_conditioned'] = isAirConditioned;
      if (status != null) body['status'] = status;

      if (body.isEmpty) {
        throw ApiException('No data provided for update');
      }

      final response = await _apiClient.patch(
        '${Endpoints.buses}$busId/',
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update bus: ${e.toString()}');
    }
  }

  // Update bus location
  Future<Map<String, dynamic>> updateLocation({
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
      final Map<String, dynamic> body = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      if (altitude != null) body['altitude'] = altitude.toString();
      if (speed != null) body['speed'] = speed.toString();
      if (heading != null) body['heading'] = heading.toString();
      if (accuracy != null) body['accuracy'] = accuracy.toString();
      if (passengerCount != null) body['passenger_count'] = passengerCount;

      final response = await _apiClient.post(
        '${Endpoints.buses}$busId/update_location/',
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update bus location: ${e.toString()}');
    }
  }

  // Update passenger count
  Future<Map<String, dynamic>> updatePassengerCount({
    required String busId,
    required int count,
  }) async {
    try {
      final response = await _apiClient.post(
        '${Endpoints.buses}$busId/update_passenger_count/',
        body: {
          'count': count,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update passenger count: ${e.toString()}');
    }
  }

  // Get bus locations
  Future<List<Map<String, dynamic>>> getBusLocations({
    String? busId,
    bool? isTrackingActive,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (busId != null) queryParams[ApiConstants.busIdKey] = busId;
      if (isTrackingActive != null) queryParams[ApiConstants.isTrackingActiveKey] = isTrackingActive;

      final response = await _apiClient.get(
        Endpoints.busLocations,
        queryParameters: queryParams,
      );

      if (response is Map<String, dynamic> && response.containsKey(ApiConstants.resultsKey)) {
        return List<Map<String, dynamic>>.from(response[ApiConstants.resultsKey]);
      }

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }

      return [];
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get bus locations: ${e.toString()}');
    }
  }
}