/// lib/data/data_sources/remote/tracking_remote_data_source.dart

import 'package:collection/collection.dart'; // For firstWhereOrNull

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/location_service.dart'; // For LocationUpdateData
import '../../../core/typedefs/common_types.dart'; // For JsonMap
import '../../../core/utils/logger.dart';
import '../../models/api_response.dart';
import '../../models/location_update_model.dart';
import '../../models/tracking_session_model.dart';

/// Abstract interface for remote data operations related to Tracking.
/// Defines methods for interacting with tracking session and location update API endpoints.
abstract class TrackingRemoteDataSource {
  /// Calls the API to start a new tracking session.
  Future<TrackingSessionModel> startTrackingSession({
    required String busId,
    required String lineId,
    String? scheduleId,
  });

  /// Calls the API to stop an existing tracking session.
  Future<TrackingSessionModel> stopTrackingSession(String sessionId);

  /// Calls the API to pause an existing tracking session.
  Future<TrackingSessionModel> pauseTrackingSession(String sessionId);

  /// Calls the API to resume a paused tracking session.
  Future<TrackingSessionModel> resumeTrackingSession(String sessionId);

  /// Fetches the currently active tracking session for the authenticated driver.
  /// Returns null if no active session is found.
  Future<TrackingSessionModel?> getActiveTrackingSession();

  /// Sends a single location update to the API for a given session.
  /// Returns the created [LocationUpdateModel].
  Future<LocationUpdateModel> sendLocationUpdate({
    required String sessionId,
    required LocationUpdateData locationData,
  });

  /// Sends a batch of location updates to the API for a given session.
  Future<void> sendBatchLocationUpdates({
    required String sessionId,
    required List<LocationUpdateData> locations,
  });

  /// Fetches the most recent location update for a given session.
  /// Returns null if no location has been recorded yet.
  Future<LocationUpdateModel?> getCurrentTrackingLocation(String sessionId);

  /// Fetches a paginated history of tracking sessions.
  Future<ApiResponse<TrackingSessionModel>> getTrackingSessionHistory({
    String? driverId,
    String? busId,
    String? lineId,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches a paginated history of location updates for a specific session.
  Future<ApiResponse<LocationUpdateModel>> getTrackingSessionLocationUpdates(
    String sessionId, {
    int page = 1,
    int pageSize = 50, // Potentially fetch more locations per page
  });
}

/// Implementation of [TrackingRemoteDataSource] using the core [ApiClient].
/// Makes specific API calls for tracking management tasks.
class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final ApiClient _apiClient;

  /// Creates an instance of [TrackingRemoteDataSourceImpl].
  /// Requires an instance of [ApiClient] to make HTTP requests.
  const TrackingRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<TrackingSessionModel> startTrackingSession({
    required String busId,
    required String lineId,
    String? scheduleId,
  }) async {
    Log.d('TrackingRemoteDataSource: Calling start tracking session API.');
    // API expects StartTrackingRequest schema
    final payload = <String, dynamic>{
      'bus': busId,
      'line': lineId,
      if (scheduleId != null) 'schedule': scheduleId,
    };
    final response = await _apiClient.post(
      ApiConstants.trackingSessionStart,
      data: payload,
    );
    return TrackingSessionModel.fromJson(response.data);
  }

  @override
  Future<TrackingSessionModel> stopTrackingSession(String sessionId) async {
    Log.d('TrackingRemoteDataSource: Calling stop tracking session API for ID: $sessionId.');
    final response = await _apiClient.post(ApiConstants.trackingSessionEnd(sessionId));
    return TrackingSessionModel.fromJson(response.data);
  }

  @override
  Future<TrackingSessionModel> pauseTrackingSession(String sessionId) async {
     Log.d('TrackingRemoteDataSource: Calling pause tracking session API for ID: $sessionId.');
     final response = await _apiClient.post(ApiConstants.trackingSessionPause(sessionId));
     return TrackingSessionModel.fromJson(response.data);
  }

  @override
  Future<TrackingSessionModel> resumeTrackingSession(String sessionId) async {
      Log.d('TrackingRemoteDataSource: Calling resume tracking session API for ID: $sessionId.');
      final response = await _apiClient.post(ApiConstants.trackingSessionResume(sessionId));
      return TrackingSessionModel.fromJson(response.data);
  }

  @override
  Future<TrackingSessionModel?> getActiveTrackingSession() async {
     Log.d('TrackingRemoteDataSource: Calling get active tracking session API.');
     // API endpoint /tracking-sessions/active/ likely returns a list,
     // but for a single driver, there should only be zero or one active/paused session.
     try {
       final response = await _apiClient.get(ApiConstants.trackingSessionsActive);
       // Assuming API returns a list, even if usually just one for the current user
       final List<dynamic> results = response.data as List<dynamic>;
       final activeSessionJson = results.firstWhereOrNull(
         (json) => json is Map<String, dynamic> // Ensure it's a map
       );
       if (activeSessionJson != null) {
         return TrackingSessionModel.fromJson(activeSessionJson);
       }
       return null; // No active session found
     } catch (e) {
        // Handle potential errors like 404 Not Found if endpoint assumes one exists
        Log.w('Error fetching active tracking session (maybe none active?)', error: e);
        return null;
     }
  }

  @override
  Future<LocationUpdateModel> sendLocationUpdate({
    required String sessionId,
    required LocationUpdateData locationData,
  }) async {
     Log.v('TrackingRemoteDataSource: Calling send location update API.'); // Verbose log
     // API expects LocationUpdateCreateRequest schema
     final payload = <String, dynamic>{
        'session': sessionId,
        ...locationData.toJson(), // Spread the map from LocationUpdateData
     };
     final response = await _apiClient.post(
       ApiConstants.locationUpdates,
       data: payload,
       // useMsgpack: true, // Prefer Msgpack for location data
     );
     return LocationUpdateModel.fromJson(response.data);
  }

  @override
  Future<void> sendBatchLocationUpdates({
    required String sessionId,
    required List<LocationUpdateData> locations,
  }) async {
      Log.d('TrackingRemoteDataSource: Calling send batch location updates API.');
      // API expects BatchLocationUpdateCreateRequest schema
      final payload = <String, dynamic>{
         'session_id': sessionId, // Check if API uses session or session_id here
         'locations': locations.map((loc) => loc.toJson()).toList(),
      };
      await _apiClient.post(
        ApiConstants.batchLocationUpdate,
        data: payload,
        // useMsgpack: true, // Prefer Msgpack for batch location data
      );
      // No response body expected on success (201 Created often)
  }

  @override
  Future<LocationUpdateModel?> getCurrentTrackingLocation(String sessionId) async {
    Log.d('TrackingRemoteDataSource: Calling get current tracking location API for session: $sessionId.');
     try {
       final response = await _apiClient.get(ApiConstants.trackingSessionCurrentLocation(sessionId));
       if (response.data != null) {
         return LocationUpdateModel.fromJson(response.data);
       }
       return null;
     } catch (e) {
        // Handle potential errors like 404 Not Found if no location yet
        Log.w('Error fetching current location for session $sessionId (maybe none recorded?)', error: e);
        return null;
     }
  }

  @override
  Future<ApiResponse<TrackingSessionModel>> getTrackingSessionHistory({
    String? driverId,
    String? busId,
    String? lineId,
    int page = 1,
    int pageSize = 20,
  }) async {
     Log.d('TrackingRemoteDataSource: Calling get tracking session history API.');
     final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (driverId != null) 'driver_id': driverId, // Adjust param names based on API
      if (busId != null) 'bus_id': busId,
      if (lineId != null) 'line_id': lineId,
     };
     final response = await _apiClient.get(
       ApiConstants.trackingSessions, // Base endpoint for listing
       queryParameters: queryParameters,
     );
     return ApiResponse<TrackingSessionModel>.fromJson(
       response.data,
       (json) => TrackingSessionModel.fromJson(json as Map<String, dynamic>),
     );
  }

   @override
  Future<ApiResponse<LocationUpdateModel>> getTrackingSessionLocationUpdates(
    String sessionId, {
    int page = 1,
    int pageSize = 50,
  }) async {
      Log.d('TrackingRemoteDataSource: Calling get tracking session location updates API for session: $sessionId.');
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      final response = await _apiClient.get(
        ApiConstants.trackingSessionLocationUpdates(sessionId),
        queryParameters: queryParameters,
      );
      // API returns PaginatedLocationUpdateList
      return ApiResponse<LocationUpdateModel>.fromJson(
        response.data,
        (json) => LocationUpdateModel.fromJson(json as Map<String, dynamic>),
      );
  }
}
