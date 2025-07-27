// lib/services/stop_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/stop_model.dart';
import '../models/api_response_models.dart';

class StopService {
  final ApiClient _apiClient;

  StopService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get all stops
  Future<List<Stop>> getStops({
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

      List<Map<String, dynamic>> stopsData = [];
      if (response is Map<String, dynamic> &&
          response.containsKey(ApiConstants.resultsKey)) {
        stopsData = List<Map<String, dynamic>>.from(
          response[ApiConstants.resultsKey],
        );
      } else if (response is List) {
        stopsData = List<Map<String, dynamic>>.from(response);
      }

      return stopsData.map((json) => Stop.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get stops: ${e.toString()}');
    }
  }

  // Get stop by ID
  Future<Stop> getStopById(String stopId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.stopById(stopId)),
      );
      return Stop.fromJson(response);
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
  Future<List<Stop>> getNearbyStops({
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

      List<Map<String, dynamic>> stopsData = [];
      if (response is Map<String, dynamic> &&
          response.containsKey(ApiConstants.resultsKey)) {
        stopsData = List<Map<String, dynamic>>.from(
          response[ApiConstants.resultsKey],
        );
      } else if (response is List) {
        stopsData = List<Map<String, dynamic>>.from(response);
      }

      return stopsData.map((json) => Stop.fromJson(json)).toList();
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
      final Map<String, dynamic> body = {'stop': stopId, 'count': count};

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
      throw ApiException(
        'Failed to report waiting passengers: ${e.toString()}',
      );
    }
  }

  /// Get all stops for admin management
  Future<ApiResponse<List<Stop>>> getAllStops() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.stops),
      );

      if (response is Map<String, dynamic> && response.containsKey('results')) {
        final stops = (response['results'] as List)
            .map((json) => Stop.fromJson(json))
            .toList();
        return ApiResponse.success(data: stops);
      } else if (response is List) {
        final stops = response
            .map((json) => Stop.fromJson(json))
            .toList();
        return ApiResponse.success(data: stops);
      }

      return ApiResponse.error(message: 'Invalid response format');
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get all stops: ${e.toString()}',
      );
    }
  }
}
