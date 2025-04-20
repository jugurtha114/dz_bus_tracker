/// lib/domain/usecases/driver/get_assigned_buses_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/bus_entity.dart';
import '../../repositories/bus_repository.dart'; // Import the Bus repository
import '../base_usecase.dart';

/// Use Case for fetching the list of buses assigned to the currently authenticated driver.
///
/// This class retrieves the bus list by calling the corresponding
/// method in the [BusRepository]. It assumes the user is authenticated as a driver.
class GetAssignedBusesUseCase implements UseCase<List<BusEntity>, NoParams> {
  /// The repository instance responsible for bus data operations.
  final BusRepository repository;

  /// Creates a [GetAssignedBusesUseCase] instance that requires a [BusRepository].
  const GetAssignedBusesUseCase(this.repository);

  /// Executes the logic to fetch the assigned buses.
  ///
  /// Takes [NoParams] as input, calls the repository's getDriverBuses method,
  /// and returns the result. The result is an [Either] type, containing
  /// a [Failure] on error (e.g., user not a driver, network error)
  /// or a list of [BusEntity] objects on success.
  @override
  Future<Either<Failure, List<BusEntity>>> call(NoParams params) async {
    return await repository.getDriverBuses();
  }
}
