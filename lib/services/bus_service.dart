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

  // Get all buses
  Future<ApiResponse<PaginatedResponse<Bus>>> getBuses({
    BusQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.buses),
        queryParameters: queryParams?.toMap(),
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
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.busById(busId)));
      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get bus details: ${e.toString()}');
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
      return ApiResponse.error(message: 'Failed to register bus: ${e.toString()}');
    }
  }

  // Update bus details
  Future<ApiResponse<Bus>> updateBus(String busId, BusUpdateRequest request) async {
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
      return ApiResponse.error(message: 'Failed to update bus: ${e.toString()}');
    }
  }

  // Update bus location
  Future<ApiResponse<BusLocation>> updateLocation(String busId, BusLocationUpdateRequest request) async {
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
      return ApiResponse.error(message: 'Failed to update bus location: ${e.toString()}');
    }
  }

  // Update passenger count
  Future<ApiResponse<void>> updatePassengerCount(String busId, PassengerCountUpdateRequest request) async {
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
      return ApiResponse.error(message: 'Failed to update passenger count: ${e.toString()}');
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
      return ApiResponse.error(message: 'Failed to get bus locations: ${e.toString()}');
    }
  }

  // Activate bus
  Future<ApiResponse<Bus>> activateBus(String busId) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.buildUrl(ApiEndpoints.activateBus(busId)));
      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to activate bus: ${e.toString()}');
    }
  }

  // Deactivate bus
  Future<ApiResponse<Bus>> deactivateBus(String busId) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.buildUrl(ApiEndpoints.deactivateBus(busId)));
      final bus = Bus.fromJson(response);
      return ApiResponse.success(data: bus);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to deactivate bus: ${e.toString()}');
    }
  }

  // Start bus tracking
  Future<ApiResponse<void>> startTracking(String busId) async {
    try {
      await _apiClient.post(ApiEndpoints.buildUrl(ApiEndpoints.startBusTracking(busId)));
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to start bus tracking: ${e.toString()}');
    }
  }

  // Stop bus tracking
  Future<ApiResponse<void>> stopTracking(String busId) async {
    try {
      await _apiClient.post(ApiEndpoints.buildUrl(ApiEndpoints.stopBusTracking(busId)));
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to stop bus tracking: ${e.toString()}');
    }
  }

  // Approve bus
  Future<ApiResponse<Bus>> approveBus(String busId, BusApprovalRequest request) async {
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
      return ApiResponse.error(message: 'Failed to ${request.approve ? 'approve' : 'reject'} bus: ${e.toString()}');
    }
  }
}