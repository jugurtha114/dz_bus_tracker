/// lib/core/enums/user_type.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the different types of users in the system.
///
/// Matches the `UserTypeEnum` defined in the backend API specification[cite: 1219].
enum UserType {
  /// Administrator with full access.
  @JsonValue('admin') // Maps to the API string value
  admin('admin'),

  /// Bus driver user who tracks their vehicle.
  @JsonValue('driver') // Maps to the API string value
  driver('driver'),

  /// Regular passenger using the app to track buses.
  @JsonValue('passenger') // Maps to the API string value
  passenger('passenger'),

  /// Represents an unknown or unsupported user type, used as a fallback.
  unknown('unknown');

  /// The string value that corresponds to the enum case, matching the API.
  final String value;

  /// Constant constructor for the enum.
  const UserType(this.value);

  /// Creates a [UserType] from its string representation [value].
  ///
  /// Defaults to [UserType.unknown] if the string doesn't match any known type.
  /// This is useful for robust deserialization from API responses.
  static UserType fromString(String? value) {
    if (value == null) return UserType.unknown;
    try {
      return UserType.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown UserType encountered: "$value"');
          return UserType.unknown;
        },
      );
    } catch (e) {
      debugPrint('Error parsing UserType from string "$value": $e');
      return UserType.unknown;
    }
  }

  /// Provides a more user-friendly display name (optional, consider localization).
  String get displayName {
    switch (this) {
      case UserType.admin:
        return 'Admin'; // TODO: Localize
      case UserType.driver:
        return 'Driver'; // TODO: Localize
      case UserType.passenger:
        return 'Passenger'; // TODO: Localize
      case UserType.unknown:
        return 'Unknown'; // TODO: Localize
    }
  }
}
