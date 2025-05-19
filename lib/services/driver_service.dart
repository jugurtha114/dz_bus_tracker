// lib/services/driver_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class DriverService {
  final ApiClient _apiClient;

  DriverService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get driver profile
  Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      // First, get the user ID
      final userResponse = await _apiClient.get(Endpoints.currentUser);

      if (!userResponse.containsKey('id')) {
        throw ApiException('Failed to get user ID');
      }

      // Then get the driver details
      final response = await _apiClient.get(
        Endpoints.drivers,
        queryParameters: {
          'user_id': userResponse['id'],
        },
      );

      if (response is Map<String, dynamic> && response.containsKey(ApiConstants.resultsKey)) {
        final drivers = List<Map<String, dynamic>>.from(response[ApiConstants.resultsKey]);

        if (drivers.isNotEmpty) {
          return drivers.first;
        }
      }

      throw ApiException('Driver profile not found');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get driver profile: ${e.toString()}');
    }
  }

  // Update driver profile
  Future<Map<String, dynamic>> updateProfile({
    required String driverId,
    String? phoneNumber,
    int? yearsOfExperience,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (yearsOfExperience != null) body['years_of_experience'] = yearsOfExperience;

      if (body.isEmpty) {
        throw ApiException('No data provided for update');
      }

      final response = await _apiClient.patch(
        '${Endpoints.drivers}$driverId/',
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update driver profile: ${e.toString()}');
    }
  }

  // Get driver ratings
  Future<List<Map<String, dynamic>>> getRatings(String driverId) async {
    try {
      final response = await _apiClient.get('${Endpoints.drivers}$driverId/ratings/');

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
      throw ApiException('Failed to get driver ratings: ${e.toString()}');
    }
  }

  // Update driver availability
  Future<Map<String, dynamic>> updateAvailability({
    required String driverId,
    required bool isAvailable,
  }) async {
    try {
      final response = await _apiClient.post(
        '${Endpoints.drivers}$driverId/update_availability/',
        body: {
          'is_available': isAvailable,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to update driver availability: ${e.toString()}');
    }
  }

  // Rate a driver
  Future<Map<String, dynamic>> rateDriver({
    required String driverId,
    required int rating,
    String? comment,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'rating': rating,
      };

      if (comment != null) body['comment'] = comment;

      final response = await _apiClient.post(
        '${Endpoints.drivers}$driverId/ratings/',
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to rate driver: ${e.toString()}');
    }
  }
}