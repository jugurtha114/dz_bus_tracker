/// lib/domain/usecases/bus/update_bus_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/bus_entity.dart';
import '../../repositories/bus_repository.dart'; // Import the Bus repository
import '../base_usecase.dart';

/// Use Case for updating the details of an existing bus.
///
/// This class encapsulates the business logic required to modify bus information
/// like brand, model, capacity, etc., by calling the corresponding method
/// in the [BusRepository].
class UpdateBusUseCase implements UseCase<BusEntity, UpdateBusParams> {
  /// The repository instance responsible for bus data operations.
  final BusRepository repository;

  /// Creates an [UpdateBusUseCase] instance that requires a [BusRepository].
  const UpdateBusUseCase(this.repository);

  /// Executes the logic to update an existing bus.
  ///
  /// Takes [UpdateBusParams] containing the ID of the bus to update and
  /// the fields to be modified, calls the repository's updateBus method,
  /// and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the updated [BusEntity] on success.
  @override
  Future<Either<Failure, BusEntity>> call(UpdateBusParams params) async {
    return await repository.updateBus(
      busId: params.busId,
      brand: params.brand,
      model: params.model,
      year: params.year,
      capacity: params.capacity,
      description: params.description,
      isActive: params.isActive,
      nextMaintenance: params.nextMaintenance,
    );
  }
}

/// Parameters required for the [UpdateBusUseCase].
///
/// Contains the ID of the bus to update and optional fields with the new values.
/// Only non-null fields should be considered for the update request (PATCH semantics).
class UpdateBusParams extends Equatable {
  /// The unique identifier of the bus to update. Required.
  final String busId;

  /// Optional: The updated manufacturer/brand.
  final String? brand;

  /// Optional: The updated specific model.
  final String? model;

  /// Optional: The updated manufacturing year.
  final int? year;

  /// Optional: The updated passenger capacity.
  final int? capacity;

  /// Optional: The updated general description.
  final String? description;

  /// Optional: The updated active status.
  final bool? isActive;

  /// Optional: The updated date for the next scheduled maintenance.
  final DateTime? nextMaintenance;

  /// Creates an [UpdateBusParams] instance.
  const UpdateBusParams({
    required this.busId,
    this.brand,
    this.model,
    this.year,
    this.capacity,
    this.description,
    this.isActive,
    this.nextMaintenance,
  });

  @override
  List<Object?> get props => [
        busId,
        brand,
        model,
        year,
        capacity,
        description,
        isActive,
        nextMaintenance,
      ];
}
