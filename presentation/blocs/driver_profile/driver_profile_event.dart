/// lib/presentation/blocs/driver_profile/driver_profile_event.dart

part of 'driver_profile_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to the driver's profile management.
/// Uses [Equatable] for value comparison.
abstract class DriverProfileEvent extends Equatable {
  const DriverProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load the profile details for the currently authenticated driver.
class LoadDriverProfile extends DriverProfileEvent {
  const LoadDriverProfile();
}

/// Event triggered when the driver submits the form to update their profile details.
class UpdateDriverDetailsSubmitted extends DriverProfileEvent {
  // Note: driverId is typically inferred from the authenticated user context
  // in the BLoC or UseCase, so it's not included as a parameter here.

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

  /// Optional: Updated administrative notes (if driver can edit).
  final String? notes;

  /// Optional: Updated active status (if driver can edit).
  final bool? isActive;

  /// Creates an [UpdateDriverDetailsSubmitted] event.
  /// Provide values only for the fields intended to be updated.
  const UpdateDriverDetailsSubmitted({
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
        idPhoto, // Equality might not work well with files/byte lists
        licensePhoto,
        experienceYears,
        dateOfBirth,
        address,
        emergencyContact,
        notes,
        isActive,
      ];

  @override
  String toString() => 'UpdateDriverDetailsSubmitted(...)'; // Avoid logging photo data
}
