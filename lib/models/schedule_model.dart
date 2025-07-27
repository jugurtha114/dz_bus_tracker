// lib/models/schedule_model.dart

import 'package:flutter/material.dart';

/// Model for bus schedule data
class Schedule {
  final String id;
  final String lineId;
  final String? busId;
  final String? driverId;
  final DateTime departureTime;
  final DateTime estimatedArrivalTime;
  final DateTime? actualDepartureTime;
  final DateTime? actualArrivalTime;
  final String status; // scheduled, active, completed, cancelled, delayed
  final List<ScheduleStop> stops;
  final int? passengerCount;
  final int? maxCapacity;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Schedule({
    required this.id,
    required this.lineId,
    this.busId,
    this.driverId,
    required this.departureTime,
    required this.estimatedArrivalTime,
    this.actualDepartureTime,
    this.actualArrivalTime,
    this.status = 'scheduled',
    this.stops = const [],
    this.passengerCount,
    this.maxCapacity,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if schedule is active
  bool get isActive => status == 'active';

  /// Check if schedule is completed
  bool get isCompleted => status == 'completed';

  /// Check if schedule is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if schedule is delayed
  bool get isDelayed => status == 'delayed';

  /// Get delay in minutes (if any)
  int? get delayMinutes {
    if (actualDepartureTime != null) {
      return actualDepartureTime!.difference(departureTime).inMinutes;
    }
    return null;
  }

  /// Get trip duration in minutes
  int get estimatedDurationMinutes {
    return estimatedArrivalTime.difference(departureTime).inMinutes;
  }

  /// Get actual trip duration (if completed)
  int? get actualDurationMinutes {
    if (actualDepartureTime != null && actualArrivalTime != null) {
      return actualArrivalTime!.difference(actualDepartureTime!).inMinutes;
    }
    return null;
  }

  /// Get occupancy percentage
  double? get occupancyPercentage {
    if (passengerCount != null && maxCapacity != null && maxCapacity! > 0) {
      return (passengerCount! / maxCapacity!) * 100;
    }
    return null;
  }

  /// Get status color
  String get statusColor {
    switch (status) {
      case 'active':
        return 'success';
      case 'completed':
        return 'info';
      case 'cancelled':
        return 'error';
      case 'delayed':
        return 'warning';
      case 'scheduled':
      default:
        return 'primary';
    }
  }

  /// Create from JSON
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      lineId: json['lineId'] ?? '',
      busId: json['busId'],
      driverId: json['driverId'],
      departureTime: DateTime.parse(json['departureTime'] ?? DateTime.now().toIso8601String()),
      estimatedArrivalTime: DateTime.parse(json['estimatedArrivalTime'] ?? DateTime.now().toIso8601String()),
      actualDepartureTime: json['actualDepartureTime'] != null 
          ? DateTime.parse(json['actualDepartureTime']) 
          : null,
      actualArrivalTime: json['actualArrivalTime'] != null 
          ? DateTime.parse(json['actualArrivalTime']) 
          : null,
      status: json['status'] ?? 'scheduled',
      stops: (json['stops'] as List<dynamic>?)
          ?.map((stopJson) => ScheduleStop.fromJson(stopJson))
          .toList() ?? [],
      passengerCount: json['passengerCount'],
      maxCapacity: json['maxCapacity'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lineId': lineId,
      'busId': busId,
      'driverId': driverId,
      'departureTime': departureTime.toIso8601String(),
      'estimatedArrivalTime': estimatedArrivalTime.toIso8601String(),
      'actualDepartureTime': actualDepartureTime?.toIso8601String(),
      'actualArrivalTime': actualArrivalTime?.toIso8601String(),
      'status': status,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'passengerCount': passengerCount,
      'maxCapacity': maxCapacity,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Schedule copyWith({
    String? id,
    String? lineId,
    String? busId,
    String? driverId,
    DateTime? departureTime,
    DateTime? estimatedArrivalTime,
    DateTime? actualDepartureTime,
    DateTime? actualArrivalTime,
    String? status,
    List<ScheduleStop>? stops,
    int? passengerCount,
    int? maxCapacity,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      busId: busId ?? this.busId,
      driverId: driverId ?? this.driverId,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      actualDepartureTime: actualDepartureTime ?? this.actualDepartureTime,
      actualArrivalTime: actualArrivalTime ?? this.actualArrivalTime,
      status: status ?? this.status,
      stops: stops ?? this.stops,
      passengerCount: passengerCount ?? this.passengerCount,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Schedule &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Schedule{id: $id, lineId: $lineId, status: $status}';
  }
}

/// Model for schedule stop information
class ScheduleStop {
  final String stopId;
  final String stopName;
  final DateTime scheduledTime;
  final DateTime? actualTime;
  final int order;
  final bool isCompleted;
  final int? passengersBoarded;
  final int? passengersAlighted;

  const ScheduleStop({
    required this.stopId,
    required this.stopName,
    required this.scheduledTime,
    this.actualTime,
    required this.order,
    this.isCompleted = false,
    this.passengersBoarded,
    this.passengersAlighted,
  });

  /// Get delay in minutes for this stop
  int? get delayMinutes {
    if (actualTime != null) {
      return actualTime!.difference(scheduledTime).inMinutes;
    }
    return null;
  }

  /// Check if stop is running late
  bool get isLate {
    final delay = delayMinutes;
    return delay != null && delay > 0;
  }

  /// Create from JSON
  factory ScheduleStop.fromJson(Map<String, dynamic> json) {
    return ScheduleStop(
      stopId: json['stopId'] ?? '',
      stopName: json['stopName'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime'] ?? DateTime.now().toIso8601String()),
      actualTime: json['actualTime'] != null ? DateTime.parse(json['actualTime']) : null,
      order: json['order'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      passengersBoarded: json['passengersBoarded'],
      passengersAlighted: json['passengersAlighted'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'stopId': stopId,
      'stopName': stopName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'actualTime': actualTime?.toIso8601String(),
      'order': order,
      'isCompleted': isCompleted,
      'passengersBoarded': passengersBoarded,
      'passengersAlighted': passengersAlighted,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleStop &&
          runtimeType == other.runtimeType &&
          stopId == other.stopId &&
          order == other.order;

  @override
  int get hashCode => stopId.hashCode ^ order.hashCode;
}

/// Simple schedule item for UI display
class ScheduleItem {
  final String timeRange;
  final String route;
  final String status;
  final Color statusColor;
  final bool isCompleted;

  const ScheduleItem({
    required this.timeRange,
    required this.route,
    required this.status,
    required this.statusColor,
    required this.isCompleted,
  });
}

/// Schedule status enumeration
class ScheduleStatus {
  static const String scheduled = 'scheduled';
  static const String active = 'active';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String delayed = 'delayed';

  static const List<String> all = [
    scheduled,
    active,
    completed,
    cancelled,
    delayed,
  ];

  static String getDisplayName(String status) {
    switch (status) {
      case scheduled:
        return 'Scheduled';
      case active:
        return 'Active';
      case completed:
        return 'Completed';
      case cancelled:
        return 'Cancelled';
      case delayed:
        return 'Delayed';
      default:
        return status;
    }
  }
}