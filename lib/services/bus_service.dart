// lib/services/bus_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/bus_model.dart';
import '../models/api_response_models.dart';

class BusService {
  final ApiClient _apiClient;

  BusService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get all buses with enhanced filtering
  Future<ApiResponse<PaginatedResponse<Bus>>> getBuses({
    BusQueryParameters? queryParams,
    String? driverId,
    bool? isActive,
    bool? isAirConditioned,
    bool? isApproved,
    String? licensePlate,
    String? manufacturer,
    String? model,
    String? status,
    int? year,
    int? minCapacity,
    int? maxCapacity,
    int? minYear,
    int? maxYear,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) async {
    try {
      // Build comprehensive query parameters
      final Map<String, dynamic> params = {};
      
      if (queryParams != null) {
        params.addAll(queryParams.toMap());
      }
      
      // Add enhanced filtering parameters
      if (driverId != null) params['driver_id'] = driverId;
      if (isActive != null) params['is_active'] = isActive;
      if (isAirConditioned != null) params['is_air_conditioned'] = isAirConditioned;
      if (isApproved != null) params['is_approved'] = isApproved;
      if (licensePlate != null) params['license_plate'] = licensePlate;
      if (manufacturer != null) params['manufacturer'] = manufacturer;
      if (model != null) params['model'] = model;
      if (status != null) params['status'] = status;
      if (year != null) params['year'] = year;
      if (minCapacity != null) params['min_capacity'] = minCapacity;
      if (maxCapacity != null) params['max_capacity'] = maxCapacity;
      if (minYear != null) params['min_year'] = minYear;
      if (maxYear != null) params['max_year'] = maxYear;
      if (orderBy != null && orderBy.isNotEmpty) params['order_by'] = orderBy;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;
      
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.buses),
        queryParameters: params,
      );

      final paginatedResponse = PaginatedResponse<Bus>.fromJson(
        response,
        (json) => Bus.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get buses: ${e.toString()}');
    }
  }

  // Get bus by ID
  Future<ApiResponse<Bus>> getBusById(String busId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.busById(busId)),
      );
      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get bus details: ${e.toString()}',
      );
    }
  }

  // Register new bus
  Future<ApiResponse<Bus>> registerBus(BusCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.buses),
        body: request.toJson(),
      );

      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to register bus: ${e.toString()}',
      );
    }
  }

  // Update bus details
  Future<ApiResponse<Bus>> updateBus(
    String busId,
    BusUpdateRequest request,
  ) async {
    try {
      final body = request.toJson();

      if (body.isEmpty) {
        return ApiResponse.error(message: 'No data provided for update');
      }

      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.busById(busId)),
        body: body,
      );

      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to update bus: ${e.toString()}',
      );
    }
  }

  // Update bus location
  Future<ApiResponse<BusLocation>> updateLocation(
    String busId,
    BusLocationUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.updateBusLocation(busId)),
        body: request.toJson(),
      );

      final location = BusLocation.fromJson(response);
      return ApiResponse.success(data: location);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to update bus location: ${e.toString()}',
      );
    }
  }

  // Update passenger count
  Future<ApiResponse<void>> updatePassengerCount(
    String busId,
    PassengerCountUpdateRequest request,
  ) async {
    try {
      await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.updatePassengerCount(busId)),
        body: request.toJson(),
      );

      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to update passenger count: ${e.toString()}',
      );
    }
  }

  // Get bus locations
  Future<ApiResponse<PaginatedResponse<BusLocation>>> getBusLocations({
    BusLocationQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.busLocations),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<BusLocation>.fromJson(
        response,
        (json) => BusLocation.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get bus locations: ${e.toString()}',
      );
    }
  }

  // Activate bus
  Future<ApiResponse<Bus>> activateBus(String busId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.activateBus(busId)),
      );
      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to activate bus: ${e.toString()}',
      );
    }
  }

  // Deactivate bus
  Future<ApiResponse<Bus>> deactivateBus(String busId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.deactivateBus(busId)),
      );
      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to deactivate bus: ${e.toString()}',
      );
    }
  }

  // Start bus tracking
  Future<ApiResponse<void>> startTracking(String busId) async {
    try {
      await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.startBusTracking(busId)),
      );
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to start bus tracking: ${e.toString()}',
      );
    }
  }

  // Stop bus tracking
  Future<ApiResponse<void>> stopTracking(String busId) async {
    try {
      await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.stopBusTracking(busId)),
      );
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to stop bus tracking: ${e.toString()}',
      );
    }
  }

  // Approve bus
  Future<ApiResponse<Bus>> approveBus(
    String busId,
    BusApprovalRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.approveBus(busId)),
        body: request.toJson(),
      );

      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message:
            'Failed to ${request.approve ? 'approve' : 'reject'} bus: ${e.toString()}',
      );
    }
  }

  /// Get all buses for admin management with filtering
  Future<ApiResponse<List<Bus>>> getAllBuses({
    bool? isApproved,
    bool? isActive,
    String? status,
    String? manufacturer,
    int? pageSize = 100, // Get more buses for admin view
  }) async {
    try {
      final Map<String, dynamic> params = {};
      
      if (isApproved != null) params['is_approved'] = isApproved;
      if (isActive != null) params['is_active'] = isActive;
      if (status != null) params['status'] = status;
      if (manufacturer != null) params['manufacturer'] = manufacturer;
      if (pageSize != null) params['page_size'] = pageSize;
      
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.buses),
        queryParameters: params,
      );

      if (response is Map<String, dynamic> && response.containsKey('results')) {
        final buses = (response['results'] as List)
            .map((json) => Bus.fromJson(json))
            .toList();
        return ApiResponse.success(data: buses);
      } else if (response is List) {
        final buses = response
            .map((json) => Bus.fromJson(json))
            .toList();
        return ApiResponse.success(data: buses);
      }

      return ApiResponse.error(message: 'Invalid response format');
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to get all buses: ${e.toString()}',
      );
    }
  }

  /// Get pending buses for approval
  Future<ApiResponse<List<Bus>>> getPendingBuses() async {
    return getAllBuses(
      isApproved: false,
      isActive: true,
      pageSize: 50,
    );
  }
  
  /// Get active approved buses
  Future<ApiResponse<List<Bus>>> getActiveBuses() async {
    return getAllBuses(
      isApproved: true,
      isActive: true,
      status: 'active',
      pageSize: 100,
    );
  }
  
  /// Get buses by driver
  Future<ApiResponse<List<Bus>>> getBusesByDriver(String driverId) async {
    try {
      final result = await getBuses(
        driverId: driverId,
        pageSize: 20,
      );
      
      if (result.isSuccess && result.data != null) {
        return ApiResponse.success(data: result.data!.results);
      }
      
      return ApiResponse.error(message: result.message ?? 'Failed to get buses');
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to get buses by driver: ${e.toString()}',
      );
    }
  }
  
  /// Approve bus for admin (simplified version)
  Future<ApiResponse<Bus>> approveBusSimple(String busId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl('${ApiEndpoints.buses}/$busId/approve/'),
        body: {'approve': true},
      );
      
      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to approve bus: ${e.toString()}',
      );
    }
  }

  /// Reject bus for admin
  Future<ApiResponse<Bus>> rejectBus(String busId, String reason) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl('${ApiEndpoints.buses}/$busId/approve/'),
        body: {
          'approve': false,
          'reason': reason,
        },
      );
      
      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(
        message: 'Failed to reject bus: ${e.toString()}',
      );
    }
  }
}
