/// lib/data/models/driver_verification_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart'; // For nested details

// Required part files for code generation
part 'driver_verification_model.freezed.dart';
part 'driver_verification_model.g.dart';

/// Data Transfer Object (DTO) representing a Driver Verification record,
/// mirroring the backend API's `DriverVerification` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class DriverVerificationModel with _$DriverVerificationModel {
  /// Creates an instance of DriverVerificationModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory DriverVerificationModel({
    /// Unique identifier for the verification record (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the driver this verification applies to. Matches API 'driver'. Required.
    required String driver, // UUID

    /// ID of the admin user who performed the verification. Matches API 'verified_by'. Nullable.
    @JsonKey(name: 'verified_by') String? verifiedBy, // UUID

    /// The verification status result (true = verified, false = rejected). Matches API 'is_verified'. Required.
    @JsonKey(name: 'is_verified') required bool isVerified,

    /// Optional comments from the verifier. Matches API 'comments'. Nullable.
    String? comments,

    /// Timestamp when the verification action was taken. Matches API 'verification_date'. Required.
    @JsonKey(name: 'verification_date') required DateTime verificationDate,

    /// Timestamp when the record was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the record was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested Field ---

    /// Details of the user who performed the verification. Matches API 'verified_by_details'. Nullable. Read-only.
    @JsonKey(name: 'verified_by_details') UserModel? verifiedByDetails,

  }) = _DriverVerificationModel;

  /// Creates a DriverVerificationModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$DriverVerificationModelFromJson` function.
  factory DriverVerificationModel.fromJson(Map<String, dynamic> json) =>
      _$DriverVerificationModelFromJson(json);
}


