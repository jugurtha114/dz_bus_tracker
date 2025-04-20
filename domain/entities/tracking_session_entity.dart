/// lib/domain/entities/tracking_session_entity.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/enums/tracking_status.dart';
import 'bus_entity.dart';
import 'driver_entity.dart';
import 'line_entity.dart';

part 'tracking_session_entity.freezed.dart';
// Add .g.dart part if you want toJson/fromJson generated for the entity
// part 'tracking_session_entity.g.dart';

/// Represents the core Tracking Session entity within the application domain.
///
/// Contains details about a driver's active or completed tracking period for a bus/line.
/// Uses freezed for immutability and helper methods.
@freezed
class TrackingSessionEntity with _$TrackingSessionEntity {

  /// Creates a [TrackingSessionEntity] instance.
  /// Use this factory constructor. Freezed generates the implementation.
  const factory TrackingSessionEntity({
    /// Unique identifier for the tracking session (UUID).
    required String id,

    /// Details of the driver conducting the session.
    required DriverEntity driverDetails,

    /// Details of the bus being tracked.
    required BusEntity busDetails,

    /// Details of the line being followed during the session.
    required LineEntity lineDetails,

    /// Optional identifier for a specific schedule instance associated with this session.
    String? scheduleId,

    /// Timestamp when the tracking session started.
    required DateTime startTime,

    /// Timestamp when the tracking session ended. Null if the session is ongoing or paused.
    DateTime? endTime,

    /// The current status of the tracking session (e.g., active, paused, completed).
    required TrackingStatus status,

    /// Timestamp of the last received location update for this session. Null if no updates yet.
    DateTime? lastUpdate,

    /// Total distance covered during the session in meters. Read-only from API.
    double? totalDistanceMeters,

    /// Timestamp when the session record was created.
    required DateTime createdAt,

    /// Timestamp when the session record was last updated.
    required DateTime updatedAt,

    /// Calculated duration of the session. Null if the session hasn't ended.
    /// (Parsing logic happens in repository/mapper).
    Duration? duration,
  }) = _TrackingSessionEntity;

  /// Private empty constructor required by freezed for methods/getters extension.
  const TrackingSessionEntity._();

  /// Convenience getter for the driver ID.
  String get driverId => driverDetails.id;

  /// Convenience getter for the bus ID.
  String get busId => busDetails.id;

  /// Convenience getter for the line ID.
  String get lineId => lineDetails.id;

  /// Checks if the session is currently active or paused (i.e., not completed or errored).
  bool get isOngoing => status == TrackingStatus.active || status == TrackingStatus.paused;

  /// Creates an empty TrackingSessionEntity, useful for default states or placeholders.
  factory TrackingSessionEntity.empty() => TrackingSessionEntity(
    id: '',
    driverDetails: DriverEntity.empty(), // Requires empty constructors on nested entities
    busDetails: BusEntity.empty(),
    lineDetails: LineEntity.empty(),
    startTime: DateTime(0),
    status: TrackingStatus.unknown,
    createdAt: DateTime(0),
    updatedAt: DateTime(0),
  );

// Optional: Add fromJson if needed for caching/state restoration, requires .g.dart part
// factory TrackingSessionEntity.fromJson(Map<String, dynamic> json) => _$TrackingSessionEntityFromJson(json);
}