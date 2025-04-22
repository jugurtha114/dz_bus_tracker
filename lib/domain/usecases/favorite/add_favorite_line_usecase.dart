/// lib/domain/usecases/favorite/add_favorite_line_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/line_repository.dart'; // Use LineRepository based on API structure
import '../base_usecase.dart';

/// Use Case for adding a specific bus line to the user's favorites list.
///
/// This class encapsulates the business logic required to mark a line as favorite,
/// optionally setting a notification threshold, by calling the corresponding
/// method in the [LineRepository].
class AddFavoriteLineUseCase
    implements UseCase<void, AddFavoriteLineParams> {
  /// The repository instance responsible for line (and favorite sub-resource) operations.
  final LineRepository repository;

  /// Creates an [AddFavoriteLineUseCase] instance that requires a [LineRepository].
  const AddFavoriteLineUseCase(this.repository);

  /// Executes the logic to add a line to favorites.
  ///
  /// Takes [AddFavoriteLineParams] containing the line ID and optional threshold,
  /// calls the repository's addFavorite method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or `void` (represented as `Right(null)`) on success.
  @override
  Future<Either<Failure, void>> call(AddFavoriteLineParams params) async {
    // Input validation (e.g., threshold range) could be added here.
    return await repository.addFavorite(
      params.lineId,
      notificationThresholdMinutes: params.notificationThresholdMinutes,
    );
  }
}

/// Parameters required for the [AddFavoriteLineUseCase].
///
/// Contains the identifier of the line to be favorited and an optional
/// notification threshold in minutes.
class AddFavoriteLineParams extends Equatable {
  /// The ID of the line to add to favorites.
  final String lineId;

  /// Optional: The threshold in minutes before ETA to receive a notification.
  /// If null, no specific threshold is set for this favorite via this action.
  final int? notificationThresholdMinutes;

  /// Creates an [AddFavoriteLineParams] instance.
  const AddFavoriteLineParams({
    required this.lineId,
    this.notificationThresholdMinutes,
  });

  @override
  List<Object?> get props => [lineId, notificationThresholdMinutes];
}
