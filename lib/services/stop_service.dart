// lib/services/stop_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class StopService {
  final ApiClient _apiClient;

  StopService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get all stops
  Future<List<Map<String, dynamic>>> getStops({
    bool? isActive,
    String? lineId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (isActive != null) queryParams[ApiConstants.isActiveKey] = isActive;
      if (lineId != null) queryParams[ApiConstants.lineIdKey] = lineId;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.stops),
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
      throw ApiException('Failed to get stops: ${e.toString()}');
    }
  }

  // Get stop by ID
  Future<Map<String, dynamic>> getStopById(String stopId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.stopById(stopId)));
      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get stop details: ${e.toString()}');
    }
  }

  // Create new stop
  Future<Map<String, dynamic>> createStop({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String? description,
    String? photo,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      if (address != null) body['address'] = address;
      if (description != null) body['description'] = description;
      if (photo != null) body['photo'] = photo;

      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.stops),
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to create stop: ${e.toString()}');
    }
  }

  // Update stop
  Future<Map<String, dynamic>> updateStop({
    required String stopId,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? description,
    String? photo,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (name != null) body['name'] = name;
      if (latitude != null) body['latitude'] = latitude.toString();
      if (longitude != null) body['longitude'] = longitude.toString();
      if (address != null) body['address'] = address;
      if (description != null) body['description'] = description;
      if (photo != null) body['photo'] = photo;
      if (isActive != null) body['is_active'] = isActive;

      if (body.isEmpty) {
        throw ApiException('No data provided for update');
      }

      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.stopById(stopId)),
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update stop: ${e.toString()}');
    }
  }

  // Get nearby stops
  Future<List<Map<String, dynamic>>> getNearbyStops({
    required double latitude,
    required double longitude,
    double radius = 1000, // default 1km
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.nearbyStops),
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'radius': radius.toString(),
        },
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
      throw ApiException('Failed to get nearby stops: ${e.toString()}');
    }
  }

  // Report waiting passengers at a stop
  Future<Map<String, dynamic>> reportWaitingPassengers({
    required String stopId,
    required int count,
    String? lineId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'stop': stopId,
        'count': count,
      };

      if (lineId != null) body['line'] = lineId;

      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.waitingPassengers),
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to report waiting passengers: ${e.toString()}');
    }
  }
}