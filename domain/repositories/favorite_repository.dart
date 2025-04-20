/// lib/domain/repositories/favorite_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart'; // For default values if needed
import '../../core/error/failures.dart';
import '../entities/favorite_entity.dart';
import '../entities/paginated_list_entity.dart';

/// Abstract interface defining the contract for data operations related to user Favorites.
///
/// This contract specifies methods primarily for retrieving the list of all favorited
/// lines for the current user and managing specific favorite settings like notification thresholds.
/// Adding/Removing favorites is handled via [LineRepository] to mirror the API structure.
/// Implementations in the data layer will interact with the corresponding backend API endpoints.
abstract class FavoriteRepository {
  /// Fetches a paginated list of all favorite lines for the currently authenticated user.
  /// Corresponds to GET /api/v1/favorites/.
  ///
  /// - [page]: The page number to retrieve.
  /// - [pageSize]: The number of items per page.
  ///
  /// Returns a [PaginatedListEntity] containing [FavoriteEntity] objects on success.
  /// Returns a [Failure] on error (e.g., not authenticated).
  Future<Either<Failure, PaginatedListEntity<FavoriteEntity>>> getFavorites({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  });

  /// Updates the notification threshold for a specific favorite record.
  /// Corresponds to POST /api/v1/favorites/{id}/update_threshold/ or potentially PATCH /api/v1/favorites/{id}/.
  ///
  /// - [favoriteId]: The ID of the favorite record to update (obtained when listing favorites).
  /// - [notificationThresholdMinutes]: The new threshold in minutes (null to disable).
  ///
  /// Returns the updated [FavoriteEntity] on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, FavoriteEntity>> updateFavoriteNotificationThreshold({
    required String favoriteId,
    int? notificationThresholdMinutes, // Pass null to clear/disable threshold
  });

  /// Fetches the details of a specific favorite record by its ID.
  /// Primarily useful if needing details beyond what `getFavorites` provides initially.
  /// Corresponds to GET /api/v1/favorites/{id}/.
  ///
  /// - [favoriteId]: The ID of the favorite record.
  ///
  /// Returns a [FavoriteEntity] on success.
  /// Returns a [Failure] on error (e.g., not found, permission denied).
  Future<Either<Failure, FavoriteEntity>> getFavoriteDetails(String favoriteId);
}
