/// lib/domain/usecases/favorite/update_favorite_threshold_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/favorite_entity.dart';
import '../../repositories/favorite_repository.dart'; // Import the Favorite repository
import '../base_usecase.dart';

/// Use Case for updating the notification threshold for a specific favorite line.
///
/// This class encapsulates the business logic required to modify the notification
/// setting of an existing favorite record by calling the corresponding
/// method in the [FavoriteRepository].
class UpdateFavoriteThresholdUseCase
    implements UseCase<FavoriteEntity, UpdateFavoriteThresholdParams> {
  /// The repository instance responsible for favorite data operations.
  final FavoriteRepository repository;

  /// Creates an [UpdateFavoriteThresholdUseCase] instance that requires a [FavoriteRepository].
  const UpdateFavoriteThresholdUseCase(this.repository);

  /// Executes the logic to update the favorite's notification threshold.
  ///
  /// Takes [UpdateFavoriteThresholdParams] containing the favorite ID and the new threshold,
  /// calls the repository's updateFavoriteNotificationThreshold method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the updated [FavoriteEntity] on success.
  @override
  Future<Either<Failure, FavoriteEntity>> call(
      UpdateFavoriteThresholdParams params) async {
    // Validation could check if threshold is within acceptable range (e.g., >= 0)
    if (params.notificationThresholdMinutes != null && params.notificationThresholdMinutes! < 0) {
        return Left(InvalidInputFailure(message: 'Notification threshold cannot be negative.'));
    }
    return await repository.updateFavoriteNotificationThreshold(
      favoriteId: params.favoriteId,
      notificationThresholdMinutes: params.notificationThresholdMinutes,
    );
  }
}

/// Parameters required for the [UpdateFavoriteThresholdUseCase].
///
/// Contains the identifier of the favorite record and the new notification
/// threshold value (in minutes before ETA).
class UpdateFavoriteThresholdParams extends Equatable {
  /// The ID of the favorite record (not the line ID).
  final String favoriteId;

  /// The new notification threshold in minutes. Pass null to disable or clear the threshold.
  final int? notificationThresholdMinutes;

  /// Creates an [UpdateFavoriteThresholdParams] instance.
  const UpdateFavoriteThresholdParams({
    required this.favoriteId,
    this.notificationThresholdMinutes,
  });

  @override
  List<Object?> get props => [favoriteId, notificationThresholdMinutes];
}
