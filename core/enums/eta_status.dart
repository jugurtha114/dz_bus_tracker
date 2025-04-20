/// lib/core/enums/eta_status.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the status of an Estimated Time of Arrival (ETA) calculation.
///
/// Matches the `StatusC73Enum` defined for the ETA model in the backend API specification.
enum EtaStatus {
  /// The arrival is scheduled but the bus is not yet actively approaching.
  @JsonValue('scheduled') // Maps to the API string value
  scheduled('scheduled'),

  /// The bus is actively approaching the stop.
  @JsonValue('approaching') // Maps to the API string value
  approaching('approaching'),

  /// The bus has arrived at the stop.
  @JsonValue('arrived') // Maps to the API string value
  arrived('arrived'),

  /// The bus arrival is delayed compared to the schedule or previous estimate.
  @JsonValue('delayed') // Maps to the API string value
  delayed('delayed'),

  /// The trip or arrival at this stop has been cancelled.
  @JsonValue('cancelled') // Maps to the API string value
  cancelled('cancelled'),

  /// Represents an unknown or unsupported ETA status, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const EtaStatus(this.value);

  /// Creates an [EtaStatus] from its string representation [value].
  ///
  /// Defaults to [EtaStatus.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static EtaStatus fromString(String? value) {
    if (value == null) return EtaStatus.unknown;
    try {
      return EtaStatus.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown EtaStatus encountered: "$value"');
          return EtaStatus.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing EtaStatus from string "$value": $e');
      return EtaStatus.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case EtaStatus.scheduled:
        return 'Scheduled'; // TODO: Localize
      case EtaStatus.approaching:
        return 'Approaching'; // TODO: Localize
      case EtaStatus.arrived:
        return 'Arrived'; // TODO: Localize
      case EtaStatus.delayed:
        return 'Delayed'; // TODO: Localize
      case EtaStatus.cancelled:
        return 'Cancelled'; // TODO: Localize
      case EtaStatus.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
