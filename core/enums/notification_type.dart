/// lib/core/enums/notification_type.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the different channels through which notifications can be sent.
///
/// Matches the `NotificationTypeEnum` defined in the backend API specification.
enum NotificationType {
  /// Notification delivered via Firebase Cloud Messaging (FCM) or similar push service.
  @JsonValue('push') // Maps to the API string value
  push('push'),

  /// Notification delivered via SMS text message.
  @JsonValue('sms') // Maps to the API string value
  sms('sms'),

  /// Notification delivered via email.
  @JsonValue('email') // Maps to the API string value
  email('email'),

  /// Represents an unknown or unsupported notification type, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const NotificationType(this.value);

  /// Creates a [NotificationType] from its string representation [value].
  ///
  /// Defaults to [NotificationType.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static NotificationType fromString(String? value) {
    if (value == null) return NotificationType.unknown;
    try {
      return NotificationType.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown NotificationType encountered: "$value"');
          return NotificationType.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing NotificationType from string "$value": $e');
      return NotificationType.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case NotificationType.push:
        return 'Push Notification'; // TODO: Localize
      case NotificationType.sms:
        return 'SMS Message'; // TODO: Localize
      case NotificationType.email:
        return 'Email'; // TODO: Localize
      case NotificationType.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
