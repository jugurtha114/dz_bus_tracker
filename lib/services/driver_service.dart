// lib/services/driver_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/driver_model.dart';
import '../models/api_response_models.dart' hide DriverRatingQueryParameters;
import '../models/driver_model.dart' show DriverRatingQueryParameters;

class DriverService {
  final ApiClient _apiClient;

  DriverService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get driver profile
  Future<ApiResponse<Driver>> getDriverProfile() async {
    try {
      // First, get the user ID
      final userResponse = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.currentUser));

      if (!userResponse.containsKey('id')) {
        return ApiResponse.error(message: 'Failed to get user ID');
      }

      // Then get the driver details
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.drivers),
        queryParameters: {
          'user_id': userResponse['id'],
        },
      );

      if (response is Map<String, dynamic> && response.containsKey(ApiConstants.resultsKey)) {
        final drivers = List<Map<String, dynamic>>.from(response[ApiConstants.resultsKey]);

        if (drivers.isNotEmpty) {
          final driver = Driver.fromJson(drivers.first);
          return ApiResponse.success(data: driver);
        }
      }

      return ApiResponse.error(message: 'Driver profile not found');
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get driver profile: ${e.toString()}');
    }
  }

  // Update driver profile
  Future<ApiResponse<Driver>> updateProfile(String driverId, DriverUpdateRequest request) async {
    try {
      final body = request.toJson();
      
      if (body.isEmpty) {
        return ApiResponse.error(message: 'No data provided for update');
      }

      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.driverById(driverId)),
        body: body,
      );

      final driver = Driver.fromJson(response);
      return ApiResponse.success(data: driver);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to update driver profile: ${e.toString()}');
    }
  }

  // Get driver ratings
  Future<ApiResponse<PaginatedResponse<DriverRating>>> getRatings({
    String? driverId,
    DriverRatingQueryParameters? queryParams,
  }) async {
    try {
      String endpoint = driverId != null 
          ? ApiEndpoints.driverRatings(driverId)
          : ApiEndpoints.driverRatings('');
      
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(endpoint),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<DriverRating>.fromJson(
        response,
        (json) => DriverRating.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get driver ratings: ${e.toString()}');
    }
  }

  // Update driver availability
  Future<ApiResponse<Driver>> updateAvailability(String driverId, DriverAvailabilityRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.updateDriverAvailability(driverId)),
        body: request.toJson(),
      );

      final driver = Driver.fromJson(response);
      return ApiResponse.success(data: driver);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to update driver availability: ${e.toString()}');
    }
  }

  // Rate a driver
  Future<ApiResponse<DriverRating>> rateDriver(String driverId, DriverRatingCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.driverRatings(driverId)),
        body: request.toJson(),
      );

      final rating = DriverRating.fromJson(response);
      return ApiResponse.success(data: rating);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to rate driver: ${e.toString()}');
    }
  }

  // Approve driver
  Future<ApiResponse<Driver>> approveDriver(String driverId, DriverApprovalRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.approveDriver(driverId)),
        body: request.toJson(),
      );
      
      final driver = Driver.fromJson(response);
      return ApiResponse.success(data: driver);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to ${request.approve ? 'approve' : 'reject'} driver: ${e.toString()}');
    }
  }

  // Reject driver (separate endpoint)
  Future<ApiResponse<Driver>> rejectDriver(String driverId, DriverApprovalRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.rejectDriver(driverId)),
        body: request.toJson(),
      );
      
      final driver = Driver.fromJson(response);
      return ApiResponse.success(data: driver);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to reject driver: ${e.toString()}');
    }
  }

  // Get all drivers (for admin)
  Future<ApiResponse<PaginatedResponse<Driver>>> getDrivers({
    DriverQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.drivers),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<Driver>.fromJson(
        response,
        (json) => Driver.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get drivers: ${e.toString()}');
    }
  }

  // Get driver by ID
  Future<ApiResponse<Driver>> getDriverById(String driverId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.driverById(driverId)));
      final driver = Driver.fromJson(response);
      return ApiResponse.success(data: driver);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get driver details: ${e.toString()}');
    }
  }
}