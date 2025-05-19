// lib/core/utils/location_utils.dart

import 'dart:math' as math;

class LocationUtils {
  // Calculate distance between two coordinates in meters
  static double calculateDistance(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    const int earthRadius = 6371000; // in meters

    // Convert degrees to radians
    final startLat = _toRadians(startLatitude);
    final startLng = _toRadians(startLongitude);
    final endLat = _toRadians(endLatitude);
    final endLng = _toRadians(endLongitude);

    // Haversine formula
    final dLat = endLat - startLat;
    final dLng = endLng - startLng;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(startLat) * math.cos(endLat) *
            math.sin(dLng / 2) * math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // Calculate bearing between two coordinates in degrees
  static double calculateBearing(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    // Convert degrees to radians
    final startLat = _toRadians(startLatitude);
    final startLng = _toRadians(startLongitude);
    final endLat = _toRadians(endLatitude);
    final endLng = _toRadians(endLongitude);

    final dLng = endLng - startLng;

    final y = math.sin(dLng) * math.cos(endLat);
    final x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    final radiansBearing = math.atan2(y, x);

    // Convert radians to degrees
    return (_toDegrees(radiansBearing) + 360) % 360;
  }

  // Format coordinates for display
  static String formatCoordinates(double latitude, double longitude, {int precision = 6}) {
    return '${latitude.toStringAsFixed(precision)}, ${longitude.toStringAsFixed(precision)}';
  }

  // Convert decimal degrees to degrees, minutes, seconds
  static String convertToDMS(double decimal, {bool isLatitude = true, int precision = 2}) {
    final absDecimal = decimal.abs();
    final degrees = absDecimal.floor();
    final minutesDecimal = (absDecimal - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = ((minutesDecimal - minutes) * 60).toStringAsFixed(precision);

    final direction = isLatitude
        ? decimal >= 0 ? 'N' : 'S'
        : decimal >= 0 ? 'E' : 'W';

    return '$degrees° $minutes\' $seconds" $direction';
  }

  // Check if a location is within a radius of another location
  static bool isWithinRadius(
      double centerLatitude,
      double centerLongitude,
      double pointLatitude,
      double pointLongitude,
      double radiusInMeters,
      ) {
    final distance = calculateDistance(
      centerLatitude,
      centerLongitude,
      pointLatitude,
      pointLongitude,
    );

    return distance <= radiusInMeters;
  }

  // Find closest point among a list of points
  static Map<String, dynamic>? findClosestPoint(
  double latitude,
  double longitude,
  List<Map<String, dynamic>> points,
  String latKey = 'latitude',
  String lngKey = 'longitude',
  ) {
  if (points.isEmpty) {
  return null;
  }

  double minDistance = double.infinity;
  Map<String, dynamic>? closestPoint;

  for (final point in points) {
  final pointLat = double.tryParse(point[latKey].toString()) ?? 0;
  final pointLng = double.tryParse(point[lngKey].toString()) ?? 0;

  final distance = calculateDistance(latitude, longitude, pointLat, pointLng);

  if (distance < minDistance) {
  minDistance = distance;
  closestPoint = point;
  }
  }

  return closestPoint;
  }

  // Helper method to convert degrees to radians
  static double _toRadians(double degrees) {
  return degrees * math.pi / 180;
  }

  // Helper method to convert radians to degrees
  static double _toDegrees(double radians) {
  return radians * 180 / math.pi;
  }
}