/// lib/domain/entities/location_entity.dart

import 'package:equatable/equatable.dart';

/// Represents the core Location entity within the application domain.
///
/// Defines a geographical point with associated metadata captured at a specific time.
/// This is distinct from the `LocationUpdateModel` which might contain database IDs etc.
class LocationEntity extends Equatable {
  /// The geographical latitude in degrees. Required.
  final double latitude;

  /// The geographical longitude in degrees. Required.
  final double longitude;

  /// The timestamp when this location was recorded. Required.
  final DateTime timestamp;

  /// Estimated horizontal accuracy of this location, in meters. Optional.
  final double? accuracy;

  /// The speed at the time of this location update, in meters per second. Optional.
  final double? speed; // meters per second

  /// The direction of travel (heading) at the time of this location update,
  /// in degrees relative to true north (0° to 359.9°). Optional.
  final double? heading; // degrees

  /// The altitude of the device at the time of this location update, in meters
  /// above the WGS84 ellipsoid. Optional.
  final double? altitude; // meters

  /// Creates a [LocationEntity] instance.
  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.speed,
    this.heading,
    this.altitude,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        timestamp,
        accuracy,
        speed,
        heading,
        altitude,
      ];

  /// Creates an empty LocationEntity, useful for default states or placeholders.
  /// Uses latitude/longitude 0.0 and epoch time.
  static LocationEntity empty() => LocationEntity(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Creates a LocationEntity from a map, typically used in mappers.
  /// Assumes keys match the API/model structure for latitude, longitude etc.
  /// Requires careful handling of types (e.g., API might send coords as strings).
  factory LocationEntity.fromMap(Map<String, dynamic> map) {
     // Basic example, assumes coordinates are doubles in the map
     // Robust implementation would handle potential String values etc.
     return LocationEntity(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime(0),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      heading: (map['heading'] as num?)?.toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
    );
  }
}
