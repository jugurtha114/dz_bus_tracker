/// lib/domain/usecases/stop/search_stops_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/stop_entity.dart';
import '../../repositories/line_repository.dart'; // Use LineRepository as it holds stop search logic
import '../base_usecase.dart';

/// Use Case for searching bus stops based on a text query.
///
/// This class retrieves a list of stops matching the query by calling the
/// corresponding method in the [LineRepository].
class SearchStopsUseCase
    implements UseCase<List<StopEntity>, SearchStopsParams> {
  /// The repository instance responsible for line and stop data operations.
  final LineRepository repository;

  /// Creates a [SearchStopsUseCase] instance that requires a [LineRepository].
  const SearchStopsUseCase(this.repository);

  /// Executes the logic to search for stops.
  ///
  /// Takes [SearchStopsParams] containing the search query,
  /// calls the repository's searchStops method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a list of matching [StopEntity] objects on success.
  @override
  Future<Either<Failure, List<StopEntity>>> call(
      SearchStopsParams params) async {
    // Add basic validation if needed (e.g., query length)
    if (params.query.trim().isEmpty) {
      // Return empty list or specific failure for empty query?
      // Returning empty list is often preferred for search UX.
      return const Right([]);
      // Or: return Left(InvalidInputFailure(message: 'Search query cannot be empty.'));
    }
    return await repository.searchStops(params.query);
  }
}

/// Parameters required for the [SearchStopsUseCase].
///
/// Contains the text query used to search for bus stops (e.g., by name or code).
class SearchStopsParams extends Equatable {
  /// The search term.
  final String query;

  /// Creates a [SearchStopsParams] instance.
  const SearchStopsParams({required this.query});

  @override
  List<Object?> get props => [query];
}
