/// lib/core/enums/abuse_reason.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the reason for submitting an abuse report.
///
/// Matches the `ReasonEnum` defined for the AbuseReport model in the backend API specification[cite: 1138].
enum AbuseReason {
  /// Report for harassment.
  @JsonValue('harassment') // Maps to the API string value
  harassment('harassment'),

  /// Report for inappropriate behavior.
  @JsonValue('inappropriate') // Maps to the API string value
  inappropriate('inappropriate'),

  /// Report for spam content or behavior.
  @JsonValue('spam') // Maps to the API string value
  spam('spam'),

  /// Report for fraudulent activity.
  @JsonValue('fraud') // Maps to the API string value
  fraud('fraud'),

  /// Report for reasons not covered by other specific categories.
  @JsonValue('other') // Maps to the API string value
  other('other'),

  /// Represents an unknown or unsupported abuse reason, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const AbuseReason(this.value);

  /// Creates an [AbuseReason] from its string representation [value].
  ///
  /// Defaults to [AbuseReason.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static AbuseReason fromString(String? value) {
    if (value == null) return AbuseReason.unknown;
    try {
      return AbuseReason.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown AbuseReason encountered: "$value"');
          return AbuseReason.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing AbuseReason from string "$value": $e');
      return AbuseReason.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case AbuseReason.harassment:
        return 'Harassment'; // TODO: Localize
      case AbuseReason.inappropriate:
        return 'Inappropriate Behavior'; // TODO: Localize
      case AbuseReason.spam:
        return 'Spam'; // TODO: Localize
      case AbuseReason.fraud:
        return 'Fraud'; // TODO: Localize
      case AbuseReason.other:
        return 'Other'; // TODO: Localize
      case AbuseReason.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
