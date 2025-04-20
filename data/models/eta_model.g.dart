// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eta_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EtaModelImpl _$$EtaModelImplFromJson(Map<String, dynamic> json) =>
    _$EtaModelImpl(
      id: json['id'] as String,
      line: json['line'] as String,
      bus: json['bus'] as String,
      stop: json['stop'] as String,
      trackingSession: json['tracking_session'] as String,
      estimatedArrivalTime:
          DateTime.parse(json['estimated_arrival_time'] as String),
      actualArrivalTime: json['actual_arrival_time'] == null
          ? null
          : DateTime.parse(json['actual_arrival_time'] as String),
      status: $enumDecode(_$EtaStatusEnumMap, json['status'],
          unknownValue: EtaStatus.unknown),
      delayMinutes: (json['delay_minutes'] as num?)?.toInt(),
      accuracy: (json['accuracy'] as num?)?.toInt(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lineName: json['line_name'] as String?,
      busMatricule: json['bus_matricule'] as String?,
      stopName: json['stop_name'] as String?,
      minutesRemaining: (json['minutes_remaining'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$EtaModelImplToJson(_$EtaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'line': instance.line,
      'bus': instance.bus,
      'stop': instance.stop,
      'tracking_session': instance.trackingSession,
      'estimated_arrival_time': instance.estimatedArrivalTime.toIso8601String(),
      'actual_arrival_time': instance.actualArrivalTime?.toIso8601String(),
      'status': _$EtaStatusEnumMap[instance.status]!,
      'delay_minutes': instance.delayMinutes,
      'accuracy': instance.accuracy,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'line_name': instance.lineName,
      'bus_matricule': instance.busMatricule,
      'stop_name': instance.stopName,
      'minutes_remaining': instance.minutesRemaining,
    };

const _$EtaStatusEnumMap = {
  EtaStatus.scheduled: 'scheduled',
  EtaStatus.approaching: 'approaching',
  EtaStatus.arrived: 'arrived',
  EtaStatus.delayed: 'delayed',
  EtaStatus.cancelled: 'cancelled',
  EtaStatus.unknown: 'unknown',
};
