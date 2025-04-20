/// lib/core/enums/feedback_type.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the type or category of user-submitted feedback.
///
/// Matches the `TypeEnum` defined for the Feedback model in the backend API specification.
enum FeedbackType {
  /// General feedback or comment.
  @JsonValue('general') // Maps to the API string value
  general('general'),

  /// Reporting a software bug or issue.
  @JsonValue('bug') // Maps to the API string value
  bug('bug'),

  /// Suggesting a new feature or improvement.
  @JsonValue('feature') // Maps to the API string value
  feature('feature'),

  /// Submitting a complaint about a service or experience.
  @JsonValue('complaint') // Maps to the API string value
  complaint('complaint'),

  /// Providing positive feedback or praise.
  @JsonValue('praise') // Maps to the API string value
  praise('praise'),

  /// Represents an unknown or unsupported feedback type, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const FeedbackType(this.value);

  /// Creates a [FeedbackType] from its string representation [value].
  ///
  /// Defaults to [FeedbackType.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static FeedbackType fromString(String? value) {
    if (value == null) return FeedbackType.unknown;
    try {
      return FeedbackType.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown FeedbackType encountered: "$value"');
          return FeedbackType.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing FeedbackType from string "$value": $e');
      return FeedbackType.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case FeedbackType.general:
        return 'General Feedback'; // TODO: Localize
      case FeedbackType.bug:
        return 'Bug Report'; // TODO: Localize
      case FeedbackType.feature:
        return 'Feature Request'; // TODO: Localize
      case FeedbackType.complaint:
        return 'Complaint'; // TODO: Localize
      case FeedbackType.praise:
        return 'Praise'; // TODO: Localize
      case FeedbackType.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
