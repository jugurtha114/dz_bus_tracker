/// lib/data/models/line_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'stop_model.dart'; // Import the StopModel for nested details

// Required part files for code generation
part 'line_model.freezed.dart';
part 'line_model.g.dart';

/// Data Transfer Object (DTO) representing a Bus Line's summary data,
/// mirroring the backend API's `Line` schema (often used in list responses).
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class LineModel with _$LineModel {
  /// Creates an instance of LineModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory LineModel({
    /// Unique identifier for the line (UUID). Matches API 'id'.
    required String id,

    /// Display name or number of the line. Matches API 'name'. Required.
    required String name,

    /// Optional description of the line. Matches API 'description'.
    String? description,

    /// Optional color code (hex string) for the line. Matches API 'color'.
    String? color,

    /// ID of the starting stop. Matches API 'start_location'. Required.
    @JsonKey(name: 'start_location') required String startLocation,

    /// ID of the ending stop. Matches API 'end_location'. Required.
    @JsonKey(name: 'end_location') required String endLocation,

    /// GeoJSON representation of the line's path. Matches API 'path'. Optional.
    /// Stored as a dynamic Map.
    Map<String, dynamic>? path,

    /// Estimated duration in minutes. Matches API 'estimated_duration'. Optional.
    @JsonKey(name: 'estimated_duration') int? estimatedDuration,

    /// Calculated distance in meters. Matches API 'distance'. Optional.
    double? distance,

    /// Flag indicating if the line is active. Matches API 'is_active'. Required.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the line was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the line was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested/Calculated Fields (often included in list views) ---

    /// Details of the starting stop. Matches API 'start_location_details'. Optional (nullable). Read-only.
    @JsonKey(name: 'start_location_details') StopModel? startLocationDetails,

    /// Details of the ending stop. Matches API 'end_location_details'. Optional (nullable). Read-only.
    @JsonKey(name: 'end_location_details') StopModel? endLocationDetails,

    /// Total number of stops on this line. Matches API 'stops_count'. Required. Read-only.
    @JsonKey(name: 'stops_count') required int stopsCount,

    /// Number of buses currently active on this line. Matches API 'active_buses_count'. Required. Read-only.
    @JsonKey(name: 'active_buses_count') required int activeBusesCount,

  }) = _LineModel;

  /// Creates a LineModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$LineModelFromJson` function.
  factory LineModel.fromJson(Map<String, dynamic> json) =>
      _$LineModelFromJson(json);
}
