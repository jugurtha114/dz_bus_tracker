/// lib/data/models/abuse_report_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/enums/abuse_reason.dart';
import '../../core/enums/abuse_report_status.dart';
import 'user_model.dart'; // Import UserModel for nested details

// Required part files for code generation
part 'abuse_report_model.freezed.dart';
part 'abuse_report_model.g.dart';

/// Data Transfer Object (DTO) representing an Abuse Report record,
/// mirroring the backend API's `AbuseReport` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class AbuseReportModel with _$AbuseReportModel {
  /// Creates an instance of AbuseReportModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory AbuseReportModel({
    /// Unique identifier for the abuse report (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the user who submitted the report. Matches API 'reporter'. Required.
    required String reporter, // UUID

    /// ID of the user who is the subject of the report. Matches API 'reported_user'. Required.
    @JsonKey(name: 'reported_user') required String reportedUser, // UUID

    /// The reason provided for the report. Matches API 'reason'. Required.
    /// Uses [AbuseReason.unknown] as a fallback for robustness.
    @JsonKey(unknownEnumValue: AbuseReason.unknown) required AbuseReason reason,

    /// A detailed description of the issue being reported. Matches API 'description'. Required.
    required String description,

    /// The current status of the report. Matches API 'status'. Required.
    /// Uses [AbuseReportStatus.unknown] as a fallback for robustness.
    @JsonKey(unknownEnumValue: AbuseReportStatus.unknown)
    required AbuseReportStatus status,

    /// ID of the admin who resolved the report. Matches API 'resolved_by'. Nullable.
    @JsonKey(name: 'resolved_by') String? resolvedBy, // UUID

    /// Timestamp when the report was resolved or dismissed. Matches API 'resolved_at'. Nullable.
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,

    /// Administrative notes regarding the investigation/resolution. Matches API 'notes'. Nullable.
    String? notes,

    /// Flag indicating if the report record is active. Matches API 'is_active'. Required.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the report was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the report was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // --- Read-only Nested/Display Fields ---

    /// Details of the user who submitted the report. Matches API 'reporter_details'. Required. Read-only.
    @JsonKey(name: 'reporter_details') required UserModel reporterDetails,

    /// Details of the user who is the subject of the report. Matches API 'reported_user_details'. Required. Read-only.
    @JsonKey(name: 'reported_user_details')
    required UserModel reportedUserDetails,

    /// Details of the admin who resolved the report. Matches API 'resolved_by_details'. Nullable. Read-only.
    @JsonKey(name: 'resolved_by_details') UserModel? resolvedByDetails,

    /// Display string for the report reason. Matches API 'reason_display'. Nullable. Read-only.
    @JsonKey(name: 'reason_display') String? reasonDisplay,

    /// Display string for the report status. Matches API 'status_display'. Nullable. Read-only.
    @JsonKey(name: 'status_display') String? statusDisplay,

    // Metadata field is excluded.

  }) = _AbuseReportModel;

  /// Creates an AbuseReportModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$AbuseReportModelFromJson` function.
  factory AbuseReportModel.fromJson(Map<String, dynamic> json) =>
      _$AbuseReportModelFromJson(json);
}
