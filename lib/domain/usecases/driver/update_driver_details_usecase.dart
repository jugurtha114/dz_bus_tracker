/// lib/domain/usecases/driver/update_driver_details_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/driver_entity.dart';
import '../../repositories/driver_repository.dart'; // Import the Driver repository
import '../base_usecase.dart';

/// Use Case for updating the specific details of a driver's profile.
///
/// This class encapsulates the business logic required to modify driver-specific
/// information like ID photos, license photos, experience, etc., by calling the
/// corresponding method in the [DriverRepository]. This usually applies to the
/// currently authenticated driver, but could be used by an admin if `driverId` is provided.
class UpdateDriverDetailsUseCase
    implements UseCase<DriverEntity, UpdateDriverDetailsParams> {
  /// The repository instance responsible for driver data operations.
  final DriverRepository repository;

  /// Creates an [UpdateDriverDetailsUseCase] instance that requires a [DriverRepository].
  const UpdateDriverDetailsUseCase(this.repository);

  /// Executes the driver details update logic.
  ///
  /// Takes [UpdateDriverDetailsParams] containing the fields to update,
  /// calls the repository's updateDriverDetails method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the updated [DriverEntity] on success.
  @override
  Future<Either<Failure, DriverEntity>> call(
      UpdateDriverDetailsParams params) async {
    return await repository.updateDriverDetails(
      driverId: params.driverId, // Pass driverId if provided (for admin updates)
      idPhoto: params.idPhoto,
      licensePhoto: params.licensePhoto,
      experienceYears: params.experienceYears,
      dateOfBirth: params.dateOfBirth,
      address: params.address,
      emergencyContact: params.emergencyContact,
      notes: params.notes,
      isActive: params.isActive,
    );
  }
}

/// Parameters required for the [UpdateDriverDetailsUseCase].
///
/// Contains the optional fields that can be updated for a driver's profile.
/// Only non-null fields should be considered for the update request.
/// The [idPhoto] and [licensePhoto] expect platform-specific file representations
/// (e.g., File from dart:io or Uint8List from web/memory).
class UpdateDriverDetailsParams extends Equatable {
  /// Optional: ID of the driver to update (if action performed by admin).
  /// If null, the repository implementation should update the current authenticated driver.
  final String? driverId;

  /// Optional: New ID photo file data (File or Uint8List).
  final dynamic idPhoto;

  /// Optional: New license photo file data (File or Uint8List).
  final dynamic licensePhoto;

  /// Optional: Updated years of experience.
  final int? experienceYears;

  /// Optional: Updated date of birth.
  final DateTime? dateOfBirth;

  /// Optional: Updated address.
  final String? address;

  /// Optional: Updated emergency contact information.
  final String? emergencyContact;

  /// Optional: Updated administrative notes (likely admin only).
  final String? notes;

  /// Optional: Updated active status (likely admin only).
  final bool? isActive;

  /// Creates an [UpdateDriverDetailsParams] instance.
  /// Provide values only for the fields intended to be updated.
  const UpdateDriverDetailsParams({
    this.driverId,
    this.idPhoto,
    this.licensePhoto,
    this.experienceYears,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
    this.notes,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        driverId,
        idPhoto, // Note: Equality checks on File/Uint8List might not be reliable with Equatable
        licensePhoto,
        experienceYears,
        dateOfBirth,
        address,
        emergencyContact,
        notes,
        isActive,
      ];
}
