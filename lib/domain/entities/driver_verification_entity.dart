/// lib/domain/entities/driver_verification_entity.dart

import 'package:equatable/equatable.dart';
import 'user_entity.dart'; // Import for nested user details

/// Represents the core Driver Verification entity within the application domain.
/// Contains information about a specific verification action taken on a driver profile.
class DriverVerificationEntity extends Equatable {
  /// Unique identifier for the verification record (UUID).
  final String id;
  /// ID of the driver profile that was verified/rejected.
  final String driverId;
  /// Details of the admin user who performed the verification (nullable).
  final UserEntity? verifiedByDetails;
  /// The result of the verification (true = verified, false = rejected).
  final bool isVerified;
  /// Optional comments provided by the verifier.
  final String? comments;
  /// Timestamp when the verification action was performed.
  final DateTime verificationDate;
  /// Timestamp when the verification record was created.
  final DateTime createdAt;
  /// Timestamp when the verification record was last updated.
  final DateTime updatedAt;

  /// Creates a [DriverVerificationEntity] instance.
  const DriverVerificationEntity({
    required this.id,
    required this.driverId,
    this.verifiedByDetails,
    required this.isVerified,
    this.comments,
    required this.verificationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience getter for the verifying user's ID, if available.
  String? get verifiedById => verifiedByDetails?.id;

  @override
  List<Object?> get props => [
    id,
    driverId,
    verifiedByDetails,
    isVerified,
    comments,
    verificationDate,
    createdAt,
    updatedAt,
  ];

  /// Creates an empty DriverVerificationEntity, useful for placeholders.
  static DriverVerificationEntity empty() => DriverVerificationEntity(
    id: '',
    driverId: '',
    isVerified: false,
    verificationDate: DateTime(0),
    createdAt: DateTime(0),
    updatedAt: DateTime(0),
  );
}
