// lib/models/line_model.dart

import 'package:flutter/material.dart';

/// Line status enum for managing line states
enum LineStatus {
  active('active'),
  inactive('inactive');

  const LineStatus(this.value);
  final String value;
}

/// Day of week enumeration for schedules
enum DayOfWeek {
  monday(0, 'Monday'),
  tuesday(1, 'Tuesday'),
  wednesday(2, 'Wednesday'),
  thursday(3, 'Thursday'),
  friday(4, 'Friday'),
  saturday(5, 'Saturday'),
  sunday(6, 'Sunday');

  const DayOfWeek(this.value, this.name);
  final int value;
  final String name;

  static DayOfWeek fromValue(int value) {
    return DayOfWeek.values.firstWhere(
      (day) => day.value == value,
      orElse: () => DayOfWeek.monday,
    );
  }
}

/// Comprehensive Line model with helper methods
class Line {
  final String id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final String? color;
  final int? frequency;
  final List<LineStop> stops;
  final List<Schedule> schedules;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Line({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    this.color,
    this.frequency,
    required this.stops,
    required this.schedules,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Line.fromJson(Map<String, dynamic> json) {
    return Line(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      color: json['color'] as String?,
      frequency: json['frequency'] as int?,
      stops: (json['stops'] as List<dynamic>?)
          ?.map((item) => LineStop.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((item) => Schedule.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'is_active': isActive,
      'color': color,
      'frequency': frequency,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  LineStatus get status => isActive ? LineStatus.active : LineStatus.inactive;
  
  Color get lineColor {
    if (color != null && color!.isNotEmpty) {
      try {
        return Color(int.parse(color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }

  String get displayName => '$code - $name';
  
  int get stopCount => stops.length;
  
  bool get hasSchedules => schedules.isNotEmpty;
  
  String? get frequencyText => frequency != null ? '${frequency} min' : null;
  
  List<Schedule> get activeSchedules => 
      schedules.where((schedule) => schedule.isActive).toList();
  
  List<Schedule> getSchedulesForDay(DayOfWeek day) =>
      schedules.where((schedule) => schedule.dayOfWeek == day).toList();
  
  // Helper methods
  bool isOperational() => isActive && hasSchedules;
  
  String getStopOrderText() {
    if (stops.isEmpty) return 'No stops';
    if (stops.length == 1) return '1 stop';
    return '${stops.length} stops';
  }

  static Color getStatusColor(LineStatus status) {
    switch (status) {
      case LineStatus.active:
        return Colors.green;
      case LineStatus.inactive:
        return Colors.red;
    }
  }

  Color get statusColor => getStatusColor(status);

  Line copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    bool? isActive,
    String? color,
    int? frequency,
    List<LineStop>? stops,
    List<Schedule>? schedules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Line(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      stops: stops ?? this.stops,
      schedules: schedules ?? this.schedules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Line stop model representing a stop within a line
class LineStop {
  final String id;
  final String stopId;
  final String lineId;
  final int order;
  final double? distanceFromPrevious;
  final int? averageTimeFromPrevious;
  final String? stopName;
  final double? latitude;
  final double? longitude;

  const LineStop({
    required this.id,
    required this.stopId,
    required this.lineId,
    required this.order,
    this.distanceFromPrevious,
    this.averageTimeFromPrevious,
    this.stopName,
    this.latitude,
    this.longitude,
  });

  factory LineStop.fromJson(Map<String, dynamic> json) {
    return LineStop(
      id: json['id'] as String,
      stopId: json['stop_id'] as String,
      lineId: json['line_id'] as String,
      order: json['order'] as int,
      distanceFromPrevious: json['distance_from_previous'] != null
          ? double.tryParse(json['distance_from_previous'].toString())
          : null,
      averageTimeFromPrevious: json['average_time_from_previous'] as int?,
      stopName: json['stop_name'] as String?,
      latitude: json['latitude'] != null 
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null 
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stop_id': stopId,
      'line_id': lineId,
      'order': order,
      'distance_from_previous': distanceFromPrevious?.toString(),
      'average_time_from_previous': averageTimeFromPrevious,
      'stop_name': stopName,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
    };
  }

  String get displayName => stopName ?? 'Stop $order';
  
  String get timeText => averageTimeFromPrevious != null 
      ? '${averageTimeFromPrevious} min' 
      : '';

  String get distanceText => distanceFromPrevious != null 
      ? '${distanceFromPrevious!.toStringAsFixed(1)} km' 
      : '';
}

/// Schedule model for line timetables
class Schedule {
  final String id;
  final String lineId;
  final DayOfWeek dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;
  final int frequencyMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Schedule({
    required this.id,
    required this.lineId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.frequencyMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      lineId: json['line'] as String,
      dayOfWeek: DayOfWeek.fromValue(json['day_of_week'] as int),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isActive: json['is_active'] as bool? ?? false,
      frequencyMinutes: json['frequency_minutes'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'line': lineId,
      'day_of_week': dayOfWeek.value,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
      'frequency_minutes': frequencyMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayTime => '$startTime - $endTime';
  
  String get frequencyText => '${frequencyMinutes} min';
  
  String get dayText => dayOfWeek.name;
  
  bool isCurrentlyActive() {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final currentDayOfWeek = DayOfWeek.fromValue(now.weekday - 1);
    
    if (currentDayOfWeek != dayOfWeek) return false;
    
    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      final startDateTime = DateTime(
        now.year, now.month, now.day,
        int.parse(startParts[0]), int.parse(startParts[1]),
      );
      
      final endDateTime = DateTime(
        now.year, now.month, now.day,
        int.parse(endParts[0]), int.parse(endParts[1]),
      );
      
      return now.isAfter(startDateTime) && now.isBefore(endDateTime);
    } catch (e) {
      return false;
    }
  }
}

/// Request models for Line operations

class LineCreateRequest {
  final String name;
  final String code;
  final String? description;
  final String? color;
  final int? frequency;

  const LineCreateRequest({
    required this.name,
    required this.code,
    this.description,
    this.color,
    this.frequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (frequency != null) 'frequency': frequency,
    };
  }
}

class LineUpdateRequest {
  final String? name;
  final String? code;
  final String? description;
  final String? color;
  final int? frequency;
  final bool? isActive;

  const LineUpdateRequest({
    this.name,
    this.code,
    this.description,
    this.color,
    this.frequency,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (code != null) json['code'] = code;
    if (description != null) json['description'] = description;
    if (color != null) json['color'] = color;
    if (frequency != null) json['frequency'] = frequency;
    if (isActive != null) json['is_active'] = isActive;
    return json;
  }
}

class AddStopToLineRequest {
  final String stopId;
  final int order;
  final double? distanceFromPrevious;
  final int? averageTimeFromPrevious;

  const AddStopToLineRequest({
    required this.stopId,
    required this.order,
    this.distanceFromPrevious,
    this.averageTimeFromPrevious,
  });

  Map<String, dynamic> toJson() {
    return {
      'stop_id': stopId,
      'order': order,
      if (distanceFromPrevious != null) 
        'distance_from_previous': distanceFromPrevious.toString(),
      if (averageTimeFromPrevious != null) 
        'average_time_from_previous': averageTimeFromPrevious,
    };
  }
}

class RemoveStopFromLineRequest {
  final String stopId;

  const RemoveStopFromLineRequest({
    required this.stopId,
  });

  Map<String, dynamic> toJson() {
    return {
      'stop_id': stopId,
    };
  }
}

class UpdateStopOrderRequest {
  final String stopId;
  final int newOrder;

  const UpdateStopOrderRequest({
    required this.stopId,
    required this.newOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'stop_id': stopId,
      'new_order': newOrder,
    };
  }
}

class ScheduleCreateRequest {
  final String lineId;
  final DayOfWeek dayOfWeek;
  final String startTime;
  final String endTime;
  final int frequencyMinutes;
  final bool isActive;

  const ScheduleCreateRequest({
    required this.lineId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.frequencyMinutes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'line': lineId,
      'day_of_week': dayOfWeek.value,
      'start_time': startTime,
      'end_time': endTime,
      'frequency_minutes': frequencyMinutes,
      'is_active': isActive,
    };
  }
}