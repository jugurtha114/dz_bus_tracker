/// lib/data/models/location_update_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

// Required part files for code generation
part 'location_update_model.freezed.dart';
part 'location_update_model.g.dart';

/// Data Transfer Object (DTO) representing a Location Update record,
/// mirroring the backend API's `LocationUpdate` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class LocationUpdateModel with _$LocationUpdateModel {
  /// Creates an instance of LocationUpdateModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory LocationUpdateModel({
    /// Unique identifier for the location update record (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the tracking session this update belongs to. Matches API 'session'. Required.
    required String session, // UUID

    /// Timestamp when the location was recorded by the device. Matches API 'timestamp'. Required.
    required DateTime timestamp,

    /// Geographical latitude. Matches API 'latitude'. Required. Sent/Received as String.
    required String latitude,

    /// Geographical longitude. Matches API 'longitude'. Required. Sent/Received as String.
    required String longitude,

    /// Estimated horizontal accuracy in meters. Matches API 'accuracy'. Optional.
    double? accuracy,

    /// Speed in meters per second. Matches API 'speed'. Optional.
    double? speed,

    /// Direction of travel in degrees (0-359.9). Matches API 'heading'. Optional.
    double? heading,

    /// Altitude in meters above WGS84 ellipsoid. Matches API 'altitude'. Optional.
    double? altitude,

    /// Distance in meters from the previous update in the session. Matches API 'distance_from_last'. Optional. Read-only.
    @JsonKey(name: 'distance_from_last') double? distanceFromLast,

    /// Timestamp when the record was created in the database. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the record was last updated in the database. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // Metadata field is excluded.

  }) = _LocationUpdateModel;

  /// Creates a LocationUpdateModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$LocationUpdateModelFromJson` function.
  factory LocationUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateModelFromJson(json);
}
