// lib/models/bus_model.dart

import 'package:flutter/material.dart';

/// Bus status enumeration based on API schema
enum BusStatus {
  active('active'),
  inactive('inactive'),
  maintenance('maintenance');

  const BusStatus(this.value);
  final String value;

  static BusStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return BusStatus.active;
      case 'inactive':
        return BusStatus.inactive;
      case 'maintenance':
        return BusStatus.maintenance;
      default:
        throw ArgumentError('Invalid bus status: $value');
    }
  }

  @override
  String toString() => value;
}

/// Bus data model based on API schema
class Bus {
  final String id;
  final String licensePlate;
  final String driver;
  final Map<String, dynamic>? driverDetails;
  final String model;
  final String manufacturer;
  final int year;
  final int capacity;
  final BusStatus status;
  final bool isAirConditioned;
  final bool hasWifi;
  final bool hasGPS;
  final String? photo;
  final dynamic features;
  final String? description;
  final bool isActive;
  final bool isApproved;
  final bool isRejected;
  final double? driverRating;
  final bool isWheelchairAccessible;
  final DateTime? lastLocationUpdate;
  final Map<String, dynamic>? currentLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Bus({
    required this.id,
    required this.licensePlate,
    required this.driver,
    this.driverDetails,
    required this.model,
    required this.manufacturer,
    required this.year,
    required this.capacity,
    required this.status,
    required this.isAirConditioned,
    this.hasWifi = false,
    this.hasGPS = false,
    this.photo,
    this.features,
    this.description,
    required this.isActive,
    required this.isApproved,
    this.isRejected = false,
    this.driverRating,
    this.isWheelchairAccessible = false,
    this.lastLocationUpdate,
    this.currentLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'] as String,
      licensePlate: json['license_plate'] as String,
      driver: json['driver'] as String,
      driverDetails: json['driver_details'] as Map<String, dynamic>?,
      model: json['model'] as String,
      manufacturer: json['manufacturer'] as String,
      year: json['year'] as int,
      capacity: json['capacity'] as int,
      status: BusStatus.fromString(json['status'] as String),
      isAirConditioned: json['is_air_conditioned'] as bool? ?? false,
      hasWifi: json['has_wifi'] as bool? ?? false,
      hasGPS: json['has_gps'] as bool? ?? false,
      photo: json['photo'] as String?,
      features: json['features'],
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isApproved: json['is_approved'] as bool? ?? false,
      isRejected: json['is_rejected'] as bool? ?? false,
      driverRating: (json['driver_rating'] as num?)?.toDouble(),
      isWheelchairAccessible: json['is_wheelchair_accessible'] as bool? ?? false,
      lastLocationUpdate: json['last_location_update'] != null 
          ? DateTime.parse(json['last_location_update'] as String)
          : null,
      currentLocation: json['current_location'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_plate': licensePlate,
      'driver': driver,
      'driver_details': driverDetails,
      'model': model,
      'manufacturer': manufacturer,
      'year': year,
      'capacity': capacity,
      'status': status.value,
      'is_air_conditioned': isAirConditioned,
      'has_wifi': hasWifi,
      'has_gps': hasGPS,
      'photo': photo,
      'features': features,
      'description': description,
      'is_active': isActive,
      'is_approved': isApproved,
      'is_rejected': isRejected,
      'driver_rating': driverRating,
      'is_wheelchair_accessible': isWheelchairAccessible,
      'last_location_update': lastLocationUpdate?.toIso8601String(),
      'current_location': currentLocation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Map for forms (alias for toJson)
  Map<String, dynamic> toMap() => toJson();

  Bus copyWith({
    String? licensePlate,
    String? driver,
    Map<String, dynamic>? driverDetails,
    String? model,
    String? manufacturer,
    int? year,
    int? capacity,
    BusStatus? status,
    bool? isAirConditioned,
    String? photo,
    dynamic features,
    String? description,
    bool? isActive,
    bool? isApproved,
    bool? isRejected,
    double? driverRating,
    bool? isWheelchairAccessible,
    DateTime? lastLocationUpdate,
    Map<String, dynamic>? currentLocation,
  }) {
    return Bus(
      id: id,
      licensePlate: licensePlate ?? this.licensePlate,
      driver: driver ?? this.driver,
      driverDetails: driverDetails ?? this.driverDetails,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      year: year ?? this.year,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      isAirConditioned: isAirConditioned ?? this.isAirConditioned,
      photo: photo ?? this.photo,
      features: features ?? this.features,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      isRejected: isRejected ?? this.isRejected,
      driverRating: driverRating ?? this.driverRating,
      isWheelchairAccessible: isWheelchairAccessible ?? this.isWheelchairAccessible,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      currentLocation: currentLocation ?? this.currentLocation,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Get the driver's name from driver details
  String get driverName {
    if (driverDetails != null) {
      final firstName = driverDetails!['first_name'] as String?;
      final lastName = driverDetails!['last_name'] as String?;
      if (firstName != null && lastName != null) {
        return '$firstName $lastName'.trim();
      }
    }
    return 'Unknown Driver';
  }

  /// Get bus info for display
  String get displayInfo => '$year $manufacturer $model';

  /// Check if bus is operational
  bool get isOperational =>
      isActive && isApproved && status == BusStatus.active;

  /// Get current passenger count from location data
  int get currentPassengerCount {
    if (currentLocation != null &&
        currentLocation!.containsKey('passenger_count')) {
      return currentLocation!['passenger_count'] as int? ?? 0;
    }
    return 0;
  }

  /// Get occupancy percentage
  double get occupancyPercentage {
    if (capacity == 0) return 0.0;
    return (currentPassengerCount / capacity).clamp(0.0, 1.0);
  }

  /// Get driver ID (alias for driver field)
  String get driverId => driver;

  /// Get bus number for display (alias for license plate)
  String get busNumber => licensePlate;

  /// Check if bus needs maintenance
  bool get needsMaintenance => status == BusStatus.maintenance;

  /// Get bus number (alias for license plate)
  String get number => licensePlate;

  /// Get maintenance notes (mock property)
  String? get maintenanceNotes => status == BusStatus.maintenance 
      ? 'Scheduled maintenance required' 
      : null;

  /// Get last maintenance date (mock property)
  DateTime? get lastMaintenanceDate => status == BusStatus.maintenance 
      ? DateTime.now().subtract(const Duration(days: 30)) 
      : null;

  /// Get total distance (mock property)
  double get totalDistance => 15000.0; // Mock km driven

  /// Get total trips (mock property)
  int get totalTrips => 250; // Mock number of trips

  /// Get line name from current location or default
  String get lineName {
    if (currentLocation != null && currentLocation!.containsKey('line_name')) {
      return currentLocation!['line_name'] as String? ?? 'Unknown Line';
    }
    return 'Unknown Line';
  }

  /// Additional properties for UI compatibility
  String get occupancyLevel {
    final percentage = (currentPassengerCount / capacity) * 100;
    if (percentage < 30) return 'Low';
    if (percentage < 70) return 'Medium';
    if (percentage < 90) return 'High';
    return 'Full';
  }

  double get currentSpeed => 25.0; // Mock - should come from GPS data
  String get currentRoute => lineName; // Alias for lineName
  String get direction => 'Inbound'; // Mock - should come from route data
  String? get nextStop => 'Central Station'; // Mock - should come from route data
  String get distanceToNextStop => '2.5 km'; // Mock - should be calculated
  String get estimatedArrival => '8 min'; // Mock - should be calculated
  String get firstDeparture => '06:00'; // Mock - should come from schedule
  String get lastDeparture => '22:00'; // Mock - should come from schedule
  int get frequency => 15; // Mock - should come from schedule
  String get serviceDays => 'Daily'; // Mock - should come from schedule
  DateTime get lastUpdate => DateTime.now().subtract(const Duration(minutes: 2));
  int get currentPassengers => currentPassengerCount; // Alias

  /// Get estimated arrival time in minutes
  int? get eta {
    if (currentLocation != null && currentLocation!.containsKey('eta_minutes')) {
      return currentLocation!['eta_minutes'] as int?;
    }
    return null;
  }

  /// Get passenger count (alias for currentPassengerCount)
  int get passengerCount => currentPassengerCount;

  /// Get current latitude from location
  double get latitude {
    if (currentLocation != null && currentLocation!.containsKey('latitude')) {
      return (currentLocation!['latitude'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  /// Get current longitude from location
  double get longitude {
    if (currentLocation != null && currentLocation!.containsKey('longitude')) {
      return (currentLocation!['longitude'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  /// Get line ID from current location
  String? get lineId {
    if (currentLocation != null && currentLocation!.containsKey('line_id')) {
      return currentLocation!['line_id'] as String?;
    }
    return null;
  }

  /// Get image URL for bus (alias for photo)
  String? get imageUrl => photo;

  /// Get plate number (alias for licensePlate)
  String get plateNumber => licensePlate;

  /// Get make (alias for manufacturer)
  String get make => manufacturer;

  /// Get owner name from driver details
  String get ownerName {
    if (driverDetails != null) {
      final firstName = driverDetails!['first_name'] as String?;
      final lastName = driverDetails!['last_name'] as String?;
      if (firstName != null && lastName != null) {
        return '$firstName $lastName'.trim();
      }
    }
    return 'Unknown Owner';
  }

  /// Get owner phone from driver details
  String get ownerPhone {
    if (driverDetails != null && driverDetails!.containsKey('phone')) {
      return driverDetails!['phone'] as String? ?? 'N/A';
    }
    return 'N/A';
  }

  /// Get registration date (using creation date as DateTime)
  DateTime get registrationDate => createdAt;

  /// Get formatted registration date string
  String get registrationDateString {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get rejection reason (mock - should be stored in database)
  String get rejectionReason => 'No rejection reason specified';

  /// Get bus color (mock property)
  String get color => 'White';

  /// Get engine number (mock property)
  String get engineNumber => 'ENG${year}${id.hashCode.abs().toString().substring(0, 4)}';

  /// Get chassis number (mock property)
  String get chassisNumber => 'CHA${year}${id.hashCode.abs().toString().substring(0, 4)}';

  /// Get fuel type (mock property)
  String get fuelType => 'Diesel';

  /// Get insurance number (mock property)
  String get insuranceNumber => 'INS${year}${id.hashCode.abs().toString().substring(0, 4)}';

  /// Get registration document URL (mock)
  String? get registrationDocument => photo;

  /// Get insurance document URL (mock)
  String? get insuranceDocument => photo;

  /// Get technical inspection document URL (mock)
  String? get technicalInspection => photo;

  /// Get assigned driver name from driver details
  String get assignedDriverName {
    if (driverDetails != null) {
      final firstName = driverDetails!['first_name'] as String?;
      final lastName = driverDetails!['last_name'] as String?;
      if (firstName != null && lastName != null) {
        return '$firstName $lastName'.trim();
      }
    }
    return 'No Driver Assigned';
  }

  /// Get assigned route (mock property)
  String get assignedRoute => 'Route ${id.hashCode.abs() % 50 + 1}'; // Mock route assignment

  /// Get mileage (mock property)
  String get mileage => '${(year * 1000 + id.hashCode.abs() % 50000).toString()} km';

  /// Get status color based on bus status
  Color get statusColor => getStatusColor(status);

  /// Get status color for a given bus status
  static Color getStatusColor(BusStatus status) {
    switch (status) {
      case BusStatus.active:
        return const Color(0xFF4CAF50); // Green
      case BusStatus.inactive:
        return const Color(0xFF9E9E9E); // Grey
      case BusStatus.maintenance:
        return const Color(0xFFFF9800); // Orange
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bus && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Bus(id: $id, licensePlate: $licensePlate, model: $model, status: $status)';
  }
}

/// Bus creation request model
class BusCreateRequest {
  final String licensePlate;
  final String driver;
  final String model;
  final String manufacturer;
  final int year;
  final int capacity;
  final bool isAirConditioned;
  final String? photo;
  final dynamic features;
  final String? description;

  const BusCreateRequest({
    required this.licensePlate,
    required this.driver,
    required this.model,
    required this.manufacturer,
    required this.year,
    required this.capacity,
    required this.isAirConditioned,
    this.photo,
    this.features,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'license_plate': licensePlate,
      'driver': driver,
      'model': model,
      'manufacturer': manufacturer,
      'year': year,
      'capacity': capacity,
      'is_air_conditioned': isAirConditioned,
    };

    if (photo != null) json['photo'] = photo;
    if (features != null) json['features'] = features;
    if (description != null) json['description'] = description;

    return json;
  }
}

/// Bus update request model
class BusUpdateRequest {
  final String? licensePlate;
  final String? driver;
  final String? model;
  final String? manufacturer;
  final int? year;
  final int? capacity;
  final BusStatus? status;
  final bool? isAirConditioned;
  final String? photo;
  final dynamic features;
  final String? description;
  final bool? isActive;

  const BusUpdateRequest({
    this.licensePlate,
    this.driver,
    this.model,
    this.manufacturer,
    this.year,
    this.capacity,
    this.status,
    this.isAirConditioned,
    this.photo,
    this.features,
    this.description,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (licensePlate != null) json['license_plate'] = licensePlate;
    if (driver != null) json['driver'] = driver;
    if (model != null) json['model'] = model;
    if (manufacturer != null) json['manufacturer'] = manufacturer;
    if (year != null) json['year'] = year;
    if (capacity != null) json['capacity'] = capacity;
    if (status != null) json['status'] = status!.value;
    if (isAirConditioned != null) json['is_air_conditioned'] = isAirConditioned;
    if (photo != null) json['photo'] = photo;
    if (features != null) json['features'] = features;
    if (description != null) json['description'] = description;
    if (isActive != null) json['is_active'] = isActive;

    return json;
  }
}

/// Bus location update request model
class BusLocationUpdateRequest {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final int? passengerCount;

  const BusLocationUpdateRequest({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    this.passengerCount,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };

    if (altitude != null) json['altitude'] = altitude.toString();
    if (speed != null) json['speed'] = speed.toString();
    if (heading != null) json['heading'] = heading.toString();
    if (accuracy != null) json['accuracy'] = accuracy.toString();
    if (passengerCount != null) json['passenger_count'] = passengerCount;

    return json;
  }
}

/// Bus location model
class BusLocation {
  final String id;
  final String bus;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? accuracy;
  final int passengerCount;
  final bool isTrackingActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusLocation({
    required this.id,
    required this.bus,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    required this.passengerCount,
    required this.isTrackingActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    return BusLocation(
      id: json['id'] as String,
      bus: json['bus'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null
          ? (json['heading'] as num).toDouble()
          : null,
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      passengerCount: json['passenger_count'] as int? ?? 0,
      isTrackingActive: json['is_tracking_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus': bus,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
      'passenger_count': passengerCount,
      'is_tracking_active': isTrackingActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BusLocation(id: $id, bus: $bus, lat: $latitude, lng: $longitude)';
  }
}

/// Passenger count update request model
class PassengerCountUpdateRequest {
  final int count;

  const PassengerCountUpdateRequest({required this.count});

  Map<String, dynamic> toJson() {
    return {'count': count};
  }
}

/// Bus approval request model
class BusApprovalRequest {
  final bool approve;
  final String? reason;

  const BusApprovalRequest({required this.approve, this.reason});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'approve': approve};
    if (reason != null) json['reason'] = reason;
    return json;
  }
}
