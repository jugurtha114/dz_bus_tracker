/// lib/data/models/stop_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

// Required part files for code generation
part 'stop_model.freezed.dart';
part 'stop_model.g.dart';

/// Data Transfer Object (DTO) representing a Bus Stop, mirroring the backend API's `Stop` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class StopModel with _$StopModel {
  /// Creates an instance of StopModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory StopModel({
    /// Unique identifier for the stop (UUID). Matches API 'id'.
    required String id,

    /// The display name of the bus stop. Matches API 'name'. Required.
    required String name,

    /// An optional code identifying the stop. Matches API 'code'.
    String? code,

    /// Physical address or general location description. Matches API 'address'. Optional.
    String? address,

    /// URL to an image associated with the stop. Matches API 'image'. Optional.
    String? image, // API schema name is 'image'

    /// Additional description for the stop. Matches API 'description'. Optional.
    String? description,

    /// The geographical latitude of the stop. Matches API 'latitude'. Required.
    /// API sends as String, needs parsing later if double is needed.
    required String latitude,

    /// The geographical longitude of the stop. Matches API 'longitude'. Required.
    /// API sends as String, needs parsing later if double is needed.
    required String longitude,

    /// Positional accuracy radius in meters. Matches API 'accuracy'. Optional.
    double? accuracy,

    /// Flag indicating if the stop is active. Matches API 'is_active'. Required.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the stop record was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the stop record was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // Metadata field is excluded as it's likely unstructured or for internal use.

  }) = _StopModel;

  /// Creates a StopModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$StopModelFromJson` function.
  factory StopModel.fromJson(Map<String, dynamic> json) =>
      _$StopModelFromJson(json);
}
