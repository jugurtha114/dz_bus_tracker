/// lib/core/enums/photo_type.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the type or category of a photo uploaded for a bus.
///
/// Matches the `PhotoTypeEnum` defined in the backend API specification[cite: 1136].
enum PhotoType {
  /// Photo showing the exterior of the bus.
  @JsonValue('exterior') // Maps to the API string value
  exterior('exterior'),

  /// Photo showing the interior of the bus.
  @JsonValue('interior') // Maps to the API string value
  interior('interior'),

  /// Photo of a relevant document (e.g., registration, insurance).
  @JsonValue('document') // Maps to the API string value
  document('document'),

  /// Any other type of photo related to the bus.
  @JsonValue('other') // Maps to the API string value
  other('other'),

  /// Represents an unknown or unsupported photo type, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const PhotoType(this.value);

  /// Creates a [PhotoType] from its string representation [value].
  ///
  /// Defaults to [PhotoType.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static PhotoType fromString(String? value) {
    if (value == null) return PhotoType.unknown;
    try {
      return PhotoType.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown PhotoType encountered: "$value"');
          return PhotoType.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing PhotoType from string "$value": $e');
      return PhotoType.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case PhotoType.exterior:
        return 'Exterior'; // TODO: Localize
      case PhotoType.interior:
        return 'Interior'; // TODO: Localize
      case PhotoType.document:
        return 'Document'; // TODO: Localize
      case PhotoType.other:
        return 'Other'; // TODO: Localize
      case PhotoType.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
