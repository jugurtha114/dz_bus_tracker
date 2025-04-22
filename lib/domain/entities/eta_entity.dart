/// lib/domain/entities/eta_entity.dart

import 'package:equatable/equatable.dart';

import '../../core/enums/eta_status.dart'; // Import the EtaStatus enum

/// Represents the core Estimated Time of Arrival (ETA) entity within the application domain.
///
/// Contains information about when a specific bus is expected to arrive at a specific stop.
class EtaEntity extends Equatable {
  /// Unique identifier for the ETA record (UUID).
  final String id;

  /// ID of the relevant bus line.
  final String lineId;

  /// ID of the relevant bus.
  final String busId;

  /// ID of the relevant stop.
  final String stopId;

  /// ID of the tracking session this ETA belongs to.
  final String trackingSessionId;

  /// The calculated estimated time of arrival. Required.
  final DateTime estimatedArrivalTime;

  /// The actual time the bus arrived. Null until the bus arrives.
  final DateTime? actualArrivalTime;

  /// The current status of this ETA (e.g., scheduled, approaching, delayed). Required.
  final EtaStatus status;

  /// Estimated delay in minutes (can be negative if early). Optional.
  final int? delayMinutes;

  /// Estimated accuracy of the ETA calculation in seconds. Optional.
  final int? accuracySeconds;

  /// Flag indicating if this ETA record is currently active/relevant.
  final bool isActive;

  /// Timestamp when the ETA record was created.
  final DateTime createdAt;

  /// Timestamp when the ETA record was last updated.
  final DateTime updatedAt;

  // --- Read-only fields often included in API responses for convenience ---

  /// Name of the associated line. Optional.
  final String? lineName;

  /// Matricule (license plate) of the associated bus. Optional.
  final String? busMatricule;

  /// Name of the associated stop. Optional.
  final String? stopName;

  /// Estimated minutes remaining until arrival (calculated). Optional.
  final int? minutesRemaining;

  /// Creates an [EtaEntity] instance.
  const EtaEntity({
    required this.id,
    required this.lineId,
    required this.busId,
    required this.stopId,
    required this.trackingSessionId,
    required this.estimatedArrivalTime,
    this.actualArrivalTime,
    required this.status,
    this.delayMinutes,
    this.accuracySeconds,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lineName,
    this.busMatricule,
    this.stopName,
    this.minutesRemaining,
  });

  @override
  List<Object?> get props => [
        id,
        lineId,
        busId,
        stopId,
        trackingSessionId,
        estimatedArrivalTime,
        actualArrivalTime,
        status,
        delayMinutes,
        accuracySeconds,
        isActive,
        createdAt,
        updatedAt,
        lineName,
        busMatricule,
        stopName,
        minutesRemaining,
      ];

  /// Creates an empty EtaEntity, useful for default states or placeholders.
  static EtaEntity empty() => EtaEntity(
        id: '',
        lineId: '',
        busId: '',
        stopId: '',
        trackingSessionId: '',
        estimatedArrivalTime: DateTime(0),
        status: EtaStatus.unknown,
        isActive: false,
        createdAt: DateTime(0),
        updatedAt: DateTime(0),
      );
}

