/// lib/data/models/eta_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/enums/eta_status.dart'; // Import the status enum

// Required part files for code generation
part 'eta_model.freezed.dart';
part 'eta_model.g.dart';

/// Data Transfer Object (DTO) representing an Estimated Time of Arrival (ETA),
/// mirroring the backend API's `ETA` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class EtaModel with _$EtaModel {
  /// Creates an instance of EtaModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory EtaModel({
    /// Unique identifier for the ETA record (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the associated Line. Matches API 'line'. Required.
    required String line, // UUID

    /// ID of the associated Bus. Matches API 'bus'. Required.
    required String bus, // UUID

    /// ID of the associated Stop. Matches API 'stop'. Required.
    required String stop, // UUID

    /// ID of the associated TrackingSession. Matches API 'tracking_session'. Required.
    @JsonKey(name: 'tracking_session') required String trackingSession, // UUID

    /// The calculated estimated time of arrival. Matches API 'estimated_arrival_time'. Required.
    @JsonKey(name: 'estimated_arrival_time') required DateTime estimatedArrivalTime,

    /// The actual time the bus arrived. Matches API 'actual_arrival_time'. Nullable.
    @JsonKey(name: 'actual_arrival_time') DateTime? actualArrivalTime,

    /// The current status of this ETA. Matches API 'status'. Required.
    /// Uses [EtaStatus.unknown] as a fallback for robustness.
    @JsonKey(unknownEnumValue: EtaStatus.unknown) required EtaStatus status,

    /// Estimated delay in minutes (negative if early). Matches API 'delay_minutes'. Nullable.
    @JsonKey(name: 'delay_minutes') int? delayMinutes,

    /// Estimated accuracy of the ETA in seconds. Matches API 'accuracy'. Nullable.
    int? accuracy, // API shows integer format: seconds

    /// Flag indicating if this ETA record is active. Matches API 'is_active'. Required.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the ETA record was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the ETA record was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Convenience Fields ---

    /// Name of the associated line. Matches API 'line_name'. Nullable. Read-only.
    @JsonKey(name: 'line_name') String? lineName,

    /// Matricule of the associated bus. Matches API 'bus_matricule'. Nullable. Read-only.
    @JsonKey(name: 'bus_matricule') String? busMatricule,

    /// Name of the associated stop. Matches API 'stop_name'. Nullable. Read-only.
    @JsonKey(name: 'stop_name') String? stopName,

    /// Calculated minutes remaining until arrival. Matches API 'minutes_remaining'. Nullable. Read-only.
    @JsonKey(name: 'minutes_remaining') int? minutesRemaining,

    // Metadata field is excluded.

  }) = _EtaModel;

  /// Creates an EtaModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$EtaModelFromJson` function.
  factory EtaModel.fromJson(Map<String, dynamic> json) =>
      _$EtaModelFromJson(json);
}
