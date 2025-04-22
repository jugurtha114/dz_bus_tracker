/// lib/data/data_sources/remote/bus_remote_data_source.dart

import 'package:dio/dio.dart'; // For FormData, Response, Map

import '../../../core/constants/api_constants.dart';
import '../../../core/enums/maintenance_type.dart';
import '../../../core/enums/photo_type.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../models/api_response.dart';
import '../../models/bus_maintenance_model.dart';
import '../../models/bus_model.dart';
import '../../models/bus_photo_model.dart';
import '../../models/bus_verification_model.dart';

/// Abstract interface for remote data operations related to Buses.
/// Defines methods for interacting with bus-specific API endpoints.
abstract class BusRemoteDataSource {
  /// Fetches a paginated list of buses from the API.
  Future<ApiResponse<BusModel>> getBuses({
    int page = 1,
    int pageSize = 20,
    String? driverId,
    bool? isVerified,
    bool? isActive,
    String? searchQuery,
  });

  /// Fetches the list of buses assigned to the current authenticated driver.
  Future<List<BusModel>> getDriverBuses();

  /// Fetches detailed information for a specific bus by its ID.
  Future<BusModel> getBusDetails(String busId);

  /// Creates a new bus via the API using multipart/form-data.
  Future<BusModel> addBus(FormData busData);

  /// Updates an existing bus via the API using PATCH.
  /// [updateData] contains only the fields to be changed.
  Future<BusModel> updateBus(String busId, Map<String, dynamic> updateData);

  /// Adds a photo to a bus via the API using multipart/form-data.
  Future<BusPhotoModel> addBusPhoto(String busId, FormData photoData);

  /// Deletes a specific bus photo via the API.
  Future<void> deleteBusPhoto(String photoId);

  /// Records a maintenance event for a bus via the API.
  Future<BusMaintenanceModel> recordBusMaintenance(
      String busId, Map<String, dynamic> maintenanceData);

  /// Submits a verification action (verify/reject) for a bus via the API.
  Future<BusVerificationModel> verifyBus({
    required String busId,
    required bool isVerified,
    String? comments,
  });

  /// Calls the API endpoint to deactivate a bus.
  Future<void> deactivateBus(String busId);

  /// Calls the API endpoint to reactivate a bus.
  Future<void> reactivateBus(String busId);

  /// Fetches a paginated list of buses pending verification from the API.
  Future<ApiResponse<BusModel>> getBusesPendingVerification({
    int page = 1,
    int pageSize = 20,
  });
}

/// Implementation of [BusRemoteDataSource] using the core [ApiClient].
/// Makes specific API calls for bus management tasks.
class BusRemoteDataSourceImpl implements BusRemoteDataSource {
  final ApiClient _apiClient;

  /// Creates an instance of [BusRemoteDataSourceImpl].
  /// Requires an instance of [ApiClient] to make HTTP requests.
  const BusRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ApiResponse<BusModel>> getBuses({
    int page = 1,
    int pageSize = 20,
    String? driverId,
    bool? isVerified,
    bool? isActive,
    String? searchQuery,
  }) async {
    Log.d('BusRemoteDataSource: Calling get buses API.');
    final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (driverId != null) queryParameters['driver_id'] = driverId;
    if (isVerified != null) queryParameters['is_verified'] = isVerified;
    if (isActive != null) queryParameters['is_active'] = isActive;
    if (searchQuery != null && searchQuery.isNotEmpty) queryParameters['search'] = searchQuery;

    final response = await _apiClient.get(
      ApiConstants.buses,
      queryParameters: queryParameters,
    );
    // Assuming response.data is already Map<String, dynamic>
    // The ApiResponse.fromJson needs a function to convert individual items
    return ApiResponse<BusModel>.fromJson(
      response.data,
      (json) => BusModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<List<BusModel>> getDriverBuses() async {
     Log.d('BusRemoteDataSource: Calling get driver buses API.');
     final response = await _apiClient.get(ApiConstants.busesForDriver);
     // API returns a direct list, not paginated
     final List<dynamic> results = response.data as List<dynamic>;
     return results.map((json) => BusModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<BusModel> getBusDetails(String busId) async {
     Log.d('BusRemoteDataSource: Calling get bus details API for ID: $busId.');
     final response = await _apiClient.get(ApiConstants.busDetail(busId));
     return BusModel.fromJson(response.data);
  }

  @override
  Future<BusModel> addBus(FormData busData) async {
     Log.d('BusRemoteDataSource: Calling add bus API (multipart).');
     // ApiClient's postMultipart handles content type
     final response = await _apiClient.postMultipart(
        ApiConstants.buses,
        data: busData,
     );
     return BusModel.fromJson(response.data);
  }

   @override
  Future<BusModel> updateBus(String busId, Map<String, dynamic> updateData) async {
     Log.d('BusRemoteDataSource: Calling update bus API (PATCH) for ID: $busId.');
     final response = await _apiClient.patch(
        ApiConstants.busDetail(busId),
        data: updateData,
     );
     return BusModel.fromJson(response.data);
  }

  @override
  Future<BusPhotoModel> addBusPhoto(String busId, FormData photoData) async {
     Log.d('BusRemoteDataSource: Calling add bus photo API (multipart) for Bus ID: $busId.');
     final response = await _apiClient.postMultipart(
        ApiConstants.busAddPhoto(busId),
        data: photoData,
     );
      return BusPhotoModel.fromJson(response.data);
  }

  @override
  Future<void> deleteBusPhoto(String photoId) async {
      Log.d('BusRemoteDataSource: Calling delete bus photo API for Photo ID: $photoId.');
      // API uses DELETE /bus-photos/{id}/
      await _apiClient.delete(ApiConstants.busPhotoDetail(photoId));
      // No response body expected on success (204 No Content often)
  }

   @override
  Future<BusMaintenanceModel> recordBusMaintenance(String busId, Map<String, dynamic> maintenanceData) async {
      Log.d('BusRemoteDataSource: Calling record bus maintenance API for Bus ID: $busId.');
      // API expects BusMaintenanceCreateRequest schema
      final response = await _apiClient.post(
         ApiConstants.busMaintenance(busId),
         data: maintenanceData,
      );
       return BusMaintenanceModel.fromJson(response.data);
  }

  @override
  Future<BusVerificationModel> verifyBus({required String busId, required bool isVerified, String? comments}) async {
       Log.d('BusRemoteDataSource: Calling verify bus API for Bus ID: $busId.');
       // API expects BusVerificationActionRequest schema
       final payload = <String, dynamic>{
          'is_verified': isVerified,
          if (comments != null) 'comments': comments,
       };
       final response = await _apiClient.post(
           ApiConstants.busVerify(busId),
           data: payload,
       );
        return BusVerificationModel.fromJson(response.data);
  }

  @override
  Future<void> deactivateBus(String busId) async {
     Log.d('BusRemoteDataSource: Calling deactivate bus API for ID: $busId.');
     await _apiClient.post(ApiConstants.busDeactivate(busId));
      // No request/response body expected
  }

  @override
  Future<void> reactivateBus(String busId) async {
      Log.d('BusRemoteDataSource: Calling reactivate bus API for ID: $busId.');
      await _apiClient.post(ApiConstants.busReactivate(busId));
       // No request/response body expected
  }

   @override
  Future<ApiResponse<BusModel>> getBusesPendingVerification({int page = 1, int pageSize = 20}) async {
      Log.d('BusRemoteDataSource: Calling get pending verification buses API.');
      final queryParameters = <String, dynamic>{
         'page': page,
         'page_size': pageSize,
       };
       final response = await _apiClient.get(
         ApiConstants.busesPendingVerification,
         queryParameters: queryParameters,
       );
       return ApiResponse<BusModel>.fromJson(
         response.data,
         (json) => BusModel.fromJson(json as Map<String, dynamic>),
       );
  }
}
