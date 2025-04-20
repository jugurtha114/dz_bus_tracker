/// lib/domain/usecases/bus/get_bus_details_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/bus_entity.dart';
import '../../repositories/bus_repository.dart'; // Import the Bus repository
import '../base_usecase.dart';

/// Use Case for fetching the detailed information of a specific bus.
///
/// This class retrieves the bus details by calling the corresponding
/// method in the [BusRepository].
class GetBusDetailsUseCase
    implements UseCase<BusEntity, GetBusDetailsParams> {
  /// The repository instance responsible for bus data operations.
  final BusRepository repository;

  /// Creates a [GetBusDetailsUseCase] instance that requires a [BusRepository].
  const GetBusDetailsUseCase(this.repository);

  /// Executes the logic to fetch bus details.
  ///
  /// Takes [GetBusDetailsParams] containing the ID of the bus to fetch,
  /// calls the repository's getBusDetails method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// (e.g., bus not found, network error) or the [BusEntity] on success.
  @override
  Future<Either<Failure, BusEntity>> call(GetBusDetailsParams params) async {
    return await repository.getBusDetails(params.busId);
  }
}

/// Parameters required for the [GetBusDetailsUseCase].
///
/// Contains the unique identifier of the bus whose details are requested.
class GetBusDetailsParams extends Equatable {
  /// The ID of the bus.
  final String busId;

  /// Creates a [GetBusDetailsParams] instance.
  const GetBusDetailsParams({required this.busId});

  @override
  List<Object?> get props => [busId];
}
