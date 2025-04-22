/// lib/domain/entities/line_entity.dart

import 'package:equatable/equatable.dart';

import 'stop_entity.dart'; // Import the StopEntity

/// Represents the core Bus Line entity within the application domain.
///
/// Contains details about a specific bus route.
class LineEntity extends Equatable {
  /// Unique identifier for the line (UUID).
  final String id;

  /// The display name or number of the line (e.g., "Ligne 101", "Bab Ezzouar - Place Audin"). Required.
  final String name;

  /// An optional description for the line.
  final String? description;

  /// A color code (e.g., hex string like "#FF0000") associated with the line for display. Optional.
  final String? color;

  /// Details of the starting stop of the line. Required.
  final StopEntity startLocationDetails;

  /// Details of the ending stop of the line. Required.
  final StopEntity endLocationDetails;

  /// GeoJSON representation of the line's path (typically a LineString). Optional.
  /// Stored as a Map<String, dynamic> which can be parsed for coordinates.
  final Map<String, dynamic>? path;

  /// Estimated duration of the line trip in minutes. Optional.
  final int? estimatedDurationMinutes;

  /// Calculated distance of the line path in meters. Optional.
  final double? distanceMeters;

  /// Flag indicating if the line is currently active or in service.
  final bool isActive;

  /// Timestamp when the line record was created.
  final DateTime createdAt;

  /// Timestamp when the line record was last updated.
  final DateTime updatedAt;

  /// The total number of stops associated with this line. Read-only from API.
  final int stopsCount;

  /// The number of buses currently active and tracking on this line. Read-only from API.
  final int activeBusesCount;

  /// Creates a [LineEntity] instance.
  const LineEntity({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.startLocationDetails,
    required this.endLocationDetails,
    this.path,
    this.estimatedDurationMinutes,
    this.distanceMeters,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.stopsCount,
    required this.activeBusesCount,
  });

  /// Convenience getter for the start stop ID.
  String get startStopId => startLocationDetails.id;

  /// Convenience getter for the start stop name.
  String get startStopName => startLocationDetails.name;

  /// Convenience getter for the end stop ID.
  String get endStopId => endLocationDetails.id;

  /// Convenience getter for the end stop name.
  String get endStopName => endLocationDetails.name;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        color,
        startLocationDetails,
        endLocationDetails,
        path, // Note: Map equality might not work as expected with Equatable if not canonicalized.
        estimatedDurationMinutes,
        distanceMeters,
        isActive,
        createdAt,
        updatedAt,
        stopsCount,
        activeBusesCount,
      ];

  /// Creates an empty LineEntity, useful for default states or placeholders.
  /// Note: Requires valid empty StopEntities.
  static LineEntity empty() => LineEntity(
        id: '',
        name: '',
        startLocationDetails: StopEntity.empty(),
        endLocationDetails: StopEntity.empty(),
        isActive: false,
        createdAt: DateTime(0),
        updatedAt: DateTime(0),
        stopsCount: 0,
        activeBusesCount: 0,
      );
}
