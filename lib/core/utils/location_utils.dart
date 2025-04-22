/// lib/core/utils/location_utils.dart

import 'dart:math' show asin, cos, pow, sin, sqrt, pi;

/// Utility class providing helper methods for geographical calculations and formatting.
class LocationUtils {
  // Private constructor to prevent instantiation
  LocationUtils._();

  // Earth radius in meters (mean radius)
  static const double _earthRadiusMeters = 6371000.0;

  /// Calculates the great-circle distance between two points on Earth
  /// specified by their latitude/longitude using the Haversine formula.
  ///
  /// Returns the distance in meters.
  /// Returns 0.0 if either point is null or coordinates are invalid.
  static double calculateDistance(
      double? lat1, double? lon1, double? lat2, double? lon2) {
    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
      return 0.0;
    }

    // Convert degrees to radians
    final double lat1Rad = _degreesToRadians(lat1);
    final double lon1Rad = _degreesToRadians(lon1);
    final double lat2Rad = _degreesToRadians(lat2);
    final double lon2Rad = _degreesToRadians(lon2);

    // Haversine formula
    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;
    final double a = pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
    final double c = 2 * asin(sqrt(a)); // 2 * atan2(sqrt(a), sqrt(1-a)) is also common

    // Distance in meters
    return _earthRadiusMeters * c;
  }

  /// Converts degrees to radians.
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Formats a distance given in [distanceMeters] into a human-readable string.
  ///
  /// Examples: "500 m", "1.2 km".
  /// Returns '-' if the distance is null or negative.
  static String formatDistance(double? distanceMeters) {
    if (distanceMeters == null || distanceMeters < 0) {
      return '-';
    }

    if (distanceMeters < 1000) {
      // Show in meters
      return '${distanceMeters.toStringAsFixed(0)} m'; // TODO: Localize 'm'
    } else {
      // Show in kilometers with one decimal place
      final distanceKm = distanceMeters / 1000.0;
      return '${distanceKm.toStringAsFixed(1)} km'; // TODO: Localize 'km'
    }
  }

  /// Formats latitude and longitude coordinates into a standard string.
  /// Example: "36.7753° N, 3.0603° E"
  /// Returns '-' if latitude or longitude is null.
  static String formatCoordinates(double? latitude, double? longitude, {int decimalPlaces = 4}) {
     if (latitude == null || longitude == null) return '-';

     final latDirection = latitude >= 0 ? 'N' : 'S';
     final lonDirection = longitude >= 0 ? 'E' : 'W';

     final latStr = latitude.abs().toStringAsFixed(decimalPlaces);
     final lonStr = longitude.abs().toStringAsFixed(decimalPlaces);

     return '$latStr° $latDirection, $lonStr° $lonDirection';
  }
}
