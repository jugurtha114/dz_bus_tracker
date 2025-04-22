/// lib/domain/usecases/eta/get_etas_for_line_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/eta_entity.dart';
import '../../repositories/eta_repository.dart'; // Import ETA repo
import '../base_usecase.dart';

/// Use Case for fetching the Estimated Times of Arrival (ETAs) for buses
/// operating on a specific line.
///
/// This class retrieves the list of ETAs by calling the corresponding
/// method in the [EtaRepository]. It can optionally filter ETAs for a specific stop
/// on that line.
class GetEtasForLineUseCase
    implements UseCase<List<EtaEntity>, GetEtasForLineParams> {
  /// The repository instance responsible for ETA data operations.
  final EtaRepository repository;

  /// Creates a [GetEtasForLineUseCase] instance that requires an [EtaRepository].
  const GetEtasForLineUseCase(this.repository);

  /// Executes the logic to fetch ETAs for a line.
  ///
  /// Takes [GetEtasForLineParams] containing the line ID and optional stop ID,
  /// calls the repository's getEtasForLine method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a list of [EtaEntity] objects on success.
  @override
  Future<Either<Failure, List<EtaEntity>>> call(
      GetEtasForLineParams params) async {
    return await repository.getEtasForLine(
      params.lineId,
      stopId: params.stopId,
    );
  }
}

/// Parameters required for the [GetEtasForLineUseCase].
///
/// Contains the identifier for the line and optionally a stop ID to filter results.
class GetEtasForLineParams extends Equatable {
  /// The ID of the line for which ETAs are requested.
  final String lineId;

  /// Optional: The ID of a specific stop on the line to filter ETAs for.
  /// If null, ETAs for all stops on the line might be returned (depending on API).
  final String? stopId;

  /// Creates a [GetEtasForLineParams] instance.
  const GetEtasForLineParams({
    required this.lineId,
    this.stopId,
  });

  @override
  List<Object?> get props => [lineId, stopId];
}
