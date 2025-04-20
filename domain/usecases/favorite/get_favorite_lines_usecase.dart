/// lib/domain/usecases/favorite/get_favorite_lines_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart'; // For default pagination size
import '../../../core/error/failures.dart';
import '../../entities/favorite_entity.dart';
import '../../entities/paginated_list_entity.dart';
import '../../repositories/favorite_repository.dart'; // Import the Favorite repository
import '../base_usecase.dart';

/// Use Case for fetching the paginated list of lines favorited by the current user.
///
/// This class retrieves the list of favorites by calling the corresponding
/// method in the [FavoriteRepository].
class GetFavoriteLinesUseCase
    implements UseCase<PaginatedListEntity<FavoriteEntity>, GetFavoriteLinesParams> {
  /// The repository instance responsible for favorite data operations.
  final FavoriteRepository repository;

  /// Creates a [GetFavoriteLinesUseCase] instance that requires a [FavoriteRepository].
  const GetFavoriteLinesUseCase(this.repository);

  /// Executes the logic to fetch the user's favorite lines.
  ///
  /// Takes [GetFavoriteLinesParams] containing pagination options,
  /// calls the repository's getFavorites method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a [PaginatedListEntity] of [FavoriteEntity] objects on success.
  @override
  Future<Either<Failure, PaginatedListEntity<FavoriteEntity>>> call(
      GetFavoriteLinesParams params) async {
    return await repository.getFavorites(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// Parameters required for the [GetFavoriteLinesUseCase].
///
/// Contains pagination options for fetching the list of favorites.
class GetFavoriteLinesParams extends Equatable {
  /// The page number to retrieve (defaults to 1).
  final int page;

  /// The number of items per page (defaults to AppConstants.defaultPaginationSize).
  final int pageSize;

  /// Creates a [GetFavoriteLinesParams] instance.
  const GetFavoriteLinesParams({
    this.page = 1,
    this.pageSize = AppConstants.defaultPaginationSize,
  });

  @override
  List<Object?> get props => [page, pageSize];
}
