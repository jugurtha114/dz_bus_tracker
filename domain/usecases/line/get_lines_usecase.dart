/// lib/domain/usecases/line/get_lines_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart'; // For default pagination size
import '../../../core/error/failures.dart';
import '../../entities/line_entity.dart';
import '../../entities/paginated_list_entity.dart';
import '../../repositories/line_repository.dart'; // Import the Line repository
import '../base_usecase.dart';

/// Use Case for fetching a paginated and potentially filtered list of bus lines.
///
/// This class retrieves the list of lines by calling the corresponding
/// method in the [LineRepository].
class GetLinesUseCase
    implements UseCase<PaginatedListEntity<LineEntity>, GetLinesParams> {
  /// The repository instance responsible for line data operations.
  final LineRepository repository;

  /// Creates a [GetLinesUseCase] instance that requires a [LineRepository].
  const GetLinesUseCase(this.repository);

  /// Executes the logic to fetch the list of lines.
  ///
  /// Takes [GetLinesParams] containing pagination and filter options,
  /// calls the repository's getLines method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a [PaginatedListEntity] containing a list of [LineEntity] on success.
  @override
  Future<Either<Failure, PaginatedListEntity<LineEntity>>> call(
      GetLinesParams params) async {
    return await repository.getLines(
      page: params.page,
      pageSize: params.pageSize,
      searchQuery: params.searchQuery,
      isActive: params.isActive,
      withActiveBuses: params.withActiveBuses,
    );
  }
}

/// Parameters required for the [GetLinesUseCase].
///
/// Contains pagination options and optional filters for fetching lines.
class GetLinesParams extends Equatable {
  /// The page number to retrieve (defaults to 1).
  final int page;

  /// The number of items per page (defaults to AppConstants.defaultPaginationSize).
  final int pageSize;

  /// Optional search term to filter lines by name or description.
  final String? searchQuery;

  /// Optional filter to retrieve only active lines.
  final bool? isActive;

  /// Optional filter to retrieve only lines that currently have active buses.
  final bool? withActiveBuses;

  /// Creates a [GetLinesParams] instance.
  const GetLinesParams({
    this.page = 1,
    this.pageSize = AppConstants.defaultPaginationSize,
    this.searchQuery,
    this.isActive,
    this.withActiveBuses,
  });

  @override
  List<Object?> get props => [
        page,
        pageSize,
        searchQuery,
        isActive,
        withActiveBuses,
      ];
}
