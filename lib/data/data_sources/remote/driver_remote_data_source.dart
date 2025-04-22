/// lib/data/data_sources/remote/driver_remote_data_source.dart

import 'package:dio/dio.dart'; // For FormData and Response

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/typedefs/common_types.dart'; // For JsonMap
import '../../../core/utils/logger.dart';
import '../../models/api_response.dart';
import '../../models/driver_model.dart';
// CORRECTED: Import actual models, remove placeholders
import '../../models/driver_rating_model.dart';
import '../../models/driver_verification_model.dart';
// Import User Model if needed for responses directly from here (needed for parsing DriverRatingModel)
import '../../models/user_model.dart';


/// Abstract interface for remote data operations related to Drivers.
/// Defines methods for interacting with driver-specific API endpoints.
abstract class DriverRemoteDataSource {
  Future<DriverModel> getDriverProfile();
  Future<DriverModel> updateDriverDetails(String? driverId, dynamic updateData); // Accepts Map or FormData
  Future<JsonMap> getDriverStats(String driverId);
  Future<ApiResponse<DriverRatingModel>> getDriverRatings({ required String driverId, int page = 1, int pageSize = 20 });
  Future<DriverRatingModel> rateDriver({ required String driverId, required int rating, String? comment });

  // --- Admin Methods ---
  Future<ApiResponse<DriverModel>> getDrivers({ int page = 1, int pageSize = 20, String? searchQuery, bool? isVerified, bool? isActive });
  Future<DriverModel> getDriverById(String driverId);
  // CORRECTED: Return type matches API spec response
  Future<DriverVerificationModel> verifyDriver({ required String driverId, required bool isVerified, String? verificationNotes });
  // CORRECTED: Return type matches API spec response
  Future<DriverModel> deactivateDriver(String driverId);
  // CORRECTED: Return type matches API spec response
  Future<DriverModel> reactivateDriver(String driverId);
  Future<ApiResponse<DriverModel>> getDriversPendingVerification({ int page = 1, int pageSize = 20 });
}


/// Implementation of [DriverRemoteDataSource] using the core [ApiClient].
class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final ApiClient _apiClient;

  const DriverRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  // --- Helper Mappers (Needed for Paginated Responses) ---
  DriverModel _parseDriverModel(Object? json) => DriverModel.fromJson(json as JsonMap);
  DriverRatingModel _parseDriverRatingModel(Object? json) => DriverRatingModel.fromJson(json as JsonMap);

  @override
  Future<DriverModel> getDriverProfile() async {
    Log.d('DriverRemoteDataSource: Calling get driver profile (me) API.');
    final response = await _apiClient.get(ApiConstants.driverProfileMe);
    return DriverModel.fromJson(response.data);
  }

  @override
  Future<DriverModel> updateDriverDetails(String? driverId, dynamic updateData) async {
    // Determine path and method based on whether files are present
    final path = driverId != null ? ApiConstants.driverDetail(driverId) : ApiConstants.driverProfileMe;
    Log.d('DriverRemoteDataSource: Calling update driver details API (PATCH/POST?) for path: $path.');

    Response response;
    if (updateData is FormData) {
      // If API supports PATCH with FormData (less common) or if this should be POST to a different endpoint for files
      Log.d("Using PATCH with FormData for driver update (verify API support).");
      // For safety, might need a dedicated ApiClient method or check API spec carefully
      // Assuming ApiClient.patch handles FormData correctly for now:
      response = await _apiClient.patch(path, data: updateData);
      // If PATCH doesn't support FormData, this needs to be split:
      // 1. PATCH JSON data
      // 2. POST photos to separate endpoints
    } else if (updateData is JsonMap) {
      Log.d("Using PATCH with JSON for driver update.");
      response = await _apiClient.patch(path, data: updateData);
    } else {
      throw ArgumentError('Invalid data type for updateDriverDetails: ${updateData.runtimeType}');
    }
    return DriverModel.fromJson(response.data);
  }


  @override
  Future<JsonMap> getDriverStats(String driverId) async {
    Log.d('DriverRemoteDataSource: Calling get driver stats API for ID: $driverId.');
    final response = await _apiClient.get(ApiConstants.driverStats(driverId));
    return response.data as JsonMap;
  }

  @override
  Future<ApiResponse<DriverRatingModel>> getDriverRatings({required String driverId, int page = 1, int pageSize = 20}) async {
    Log.d('DriverRemoteDataSource: Calling get driver ratings API for ID: $driverId.');
    final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
    final response = await _apiClient.get( ApiConstants.driverRatings(driverId), queryParameters: queryParameters, );
    return ApiResponse<DriverRatingModel>.fromJson(response.data, _parseDriverRatingModel);
  }

  @override
  Future<DriverRatingModel> rateDriver({required String driverId, required int rating, String? comment}) async {
    Log.d('DriverRemoteDataSource: Calling rate driver API for ID: $driverId.');
    final payload = <String, dynamic>{ 'rating': rating, if (comment != null) 'comment': comment, };
    final response = await _apiClient.post( ApiConstants.driverRate(driverId), data: payload, );
    return DriverRatingModel.fromJson(response.data);
  }

  // --- Admin Methods Implementation ---

  @override
  Future<ApiResponse<DriverModel>> getDrivers({int page = 1, int pageSize = 20, String? searchQuery, bool? isVerified, bool? isActive}) async {
    Log.d('DriverRemoteDataSource: Calling get drivers API (Admin).');
    final queryParameters = <String, dynamic>{ 'page': page, 'page_size': pageSize, if (searchQuery != null) 'search': searchQuery, if (isVerified != null) 'is_verified': isVerified, if (isActive != null) 'is_active': isActive, };
    queryParameters.removeWhere((key, value) => value == null);
    final response = await _apiClient.get(ApiConstants.drivers, queryParameters: queryParameters);
    return ApiResponse<DriverModel>.fromJson(response.data, _parseDriverModel);
  }

  @override
  Future<DriverModel> getDriverById(String driverId) async {
    Log.d('DriverRemoteDataSource: Calling get driver by ID API (Admin) for ID: $driverId.');
    final response = await _apiClient.get(ApiConstants.driverDetail(driverId));
    return DriverModel.fromJson(response.data);
  }

  @override
  Future<DriverVerificationModel> verifyDriver({required String driverId, required bool isVerified, String? verificationNotes}) async { // CORRECTED: Return Type
    Log.d('DriverRemoteDataSource: Calling verify driver API (Admin) for ID: $driverId.');
    final payload = <String, dynamic>{ 'is_verified': isVerified, if (verificationNotes != null) 'comments': verificationNotes, };
    final response = await _apiClient.post(ApiConstants.driverVerify(driverId), data: payload);
    return DriverVerificationModel.fromJson(response.data); // CORRECTED: Return Parsed Model
  }

  @override
  Future<DriverModel> deactivateDriver(String driverId) async { // CORRECTED: Return Type
    Log.d('DriverRemoteDataSource: Calling deactivate driver API (Admin) for ID: $driverId.');
    final response = await _apiClient.post(ApiConstants.driverDeactivate(driverId));
    return DriverModel.fromJson(response.data); // CORRECTED: Return Parsed Model
  }

  @override
  Future<DriverModel> reactivateDriver(String driverId) async { // CORRECTED: Return Type
    Log.d('DriverRemoteDataSource: Calling reactivate driver API (Admin) for ID: $driverId.');
    final response = await _apiClient.post(ApiConstants.driverReactivate(driverId));
    return DriverModel.fromJson(response.data); // CORRECTED: Return Parsed Model
  }

  @override
  Future<ApiResponse<DriverModel>> getDriversPendingVerification({int page = 1, int pageSize = 20}) async {
    Log.d('DriverRemoteDataSource: Calling get pending verification drivers API (Admin).');
    final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
    final response = await _apiClient.get(ApiConstants.driversPendingVerification, queryParameters: queryParameters);
    return ApiResponse<DriverModel>.fromJson(response.data, _parseDriverModel);
  }
}

// REMOVED Placeholder Models - Ensure DriverRatingModel and DriverVerificationModel are generated elsewhere.