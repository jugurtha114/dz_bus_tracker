/// lib/data/models/bus_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'bus_photo_model.dart'; // Import the BusPhotoModel
import 'driver_model.dart'; // Import the DriverModel

// Required part files for code generation
part 'bus_model.freezed.dart';
part 'bus_model.g.dart';

/// Data Transfer Object (DTO) representing a Bus, mirroring the backend API's `Bus` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class BusModel with _$BusModel {
  /// Creates an instance of BusModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory BusModel({
    /// Unique identifier for the bus (UUID). Matches API 'id'.
    required String id,

    /// ID of the associated driver record. Matches API 'driver'. Required.
    required String driver, // Keep as 'driver' matching the API field name (UUID)

    /// The bus's registration number (matricule). Matches API 'matricule'. Required.
    required String matricule,

    /// The manufacturer/brand of the bus. Matches API 'brand'. Required.
    required String brand,

    /// The specific model of the bus. Matches API 'model'. Required.
    required String model,

    /// The manufacturing year. Matches API 'year'. Optional.
    int? year,

    /// The passenger capacity. Matches API 'capacity'. Optional.
    int? capacity,

    /// A general description of the bus. Matches API 'description'. Optional.
    String? description,

    /// Flag indicating if the bus is verified. Matches API 'is_verified'. Read-only.
    @JsonKey(name: 'is_verified') required bool isVerified,

    /// Timestamp when the bus was last verified. Matches API 'verification_date'. Optional. Read-only.
    @JsonKey(name: 'verification_date') DateTime? verificationDate,

    /// Timestamp of the last recorded maintenance. Matches API 'last_maintenance'. Optional. Read-only.
    @JsonKey(name: 'last_maintenance') DateTime? lastMaintenance,

    /// Timestamp when the next maintenance is scheduled. Matches API 'next_maintenance'. Optional.
    @JsonKey(name: 'next_maintenance') DateTime? nextMaintenance,

    /// Flag indicating if the bus is currently active. Matches API 'is_active'.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the bus record was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the bus record was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested/Calculated Fields ---

    /// List of photos associated with this bus. Matches API 'photos'. Required (can be empty list). Read-only.
    required List<BusPhotoModel> photos,

    /// Details of the associated driver record. Matches API 'driver_details'. Required.
    @JsonKey(name: 'driver_details') required DriverModel driverDetails,

    /// Flag indicating if the bus is currently being tracked. Matches API 'is_tracking'. Required. Read-only.
    @JsonKey(name: 'is_tracking') required bool isTracking,

  }) = _BusModel;

  /// Creates a BusModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$BusModelFromJson` function.
  factory BusModel.fromJson(Map<String, dynamic> json) =>
      _$BusModelFromJson(json);
}
