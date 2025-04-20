/// lib/domain/usecases/eta/get_etas_for_stop_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/eta_entity.dart';
import '../../repositories/eta_repository.dart'; // Import ETA repo
import '../base_usecase.dart';

/// Use Case for fetching the Estimated Times of Arrival (ETAs) for buses
/// arriving at a specific stop.
///
/// This class retrieves the list of ETAs by calling the corresponding
/// method in the [EtaRepository]. It can optionally filter ETAs for a specific line
/// serving that stop.
class GetEtasForStopUseCase
    implements UseCase<List<EtaEntity>, GetEtasForStopParams> {
  /// The repository instance responsible for ETA data operations.
  final EtaRepository repository;

  /// Creates a [GetEtasForStopUseCase] instance that requires an [EtaRepository].
  const GetEtasForStopUseCase(this.repository);

  /// Executes the logic to fetch ETAs for a stop.
  ///
  /// Takes [GetEtasForStopParams] containing the stop ID and optional line ID,
  /// calls the repository's getEtasForStop method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a list of [EtaEntity] objects on success.
  @override
  Future<Either<Failure, List<EtaEntity>>> call(
      GetEtasForStopParams params) async {
    return await repository.getEtasForStop(
      params.stopId,
      lineId: params.lineId,
    );
  }
}

/// Parameters required for the [GetEtasForStopUseCase].
///
/// Contains the identifier for the stop and optionally a line ID to filter results.
class GetEtasForStopParams extends Equatable {
  /// The ID of the stop for which ETAs are requested.
  final String stopId;

  /// Optional: The ID of a specific line serving this stop to filter ETAs for.
  /// If null, ETAs for all lines serving the stop might be returned (depending on API).
  final String? lineId;

  /// Creates a [GetEtasForStopParams] instance.
  const GetEtasForStopParams({
    required this.stopId,
    this.lineId,
  });

  @override
  List<Object?> get props => [stopId, lineId];
}
