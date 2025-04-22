/// lib/data/models/driver_rating_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart'; // For nested user details

// Required part files for code generation
part 'driver_rating_model.freezed.dart';
part 'driver_rating_model.g.dart';

/// Data Transfer Object (DTO) representing a Driver Rating record,
/// mirroring the backend API's `DriverRating` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class DriverRatingModel with _$DriverRatingModel {
  /// Creates an instance of DriverRatingModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory DriverRatingModel({
    /// Unique identifier for the rating record (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the driver who received the rating. Matches API 'driver'. Required.
    required String driver, // UUID

    /// ID of the user who submitted the rating. Matches API 'user'. Required.
    required String user, // UUID

    /// The numerical rating given (e.g., 1-5). Matches API 'rating'. Required.
    /// API Schema shows minimum: 1, maximum: 5.
    required int rating,

    /// Optional comment provided with the rating. Matches API 'comment'. Nullable.
    String? comment,

    /// Timestamp when the rating was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the rating record was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested Field ---

    /// Details of the user who submitted the rating. Matches API 'user_details'. Nullable (API says required, making nullable for robustness). Read-only.
    @JsonKey(name: 'user_details') UserModel? userDetails,

  }) = _DriverRatingModel;

  /// Creates a DriverRatingModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$DriverRatingModelFromJson` function.
  factory DriverRatingModel.fromJson(Map<String, dynamic> json) =>
      _$DriverRatingModelFromJson(json);
}