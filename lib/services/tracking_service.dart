// lib/services/tracking_service.dart

import '../config/api_config.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/tracking_model.dart';
import '../models/api_response_models.dart';

class TrackingService {
  final ApiClient _apiClient;

  TrackingService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Anomaly management methods

  /// Get all anomalies with optional filtering
  Future<ApiResponse<PaginatedResponse<Anomaly>>> getAnomalies({
    AnomalyQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.anomalies),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<Anomaly>.fromJson(
        response,
        (json) => Anomaly.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get anomalies: ${e.toString()}');
    }
  }

  /// Get anomaly by ID
  Future<ApiResponse<Anomaly>> getAnomalyById(String anomalyId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.anomalyById(anomalyId)));
      final anomaly = Anomaly.fromJson(response);
      return ApiResponse.success(data: anomaly);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get anomaly details: ${e.toString()}');
    }
  }

  /// Create new anomaly
  Future<ApiResponse<Anomaly>> createAnomaly(AnomalyCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.anomalies),
        body: request.toJson(),
      );

      final anomaly = Anomaly.fromJson(response);
      return ApiResponse.success(data: anomaly);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to create anomaly: ${e.toString()}');
    }
  }

  /// Resolve anomaly
  Future<ApiResponse<Anomaly>> resolveAnomaly(String anomalyId, {String? resolutionNotes}) async {
    try {
      final body = <String, dynamic>{};
      if (resolutionNotes != null && resolutionNotes.isNotEmpty) {
        body['resolution_notes'] = resolutionNotes;
      }

      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.resolveAnomaly(anomalyId)),
        body: body,
      );

      final anomaly = Anomaly.fromJson(response);
      return ApiResponse.success(data: anomaly);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to resolve anomaly: ${e.toString()}');
    }
  }

  // Trip management methods

  /// Get all trips with optional filtering
  Future<ApiResponse<PaginatedResponse<Trip>>> getTrips({
    TripQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.trips),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<Trip>.fromJson(
        response,
        (json) => Trip.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get trips: ${e.toString()}');
    }
  }

  /// Get trip by ID
  Future<ApiResponse<Trip>> getTripById(String tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.tripById(tripId)));
      final trip = Trip.fromJson(response);
      return ApiResponse.success(data: trip);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get trip details: ${e.toString()}');
    }
  }

  /// Create new trip
  Future<ApiResponse<Trip>> createTrip(TripCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.trips),
        body: request.toJson(),
      );

      final trip = Trip.fromJson(response);
      return ApiResponse.success(data: trip);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to create trip: ${e.toString()}');
    }
  }

  /// End trip
  Future<ApiResponse<Trip>> endTrip(String tripId, {String? endStopId, String? notes}) async {
    try {
      final body = <String, dynamic>{};
      if (endStopId != null) body['end_stop'] = endStopId;
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;

      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.endTrip(tripId)),
        body: body,
      );

      final trip = Trip.fromJson(response);
      return ApiResponse.success(data: trip);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to end trip: ${e.toString()}');
    }
  }

  /// Get trip statistics
  Future<ApiResponse<Map<String, dynamic>>> getTripStatistics(String tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.tripStatistics(tripId)));
      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get trip statistics: ${e.toString()}');
    }
  }

  // Location tracking methods

  /// Get location updates with optional filtering
  Future<ApiResponse<PaginatedResponse<LocationUpdate>>> getLocationUpdates({
    LocationUpdateQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.locationUpdates),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<LocationUpdate>.fromJson(
        response,
        (json) => LocationUpdate.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get location updates: ${e.toString()}');
    }
  }

  /// Get location update by ID
  Future<ApiResponse<LocationUpdate>> getLocationUpdateById(String locationId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.locationUpdateById(locationId)));
      final location = LocationUpdate.fromJson(response);
      return ApiResponse.success(data: location);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get location update: ${e.toString()}');
    }
  }

  /// Create location update
  Future<ApiResponse<LocationUpdate>> createLocationUpdate(LocationUpdateCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.locationUpdates),
        body: request.toJson(),
      );

      final location = LocationUpdate.fromJson(response);
      return ApiResponse.success(data: location);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to create location update: ${e.toString()}');
    }
  }

  /// Estimate arrival time
  Future<ApiResponse<Map<String, dynamic>>> estimateArrival({
    required String busId,
    required String stopId,
  }) async {
    try {
      final queryParams = {
        'bus_id': busId,
        'stop_id': stopId,
      };

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.estimateArrival),
        queryParameters: queryParams,
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to estimate arrival: ${e.toString()}');
    }
  }

  // Bus-Line assignment methods

  /// Get bus-line assignments with optional filtering
  Future<ApiResponse<PaginatedResponse<BusLine>>> getBusLines({
    BusLineQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.busLines),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<BusLine>.fromJson(
        response,
        (json) => BusLine.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get bus-line assignments: ${e.toString()}');
    }
  }

  /// Get bus-line assignment by ID
  Future<ApiResponse<BusLine>> getBusLineById(String busLineId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.busLineById(busLineId)));
      final busLine = BusLine.fromJson(response);
      return ApiResponse.success(data: busLine);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get bus-line assignment: ${e.toString()}');
    }
  }

  /// Create bus-line assignment
  Future<ApiResponse<BusLine>> createBusLine(BusLineCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.busLines),
        body: request.toJson(),
      );

      final busLine = BusLine.fromJson(response);
      return ApiResponse.success(data: busLine);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to create bus-line assignment: ${e.toString()}');
    }
  }

  /// Start tracking for bus-line assignment
  Future<ApiResponse<BusLine>> startTracking(String busLineId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.startTracking(busLineId)),
        body: {},
      );

      final busLine = BusLine.fromJson(response);
      return ApiResponse.success(data: busLine);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to start tracking: ${e.toString()}');
    }
  }

  /// Stop tracking for bus-line assignment
  Future<ApiResponse<BusLine>> stopTracking(String busLineId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.stopTracking(busLineId)),
        body: {},
      );

      final busLine = BusLine.fromJson(response);
      return ApiResponse.success(data: busLine);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to stop tracking: ${e.toString()}');
    }
  }

  // Active tracking methods

  /// Get active buses currently being tracked
  Future<ApiResponse<List<Map<String, dynamic>>>> getActiveBuses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.activeBuses));
      
      List<Map<String, dynamic>> activeBuses = [];
      if (response is List) {
        activeBuses = response.cast<Map<String, dynamic>>();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        activeBuses = results.cast<Map<String, dynamic>>();
      }

      return ApiResponse.success(data: activeBuses);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get active buses: ${e.toString()}');
    }
  }

  /// Start bus tracking (for individual bus)
  Future<ApiResponse<Map<String, dynamic>>> startBusTracking(String busId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.startBusTracking(busId)),
        body: {},
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to start bus tracking: ${e.toString()}');
    }
  }

  /// Stop bus tracking (for individual bus)
  Future<ApiResponse<Map<String, dynamic>>> stopBusTracking(String busId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.stopBusTracking(busId)),
        body: {},
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to stop bus tracking: ${e.toString()}');
    }
  }

  /// Update passenger count for a bus
  Future<ApiResponse<Map<String, dynamic>>> updatePassengerCount({
    required String busId,
    required int count,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl('/api/v1/buses/buses/$busId/update_passenger_count/'),
        body: {'count': count},
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to update passenger count: ${e.toString()}');
    }
  }

  // Route and visualization methods

  /// Get bus route information
  Future<ApiResponse<Map<String, dynamic>>> getBusRoute({
    required String busId,
    String? lineId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'bus_id': busId};
      if (lineId != null) queryParams['line_id'] = lineId;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.busRoute),
        queryParameters: queryParams,
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get bus route: ${e.toString()}');
    }
  }

  /// Get route arrivals
  Future<ApiResponse<List<Map<String, dynamic>>>> getRouteArrivals({
    String? lineId,
    String? stopId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (lineId != null) queryParams['line_id'] = lineId;
      if (stopId != null) queryParams['stop_id'] = stopId;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.routeArrivals),
        queryParameters: queryParams,
      );

      List<Map<String, dynamic>> arrivals = [];
      if (response is List) {
        arrivals = response.cast<Map<String, dynamic>>();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        arrivals = results.cast<Map<String, dynamic>>();
      }

      return ApiResponse.success(data: arrivals);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get route arrivals: ${e.toString()}');
    }
  }

  /// Track current user location (for passenger tracking)
  Future<ApiResponse<Map<String, dynamic>>> trackMe({
    required double latitude,
    required double longitude,
    String? lineId,
  }) async {
    try {
      final body = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };
      if (lineId != null) body['line_id'] = lineId;

      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.trackMe),
        body: body,
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to track location: ${e.toString()}');
    }
  }

  /// Get route visualization data
  Future<ApiResponse<Map<String, dynamic>>> getRouteVisualization({
    String? lineId,
    String? busId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (lineId != null) queryParams['line_id'] = lineId;
      if (busId != null) queryParams['bus_id'] = busId;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.routeVisualization),
        queryParameters: queryParams,
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get route visualization: ${e.toString()}');
    }
  }

  // Additional helper methods

  /// Get recent anomalies for a specific bus
  Future<ApiResponse<List<Anomaly>>> getRecentAnomaliesForBus(String busId, {int limit = 10}) async {
    final queryParams = AnomalyQueryParameters(
      busId: busId,
      orderBy: ['-created_at'],
      pageSize: limit,
    );

    final response = await getAnomalies(queryParams: queryParams);
    if (response.isSuccess) {
      return ApiResponse.success(data: response.data?.results ?? []);
    }
    return ApiResponse.error(message: response.message);
  }

  /// Get current location for a bus
  Future<ApiResponse<LocationUpdate?>> getCurrentBusLocation(String busId) async {
    final queryParams = LocationUpdateQueryParameters(
      busId: busId,
      orderBy: ['-created_at'],
      pageSize: 1,
    );

    final response = await getLocationUpdates(queryParams: queryParams);
    if (response.isSuccess && response.data!.results.isNotEmpty) {
      return ApiResponse.success(data: response.data!.results.first);
    }
    return ApiResponse.success(data: null);
  }

  /// Get active trip for a bus
  Future<ApiResponse<Trip?>> getActiveTripForBus(String busId) async {
    final queryParams = TripQueryParameters(
      busId: busId,
      isCompleted: false,
      orderBy: ['-start_time'],
      pageSize: 1,
    );

    final response = await getTrips(queryParams: queryParams);
    if (response.isSuccess && response.data!.results.isNotEmpty) {
      return ApiResponse.success(data: response.data!.results.first);
    }
    return ApiResponse.success(data: null);
  }

  /// Get unresolved anomalies
  Future<ApiResponse<List<Anomaly>>> getUnresolvedAnomalies({int limit = 50}) async {
    final queryParams = AnomalyQueryParameters(
      resolved: false,
      orderBy: ['-created_at'],
      pageSize: limit,
    );

    final response = await getAnomalies(queryParams: queryParams);
    if (response.isSuccess) {
      return ApiResponse.success(data: response.data?.results ?? []);
    }
    return ApiResponse.error(message: response.message);
  }
}