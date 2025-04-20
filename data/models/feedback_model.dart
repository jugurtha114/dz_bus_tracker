/// lib/data/models/feedback_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/enums/feedback_status.dart';
import '../../core/enums/feedback_type.dart';
import 'user_model.dart'; // Import UserModel for nested details

// Required part files for code generation
part 'feedback_model.freezed.dart';
part 'feedback_model.g.dart';

/// Data Transfer Object (DTO) representing a User Feedback record,
/// mirroring the backend API's `Feedback` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class FeedbackModel with _$FeedbackModel {
  /// Creates an instance of FeedbackModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory FeedbackModel({
    /// Unique identifier for the feedback record (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the user who submitted the feedback. Matches API 'user'. Required.
    required String user, // UUID

    /// The type or category of the feedback. Matches API 'type'. Required.
    /// Uses [FeedbackType.unknown] as a fallback for robustness.
    @JsonKey(unknownEnumValue: FeedbackType.unknown) required FeedbackType type,

    /// The subject line of the feedback. Matches API 'subject'. Required.
    required String subject,

    /// The main content or message of the feedback. Matches API 'message'. Required.
    required String message,

    /// Optional contact information provided by the submitter. Matches API 'contact_info'. Nullable.
    @JsonKey(name: 'contact_info') String? contactInfo,

    /// The current status of the feedback. Matches API 'status'. Required.
    /// Uses [FeedbackStatus.unknown] as a fallback for robustness.
    @JsonKey(unknownEnumValue: FeedbackStatus.unknown) required FeedbackStatus status,

    /// ID of the admin/staff assigned to handle this feedback. Matches API 'assigned_to'. Nullable.
    @JsonKey(name: 'assigned_to') String? assignedTo, // UUID

    /// The official response provided. Matches API 'response'. Nullable.
    String? response,

    /// Timestamp when the feedback was marked as resolved. Matches API 'resolved_at'. Nullable.
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,

    /// Flag indicating if the feedback record is active. Matches API 'is_active'. Required.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the feedback was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the feedback was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested/Display Fields ---

    /// Details of the user who submitted the feedback. Matches API 'user_details'. Required. Read-only.
    @JsonKey(name: 'user_details') required UserModel userDetails,

    /// Details of the user assigned to handle the feedback. Matches API 'assigned_to_details'. Nullable. Read-only.
    @JsonKey(name: 'assigned_to_details') UserModel? assignedToDetails,

    /// Display string for the feedback type. Matches API 'type_display'. Read-only.
    @JsonKey(name: 'type_display') String? typeDisplay,

    /// Display string for the feedback status. Matches API 'status_display'. Read-only.
    @JsonKey(name: 'status_display') String? statusDisplay,

    // Metadata field is excluded.

  }) = _FeedbackModel;

  /// Creates a FeedbackModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$FeedbackModelFromJson` function.
  factory FeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackModelFromJson(json);
}
