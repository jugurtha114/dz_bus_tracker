// lib/models/stop_model.dart

/// Stop model representing bus stops in the system
class Stop {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Stop({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Request model for reporting waiting passengers
class WaitingPassengersReportRequest {
  final int count;
  final String? lineId;

  const WaitingPassengersReportRequest({
    required this.count,
    this.lineId,
  });

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      if (lineId != null) 'line_id': lineId,
    };
  }
}