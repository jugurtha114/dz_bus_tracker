// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackingSessionModelImpl _$$TrackingSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrackingSessionModelImpl(
      id: json['id'] as String,
      driver: json['driver'] as String,
      bus: json['bus'] as String,
      line: json['line'] as String,
      schedule: json['schedule'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      status: $enumDecode(_$TrackingStatusEnumMap, json['status'],
          unknownValue: TrackingStatus.unknown),
      lastUpdate: json['last_update'] == null
          ? null
          : DateTime.parse(json['last_update'] as String),
      totalDistance: (json['total_distance'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      duration: json['duration'] as String?,
      driverDetails:
          DriverModel.fromJson(json['driver_details'] as Map<String, dynamic>),
      busDetails:
          BusModel.fromJson(json['bus_details'] as Map<String, dynamic>),
      lineDetails:
          LineModel.fromJson(json['line_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TrackingSessionModelImplToJson(
        _$TrackingSessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driver': instance.driver,
      'bus': instance.bus,
      'line': instance.line,
      'schedule': instance.schedule,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'status': _$TrackingStatusEnumMap[instance.status]!,
      'last_update': instance.lastUpdate?.toIso8601String(),
      'total_distance': instance.totalDistance,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'duration': instance.duration,
      'driver_details': instance.driverDetails,
      'bus_details': instance.busDetails,
      'line_details': instance.lineDetails,
    };

const _$TrackingStatusEnumMap = {
  TrackingStatus.active: 'active',
  TrackingStatus.paused: 'paused',
  TrackingStatus.completed: 'completed',
  TrackingStatus.error: 'error',
  TrackingStatus.unknown: 'unknown',
};
