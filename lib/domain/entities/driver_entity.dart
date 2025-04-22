/// lib/domain/entities/driver_entity.dart

import 'package:equatable/equatable.dart';

import 'user_entity.dart'; // Import the base UserEntity

/// Represents the core Driver entity within the application domain.
///
/// Contains driver-specific details linked to a base UserEntity.
class DriverEntity extends Equatable {
  /// Unique identifier for the driver record (UUID). Matches the Driver model ID.
  final String id;

  /// The base user information associated with this driver. Contains email, name, etc.
  final UserEntity userDetails;

  /// Driver's national identification number.
  final String idNumber;

  /// URL to the driver's ID photo.
  final String idPhotoUrl;

  /// Driver's license number.
  final String licenseNumber;

  /// URL to the driver's license photo.
  final String licensePhotoUrl;

  /// Flag indicating if the driver's identity and documents have been verified by an admin.
  final bool isVerified;

  /// Timestamp when the driver was last verified. Null if never verified.
  final DateTime? verificationDate;

  /// Driver's years of professional driving experience. Optional.
  final int? experienceYears;

  /// Driver's date of birth. Optional.
  final DateTime? dateOfBirth;

  /// Driver's residential address. Optional.
  final String? address;

  /// Contact information for emergencies. Optional.
  final String? emergencyContact;

  /// Administrative notes about the driver. Optional.
  final String? notes;

  /// Flag indicating if the driver account (linked user) is currently active.
  final bool isActive; // Derived from linked UserEntity or Driver status? API shows Driver.is_active

  /// Timestamp when the driver record was created.
  final DateTime createdAt;

  /// Timestamp when the driver record was last updated.
  final DateTime updatedAt;

  /// The driver's average rating calculated from passenger feedback. Read-only from API.
  final double? averageRating; // API provides string, convert during mapping

  /// Creates a [DriverEntity] instance.
  const DriverEntity({
    required this.id,
    required this.userDetails,
    required this.idNumber,
    required this.idPhotoUrl,
    required this.licenseNumber,
    required this.licensePhotoUrl,
    required this.isVerified,
    this.verificationDate,
    this.experienceYears,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
    this.notes,
    required this.isActive, // Assuming this reflects driver status specifically
    required this.createdAt,
    required this.updatedAt,
    this.averageRating,
  });

  /// Convenience getter for the associated User ID.
  String get userId => userDetails.id;

  /// Convenience getter for the driver's full name from the associated UserEntity.
  String get fullName => userDetails.fullName;

  /// Convenience getter for the driver's email from the associated UserEntity.
  String get email => userDetails.email;

  /// Convenience getter for the driver's phone number from the associated UserEntity.
  String? get phoneNumber => userDetails.phoneNumber;

  @override
  List<Object?> get props => [
        id,
        userDetails,
        idNumber,
        idPhotoUrl,
        licenseNumber,
        licensePhotoUrl,
        isVerified,
        verificationDate,
        experienceYears,
        dateOfBirth,
        address,
        emergencyContact,
        notes,
        isActive,
        createdAt,
        updatedAt,
        averageRating,
      ];

  /// Creates an empty DriverEntity, useful for default states or placeholders.
  /// Note: Requires a valid empty UserEntity.
  static DriverEntity empty() => DriverEntity(
        id: '',
        userDetails: UserEntity.empty(), // Use the empty UserEntity
        idNumber: '',
        idPhotoUrl: '',
        licenseNumber: '',
        licensePhotoUrl: '',
        isVerified: false,
        isActive: false,
        createdAt: DateTime(0),
        updatedAt: DateTime(0),
      );
}
