/// lib/data/models/notification_preferences_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

// Required part files for code generation
part 'notification_preferences_model.freezed.dart';
part 'notification_preferences_model.g.dart';

/// Data Transfer Object (DTO) representing User Notification Preferences,
/// mirroring the backend API's `NotificationPreferences` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class NotificationPreferencesModel with _$NotificationPreferencesModel {
  /// Creates an instance of NotificationPreferencesModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory NotificationPreferencesModel({
    /// ID of the user these preferences belong to. Matches API 'user'. Required. Read-only.
    required String user, // UUID

    /// Enable/disable notifications for updates on favorited lines. Matches API 'favorite_line_updates'.
    @JsonKey(name: 'favorite_line_updates', defaultValue: true) required bool favoriteLineUpdates,

    /// Enable/disable notifications about service disruptions. Matches API 'service_disruptions'.
    @JsonKey(name: 'service_disruptions', defaultValue: true) required bool serviceDisruptions,

    /// Enable/disable notifications for general announcements. Matches API 'general_announcements'.
    @JsonKey(name: 'general_announcements', defaultValue: true) required bool generalAnnouncements,

    /// Enable/disable notifications about new app features. Matches API 'new_features'.
    @JsonKey(name: 'new_features', defaultValue: false) required bool newFeatures,

    // Note: The API spec for NotificationPreferences schema doesn't explicitly show
    // 'preferred_channels', but NotificationPreferencesRequest does. Assuming the
    // response reflects the current state of boolean flags.
    // If 'preferred_channels' (List<NotificationTypeEnum>) is returned by the GET/PATCH response, add it here:
    // @JsonKey(name: 'preferred_channels') List<NotificationType>? preferredChannels,

  }) = _NotificationPreferencesModel;

  /// Creates a NotificationPreferencesModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$NotificationPreferencesModelFromJson` function.
  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesModelFromJson(json);
}
