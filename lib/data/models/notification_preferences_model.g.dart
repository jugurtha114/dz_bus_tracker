// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPreferencesModelImpl _$$NotificationPreferencesModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationPreferencesModelImpl(
      user: json['user'] as String,
      favoriteLineUpdates: json['favorite_line_updates'] as bool? ?? true,
      serviceDisruptions: json['service_disruptions'] as bool? ?? true,
      generalAnnouncements: json['general_announcements'] as bool? ?? true,
      newFeatures: json['new_features'] as bool? ?? false,
    );

Map<String, dynamic> _$$NotificationPreferencesModelImplToJson(
        _$NotificationPreferencesModelImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'favorite_line_updates': instance.favoriteLineUpdates,
      'service_disruptions': instance.serviceDisruptions,
      'general_announcements': instance.generalAnnouncements,
      'new_features': instance.newFeatures,
    };
