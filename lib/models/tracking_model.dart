// lib/models/tracking_model.dart

import 'package:flutter/material.dart';

/// Anomaly severity levels for tracking issues
enum AnomalySeverity {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  const AnomalySeverity(this.value, this.displayName);
  final String value;
  final String displayName;

  static AnomalySeverity fromValue(String value) {
    return AnomalySeverity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => AnomalySeverity.low,
    );
  }
}

/// Anomaly types for different tracking issues
enum AnomalyType {
  speed('speed', 'Speed anomaly'),
  route('route', 'Route deviation'),
  schedule('schedule', 'Schedule deviation'),
  passengers('passengers', 'Unusual passenger count'),
  gap('gap', 'Service gap'),
  bunching('bunching', 'Bus bunching'),
  other('other', 'Other');

  const AnomalyType(this.value, this.displayName);
  final String value;
  final String displayName;

  static AnomalyType fromValue(String value) {
    return AnomalyType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AnomalyType.other,
    );
  }
}

/// Tracking status for bus-line assignments
enum TrackingStatus {
  idle('idle', 'Idle'),
  active('active', 'Active'),
  paused('paused', 'Paused');

  const TrackingStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static TrackingStatus fromValue(String value) {
    return TrackingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TrackingStatus.idle,
    );
  }
}

/// Comprehensive Anomaly model for tracking issues
class Anomaly {
  final String id;
  final String busId;
  final String? tripId;
  final AnomalyType type;
  final String description;
  final AnomalySeverity severity;
  final double? locationLatitude;
  final double? locationLongitude;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Anomaly({
    required this.id,
    required this.busId,
    this.tripId,
    required this.type,
    required this.description,
    required this.severity,
    this.locationLatitude,
    this.locationLongitude,
    required this.resolved,
    this.resolvedAt,
    this.resolutionNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Anomaly.fromJson(Map<String, dynamic> json) {
    return Anomaly(
      id: json['id'] as String,
      busId: json['bus'] as String,
      tripId: json['trip'] as String?,
      type: AnomalyType.fromValue(json['type'] as String),
      description: json['description'] as String,
      severity: AnomalySeverity.fromValue(json['severity'] as String),
      locationLatitude: json['location_latitude'] != null
          ? double.tryParse(json['location_latitude'].toString())
          : null,
      locationLongitude: json['location_longitude'] != null
          ? double.tryParse(json['location_longitude'].toString())
          : null,
      resolved: json['resolved'] as bool? ?? false,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolutionNotes: json['resolution_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus': busId,
      'trip': tripId,
      'type': type.value,
      'description': description,
      'severity': severity.value,
      'location_latitude': locationLatitude?.toString(),
      'location_longitude': locationLongitude?.toString(),
      'resolved': resolved,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolution_notes': resolutionNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  Color get severityColor {
    switch (severity) {
      case AnomalySeverity.low:
        return Colors.green;
      case AnomalySeverity.medium:
        return Colors.orange;
      case AnomalySeverity.high:
        return Colors.red;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case AnomalyType.speed:
        return Icons.speed;
      case AnomalyType.route:
        return Icons.route;
      case AnomalyType.schedule:
        return Icons.schedule;
      case AnomalyType.passengers:
        return Icons.people;
      case AnomalyType.gap:
        return Icons.av_timer_sharp;
      case AnomalyType.bunching:
        return Icons.group_work;
      case AnomalyType.other:
        return Icons.warning;
    }
  }

  String get statusText => resolved ? 'Resolved' : 'Active';
  Color get statusColor => resolved ? Colors.green : severityColor;
  
  bool get hasLocation => locationLatitude != null && locationLongitude != null;
  
  String get formattedCreatedAt => '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  
  String get formattedResolvedAt => resolvedAt != null 
      ? '${resolvedAt!.day}/${resolvedAt!.month}/${resolvedAt!.year} ${resolvedAt!.hour}:${resolvedAt!.minute.toString().padLeft(2, '0')}'
      : '';
  
  // Additional properties expected by UI components
  String get typeDisplayName => type.displayName;
  String get severityDisplayName => severity.displayName;
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;
  
  // Location getters for backward compatibility
  double get latitude => locationLatitude ?? 0.0;
  double get longitude => locationLongitude ?? 0.0;
  
  // Object wrappers for compatibility with UI components
  Map<String, dynamic>? get bus => busId != null 
    ? {'id': busId, 'license_plate': 'Bus $busId'}
    : null;
    
  Map<String, dynamic>? get trip => tripId != null 
    ? {'id': tripId}
    : null;

  Anomaly copyWith({
    String? id,
    String? busId,
    String? tripId,
    AnomalyType? type,
    String? description,
    AnomalySeverity? severity,
    double? locationLatitude,
    double? locationLongitude,
    bool? resolved,
    DateTime? resolvedAt,
    String? resolutionNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Anomaly(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      tripId: tripId ?? this.tripId,
      type: type ?? this.type,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      resolved: resolved ?? this.resolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Comprehensive LocationUpdate model for real-time tracking
class LocationUpdate {
  final String id;
  final String busId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final String? tripId;
  final String? nearestStopId;
  final double? distanceToStop;
  final String? lineId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocationUpdate({
    required this.id,
    required this.busId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    this.tripId,
    this.nearestStopId,
    this.distanceToStop,
    this.lineId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      id: json['id'] as String,
      busId: json['bus'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      altitude: json['altitude'] != null
          ? double.tryParse(json['altitude'].toString())
          : null,
      speed: json['speed'] != null
          ? double.tryParse(json['speed'].toString())
          : null,
      heading: json['heading'] != null
          ? double.tryParse(json['heading'].toString())
          : null,
      accuracy: json['accuracy'] != null
          ? double.tryParse(json['accuracy'].toString())
          : null,
      tripId: json['trip_id'] as String?,
      nearestStopId: json['nearest_stop'] as String?,
      distanceToStop: json['distance_to_stop'] != null
          ? double.tryParse(json['distance_to_stop'].toString())
          : null,
      lineId: json['line'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus': busId,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'altitude': altitude?.toString(),
      'speed': speed?.toString(),
      'heading': heading?.toString(),
      'accuracy': accuracy?.toString(),
      'trip_id': tripId,
      'nearest_stop': nearestStopId,
      'distance_to_stop': distanceToStop?.toString(),
      'line': lineId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get speedText => speed != null ? '${speed!.toStringAsFixed(1)} km/h' : 'N/A';
  String get headingText => heading != null ? '${heading!.toStringAsFixed(0)}°' : 'N/A';
  String get accuracyText => accuracy != null ? '±${accuracy!.toStringAsFixed(1)}m' : 'N/A';
  String get distanceToStopText => distanceToStop != null 
      ? '${(distanceToStop! / 1000).toStringAsFixed(2)} km' 
      : 'N/A';
  
  bool get hasSpeed => speed != null && speed! > 0;
  bool get isStationary => speed != null && speed! < 0.5;
  bool get isNearStop => distanceToStop != null && distanceToStop! < 100; // within 100m
  
  String get formattedTimestamp => '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')}';
  
  // Additional properties expected by UI components
  String get formattedCoordinates => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  String get formattedTime => formattedTimestamp;
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;
  
  // Object wrappers for compatibility with UI components
  Map<String, dynamic>? get bus => busId != null 
    ? {'id': busId, 'license_plate': 'Bus $busId'}
    : null;
    
  Map<String, dynamic>? get trip => tripId != null 
    ? {'id': tripId}
    : null;
    
  Map<String, dynamic>? get nearestStop => nearestStopId != null 
    ? {'id': nearestStopId, 'name': 'Stop ${nearestStopId?.substring(0, 8) ?? 'Unknown'}'}
    : null;

  LocationUpdate copyWith({
    String? id,
    String? busId,
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? accuracy,
    String? tripId,
    String? nearestStopId,
    double? distanceToStop,
    String? lineId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationUpdate(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      tripId: tripId ?? this.tripId,
      nearestStopId: nearestStopId ?? this.nearestStopId,
      distanceToStop: distanceToStop ?? this.distanceToStop,
      lineId: lineId ?? this.lineId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Comprehensive Trip model for journey tracking
class Trip {
  final String id;
  final String busId;
  final Map<String, dynamic>? busDetails;
  final String driverId;
  final Map<String, dynamic>? driverDetails;
  final String lineId;
  final Map<String, dynamic>? lineDetails;
  final DateTime startTime;
  final DateTime? endTime;
  final String? startStopId;
  final String? endStopId;
  final bool isCompleted;
  final double? distance;
  final double? averageSpeed;
  final int maxPassengers;
  final int totalStops;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.busId,
    this.busDetails,
    required this.driverId,
    this.driverDetails,
    required this.lineId,
    this.lineDetails,
    required this.startTime,
    this.endTime,
    this.startStopId,
    this.endStopId,
    required this.isCompleted,
    this.distance,
    this.averageSpeed,
    required this.maxPassengers,
    required this.totalStops,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      busId: json['bus'] as String,
      busDetails: json['bus_details'] as Map<String, dynamic>?,
      driverId: json['driver'] as String,
      driverDetails: json['driver_details'] as Map<String, dynamic>?,
      lineId: json['line'] as String,
      lineDetails: json['line_details'] as Map<String, dynamic>?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      startStopId: json['start_stop'] as String?,
      endStopId: json['end_stop'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null,
      averageSpeed: json['average_speed'] != null
          ? double.tryParse(json['average_speed'].toString())
          : null,
      maxPassengers: json['max_passengers'] as int? ?? 0,
      totalStops: json['total_stops'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus': busId,
      'bus_details': busDetails,
      'driver': driverId,
      'driver_details': driverDetails,
      'line': lineId,
      'line_details': lineDetails,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'start_stop': startStopId,
      'end_stop': endStopId,
      'is_completed': isCompleted,
      'distance': distance?.toString(),
      'average_speed': averageSpeed?.toString(),
      'max_passengers': maxPassengers,
      'total_stops': totalStops,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Trip copyWith({
    String? id,
    String? busId,
    Map<String, dynamic>? busDetails,
    String? driverId,
    Map<String, dynamic>? driverDetails,
    String? lineId,
    Map<String, dynamic>? lineDetails,
    DateTime? startTime,
    DateTime? endTime,
    String? startStopId,
    String? endStopId,
    bool? isCompleted,
    double? distance,
    double? averageSpeed,
    int? maxPassengers,
    int? totalStops,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      busDetails: busDetails ?? this.busDetails,
      driverId: driverId ?? this.driverId,
      driverDetails: driverDetails ?? this.driverDetails,
      lineId: lineId ?? this.lineId,
      lineDetails: lineDetails ?? this.lineDetails,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startStopId: startStopId ?? this.startStopId,
      endStopId: endStopId ?? this.endStopId,
      isCompleted: isCompleted ?? this.isCompleted,
      distance: distance ?? this.distance,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      maxPassengers: maxPassengers ?? this.maxPassengers,
      totalStops: totalStops ?? this.totalStops,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  Duration? get duration => endTime != null 
      ? endTime!.difference(startTime)
      : DateTime.now().difference(startTime);
  
  String get durationText {
    final dur = duration;
    if (dur == null) return 'N/A';
    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
  
  String get distanceText => distance != null 
      ? '${distance!.toStringAsFixed(1)} km' 
      : 'N/A';
  
  String get averageSpeedText => averageSpeed != null 
      ? '${averageSpeed!.toStringAsFixed(1)} km/h' 
      : 'N/A';
  
  String get statusText => isCompleted ? 'Completed' : 'In Progress';
  Color get statusColor => isCompleted ? Colors.green : Colors.blue;
  
  String get formattedStartTime => '${startTime.day}/${startTime.month}/${startTime.year} ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
  String get formattedEndTime => endTime != null 
      ? '${endTime!.day}/${endTime!.month}/${endTime!.year} ${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}'
      : 'Ongoing';
  
  // Additional properties expected by UI components
  String get formattedDuration => durationText;
  String get formattedDistance => distanceText;
  double get totalDistance => distance ?? 0.0;
  double? get maxSpeed => averageSpeed != null ? averageSpeed! * 1.2 : null; // Estimate max speed as 20% higher than average
  IconData get statusIcon => isCompleted ? Icons.check_circle : Icons.play_arrow;
  
  // Computed properties for UI
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
  
  // Stop-related properties from details
  Map<String, dynamic>? get startStop => startStopId != null 
    ? {'id': startStopId, 'name': 'Stop ${startStopId?.substring(0, 8) ?? 'Unknown'}'}
    : null;
  Map<String, dynamic>? get endStop => endStopId != null 
    ? {'id': endStopId, 'name': 'Stop ${endStopId?.substring(0, 8) ?? 'Unknown'}'}
    : null;
  
  // Line and bus wrapper objects for compatibility
  Map<String, dynamic> get line => lineDetails ?? {'id': lineId, 'name': 'Line $lineId'};
  Map<String, dynamic> get bus => busDetails ?? {'id': busId, 'license_plate': 'Bus $busId'};
}

/// BusLine assignment model for tracking bus-line relationships
class BusLine {
  final String id;
  final String busId;
  final Map<String, dynamic>? busDetails;
  final String lineId;
  final Map<String, dynamic>? lineDetails;
  final bool isActive;
  final TrackingStatus trackingStatus;
  final String? tripId;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusLine({
    required this.id,
    required this.busId,
    this.busDetails,
    required this.lineId,
    this.lineDetails,
    required this.isActive,
    required this.trackingStatus,
    this.tripId,
    this.startTime,
    this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      id: json['id'] as String,
      busId: json['bus'] as String,
      busDetails: json['bus_details'] as Map<String, dynamic>?,
      lineId: json['line'] as String,
      lineDetails: json['line_details'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? false,
      trackingStatus: TrackingStatus.fromValue(json['tracking_status'] as String? ?? 'idle'),
      tripId: json['trip_id'] as String?,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus': busId,
      'bus_details': busDetails,
      'line': lineId,
      'line_details': lineDetails,
      'is_active': isActive,
      'tracking_status': trackingStatus.value,
      'trip_id': tripId,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  Color get trackingStatusColor {
    switch (trackingStatus) {
      case TrackingStatus.idle:
        return Colors.grey;
      case TrackingStatus.active:
        return Colors.green;
      case TrackingStatus.paused:
        return Colors.orange;
    }
  }

  IconData get trackingStatusIcon {
    switch (trackingStatus) {
      case TrackingStatus.idle:
        return Icons.stop;
      case TrackingStatus.active:
        return Icons.play_arrow;
      case TrackingStatus.paused:
        return Icons.pause;
    }
  }

  String get statusText => isActive ? 'Active' : 'Inactive';
  Color get statusColor => isActive ? Colors.green : Colors.red;
  
  bool get hasCurrentTrip => tripId != null;
  bool get isTracking => trackingStatus == TrackingStatus.active;
  
  // Additional properties expected by UI components
  String get trackingStatusText => trackingStatus.displayName;
  String get formattedAssignedAt => startTime != null 
      ? '${startTime!.day}/${startTime!.month}/${startTime!.year} ${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}'
      : 'Not assigned';
  
  // Object wrappers for compatibility with UI components
  Map<String, dynamic> get bus => busDetails ?? {'id': busId, 'license_plate': 'Bus $busId'};
  Map<String, dynamic> get line => lineDetails ?? {'id': lineId, 'name': 'Line $lineId'};

  BusLine copyWith({
    String? id,
    String? busId,
    Map<String, dynamic>? busDetails,
    String? lineId,
    Map<String, dynamic>? lineDetails,
    bool? isActive,
    TrackingStatus? trackingStatus,
    String? tripId,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusLine(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      busDetails: busDetails ?? this.busDetails,
      lineId: lineId ?? this.lineId,
      lineDetails: lineDetails ?? this.lineDetails,
      isActive: isActive ?? this.isActive,
      trackingStatus: trackingStatus ?? this.trackingStatus,
      tripId: tripId ?? this.tripId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Request models for Tracking operations

class AnomalyCreateRequest {
  final AnomalyType type;
  final String description;
  final AnomalySeverity? severity;
  final double? locationLatitude;
  final double? locationLongitude;

  const AnomalyCreateRequest({
    required this.type,
    required this.description,
    this.severity,
    this.locationLatitude,
    this.locationLongitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'description': description,
      if (severity != null) 'severity': severity!.value,
      if (locationLatitude != null) 'location_latitude': locationLatitude.toString(),
      if (locationLongitude != null) 'location_longitude': locationLongitude.toString(),
    };
  }
}

class LocationUpdateCreateRequest {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;

  const LocationUpdateCreateRequest({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (altitude != null) 'altitude': altitude.toString(),
      if (speed != null) 'speed': speed.toString(),
      if (heading != null) 'heading': heading.toString(),
      if (accuracy != null) 'accuracy': accuracy.toString(),
    };
  }
}

class TripCreateRequest {
  final String busId;
  final String driverId;
  final String lineId;
  final DateTime startTime;
  final String? startStopId;
  final String? notes;

  const TripCreateRequest({
    required this.busId,
    required this.driverId,
    required this.lineId,
    required this.startTime,
    this.startStopId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'bus': busId,
      'driver': driverId,
      'line': lineId,
      'start_time': startTime.toIso8601String(),
      if (startStopId != null) 'start_stop': startStopId,
      if (notes != null) 'notes': notes,
    };
  }
}

class BusLineCreateRequest {
  final String busId;
  final String lineId;

  const BusLineCreateRequest({
    required this.busId,
    required this.lineId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bus': busId,
      'line': lineId,
    };
  }
}

/// Query parameters for filtering trips
class TripQueryParameters {
  final String? busId;
  final String? driverId;
  final String? lineId;
  final bool? isCompleted;
  final DateTime? startTimeAfter;
  final DateTime? startTimeBefore;
  final DateTime? endTimeAfter;
  final DateTime? endTimeBefore;
  final List<String>? orderBy;
  final int? offset;
  final int? limit;
  final int? pageSize;

  const TripQueryParameters({
    this.busId,
    this.driverId,
    this.lineId,
    this.isCompleted,
    this.startTimeAfter,
    this.startTimeBefore,
    this.endTimeAfter,
    this.endTimeBefore,
    this.orderBy,
    this.offset,
    this.limit,
    this.pageSize,
  });

  Map<String, dynamic> toMap() {
    final params = <String, dynamic>{};
    
    if (busId != null) params['bus'] = busId;
    if (driverId != null) params['driver'] = driverId;
    if (lineId != null) params['line'] = lineId;
    if (isCompleted != null) params['is_completed'] = isCompleted;
    if (startTimeAfter != null) params['start_time__gte'] = startTimeAfter!.toIso8601String();
    if (startTimeBefore != null) params['start_time__lte'] = startTimeBefore!.toIso8601String();
    if (endTimeAfter != null) params['end_time__gte'] = endTimeAfter!.toIso8601String();
    if (endTimeBefore != null) params['end_time__lte'] = endTimeBefore!.toIso8601String();
    if (orderBy != null && orderBy!.isNotEmpty) params['ordering'] = orderBy!.join(',');
    if (offset != null) params['offset'] = offset;
    if (limit != null) params['limit'] = limit;
    if (pageSize != null) params['page_size'] = pageSize;
    
    return params;
  }
}