// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedbackModelImpl _$$FeedbackModelImplFromJson(Map<String, dynamic> json) =>
    _$FeedbackModelImpl(
      id: json['id'] as String,
      user: json['user'] as String,
      type: $enumDecode(_$FeedbackTypeEnumMap, json['type'],
          unknownValue: FeedbackType.unknown),
      subject: json['subject'] as String,
      message: json['message'] as String,
      contactInfo: json['contact_info'] as String?,
      status: $enumDecode(_$FeedbackStatusEnumMap, json['status'],
          unknownValue: FeedbackStatus.unknown),
      assignedTo: json['assigned_to'] as String?,
      response: json['response'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userDetails:
          UserModel.fromJson(json['user_details'] as Map<String, dynamic>),
      assignedToDetails: json['assigned_to_details'] == null
          ? null
          : UserModel.fromJson(
              json['assigned_to_details'] as Map<String, dynamic>),
      typeDisplay: json['type_display'] as String?,
      statusDisplay: json['status_display'] as String?,
    );

Map<String, dynamic> _$$FeedbackModelImplToJson(_$FeedbackModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'type': _$FeedbackTypeEnumMap[instance.type]!,
      'subject': instance.subject,
      'message': instance.message,
      'contact_info': instance.contactInfo,
      'status': _$FeedbackStatusEnumMap[instance.status]!,
      'assigned_to': instance.assignedTo,
      'response': instance.response,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user_details': instance.userDetails,
      'assigned_to_details': instance.assignedToDetails,
      'type_display': instance.typeDisplay,
      'status_display': instance.statusDisplay,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.general: 'general',
  FeedbackType.bug: 'bug',
  FeedbackType.feature: 'feature',
  FeedbackType.complaint: 'complaint',
  FeedbackType.praise: 'praise',
  FeedbackType.unknown: 'unknown',
};

const _$FeedbackStatusEnumMap = {
  FeedbackStatus.new_: 'new',
  FeedbackStatus.inProgress: 'in_progress',
  FeedbackStatus.resolved: 'resolved',
  FeedbackStatus.closed: 'closed',
  FeedbackStatus.unknown: 'unknown',
};
