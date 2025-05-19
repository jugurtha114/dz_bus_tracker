// lib/services/line_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class LineService {
  final ApiClient _apiClient;

  LineService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get all lines
  Future<List<Map<String, dynamic>>> getLines({
    bool? isActive,
    String? stopId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (isActive != null) queryParams[ApiConstants.isActiveKey] = isActive;
      if (stopId != null) queryParams[ApiConstants.stopIdKey] = stopId;

      final response = await _apiClient.get(
        Endpoints.lines,
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
      throw ApiException('Failed to get lines: ${e.toString()}');
    }
  }

  // Get line by ID
  Future<Map<String, dynamic>> getLineById(String lineId) async {
    try {
      final response = await _apiClient.get('${Endpoints.lines}$lineId/');
      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get line details: ${e.toString()}');
    }
  }

  // Create new line
  Future<Map<String, dynamic>> createLine({
    required String name,
    required String code,
    String? description,
    String? color,
    int? frequency,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'code': code,
      };

      if (description != null) body['description'] = description;
      if (color != null) body['color'] = color;
      if (frequency != null) body['frequency'] = frequency;

      final response = await _apiClient.post(
        Endpoints.lines,
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to create line: ${e.toString()}');
    }
  }

  // Update line
  Future<Map<String, dynamic>> updateLine({
    required String lineId,
    String? name,
    String? code,
    String? description,
    String? color,
    int? frequency,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (name != null) body['name'] = name;
      if (code != null) body['code'] = code;
      if (description != null) body['description'] = description;
      if (color != null) body['color'] = color;
      if (frequency != null) body['frequency'] = frequency;
      if (isActive != null) body['is_active'] = isActive;

      if (body.isEmpty) {
        throw ApiException('No data provided for update');
      }

      final response = await _apiClient.patch(
        '${Endpoints.lines}$lineId/',
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update line: ${e.toString()}');
    }
  }

  // Get stops for a line
  Future<List<Map<String, dynamic>>> getLineStops(String lineId) async {
    try {
      final response = await _apiClient.get('${Endpoints.lines}$lineId/stops/');

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
      throw ApiException('Failed to get line stops: ${e.toString()}');
    }
  }

  // Add stop to line
  Future<Map<String, dynamic>> addStopToLine({
    required String lineId,
    required String stopId,
    required int order,
    double? distanceFromPrevious,
    int? averageTimeFromPrevious,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'stop_id': stopId,
        'order': order,
      };

      if (distanceFromPrevious != null) {
        body['distance_from_previous'] = distanceFromPrevious.toString();
      }

      if (averageTimeFromPrevious != null) {
        body['average_time_from_previous'] = averageTimeFromPrevious;
      }

      final response = await _apiClient.post(
        '${Endpoints.lines}$lineId/add_stop/',
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to add stop to line: ${e.toString()}');
    }
  }

  // Remove stop from line
  Future<Map<String, dynamic>> removeStopFromLine({
    required String lineId,
    required String stopId,
  }) async {
    try {
      final response = await _apiClient.post(
        '${Endpoints.lines}$lineId/remove_stop/',
        body: {
          'stop_id': stopId,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to remove stop from line: ${e.toString()}');
    }
  }

  // Add schedule to line
  Future<Map<String, dynamic>> addSchedule({
    required String lineId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int frequencyMinutes,
  }) async {
    try {
      final response = await _apiClient.post(
        '${Endpoints.lines}$lineId/add_schedule/',
        body: {
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
          'frequency_minutes': frequencyMinutes,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to add schedule to line: ${e.toString()}');
    }
  }

  // Get line schedule
  Future<List<Map<String, dynamic>>> getLineSchedule(String lineId) async {
    try {
      final response = await _apiClient.get('${Endpoints.lines}$lineId/schedules/');

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
      throw ApiException('Failed to get line schedule: ${e.toString()}');
    }
  }
}