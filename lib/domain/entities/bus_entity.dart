/// lib/domain/entities/bus_entity.dart

import 'package:equatable/equatable.dart';

import 'bus_photo_entity.dart';
import 'driver_entity.dart';

/// Represents the core Bus entity within the application domain.
///
/// Contains details about a specific bus vehicle.
class BusEntity extends Equatable {
  /// Unique identifier for the bus (UUID).
  final String id;

  /// The driver primarily associated with this bus. Contains full driver details.
  final DriverEntity driverDetails;

  /// The bus's registration or license plate number (matricule). Required.
  final String matricule;

  /// The manufacturer/brand of the bus (e.g., Mercedes, Higer). Required.
  final String brand;

  /// The specific model of the bus (e.g., Sprinter, Citaro). Required.
  final String model;

  /// The manufacturing year of the bus. Optional.
  final int? year;

  /// The passenger capacity of the bus. Optional.
  final int? capacity;

  /// A general description of the bus. Optional.
  final String? description;

  /// Flag indicating if the bus has been verified by an admin. Read-only from API.
  final bool isVerified;

  /// Timestamp when the bus was last verified. Null if never verified. Read-only from API.
  final DateTime? verificationDate;

  /// Timestamp of the last recorded maintenance. Optional. Read-only from API.
  final DateTime? lastMaintenance;

  /// Timestamp when the next maintenance is scheduled or due. Optional.
  final DateTime? nextMaintenance;

  /// Flag indicating if the bus is currently considered active/operational.
  final bool isActive;

  /// Timestamp when the bus record was created.
  final DateTime createdAt;

  /// Timestamp when the bus record was last updated.
  final DateTime updatedAt;

  /// A list of photos associated with this bus. Read-only from API.
  final List<BusPhotoEntity> photos;

  /// Flag indicating if the bus is currently being tracked (has an active session). Read-only from API.
  final bool isTracking;

  /// Creates a [BusEntity] instance.
  const BusEntity({
    required this.id,
    required this.driverDetails,
    required this.matricule,
    required this.brand,
    required this.model,
    this.year,
    this.capacity,
    this.description,
    required this.isVerified,
    this.verificationDate,
    this.lastMaintenance,
    this.nextMaintenance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.photos,
    required this.isTracking,
  });

  /// Convenience getter for the primary driver's ID.
  String get driverId => driverDetails.id;

  @override
  List<Object?> get props => [
        id,
        driverDetails,
        matricule,
        brand,
        model,
        year,
        capacity,
        description,
        isVerified,
        verificationDate,
        lastMaintenance,
        nextMaintenance,
        isActive,
        createdAt,
        updatedAt,
        photos,
        isTracking,
      ];

  /// Creates an empty BusEntity, useful for default states or placeholders.
  /// Note: Requires valid empty DriverEntity.
  static BusEntity empty() => BusEntity(
        id: '',
        driverDetails: DriverEntity.empty(),
        matricule: '',
        brand: '',
        model: '',
        isVerified: false,
        isActive: false,
        createdAt: DateTime(0),
        updatedAt: DateTime(0),
        photos: const [],
        isTracking: false,
      );
}
