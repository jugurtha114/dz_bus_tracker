/// lib/presentation/blocs/driver_bus/driver_bus_event.dart

part of 'driver_bus_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to managing the driver's buses.
/// Uses [Equatable] for value comparison.
abstract class DriverBusEvent extends Equatable {
  const DriverBusEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load the list of buses associated with the current driver.
class LoadDriverBuses extends DriverBusEvent {
  const LoadDriverBuses();
}

/// Event triggered when the driver submits the form to add a new bus.
class AddBusSubmitted extends DriverBusEvent {
  /// ID of the driver adding the bus (typically the current user).
  final String driverId; // Added driverId
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
  /// Optional: A list of initial photos (File or Uint8List) to upload.
  final List<dynamic>? photos; // List of File or Uint8List

  const AddBusSubmitted({
    required this.driverId, // Added driverId
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
        driverId, // Added driverId
        matricule,
        brand,
        model,
        year,
        capacity,
        description,
        photos, // Equality might not work well with files/byte lists
      ];

   @override
  String toString() => 'AddBusSubmitted(driverId: $driverId, matricule: $matricule, brand: $brand, model: $model)';
}


/// Event triggered when the driver submits the form to update an existing bus.
class UpdateBusSubmitted extends DriverBusEvent {
  /// The ID of the bus being updated.
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
  // Note: Updating photos is handled by a separate AddBusPhotoUseCase/Event

  const UpdateBusSubmitted({
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

   @override
  String toString() => 'UpdateBusSubmitted(busId: $busId)';
}

// Optional: Event if deleting buses is added later
// class DeleteBusRequested extends DriverBusEvent {
//   final String busId;
//   const DeleteBusRequested({required this.busId});
//   @override List<Object?> get props => [busId];
// }

/// Internal event dispatched after an add/update/delete action to refresh the list.
class _DriverBusesChanged extends DriverBusEvent {
  const _DriverBusesChanged();
}
