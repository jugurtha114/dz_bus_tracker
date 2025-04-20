/// lib/data/models/bus_photo_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/enums/photo_type.dart'; // Import the PhotoType enum

// Required part files for code generation
part 'bus_photo_model.freezed.dart';
part 'bus_photo_model.g.dart';

/// Data Transfer Object (DTO) representing a Bus Photo, mirroring the backend API's `BusPhoto` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class BusPhotoModel with _$BusPhotoModel {
  /// Creates an instance of BusPhotoModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory BusPhotoModel({
    /// Unique identifier for the photo record (UUID). Matches API 'id'.
    required String id,

    /// ID of the bus this photo belongs to. Matches API 'bus'. Required.
    required String bus, // Keep as 'bus' matching the API field name

    /// URL where the photo image can be accessed. Matches API 'photo'. Required (minLength=1).
    required String photo, // Keep as 'photo' matching the API field name

    /// The type or category of the photo. Matches API 'type'. Required.
    /// Uses [PhotoType.unknown] as a fallback for robustness.
    @JsonKey(unknownEnumValue: PhotoType.unknown) required PhotoType type,

    /// An optional description for the photo. Matches API 'description'.
    String? description,

    /// Timestamp when the photo record was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

  }) = _BusPhotoModel;

  /// Creates a BusPhotoModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$BusPhotoModelFromJson` function.
  factory BusPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$BusPhotoModelFromJson(json);
}
