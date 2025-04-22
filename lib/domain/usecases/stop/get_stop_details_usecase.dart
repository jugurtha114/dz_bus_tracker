/// lib/domain/usecases/stop/get_stop_details_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/stop_entity.dart';
import '../../repositories/line_repository.dart'; // Stop details are fetched via LineRepository
import '../base_usecase.dart';

/// Use Case for fetching the detailed information of a specific bus stop.
///
/// This class retrieves the stop details by calling the corresponding
/// method in the [LineRepository].
class GetStopDetailsUseCase
    implements UseCase<StopEntity, GetStopDetailsParams> {
  /// The repository instance responsible for line and stop data operations.
  final LineRepository repository;

  /// Creates a [GetStopDetailsUseCase] instance that requires a [LineRepository].
  const GetStopDetailsUseCase(this.repository);

  /// Executes the logic to fetch stop details.
  ///
  /// Takes [GetStopDetailsParams] containing the ID of the stop to fetch,
  /// calls the repository's getStopDetails method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// (e.g., stop not found, network error) or the [StopEntity] on success.
  @override
  Future<Either<Failure, StopEntity>> call(GetStopDetailsParams params) async {
    return await repository.getStopDetails(params.stopId);
  }
}

/// Parameters required for the [GetStopDetailsUseCase].
///
/// Contains the unique identifier of the bus stop whose details are requested.
class GetStopDetailsParams extends Equatable {
  /// The ID of the stop.
  final String stopId;

  /// Creates a [GetStopDetailsParams] instance.
  const GetStopDetailsParams({required this.stopId});

  @override
  List<Object?> get props => [stopId];
}
