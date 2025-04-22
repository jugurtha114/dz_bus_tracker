/// lib/domain/usecases/favorite/remove_favorite_line_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/line_repository.dart'; // Use LineRepository based on API structure
import '../base_usecase.dart';

/// Use Case for removing a specific bus line from the user's favorites list.
///
/// This class encapsulates the business logic required to unfavorite a line
/// by calling the corresponding method in the [LineRepository].
class RemoveFavoriteLineUseCase
    implements UseCase<void, RemoveFavoriteLineParams> {
  /// The repository instance responsible for line (and favorite sub-resource) operations.
  final LineRepository repository;

  /// Creates a [RemoveFavoriteLineUseCase] instance that requires a [LineRepository].
  const RemoveFavoriteLineUseCase(this.repository);

  /// Executes the logic to remove a line from favorites.
  ///
  /// Takes [RemoveFavoriteLineParams] containing the line ID,
  /// calls the repository's removeFavorite method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or `void` (represented as `Right(null)`) on success.
  @override
  Future<Either<Failure, void>> call(RemoveFavoriteLineParams params) async {
    return await repository.removeFavorite(params.lineId);
  }
}

/// Parameters required for the [RemoveFavoriteLineUseCase].
///
/// Contains the identifier of the line to be removed from favorites.
class RemoveFavoriteLineParams extends Equatable {
  /// The ID of the line to remove from favorites.
  final String lineId;

  /// Creates a [RemoveFavoriteLineParams] instance.
  const RemoveFavoriteLineParams({required this.lineId});

  @override
  List<Object?> get props => [lineId];
}
