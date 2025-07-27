// lib/models/trip_model.dart

/// Model for trip data
class Trip {
  final String id;
  final String lineId;
  final String busId;
  final String driverId;
  final String? passengerId;
  final DateTime startTime;
  final DateTime? endTime;
  final String startLocationId;
  final String endLocationId;
  final String startLocationName;
  final String endLocationName;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final String status; // planned, active, completed, cancelled
  final double? distance;
  final int? duration; // in minutes
  final double? fare;
  final String? paymentMethod;
  final String? paymentStatus;
  final int? passengerCount;
  final List<TripStop> stops;
  final double? rating;
  final String? feedback;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Trip({
    required this.id,
    required this.lineId,
    required this.busId,
    required this.driverId,
    this.passengerId,
    required this.startTime,
    this.endTime,
    required this.startLocationId,
    required this.endLocationId,
    required this.startLocationName,
    required this.endLocationName,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.status = 'planned',
    this.distance,
    this.duration,
    this.fare,
    this.paymentMethod,
    this.paymentStatus,
    this.passengerCount,
    this.stops = const [],
    this.rating,
    this.feedback,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if trip is active
  bool get isActive => status == 'active';

  /// Check if trip is completed
  bool get isCompleted => status == 'completed';

  /// Check if trip is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if trip is planned
  bool get isPlanned => status == 'planned';

  /// Get trip duration in minutes
  int? get actualDuration {
    if (endTime != null) {
      return endTime!.difference(startTime).inMinutes;
    }
    return null;
  }

  /// Get average speed in km/h
  double? get averageSpeed {
    final actualDur = actualDuration;
    if (distance != null && actualDur != null && actualDur > 0) {
      return (distance! / actualDur) * 60; // Convert to km/h
    }
    return null;
  }

  /// Check if payment is completed
  bool get isPaymentCompleted => paymentStatus == 'completed';

  /// Check if trip has rating
  bool get hasRating => rating != null;

  /// Get status color
  String get statusColor {
    switch (status) {
      case 'active':
        return 'success';
      case 'completed':
        return 'info';
      case 'cancelled':
        return 'error';
      case 'planned':
      default:
        return 'primary';
    }
  }

  /// Create from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      lineId: json['lineId'] ?? '',
      busId: json['busId'] ?? '',
      driverId: json['driverId'] ?? '',
      passengerId: json['passengerId'],
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      startLocationId: json['startLocationId'] ?? '',
      endLocationId: json['endLocationId'] ?? '',
      startLocationName: json['startLocationName'] ?? '',
      endLocationName: json['endLocationName'] ?? '',
      startLatitude: json['startLatitude']?.toDouble(),
      startLongitude: json['startLongitude']?.toDouble(),
      endLatitude: json['endLatitude']?.toDouble(),
      endLongitude: json['endLongitude']?.toDouble(),
      status: json['status'] ?? 'planned',
      distance: json['distance']?.toDouble(),
      duration: json['duration'],
      fare: json['fare']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      passengerCount: json['passengerCount'],
      stops: (json['stops'] as List<dynamic>?)
          ?.map((stopJson) => TripStop.fromJson(stopJson))
          .toList() ?? [],
      rating: json['rating']?.toDouble(),
      feedback: json['feedback'],
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
      'passengerId': passengerId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startLocationId': startLocationId,
      'endLocationId': endLocationId,
      'startLocationName': startLocationName,
      'endLocationName': endLocationName,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'status': status,
      'distance': distance,
      'duration': duration,
      'fare': fare,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'passengerCount': passengerCount,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'rating': rating,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Trip copyWith({
    String? id,
    String? lineId,
    String? busId,
    String? driverId,
    String? passengerId,
    DateTime? startTime,
    DateTime? endTime,
    String? startLocationId,
    String? endLocationId,
    String? startLocationName,
    String? endLocationName,
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
    String? status,
    double? distance,
    int? duration,
    double? fare,
    String? paymentMethod,
    String? paymentStatus,
    int? passengerCount,
    List<TripStop>? stops,
    double? rating,
    String? feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      busId: busId ?? this.busId,
      driverId: driverId ?? this.driverId,
      passengerId: passengerId ?? this.passengerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startLocationId: startLocationId ?? this.startLocationId,
      endLocationId: endLocationId ?? this.endLocationId,
      startLocationName: startLocationName ?? this.startLocationName,
      endLocationName: endLocationName ?? this.endLocationName,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      status: status ?? this.status,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      fare: fare ?? this.fare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      passengerCount: passengerCount ?? this.passengerCount,
      stops: stops ?? this.stops,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trip &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Additional properties expected by enhanced screens
  String get fromStop => startLocationName; // Alias for UI consistency
  String get toStop => endLocationName; // Alias for UI consistency
  String get date => startTime.toString().split(' ')[0]; // Date string

  @override
  String toString() {
    return 'Trip{id: $id, lineId: $lineId, status: $status}';
  }
}

/// Model for trip stop information
class TripStop {
  final String stopId;
  final String stopName;
  final double latitude;
  final double longitude;
  final DateTime? arrivalTime;
  final DateTime? departureTime;
  final int order;
  final bool isCompleted;
  final int? passengersBoarded;
  final int? passengersAlighted;

  const TripStop({
    required this.stopId,
    required this.stopName,
    required this.latitude,
    required this.longitude,
    this.arrivalTime,
    this.departureTime,
    required this.order,
    this.isCompleted = false,
    this.passengersBoarded,
    this.passengersAlighted,
  });

  /// Get stop duration in minutes
  int? get stopDuration {
    if (arrivalTime != null && departureTime != null) {
      return departureTime!.difference(arrivalTime!).inMinutes;
    }
    return null;
  }

  /// Create from JSON
  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      stopId: json['stopId'] ?? '',
      stopName: json['stopName'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      arrivalTime: json['arrivalTime'] != null ? DateTime.parse(json['arrivalTime']) : null,
      departureTime: json['departureTime'] != null ? DateTime.parse(json['departureTime']) : null,
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
      'latitude': latitude,
      'longitude': longitude,
      'arrivalTime': arrivalTime?.toIso8601String(),
      'departureTime': departureTime?.toIso8601String(),
      'order': order,
      'isCompleted': isCompleted,
      'passengersBoarded': passengersBoarded,
      'passengersAlighted': passengersAlighted,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripStop &&
          runtimeType == other.runtimeType &&
          stopId == other.stopId &&
          order == other.order;

  @override
  int get hashCode => stopId.hashCode ^ order.hashCode;
}

/// Trip status enumeration
class TripStatus {
  static const String planned = 'planned';
  static const String active = 'active';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static const List<String> all = [
    planned,
    active,
    completed,
    cancelled,
  ];

  static String getDisplayName(String status) {
    switch (status) {
      case planned:
        return 'Planned';
      case active:
        return 'Active';
      case completed:
        return 'Completed';
      case cancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
}

/// Payment method enumeration
class PaymentMethod {
  static const String cash = 'cash';
  static const String card = 'card';
  static const String mobile = 'mobile';
  static const String prepaid = 'prepaid';

  static const List<String> all = [
    cash,
    card,
    mobile,
    prepaid,
  ];

  static String getDisplayName(String method) {
    switch (method) {
      case cash:
        return 'Cash';
      case card:
        return 'Credit/Debit Card';
      case mobile:
        return 'Mobile Payment';
      case prepaid:
        return 'Prepaid Card';
      default:
        return method;
    }
  }
}