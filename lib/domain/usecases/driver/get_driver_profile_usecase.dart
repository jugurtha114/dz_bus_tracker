/// lib/domain/usecases/driver/get_driver_profile_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/driver_entity.dart';
import '../../repositories/driver_repository.dart'; // Import the Driver repository
import '../base_usecase.dart';

/// Use Case for fetching the profile of the currently authenticated driver.
///
/// This class retrieves the driver-specific details by calling the corresponding
/// method in the [DriverRepository]. It assumes the user is authenticated as a driver.
class GetDriverProfileUseCase implements UseCase<DriverEntity, NoParams> {
  /// The repository instance responsible for driver data operations.
  final DriverRepository repository;

  /// Creates a [GetDriverProfileUseCase] instance that requires a [DriverRepository].
  const GetDriverProfileUseCase(this.repository);

  /// Executes the logic to fetch the driver profile.
  ///
  /// Takes [NoParams] as input, calls the repository's getDriverProfile method,
  /// and returns the result. The result is an [Either] type, containing
  /// a [Failure] on error (e.g., user not a driver, network error)
  /// or the [DriverEntity] on success.
  @override
  Future<Either<Failure, DriverEntity>> call(NoParams params) async {
    return await repository.getDriverProfile();
  }
}
