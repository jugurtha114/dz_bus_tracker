// lib/services/trip_service.dart

import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/utils/api_utils.dart';
import 'base_service.dart';

class TripService extends BaseService {
  static const String _baseEndpoint = '/trips';

  // Get all trips
  Future<List<Map<String, dynamic>>> getAllTrips({
    Map<String, String>? filters,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (filters != null) {
        queryParams.addAll(filters);
      }

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get trip by ID
  Future<Map<String, dynamic>> getTripById(String tripId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/$tripId/'),
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Start a new trip
  Future<Map<String, dynamic>> startTrip({
    required String lineId,
    required String busId,
    required String driverId,
    String? scheduledDeparture,
  }) async {
    try {
      final body = {
        'line_id': lineId,
        'bus_id': busId,
        'driver_id': driverId,
        'scheduled_departure': scheduledDeparture,
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
      };

      final response = await apiClient.post(
        ApiEndpoints.buildUrl('$_baseEndpoint/start/'),
        body: body,
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // End a trip
  Future<void> endTrip({
    required String tripId,
    String? notes,
  }) async {
    try {
      final body = {
        'status': 'completed',
        'ended_at': DateTime.now().toIso8601String(),
        'notes': notes,
      };

      await apiClient.patch(
        ApiEndpoints.buildUrl('$_baseEndpoint/$tripId/end/'),
        body: body,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Cancel a trip
  Future<void> cancelTrip({
    required String tripId,
    required String reason,
  }) async {
    try {
      final body = {
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
        'cancellation_reason': reason,
      };

      await apiClient.patch(
        ApiEndpoints.buildUrl('$_baseEndpoint/$tripId/cancel/'),
        body: body,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update trip location
  Future<void> updateTripLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  }) async {
    try {
      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'heading': heading,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await apiClient.post(
        ApiEndpoints.buildUrl('$_baseEndpoint/$tripId/location/'),
        body: body,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Record stop arrival
  Future<void> recordStopArrival({
    required String tripId,
    required String stopId,
    DateTime? arrivalTime,
    int? passengerCount,
  }) async {
    try {
      final body = {
        'stop_id': stopId,
        'arrival_time': (arrivalTime ?? DateTime.now()).toIso8601String(),
        'passenger_count': passengerCount,
      };

      await apiClient.post(
        ApiEndpoints.buildUrl('$_baseEndpoint/$tripId/stops/arrival/'),
        body: body,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Record stop departure
  Future<void> recordStopDeparture({
    required String tripId,
    required String stopId,
    DateTime? departureTime,
    int? passengerCount,
  }) async {
    try {
      final body = {
        'stop_id': stopId,
        'departure_time': (departureTime ?? DateTime.now()).toIso8601String(),
        'passenger_count': passengerCount,
      };

      await apiClient.post(
        ApiEndpoints.buildUrl('$_baseEndpoint/$tripId/stops/departure/'),
        body: body,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get active trips
  Future<List<Map<String, dynamic>>> getActiveTrips() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/active/'),
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get trips by line
  Future<List<Map<String, dynamic>>> getTripsByLine(String lineId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        queryParameters: {'line_id': lineId},
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get trips by driver
  Future<List<Map<String, dynamic>>> getTripsByDriver(String driverId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        queryParameters: {'driver_id': driverId},
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get trips by bus
  Future<List<Map<String, dynamic>>> getTripsByBus(String busId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/'),
        queryParameters: {'bus_id': busId},
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get trip statistics
  Future<Map<String, dynamic>> getTripStatistics({
    String? period, // 'today', 'week', 'month'
    DateTime? startDate,
    DateTime? endDate,
    String? lineId,
    String? driverId,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      if (lineId != null) queryParams['line_id'] = lineId;
      if (driverId != null) queryParams['driver_id'] = driverId;

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/statistics/'),
        queryParameters: queryParams,
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get line statistics
  Future<List<Map<String, dynamic>>> getLineStatistics({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/line-statistics/'),
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get hourly statistics
  Future<List<Map<String, dynamic>>> getHourlyStatistics({
    DateTime? date,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (date != null) {
        queryParams['date'] = date.toIso8601String().split('T')[0];
      }

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/hourly-statistics/'),
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get daily statistics
  Future<List<Map<String, dynamic>>> getDailyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/daily-statistics/'),
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get top routes
  Future<List<Map<String, dynamic>>> getTopRoutes({
    String? period,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (period != null) queryParams['period'] = period;

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/top-routes/'),
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get trip history
  Future<List<Map<String, dynamic>>> getTripHistory({
    String? lineId,
    String? driverId,
    String? busId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (lineId != null) queryParams['line_id'] = lineId;
      if (driverId != null) queryParams['driver_id'] = driverId;
      if (busId != null) queryParams['bus_id'] = busId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await apiClient.get(
        ApiEndpoints.buildUrl('$_baseEndpoint/history/'),
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['results'] ?? []);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    
    return ApiException(
      'An error occurred while processing trip data',
      statusCode: 500,
    );
  }
}