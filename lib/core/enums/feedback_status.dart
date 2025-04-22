/// lib/core/enums/feedback_status.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the status of a user feedback submission.
///
/// Matches the `StatusBeeEnum` defined for the Feedback model in the backend API specification.
enum FeedbackStatus {
  /// The feedback has been submitted but not yet reviewed or assigned.
  @JsonValue('new') // Maps to the API string value
  new_('new'), // Using 'new_' because 'new' is a reserved keyword

  /// The feedback is currently being reviewed or addressed.
  @JsonValue('in_progress') // Maps to the API string value
  inProgress('in_progress'),

  /// The feedback has been addressed or resolved.
  @JsonValue('resolved') // Maps to the API string value
  resolved('resolved'),

  /// The feedback ticket has been closed.
  @JsonValue('closed') // Maps to the API string value
  closed('closed'),

  /// Represents an unknown or unsupported feedback status, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const FeedbackStatus(this.value);

  /// Creates a [FeedbackStatus] from its string representation [value].
  ///
  /// Defaults to [FeedbackStatus.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static FeedbackStatus fromString(String? value) {
    if (value == null) return FeedbackStatus.unknown;
    try {
      // Handle 'new' keyword mapping
      if (value.toLowerCase() == 'new') return FeedbackStatus.new_;

      return FeedbackStatus.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown FeedbackStatus encountered: "$value"');
          return FeedbackStatus.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing FeedbackStatus from string "$value": $e');
      return FeedbackStatus.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case FeedbackStatus.new_:
        return 'New'; // TODO: Localize
      case FeedbackStatus.inProgress:
        return 'In Progress'; // TODO: Localize
      case FeedbackStatus.resolved:
        return 'Resolved'; // TODO: Localize
      case FeedbackStatus.closed:
        return 'Closed'; // TODO: Localize
      case FeedbackStatus.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
