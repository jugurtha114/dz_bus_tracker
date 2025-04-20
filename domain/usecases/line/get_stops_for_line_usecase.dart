/// lib/domain/usecases/line/get_stops_for_line_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/stop_entity.dart';
import '../../repositories/line_repository.dart'; // Import the Line repository
import '../base_usecase.dart';

/// Use Case for fetching the ordered list of stops associated with a specific bus line.
///
/// This class retrieves the list of stops by calling the corresponding
/// method in the [LineRepository].
class GetStopsForLineUseCase
    implements UseCase<List<StopEntity>, GetStopsForLineParams> {
  /// The repository instance responsible for line data operations.
  final LineRepository repository;

  /// Creates a [GetStopsForLineUseCase] instance that requires a [LineRepository].
  const GetStopsForLineUseCase(this.repository);

  /// Executes the logic to fetch stops for a line.
  ///
  /// Takes [GetStopsForLineParams] containing the ID of the line,
  /// calls the repository's getStopsForLine method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a list of [StopEntity] objects (in order) on success.
  @override
  Future<Either<Failure, List<StopEntity>>> call(
      GetStopsForLineParams params) async {
    return await repository.getStopsForLine(params.lineId);
  }
}

/// Parameters required for the [GetStopsForLineUseCase].
///
/// Contains the unique identifier of the bus line whose stops are requested.
class GetStopsForLineParams extends Equatable {
  /// The ID of the line.
  final String lineId;

  /// Creates a [GetStopsForLineParams] instance.
  const GetStopsForLineParams({required this.lineId});

  @override
  List<Object?> get props => [lineId];
}
