/// lib/data/models/driver_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart'; // Import the base UserModel for nested details

// Required part files for code generation
part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

/// Data Transfer Object (DTO) representing a Driver, mirroring the backend API's `Driver` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class DriverModel with _$DriverModel {
  /// Creates an instance of DriverModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory DriverModel({
    /// Unique identifier for the driver record (UUID). Matches API 'id'.
    required String id,

    /// ID of the associated base User record. Matches API 'user'. Required.
    required String user,

    /// Driver's national identification number. Matches API 'id_number'. Required.
    @JsonKey(name: 'id_number') required String idNumber,

    /// URL to the driver's ID photo. Matches API 'id_photo'. Required (minLength=1).
    @JsonKey(name: 'id_photo') required String idPhoto,

    /// Driver's license number. Matches API 'license_number'. Required.
    @JsonKey(name: 'license_number') required String licenseNumber,

    /// URL to the driver's license photo. Matches API 'license_photo'. Required (minLength=1).
    @JsonKey(name: 'license_photo') required String licensePhoto,

    /// Flag indicating if the driver's profile is verified. Matches API 'is_verified'. Read-only.
    @JsonKey(name: 'is_verified') required bool isVerified,

    /// Timestamp when the driver was last verified. Matches API 'verification_date'. Optional. Read-only.
    @JsonKey(name: 'verification_date') DateTime? verificationDate,

    /// Driver's years of professional driving experience. Matches API 'experience_years'. Optional.
    @JsonKey(name: 'experience_years') int? experienceYears,

    /// Driver's date of birth. Matches API 'date_of_birth'. Optional.
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,

    /// Driver's residential address. Matches API 'address'. Optional.
    String? address,

    /// Contact information for emergencies. Matches API 'emergency_contact'. Optional.
    @JsonKey(name: 'emergency_contact') String? emergencyContact,

    /// Administrative notes about the driver. Matches API 'notes'. Optional.
    String? notes,

    /// Flag indicating if the driver account is active. Matches API 'is_active'.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the driver record was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the driver record was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested/Calculated Fields ---

    /// Details of the associated base User record. Matches API 'user_details'. Required.
    @JsonKey(name: 'user_details') required UserModel userDetails,

    /// Driver's full name (calculated). Matches API 'full_name'. Read-only.
    @JsonKey(name: 'full_name') String? fullName,

    /// Driver's email (derived from user). Matches API 'email'. Read-only.
    String? email,

    /// Driver's phone number (derived from user). Matches API 'phone_number'. Optional. Read-only.
    @JsonKey(name: 'phone_number') String? phoneNumber,

    /// Driver's average rating as a string. Matches API 'average_rating'. Optional. Read-only.
    /// Needs parsing to double later if used for calculations.
    @JsonKey(name: 'average_rating') String? averageRating,

  }) = _DriverModel;

  /// Creates a DriverModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$DriverModelFromJson` function.
  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
}
