/// lib/data/data_sources/remote/favorite_remote_data_source.dart

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/typedefs/common_types.dart';
import '../../../core/utils/logger.dart';
import '../../models/api_response.dart';
import '../../models/favorite_model.dart';

/// Abstract interface for remote data operations related to User Favorites.
/// Defines methods for interacting with the `/favorites/` API endpoints.
abstract class FavoriteRemoteDataSource {
  /// Fetches the current user's list of favorites (paginated).
  Future<ApiResponse<FavoriteModel>> getFavorites({
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches the details of a specific favorite record by its ID.
  Future<FavoriteModel> getFavoriteDetails(String favoriteId);

  /// Updates the notification threshold for a specific favorite record.
  Future<FavoriteModel> updateFavoriteNotificationThreshold({
    required String favoriteId,
    int? notificationThresholdMinutes,
  });

  // Note: Creating/Deleting favorites is handled via LineRemoteDataSource
  // mirroring the /lines/{id}/favorite and /lines/{id}/unfavorite endpoints.
}

/// Implementation of [FavoriteRemoteDataSource] using the core [ApiClient].
/// Makes specific API calls for fetching favorite lists and managing thresholds.
class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final ApiClient _apiClient;

  /// Creates an instance of [FavoriteRemoteDataSourceImpl].
  /// Requires an instance of [ApiClient] to make HTTP requests.
  const FavoriteRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<ApiResponse<FavoriteModel>> getFavorites({
    int page = 1,
    int pageSize = 20,
  }) async {
    Log.d('FavoriteRemoteDataSource: Calling get favorites API.');
    final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    final response = await _apiClient.get(
      ApiConstants.favorites,
      queryParameters: queryParameters,
    );
    // API returns PaginatedFavoriteList
    return ApiResponse<FavoriteModel>.fromJson(
      response.data as JsonMap, // Cast needed for type safety
      (json) => FavoriteModel.fromJson(json as JsonMap),
    );
  }

   @override
  Future<FavoriteModel> getFavoriteDetails(String favoriteId) async {
     Log.d('FavoriteRemoteDataSource: Calling get favorite details API for ID: $favoriteId.');
     final response = await _apiClient.get(ApiConstants.favoriteDetail(favoriteId));
     return FavoriteModel.fromJson(response.data);
  }

  @override
  Future<FavoriteModel> updateFavoriteNotificationThreshold({
    required String favoriteId,
    int? notificationThresholdMinutes,
  }) async {
    Log.d('FavoriteRemoteDataSource: Calling update favorite threshold API for ID: $favoriteId.');
    // API uses POST /favorites/{id}/update_threshold/ or PATCH /favorites/{id}/
    // Let's assume PATCH on the main detail endpoint for updating the threshold field.
    // Check API spec for the correct method and endpoint. If it's a dedicated POST endpoint:
    // await _apiClient.post(
    //     ApiConstants.favoriteUpdateThreshold(favoriteId),
    //     data: {'notification_threshold': notificationThresholdMinutes},
    // );
    // If it's PATCH on the detail endpoint:
    final response = await _apiClient.patch(
      ApiConstants.favoriteDetail(favoriteId),
      data: {'notification_threshold': notificationThresholdMinutes},
    );
     return FavoriteModel.fromJson(response.data); // Assuming PATCH returns the updated object
  }
}
