/// lib/domain/usecases/bus/get_driver_buses_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/bus_entity.dart';
import '../../repositories/bus_repository.dart'; // Import the Bus repository
import '../base_usecase.dart';

/// Use Case for fetching the list of buses assigned to the currently authenticated driver.
///
/// This class retrieves the bus list by calling the corresponding
/// method in the [BusRepository]. It assumes the user is authenticated as a driver.
/// This replaces the previously generated `GetAssignedBusesUseCase` if that name was used.
class GetDriverBusesUseCase implements UseCase<List<BusEntity>, NoParams> {
  /// The repository instance responsible for bus data operations.
  final BusRepository repository;

  /// Creates a [GetDriverBusesUseCase] instance that requires a [BusRepository].
  const GetDriverBusesUseCase(this.repository);

  /// Executes the logic to fetch the assigned buses for the current driver.
  ///
  /// Takes [NoParams] as input, calls the repository's getDriverBuses method,
  /// and returns the result. The result is an [Either] type, containing
  /// a [Failure] on error (e.g., user not a driver, network error)
  /// or a list of [BusEntity] objects on success.
  @override
  Future<Either<Failure, List<BusEntity>>> call(NoParams params) async {
    // This specifically uses the method intended for the current driver
    return await repository.getDriverBuses();
  }
}
