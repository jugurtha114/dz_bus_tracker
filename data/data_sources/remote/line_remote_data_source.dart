/// lib/data/data_sources/remote/line_remote_data_source.dart

import 'package:dio/dio.dart'; // For Response, Map

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/typedefs/common_types.dart'; // For JsonMap
import '../../../core/utils/logger.dart';
import '../../models/api_response.dart';
import '../../models/bus_model.dart';
import '../../models/line_detail_model.dart';
import '../../models/line_model.dart';
import '../../models/stop_model.dart';

/// Abstract interface for remote data operations related to Bus Lines and Stops.
/// Defines methods for interacting with line and stop specific API endpoints.
abstract class LineRemoteDataSource {
  Future<ApiResponse<LineModel>> getLines({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    bool? isActive,
    bool? withActiveBuses,
  });
  Future<LineDetailModel> getLineDetails(String lineId);
  Future<List<StopModel>> getStopsForLine(String lineId);
  Future<List<BusModel>> getBusesForLine(String lineId);
  Future<List<LineModel>> getLinesForStop(String stopId);
  Future<List<StopModel>> getNearestStops({
    required double latitude,
    required double longitude,
    double? radiusMeters,
  });
  Future<List<StopModel>> searchStops(String query);
  Future<StopModel> getStopDetails(String stopId); // <-- Added Method Signature
  Future<bool> isLineFavorite(String lineId);
  Future<void> addFavorite(String lineId, {int? notificationThresholdMinutes});
  Future<void> removeFavorite(String lineId);
  Future<LineModel> createLine(JsonMap lineData);
  Future<LineModel> updateLine(String lineId, JsonMap updateData);
  Future<void> deleteLine(String lineId);
  Future<void> addStopToLine(String lineId, String stopId, int order);
  Future<void> removeStopFromLine(String lineId, String stopId);
  Future<void> reorderStopsForLine(String lineId, List<String> orderedStopIds);
  Future<void> addBusToLine(String lineId, String busId);
  Future<void> removeBusFromLine(String lineId, String busId);
  Future<StopModel> createStop(JsonMap stopData);
  Future<StopModel> updateStop(String stopId, JsonMap updateData);
  Future<void> deleteStop(String stopId);
}


/// Implementation of [LineRemoteDataSource] using the core [ApiClient].
/// Makes specific API calls for line and stop management tasks.
class LineRemoteDataSourceImpl implements LineRemoteDataSource {
  final ApiClient _apiClient;

  const LineRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  // ... [Previous methods implementation - getLines, getLineDetails, etc.] ...
  // (Keep previous method implementations as they were)

   @override
  Future<ApiResponse<LineModel>> getLines({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    bool? isActive,
    bool? withActiveBuses,
  }) async {
    Log.d('LineRemoteDataSource: Calling get lines API.');
    final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
      if (isActive != null) 'is_active': isActive,
      if (withActiveBuses != null) 'with_active_buses': withActiveBuses,
    };
    queryParameters.removeWhere((key, value) => value == null);
    String endpoint = ApiConstants.lines;
    final response = await _apiClient.get(endpoint, queryParameters: queryParameters);
    return ApiResponse<LineModel>.fromJson(
      response.data,
      (json) => LineModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<LineDetailModel> getLineDetails(String lineId) async {
     Log.d('LineRemoteDataSource: Calling get line details API for ID: $lineId.');
     final response = await _apiClient.get(ApiConstants.lineDetail(lineId));
     return LineDetailModel.fromJson(response.data);
  }

  @override
  Future<List<StopModel>> getStopsForLine(String lineId) async {
      Log.d('LineRemoteDataSource: Calling get stops for line API for ID: $lineId.');
      final response = await _apiClient.get(ApiConstants.lineStops(lineId));
      final List<dynamic> results = response.data as List<dynamic>;
      return results.map((json) => StopModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<BusModel>> getBusesForLine(String lineId) async {
      Log.d('LineRemoteDataSource: Calling get buses for line API for ID: $lineId.');
      final response = await _apiClient.get(ApiConstants.lineBuses(lineId));
       final List<dynamic> results = response.data as List<dynamic>;
      return results.map((json) => BusModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<LineModel>> getLinesForStop(String stopId) async {
     Log.d('LineRemoteDataSource: Calling get lines for stop API for ID: $stopId.');
     final response = await _apiClient.get(
         ApiConstants.linesForStop,
         queryParameters: {'stop_id': stopId}
      );
      final List<dynamic> results = response.data as List<dynamic>;
      return results.map((json) => LineModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<StopModel>> getNearestStops({required double latitude, required double longitude, double? radiusMeters}) async {
     Log.d('LineRemoteDataSource: Calling get nearest stops API for $latitude, $longitude.');
     final queryParameters = <String, dynamic>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (radiusMeters != null) 'radius_m': radiusMeters,
     };
     queryParameters.removeWhere((key, value) => value == null);
     final response = await _apiClient.get(
         ApiConstants.stopsNearest,
         queryParameters: queryParameters
      );
     final List<dynamic> results = response.data as List<dynamic>;
     return results.map((json) => StopModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<StopModel>> searchStops(String query) async {
     Log.d('LineRemoteDataSource: Calling search stops API with query: "$query".');
     final response = await _apiClient.get(
         ApiConstants.stopsSearch,
         queryParameters: {'search': query}
      );
     final List<dynamic> results = response.data as List<dynamic>;
     return results.map((json) => StopModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<StopModel> getStopDetails(String stopId) async { // <-- Added Method Implementation
    Log.d('LineRemoteDataSource: Calling get stop details API for ID: $stopId.');
    final response = await _apiClient.get(ApiConstants.stopDetail(stopId));
    return StopModel.fromJson(response.data);
  }

  @override
  Future<bool> isLineFavorite(String lineId) async {
     Log.d('LineRemoteDataSource: Calling is line favorite API for ID: $lineId.');
     try {
        final response = await _apiClient.get(ApiConstants.lineIsFavorite(lineId));
        if (response.data is Map<String, dynamic> && response.data.containsKey('is_favorite')) {
           return response.data['is_favorite'] as bool;
        }
        Log.w('Unexpected response format for isLineFavorite: ${response.data}');
        return false;
     } catch (e) {
         Log.e('Error checking favorite status for line $lineId', error: e);
        return false;
     }
  }

  @override
  Future<void> addFavorite(String lineId, {int? notificationThresholdMinutes}) async {
      Log.d('LineRemoteDataSource: Calling add favorite API for ID: $lineId.');
      final payload = <String, dynamic>{
         if (notificationThresholdMinutes != null) 'notification_threshold': notificationThresholdMinutes,
      };
      await _apiClient.post(ApiConstants.lineFavorite(lineId), data: payload);
  }

  @override
  Future<void> removeFavorite(String lineId) async {
       Log.d('LineRemoteDataSource: Calling remove favorite API for ID: $lineId.');
       await _apiClient.post(ApiConstants.lineUnfavorite(lineId));
  }

  // --- Admin / Management Methods Implementation ---
  @override
  Future<LineModel> createLine(JsonMap lineData) async {
     Log.d('LineRemoteDataSource: Calling create line API.');
     final response = await _apiClient.post(ApiConstants.lines, data: lineData);
     return LineModel.fromJson(response.data);
  }

  @override
  Future<LineModel> updateLine(String lineId, JsonMap updateData) async {
      Log.d('LineRemoteDataSource: Calling update line API (PATCH) for ID: $lineId.');
      final response = await _apiClient.patch(ApiConstants.lineDetail(lineId), data: updateData);
      return LineModel.fromJson(response.data);
  }

   @override
  Future<void> deleteLine(String lineId) async {
     Log.d('LineRemoteDataSource: Calling delete line API for ID: $lineId.');
     await _apiClient.delete(ApiConstants.lineDetail(lineId));
  }

  @override
  Future<void> addStopToLine(String lineId, String stopId, int order) async {
     Log.d('LineRemoteDataSource: Calling add stop to line API for Line: $lineId, Stop: $stopId.');
     await _apiClient.post(ApiConstants.lineAddStop(lineId), data: {'stop_id': stopId, 'order': order});
  }

   @override
  Future<void> removeStopFromLine(String lineId, String stopId) async {
     Log.d('LineRemoteDataSource: Calling remove stop from line API for Line: $lineId, Stop: $stopId.');
     await _apiClient.post(ApiConstants.lineRemoveStop(lineId), data: {'stop_id': stopId});
  }

  @override
  Future<void> reorderStopsForLine(String lineId, List<String> orderedStopIds) async {
      Log.d('LineRemoteDataSource: Calling reorder stops for line API for Line: $lineId.');
      await _apiClient.post(ApiConstants.lineReorderStops(lineId), data: {'ordered_stop_ids': orderedStopIds});
  }

  @override
  Future<void> addBusToLine(String lineId, String busId) async {
     Log.d('LineRemoteDataSource: Calling add bus to line API for Line: $lineId, Bus: $busId.');
     await _apiClient.post(ApiConstants.lineAddBus(lineId), data: {'bus_id': busId});
  }

  @override
  Future<void> removeBusFromLine(String lineId, String busId) async {
     Log.d('LineRemoteDataSource: Calling remove bus from line API for Line: $lineId, Bus: $busId.');
     await _apiClient.post(ApiConstants.lineRemoveBus(lineId), data: {'bus_id': busId});
  }

   @override
  Future<StopModel> createStop(JsonMap stopData) async {
     Log.d('LineRemoteDataSource: Calling create stop API.');
     final response = await _apiClient.post(ApiConstants.stops, data: stopData);
     return StopModel.fromJson(response.data);
  }

  @override
  Future<StopModel> updateStop(String stopId, JsonMap updateData) async {
      Log.d('LineRemoteDataSource: Calling update stop API (PATCH) for ID: $stopId.');
       final response = await _apiClient.patch(ApiConstants.stopDetail(stopId), data: updateData);
      return StopModel.fromJson(response.data);
  }

  @override
  Future<void> deleteStop(String stopId) async {
     Log.d('LineRemoteDataSource: Calling delete stop API for ID: $stopId.');
      await _apiClient.delete(ApiConstants.stopDetail(stopId));
  }
}
