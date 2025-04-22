/// lib/domain/usecases/line/get_lines_for_stop_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/line_entity.dart';
import '../../repositories/line_repository.dart'; // Import the Line repository
import '../base_usecase.dart';

/// Use Case for fetching the list of lines that serve a specific bus stop.
///
/// This class retrieves the list of lines by calling the corresponding
/// method in the [LineRepository].
class GetLinesForStopUseCase
    implements UseCase<List<LineEntity>, GetLinesForStopParams> {
  /// The repository instance responsible for line and stop data operations.
  final LineRepository repository;

  /// Creates a [GetLinesForStopUseCase] instance that requires a [LineRepository].
  const GetLinesForStopUseCase(this.repository);

  /// Executes the logic to fetch lines serving a specific stop.
  ///
  /// Takes [GetLinesForStopParams] containing the ID of the stop,
  /// calls the repository's getLinesForStop method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a list of [LineEntity] objects on success.
  @override
  Future<Either<Failure, List<LineEntity>>> call(
      GetLinesForStopParams params) async {
    return await repository.getLinesForStop(params.stopId);
  }
}

/// Parameters required for the [GetLinesForStopUseCase].
///
/// Contains the unique identifier of the bus stop whose serving lines are requested.
class GetLinesForStopParams extends Equatable {
  /// The ID of the stop.
  final String stopId;

  /// Creates a [GetLinesForStopParams] instance.
  const GetLinesForStopParams({required this.stopId});

  @override
  List<Object?> get props => [stopId];
}
