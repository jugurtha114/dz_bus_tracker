// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LineModelImpl _$$LineModelImplFromJson(Map<String, dynamic> json) =>
    _$LineModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      startLocation: json['start_location'] as String,
      endLocation: json['end_location'] as String,
      path: json['path'] as Map<String, dynamic>?,
      estimatedDuration: (json['estimated_duration'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      startLocationDetails: json['start_location_details'] == null
          ? null
          : StopModel.fromJson(
              json['start_location_details'] as Map<String, dynamic>),
      endLocationDetails: json['end_location_details'] == null
          ? null
          : StopModel.fromJson(
              json['end_location_details'] as Map<String, dynamic>),
      stopsCount: (json['stops_count'] as num).toInt(),
      activeBusesCount: (json['active_buses_count'] as num).toInt(),
    );

Map<String, dynamic> _$$LineModelImplToJson(_$LineModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'color': instance.color,
      'start_location': instance.startLocation,
      'end_location': instance.endLocation,
      'path': instance.path,
      'estimated_duration': instance.estimatedDuration,
      'distance': instance.distance,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'start_location_details': instance.startLocationDetails,
      'end_location_details': instance.endLocationDetails,
      'stops_count': instance.stopsCount,
      'active_buses_count': instance.activeBusesCount,
    };
