/// lib/domain/usecases/line/get_buses_for_line_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/bus_entity.dart'; // Import the Bus entity
import '../../repositories/line_repository.dart'; // Import the Line repository
import '../base_usecase.dart';

/// Use Case for fetching the list of buses currently associated with or
/// potentially active on a specific bus line.
///
/// This class retrieves the list of buses by calling the corresponding
/// method in the [LineRepository].
class GetBusesForLineUseCase
    implements UseCase<List<BusEntity>, GetBusesForLineParams> {
  /// The repository instance responsible for line data operations.
  final LineRepository repository;

  /// Creates a [GetBusesForLineUseCase] instance that requires a [LineRepository].
  const GetBusesForLineUseCase(this.repository);

  /// Executes the logic to fetch buses for a specific line.
  ///
  /// Takes [GetBusesForLineParams] containing the ID of the line,
  /// calls the repository's getBusesForLine method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a list of [BusEntity] objects on success.
  @override
  Future<Either<Failure, List<BusEntity>>> call(
      GetBusesForLineParams params) async {
    return await repository.getBusesForLine(params.lineId);
  }
}

/// Parameters required for the [GetBusesForLineUseCase].
///
/// Contains the unique identifier of the bus line whose associated buses are requested.
class GetBusesForLineParams extends Equatable {
  /// The ID of the line.
  final String lineId;

  /// Creates a [GetBusesForLineParams] instance.
  const GetBusesForLineParams({required this.lineId});

  @override
  List<Object?> get props => [lineId];
}
