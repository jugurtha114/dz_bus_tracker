/// lib/core/enums/abuse_report_status.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the status of an abuse report submitted by a user.
///
/// Matches the `Status766Enum` defined for the AbuseReport model in the backend API specification.
enum AbuseReportStatus {
  /// The report has been submitted but not yet reviewed.
  @JsonValue('pending') // Maps to the API string value
  pending('pending'),

  /// The report is currently being investigated by an admin.
  @JsonValue('investigating') // Maps to the API string value
  investigating('investigating'),

  /// The report has been reviewed and appropriate action has been taken or deemed complete.
  @JsonValue('resolved') // Maps to the API string value
  resolved('resolved'),

  /// The report has been reviewed and dismissed (e.g., no violation found).
  @JsonValue('dismissed') // Maps to the API string value
  dismissed('dismissed'),

  /// Represents an unknown or unsupported abuse report status, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const AbuseReportStatus(this.value);

  /// Creates an [AbuseReportStatus] from its string representation [value].
  ///
  /// Defaults to [AbuseReportStatus.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static AbuseReportStatus fromString(String? value) {
    if (value == null) return AbuseReportStatus.unknown;
    try {
      return AbuseReportStatus.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown AbuseReportStatus encountered: "$value"');
          return AbuseReportStatus.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing AbuseReportStatus from string "$value": $e');
      return AbuseReportStatus.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case AbuseReportStatus.pending:
        return 'Pending'; // TODO: Localize
      case AbuseReportStatus.investigating:
        return 'Investigating'; // TODO: Localize
      case AbuseReportStatus.resolved:
        return 'Resolved'; // TODO: Localize
      case AbuseReportStatus.dismissed:
        return 'Dismissed'; // TODO: Localize
      case AbuseReportStatus.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
