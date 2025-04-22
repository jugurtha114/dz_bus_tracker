// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_stop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LineStopModelImpl _$$LineStopModelImplFromJson(Map<String, dynamic> json) =>
    _$LineStopModelImpl(
      id: json['id'] as String,
      line: json['line'] as String,
      stop: json['stop'] as String,
      order: (json['order'] as num).toInt(),
      distanceFromStart: (json['distance_from_start'] as num?)?.toDouble(),
      estimatedTimeFromStart:
          (json['estimated_time_from_start'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      stopDetails: json['stop_details'] == null
          ? null
          : StopModel.fromJson(json['stop_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LineStopModelImplToJson(_$LineStopModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'line': instance.line,
      'stop': instance.stop,
      'order': instance.order,
      'distance_from_start': instance.distanceFromStart,
      'estimated_time_from_start': instance.estimatedTimeFromStart,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'stop_details': instance.stopDetails,
    };
