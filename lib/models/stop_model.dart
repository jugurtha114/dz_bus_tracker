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
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
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

  /// Mock property for next arrival time
  String? get nextArrival => '5 min'; // Mock - should be calculated from real-time data

  /// Additional properties for UI compatibility
  String get status => isActive ? 'active' : 'inactive';
  int get lineCount => 3; // Mock - should count actual lines serving this stop
  int get avgFrequency => 15; // Mock - should calculate average frequency in minutes
  double get distance => 0.0; // Mock - should calculate distance from user location
  double? get distanceFromUser => 0.5; // Mock - distance from user in km
  String get type => 'Regular'; // Mock - should indicate stop type
  String get zone => 'Zone A'; // Mock - should indicate fare zone
  bool get accessibility => true; // Mock - should indicate accessibility features
  bool? get isAccessible => true; // Alias for accessibility
  int get dailyPassengers => 250; // Mock - should come from analytics
  int get avgWaitTime => 8; // Mock - should come from analytics in minutes
  double get reliability => 85.5; // Mock - should come from performance data
  double get rating => 4.2; // Mock - should come from user ratings
  List<String>? get lines => ['Line 1', 'Line 2', 'Line 3']; // Mock - lines serving this stop
  
  // Additional properties expected by enhanced screens
  String get code => 'ST${id.padLeft(4, '0')}'; // Mock stop code
  int get waitingPassengers => 12; // Mock waiting passengers count
  bool get hasShelter => true; // Mock shelter availability
  bool get hasBench => true; // Mock bench availability
  bool get hasDisplay => true; // Mock display availability
  bool get hasLighting => true; // Mock lighting availability
  bool get hasCCTV => true; // Mock CCTV availability
  bool get hasEmergencyButton => false; // Mock emergency button
  bool get hasWifi => false; // Mock wifi availability
  bool get hasTicketMachine => false; // Mock ticket machine
  bool get isWheelchairAccessible => true; // Mock wheelchair accessibility
  bool get hasVisualDisplays => true; // Mock visual displays
  bool get hasAudioAnnouncements => false; // Mock audio announcements
  bool get hasTactilePaving => true; // Mock tactile paving
}

/// Request model for reporting waiting passengers
class WaitingPassengersReportRequest {
  final int count;
  final String? lineId;

  const WaitingPassengersReportRequest({required this.count, this.lineId});

  Map<String, dynamic> toJson() {
    return {'count': count, if (lineId != null) 'line_id': lineId};
  }
}
