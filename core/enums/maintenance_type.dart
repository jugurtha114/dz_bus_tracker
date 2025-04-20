/// lib/core/enums/maintenance_type.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the type of maintenance performed on a bus.
///
/// Matches the `MaintenanceTypeEnum` defined in the backend API specification[cite: 1].
enum MaintenanceType {
  /// Routine or scheduled maintenance.
  @JsonValue('regular') // Maps to the API string value
  regular('regular'),

  /// Maintenance performed to fix a specific issue or damage.
  @JsonValue('repair') // Maps to the API string value
  repair('repair'),

  /// A safety or operational inspection.
  @JsonValue('inspection') // Maps to the API string value
  inspection('inspection'),

  /// Any other type of maintenance not covered by the specific categories.
  @JsonValue('other') // Maps to the API string value
  other('other'),

  /// Represents an unknown or unsupported maintenance type, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const MaintenanceType(this.value);

  /// Creates a [MaintenanceType] from its string representation [value].
  ///
  /// Defaults to [MaintenanceType.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static MaintenanceType fromString(String? value) {
    if (value == null) return MaintenanceType.unknown;
    try {
      return MaintenanceType.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown MaintenanceType encountered: "$value"');
          return MaintenanceType.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing MaintenanceType from string "$value": $e');
      return MaintenanceType.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case MaintenanceType.regular:
        return 'Regular Maintenance'; // TODO: Localize
      case MaintenanceType.repair:
        return 'Repair'; // TODO: Localize
      case MaintenanceType.inspection:
        return 'Inspection'; // TODO: Localize
      case MaintenanceType.other:
        return 'Other'; // TODO: Localize
      case MaintenanceType.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
