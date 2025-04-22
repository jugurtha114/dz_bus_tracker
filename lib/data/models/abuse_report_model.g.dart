// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abuse_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AbuseReportModelImpl _$$AbuseReportModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AbuseReportModelImpl(
      id: json['id'] as String,
      reporter: json['reporter'] as String,
      reportedUser: json['reported_user'] as String,
      reason: $enumDecode(_$AbuseReasonEnumMap, json['reason'],
          unknownValue: AbuseReason.unknown),
      description: json['description'] as String,
      status: $enumDecode(_$AbuseReportStatusEnumMap, json['status'],
          unknownValue: AbuseReportStatus.unknown),
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reporterDetails:
          UserModel.fromJson(json['reporter_details'] as Map<String, dynamic>),
      reportedUserDetails: UserModel.fromJson(
          json['reported_user_details'] as Map<String, dynamic>),
      resolvedByDetails: json['resolved_by_details'] == null
          ? null
          : UserModel.fromJson(
              json['resolved_by_details'] as Map<String, dynamic>),
      reasonDisplay: json['reason_display'] as String?,
      statusDisplay: json['status_display'] as String?,
    );

Map<String, dynamic> _$$AbuseReportModelImplToJson(
        _$AbuseReportModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporter': instance.reporter,
      'reported_user': instance.reportedUser,
      'reason': _$AbuseReasonEnumMap[instance.reason]!,
      'description': instance.description,
      'status': _$AbuseReportStatusEnumMap[instance.status]!,
      'resolved_by': instance.resolvedBy,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'notes': instance.notes,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'reporter_details': instance.reporterDetails,
      'reported_user_details': instance.reportedUserDetails,
      'resolved_by_details': instance.resolvedByDetails,
      'reason_display': instance.reasonDisplay,
      'status_display': instance.statusDisplay,
    };

const _$AbuseReasonEnumMap = {
  AbuseReason.harassment: 'harassment',
  AbuseReason.inappropriate: 'inappropriate',
  AbuseReason.spam: 'spam',
  AbuseReason.fraud: 'fraud',
  AbuseReason.other: 'other',
  AbuseReason.unknown: 'unknown',
};

const _$AbuseReportStatusEnumMap = {
  AbuseReportStatus.pending: 'pending',
  AbuseReportStatus.investigating: 'investigating',
  AbuseReportStatus.resolved: 'resolved',
  AbuseReportStatus.dismissed: 'dismissed',
  AbuseReportStatus.unknown: 'unknown',
};
