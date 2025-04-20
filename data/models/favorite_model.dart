/// lib/data/models/favorite_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'line_model.dart'; // Import the LineModel for nested details

// Required part files for code generation
part 'favorite_model.freezed.dart';
part 'favorite_model.g.dart';

/// Data Transfer Object (DTO) representing a User's Favorite Line record,
/// mirroring the backend API's `Favorite` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class FavoriteModel with _$FavoriteModel {
  /// Creates an instance of FavoriteModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory FavoriteModel({
    /// Unique identifier for the favorite record (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the user who created this favorite. Matches API 'user'. Required.
    required String user, // UUID

    /// ID of the line that was favorited. Matches API 'line'. Required.
    required String line, // UUID

    /// Notification threshold in minutes before ETA. Matches API 'notification_threshold'. Nullable.
    @JsonKey(name: 'notification_threshold') int? notificationThreshold,

    /// Flag indicating if this favorite is active. Matches API 'is_active'. Required.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the favorite was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the favorite was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested Field ---

    /// Details of the associated Line record. Matches API 'line_details'. Required. Read-only.
    @JsonKey(name: 'line_details') required LineModel lineDetails,

  }) = _FavoriteModel;

  /// Creates a FavoriteModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$FavoriteModelFromJson` function.
  factory FavoriteModel.fromJson(Map<String, dynamic> json) =>
      _$FavoriteModelFromJson(json);
}
