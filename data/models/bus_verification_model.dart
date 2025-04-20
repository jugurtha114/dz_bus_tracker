/// lib/data/models/bus_verification_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart'; // Import UserModel for nested details

// Required part files for code generation
part 'bus_verification_model.freezed.dart';
part 'bus_verification_model.g.dart';

/// Data Transfer Object (DTO) representing a Bus Verification record,
/// mirroring the backend API's `BusVerification` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class BusVerificationModel with _$BusVerificationModel {
  /// Creates an instance of BusVerificationModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory BusVerificationModel({
    /// Unique identifier for the verification record (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the bus this verification applies to. Matches API 'bus'. Required.
    required String bus, // UUID

    /// ID of the admin user who performed the verification. Matches API 'verified_by'. Nullable (might be system?).
    @JsonKey(name: 'verified_by') String? verifiedBy, // UUID

    /// The verification status (true = verified, false = rejected). Matches API 'is_verified'. Required.
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

  }) = _BusVerificationModel;

  /// Creates a BusVerificationModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$BusVerificationModelFromJson` function.
  factory BusVerificationModel.fromJson(Map<String, dynamic> json) =>
      _$BusVerificationModelFromJson(json);
}
