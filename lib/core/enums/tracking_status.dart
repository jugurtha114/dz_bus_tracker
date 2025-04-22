/// lib/core/enums/tracking_status.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the status of a driver's tracking session.
///
/// Matches the `TrackingSessionStatusEnum` defined in the backend API specification[cite: 1196].
enum TrackingStatus {
  /// The tracking session is currently active and sending location updates.
  @JsonValue('active') // Maps to the API string value [cite: 1196]
  active('active'),

  /// The tracking session has been temporarily paused by the driver.
  @JsonValue('paused') // Maps to the API string value [cite: 1196]
  paused('paused'),

  /// The tracking session has been successfully completed (stopped by the driver).
  @JsonValue('completed') // Maps to the API string value [cite: 1196]
  completed('completed'),

  /// The tracking session encountered an error.
  @JsonValue('error') // Maps to the API string value [cite: 1196]
  error('error'),

  /// Represents an unknown or unsupported tracking status, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const TrackingStatus(this.value);

  /// Creates a [TrackingStatus] from its string representation [value].
  ///
  /// Defaults to [TrackingStatus.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static TrackingStatus fromString(String? value) {
    if (value == null) return TrackingStatus.unknown;
    try {
      return TrackingStatus.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown TrackingStatus encountered: "$value"');
          return TrackingStatus.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing TrackingStatus from string "$value": $e');
      return TrackingStatus.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case TrackingStatus.active:
        return 'Active'; // TODO: Localize
      case TrackingStatus.paused:
        return 'Paused'; // TODO: Localize
      case TrackingStatus.completed:
        return 'Completed'; // TODO: Localize
      case TrackingStatus.error:
        return 'Error'; // TODO: Localize
      case TrackingStatus.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
