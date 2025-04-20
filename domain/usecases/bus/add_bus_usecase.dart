/// lib/domain/usecases/bus/add_bus_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/bus_entity.dart';
import '../../repositories/bus_repository.dart'; // Import the Bus repository
import '../base_usecase.dart';

/// Use Case for adding a new bus associated with a driver.
///
/// This class encapsulates the business logic required to create a new bus record
/// by calling the corresponding method in the [BusRepository].
class AddBusUseCase implements UseCase<BusEntity, AddBusParams> {
  /// The repository instance responsible for bus data operations.
  final BusRepository repository;

  /// Creates an [AddBusUseCase] instance that requires a [BusRepository].
  const AddBusUseCase(this.repository);

  /// Executes the logic to add a new bus.
  ///
  /// Takes [AddBusParams] containing the details of the new bus,
  /// calls the repository's addBus method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the newly created [BusEntity] on success.
  @override
  Future<Either<Failure, BusEntity>> call(AddBusParams params) async {
    // Input validation (e.g., ensuring required fields aren't just empty strings)
    // could be added here or handled in the BLoC/ViewModel layer.
    return await repository.addBus(
      driverId: params.driverId,
      matricule: params.matricule,
      brand: params.brand,
      model: params.model,
      year: params.year,
      capacity: params.capacity,
      description: params.description,
      photos: params.photos,
    );
  }
}

/// Parameters required for the [AddBusUseCase].
///
/// Contains all necessary information for creating a new bus record.
/// The [photos] list should contain platform-specific file representations
/// (e.g., File from dart:io or Uint8List from web/memory).
class AddBusParams extends Equatable {
  /// ID of the driver this bus will be associated with.
  final String driverId;

  /// The vehicle registration number (matricule).
  final String matricule;

  /// The manufacturer/brand of the bus.
  final String brand;

  /// The specific model of the bus.
  final String model;

  /// Optional: The manufacturing year.
  final int? year;

  /// Optional: The passenger capacity.
  final int? capacity;

  /// Optional: A general description.
  final String? description;

  /// Optional: A list of initial photos (File or Uint8List) to upload with the bus.
  final List<dynamic>? photos;

  /// Creates an [AddBusParams] instance.
  const AddBusParams({
    required this.driverId,
    required this.matricule,
    required this.brand,
    required this.model,
    this.year,
    this.capacity,
    this.description,
    this.photos,
  });

  @override
  List<Object?> get props => [
        driverId,
        matricule,
        brand,
        model,
        year,
        capacity,
        description,
        photos, // Note: Equality checks on File/Uint8List might not be reliable with Equatable
      ];
}
