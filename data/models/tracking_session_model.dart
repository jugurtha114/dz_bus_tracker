/// lib/data/models/tracking_session_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/enums/tracking_status.dart'; // Import enum
import 'bus_model.dart';   // Import nested models
import 'driver_model.dart';
import 'line_model.dart';

// Required part files for code generation
part 'tracking_session_model.freezed.dart';
part 'tracking_session_model.g.dart';

/// Data Transfer Object (DTO) representing a Tracking Session,
/// mirroring the backend API's `TrackingSession` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class TrackingSessionModel with _$TrackingSessionModel {
  /// Creates an instance of TrackingSessionModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory TrackingSessionModel({
    /// Unique identifier for the tracking session (UUID). Matches API 'id'.
    required String id,

    /// ID of the associated Driver record. Matches API 'driver'. Required.
    required String driver, // UUID

    /// ID of the associated Bus record. Matches API 'bus'. Required.
    required String bus, // UUID

    /// ID of the associated Line record. Matches API 'line'. Required.
    required String line, // UUID

    /// Optional ID of the specific schedule instance. Matches API 'schedule'.
    String? schedule, // UUID

    /// Timestamp when the session started. Matches API 'start_time'. Required.
    @JsonKey(name: 'start_time') required DateTime startTime,

    /// Timestamp when the session ended. Matches API 'end_time'. Nullable.
    @JsonKey(name: 'end_time') DateTime? endTime,

    /// Current status of the session. Matches API 'status'. Required.
    /// Uses [TrackingStatus.unknown] as a fallback for robustness.
    @JsonKey(unknownEnumValue: TrackingStatus.unknown)
    required TrackingStatus status,

    /// Timestamp of the last location update received for this session. Matches API 'last_update'. Nullable.
    @JsonKey(name: 'last_update') DateTime? lastUpdate,

    /// Total distance covered in meters. Matches API 'total_distance'. Nullable.
    @JsonKey(name: 'total_distance') double? totalDistance,

    /// Timestamp when the session record was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the session record was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested/Calculated Fields ---

    /// Calculated duration of the session (ISO 8601 format string). Matches API 'duration'. Nullable. Read-only.
    /// Needs parsing in the domain layer or presentation layer if needed as Duration object.
    String? duration,

    /// Details of the associated Driver record. Matches API 'driver_details'. Required. Read-only.
    @JsonKey(name: 'driver_details') required DriverModel driverDetails,

    /// Details of the associated Bus record. Matches API 'bus_details'. Required. Read-only.
    @JsonKey(name: 'bus_details') required BusModel busDetails,

    /// Details of the associated Line record. Matches API 'line_details'. Required. Read-only.
    @JsonKey(name: 'line_details') required LineModel lineDetails,

  }) = _TrackingSessionModel;

  /// Creates a TrackingSessionModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$TrackingSessionModelFromJson` function.
  factory TrackingSessionModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingSessionModelFromJson(json);
}
