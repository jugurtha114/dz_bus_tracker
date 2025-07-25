// lib/services/schedule_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class ScheduleService {
  final ApiClient _apiClient;

  ScheduleService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get all schedules
  Future<List<Map<String, dynamic>>> getSchedules({
    String? lineId,
    int? dayOfWeek,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (lineId != null) queryParams['line_id'] = lineId;
      if (dayOfWeek != null) queryParams['day_of_week'] = dayOfWeek;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.schedules),
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
      throw ApiException('Failed to get schedules: ${e.toString()}');
    }
  }

  // Get schedule by ID
  Future<Map<String, dynamic>> getScheduleById(String scheduleId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.scheduleById(scheduleId)),
      );
      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get schedule details: ${e.toString()}');
    }
  }

  // Create schedule
  Future<Map<String, dynamic>> createSchedule({
    required String lineId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int frequencyMinutes,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'line_id': lineId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'frequency_minutes': frequencyMinutes,
      };

      if (isActive != null) body['is_active'] = isActive;

      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.schedules),
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to create schedule: ${e.toString()}');
    }
  }

  // Update schedule
  Future<Map<String, dynamic>> updateSchedule({
    required String scheduleId,
    String? startTime,
    String? endTime,
    int? frequencyMinutes,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (startTime != null) body['start_time'] = startTime;
      if (endTime != null) body['end_time'] = endTime;
      if (frequencyMinutes != null) body['frequency_minutes'] = frequencyMinutes;
      if (isActive != null) body['is_active'] = isActive;

      if (body.isEmpty) {
        throw ApiException('No data provided for update');
      }

      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.scheduleById(scheduleId)),
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update schedule: ${e.toString()}');
    }
  }

  // Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.buildUrl(ApiEndpoints.scheduleById(scheduleId)),
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to delete schedule: ${e.toString()}');
    }
  }

  // Get driver schedules
  Future<List<Map<String, dynamic>>> getDriverSchedules({
    String? driverId,
    int? dayOfWeek,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (driverId != null) queryParams['driver_id'] = driverId;
      if (dayOfWeek != null) queryParams['day_of_week'] = dayOfWeek;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.schedules),
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
      throw ApiException('Failed to get driver schedules: ${e.toString()}');
    }
  }
}