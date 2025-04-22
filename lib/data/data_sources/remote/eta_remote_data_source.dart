/// lib/data/data_sources/remote/eta_remote_data_source.dart

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/typedefs/common_types.dart'; // For JsonMap
import '../../../core/utils/logger.dart';
import '../../models/api_response.dart';
import '../../models/eta_model.dart';

/// Abstract interface for remote data operations related to Estimated Times of Arrival (ETAs).
/// Defines methods for interacting with ETA-specific API endpoints.
abstract class EtaRemoteDataSource {
  /// Fetches ETAs for a specific line, optionally filtered by stop.
  Future<List<EtaModel>> getEtasForLine(String lineId, {String? stopId});

  /// Fetches ETAs for a specific stop, optionally filtered by line.
  Future<List<EtaModel>> getEtasForStop(String stopId, {String? lineId});

  /// Fetches ETAs for a specific bus.
  Future<List<EtaModel>> getEtasForBus(String busId);

  /// Fetches the next upcoming arrivals, optionally filtered and limited.
  Future<List<EtaModel>> getNextArrivals({
    String? lineId,
    String? stopId,
    int limit = 5,
  });

  /// Fetches a paginated list of currently delayed ETAs.
  Future<ApiResponse<EtaModel>> getDelayedEtas({
    int page = 1,
    int pageSize = 20,
  });
}

/// Implementation of [EtaRemoteDataSource] using the core [ApiClient].
/// Makes specific API calls for fetching ETA data.
class EtaRemoteDataSourceImpl implements EtaRemoteDataSource {
  final ApiClient _apiClient;

  /// Creates an instance of [EtaRemoteDataSourceImpl].
  /// Requires an instance of [ApiClient] to make HTTP requests.
  const EtaRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Helper method to parse a list of ETAs from API response data.
  List<EtaModel> _parseEtaList(dynamic responseData) {
    if (responseData is List) {
      return responseData
          .map((json) => EtaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // Handle cases where API might unexpectedly not return a list
      Log.w('Expected a List for ETAs but received ${responseData.runtimeType}');
      return [];
    }
  }

  @override
  Future<List<EtaModel>> getEtasForLine(String lineId, {String? stopId}) async {
    Log.d('EtaRemoteDataSource: Calling get ETAs for line API. Line: $lineId, Stop: $stopId');
    final queryParameters = <String, dynamic>{
      'line_id': lineId,
      if (stopId != null) 'stop_id': stopId,
    };
    // Remove null values before sending query parameters
    queryParameters.removeWhere((key, value) => value == null);

    final response = await _apiClient.get(
      ApiConstants.etaForLine,
      queryParameters: queryParameters,
    );
    return _parseEtaList(response.data);
  }

  @override
  Future<List<EtaModel>> getEtasForStop(String stopId, {String? lineId}) async {
    Log.d('EtaRemoteDataSource: Calling get ETAs for stop API. Stop: $stopId, Line: $lineId');
    final queryParameters = <String, dynamic>{
      'stop_id': stopId,
      if (lineId != null) 'line_id': lineId,
    };
    queryParameters.removeWhere((key, value) => value == null);

    final response = await _apiClient.get(
      ApiConstants.etaForStop,
      queryParameters: queryParameters,
    );
    return _parseEtaList(response.data);
  }

  @override
  Future<List<EtaModel>> getEtasForBus(String busId) async {
    Log.d('EtaRemoteDataSource: Calling get ETAs for bus API. Bus: $busId');
    final queryParameters = <String, dynamic>{
      'bus_id': busId,
    };
    final response = await _apiClient.get(
      ApiConstants.etaForBus,
      queryParameters: queryParameters,
    );
    return _parseEtaList(response.data);
  }

  @override
  Future<List<EtaModel>> getNextArrivals({
    String? lineId,
    String? stopId,
    int limit = 5,
  }) async {
    Log.d('EtaRemoteDataSource: Calling get next arrivals API. Line: $lineId, Stop: $stopId, Limit: $limit');
    final queryParameters = <String, dynamic>{
      'limit': limit,
      if (lineId != null) 'line_id': lineId,
      if (stopId != null) 'stop_id': stopId,
    };
    queryParameters.removeWhere((key, value) => value == null);

    final response = await _apiClient.get(
      ApiConstants.etaNextArrivals,
      queryParameters: queryParameters,
    );
    return _parseEtaList(response.data);
  }

  @override
  Future<ApiResponse<EtaModel>> getDelayedEtas({
    int page = 1,
    int pageSize = 20,
  }) async {
    Log.d('EtaRemoteDataSource: Calling get delayed ETAs API. Page: $page');
    final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    final response = await _apiClient.get(
      ApiConstants.etaDelayed,
      queryParameters: queryParameters,
    );
    // Assuming response.data is Map<String, dynamic> for paginated response
    return ApiResponse<EtaModel>.fromJson(
      response.data as JsonMap, // Cast needed for type safety
      (json) => EtaModel.fromJson(json as JsonMap),
    );
  }
}
