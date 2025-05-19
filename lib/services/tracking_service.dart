// lib/services/tracking_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class TrackingService {
  final ApiClient _apiClient;

  TrackingService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Start tracking a bus on a line
  Future<Map<String, dynamic>> startTracking({
    required String busId,
    required String lineId,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.startTracking,
        body: {
          'bus_id': busId,
          'line_id': lineId,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to start tracking: ${e.toString()}');
    }
  }

  // Stop tracking a bus
  Future<Map<String, dynamic>> stopTracking({
    required String busId,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.stopTracking,
        body: {
          'bus_id': busId,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to stop tracking: ${e.toString()}');
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
        Endpoints.locations,
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

  // Send location update
  Future<Map<String, dynamic>> sendLocationUpdate({
    required String busId,
    required double latitude,
    required double longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
    String? tripId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'bus': busId,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      if (altitude != null) body['altitude'] = altitude.toString();
      if (speed != null) body['speed'] = speed.toString();
      if (heading != null) body['heading'] = heading.toString();
      if (accuracy != null) body['accuracy'] = accuracy.toString();
      if (tripId != null) body['trip_id'] = tripId;

      final response = await _apiClient.post(
        Endpoints.locations,
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to send location update: ${e.toString()}');
    }
  }

  // Get trips
  Future<List<Map<String, dynamic>>> getTrips({
    String? busId,
    String? driverId,
    String? lineId,
    bool? isCompleted,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (busId != null) queryParams[ApiConstants.busIdKey] = busId;
      if (driverId != null) queryParams[ApiConstants.driverIdKey] = driverId;
      if (lineId != null) queryParams[ApiConstants.lineIdKey] = lineId;
      if (isCompleted != null) queryParams[ApiConstants.isCompletedKey] = isCompleted;

      final response = await _apiClient.get(
        Endpoints.trips,
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
      throw ApiException('Failed to get trips: ${e.toString()}');
    }
  }

  // Create a trip
  Future<Map<String, dynamic>> createTrip({
    required String busId,
    required String driverId,
    required String lineId,
    required DateTime startTime,
    String? startStopId,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'bus': busId,
        'driver': driverId,
        'line': lineId,
        'start_time': startTime.toUtc().toIso8601String(),
      };

      if (startStopId != null) body['start_stop'] = startStopId;
      if (notes != null) body['notes'] = notes;

      final response = await _apiClient.post(
        Endpoints.trips,
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to create trip: ${e.toString()}');
    }
  }

  // End a trip
  Future<Map<String, dynamic>> endTrip({
    required String tripId,
    String? endStopId,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (endStopId != null) body['end_stop'] = endStopId;
      if (notes != null) body['notes'] = notes;

      final response = await _apiClient.post(
        '${Endpoints.trips}$tripId/end/',
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to end trip: ${e.toString()}');
    }
  }

  // Get trip statistics
  Future<Map<String, dynamic>> getTripStatistics(String tripId) async {
    try {
      final response = await _apiClient.get('${Endpoints.trips}$tripId/statistics/');
      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get trip statistics: ${e.toString()}');
    }
  }

  // Report passenger count
  Future<Map<String, dynamic>> reportPassengerCount({
    required String busId,
    required int count,
    String? stopId,
    String? tripId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'bus': busId,
        'count': count,
      };

      if (stopId != null) body['stop'] = stopId;
      if (tripId != null) body['trip_id'] = tripId;

      final response = await _apiClient.post(
        Endpoints.passengerCounts,
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to report passenger count: ${e.toString()}');
    }
  }

  // Report anomaly
  Future<Map<String, dynamic>> reportAnomaly({
    required String busId,
    required String type,
    required String description,
    required String severity,
    double? latitude,
    double? longitude,
    String? tripId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'bus': busId,
        'type': type,
        'description': description,
        'severity': severity,
      };

      if (latitude != null && longitude != null) {
        body['location_latitude'] = latitude.toString();
        body['location_longitude'] = longitude.toString();
      }

      if (tripId != null) body['trip'] = tripId;

      final response = await _apiClient.post(
        Endpoints.anomalies,
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to report anomaly: ${e.toString()}');
    }
  }

  // Resolve anomaly
  Future<Map<String, dynamic>> resolveAnomaly({
    required String anomalyId,
    required String resolutionNotes,
  }) async {
    try {
      final response = await _apiClient.post(
        '${Endpoints.anomalies}$anomalyId/resolve/',
        body: {
          'resolution_notes': resolutionNotes,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to resolve anomaly: ${e.toString()}');
    }
  }

  // Estimate arrival time
  Future<Map<String, dynamic>> estimateArrivalTime({
    required String busId,
    required String stopId,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.estimateArrival,
        body: {
          'bus_id': busId,
          'stop_id': stopId,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to estimate arrival time: ${e.toString()}');
    }
  }
}