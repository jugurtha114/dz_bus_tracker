/// lib/data/models/line_stop_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'stop_model.dart'; // Import StopModel for nested details

// Required part files for code generation
part 'line_stop_model.freezed.dart';
part 'line_stop_model.g.dart';

/// Data Transfer Object (DTO) representing the association between a Line and a Stop,
/// including ordering information. Mirrors the backend API's `LineStop` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class LineStopModel with _$LineStopModel {
  /// Creates an instance of LineStopModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory LineStopModel({
    /// Unique identifier for the line-stop association (UUID). Matches API 'id'.
    required String id,

    /// ID of the associated Line. Matches API 'line'. Required.
    required String line, // Keep as 'line' matching the API field name (UUID)

    /// ID of the associated Stop. Matches API 'stop'. Required.
    required String stop, // Keep as 'stop' matching the API field name (UUID)

    /// The order of this stop within the line sequence (starting from 0 or 1 based on API). Matches API 'order'. Required.
    required int order,

    /// Optional distance from the start of the line to this stop in meters. Matches API 'distance_from_start'.
    @JsonKey(name: 'distance_from_start') double? distanceFromStart,

    /// Optional estimated time from the start of the line to this stop in minutes. Matches API 'estimated_time_from_start'.
    @JsonKey(name: 'estimated_time_from_start') int? estimatedTimeFromStart,

    /// Timestamp when the association was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the association was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested Field ---

    /// Detailed information about the associated stop. Matches API 'stop_details'. Optional (nullable). Read-only.
    @JsonKey(name: 'stop_details') StopModel? stopDetails,

  }) = _LineStopModel;

  /// Creates a LineStopModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$LineStopModelFromJson` function.
  factory LineStopModel.fromJson(Map<String, dynamic> json) =>
      _$LineStopModelFromJson(json);
}
