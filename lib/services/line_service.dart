// lib/services/line_service.dart

import '../config/api_config.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/line_model.dart';
import '../models/api_response_models.dart';

class LineService {
  final ApiClient _apiClient;

  LineService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get all lines
  Future<ApiResponse<PaginatedResponse<Line>>> getLines({
    LineQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.lines),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<Line>.fromJson(
        response,
        (json) => Line.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get lines: ${e.toString()}');
    }
  }

  // Get line by ID
  Future<ApiResponse<Line>> getLineById(String lineId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.lineById(lineId)),
      );
      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get line details: ${e.toString()}',
      );
    }
  }

  // Create new line
  Future<ApiResponse<Line>> createLine(LineCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.lines),
        body: request.toJson(),
      );

      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to create line: ${e.toString()}',
      );
    }
  }

  // Update line details
  Future<ApiResponse<Line>> updateLine(
    String lineId,
    LineUpdateRequest request,
  ) async {
    try {
      final body = request.toJson();

      if (body.isEmpty) {
        return ApiResponse.error(message: 'No data provided for update');
      }

      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.lineById(lineId)),
        body: body,
      );

      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to update line: ${e.toString()}',
      );
    }
  }

  // Delete line
  Future<ApiResponse<void>> deleteLine(String lineId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.buildUrl(ApiEndpoints.lineById(lineId)),
      );
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to delete line: ${e.toString()}',
      );
    }
  }

  // Activate line
  Future<ApiResponse<Line>> activateLine(String lineId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.activateLine(lineId)),
        body: {},
      );
      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to activate line: ${e.toString()}',
      );
    }
  }

  // Deactivate line
  Future<ApiResponse<Line>> deactivateLine(String lineId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.deactivateLine(lineId)),
        body: {},
      );
      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to deactivate line: ${e.toString()}',
      );
    }
  }

  // Add stop to line
  Future<ApiResponse<Line>> addStopToLine(
    String lineId,
    AddStopToLineRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.addStopToLine(lineId)),
        body: request.toJson(),
      );

      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to add stop to line: ${e.toString()}',
      );
    }
  }

  // Remove stop from line
  Future<ApiResponse<Line>> removeStopFromLine(
    String lineId,
    RemoveStopFromLineRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.removeStopFromLine(lineId)),
        body: request.toJson(),
      );

      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to remove stop from line: ${e.toString()}',
      );
    }
  }

  // Update stop order in line
  Future<ApiResponse<Line>> updateStopOrder(
    String lineId,
    UpdateStopOrderRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.updateStopOrder(lineId)),
        body: request.toJson(),
      );

      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to update stop order: ${e.toString()}',
      );
    }
  }

  // Get line stops
  Future<ApiResponse<Line>> getLineStops(String lineId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.lineStops(lineId)),
      );
      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get line stops: ${e.toString()}',
      );
    }
  }

  // Get line schedules
  Future<ApiResponse<Line>> getLineSchedules(String lineId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.lineSchedules(lineId)),
      );
      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get line schedules: ${e.toString()}',
      );
    }
  }

  // Add schedule to line
  Future<ApiResponse<Schedule>> addScheduleToLine(
    String lineId,
    ScheduleCreateRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.addScheduleToLine(lineId)),
        body: request.toJson(),
      );

      final schedule = Schedule.fromJson(response);
      return ApiResponse.success(data: schedule);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to add schedule to line: ${e.toString()}',
      );
    }
  }

  // Search lines
  Future<ApiResponse<List<Line>>> searchLines({String? query}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.searchLines),
        queryParameters: queryParams,
      );

      List<Line> lines = [];
      if (response is List) {
        lines = response
            .map((item) => Line.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> &&
          response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        lines = results
            .map((item) => Line.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: lines);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to search lines: ${e.toString()}',
      );
    }
  }

  // Schedule management methods

  // Get all schedules
  Future<ApiResponse<PaginatedResponse<Schedule>>> getSchedules({
    ScheduleQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.schedules),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<Schedule>.fromJson(
        response,
        (json) => Schedule.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get schedules: ${e.toString()}',
      );
    }
  }

  // Get schedule by ID
  Future<ApiResponse<Schedule>> getScheduleById(String scheduleId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.scheduleById(scheduleId)),
      );
      final schedule = Schedule.fromJson(response);
      return ApiResponse.success(data: schedule);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get schedule details: ${e.toString()}',
      );
    }
  }

  // Create schedule
  Future<ApiResponse<Schedule>> createSchedule(
    ScheduleCreateRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.schedules),
        body: request.toJson(),
      );

      final schedule = Schedule.fromJson(response);
      return ApiResponse.success(data: schedule);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to create schedule: ${e.toString()}',
      );
    }
  }

  // Update schedule
  Future<ApiResponse<Schedule>> updateSchedule(
    String scheduleId,
    ScheduleCreateRequest request,
  ) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.scheduleById(scheduleId)),
        body: request.toJson(),
      );

      final schedule = Schedule.fromJson(response);
      return ApiResponse.success(data: schedule);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to update schedule: ${e.toString()}',
      );
    }
  }

  // Delete schedule
  Future<ApiResponse<void>> deleteSchedule(String scheduleId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.buildUrl(ApiEndpoints.scheduleById(scheduleId)),
      );
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to delete schedule: ${e.toString()}',
      );
    }
  }

  /// Get all lines for admin management
  Future<ApiResponse<List<Line>>> getAllLines() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.lines),
      );

      if (response is Map<String, dynamic> && response.containsKey('results')) {
        final lines = (response['results'] as List)
            .map((json) => Line.fromJson(json))
            .toList();
        return ApiResponse.success(data: lines);
      } else if (response is List) {
        final lines = response
            .map((json) => Line.fromJson(json))
            .toList();
        return ApiResponse.success(data: lines);
      }

      return ApiResponse.error(message: 'Invalid response format');
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get all lines: ${e.toString()}',
      );
    }
  }
}
