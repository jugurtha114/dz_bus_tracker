// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationUpdateModelImpl _$$LocationUpdateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LocationUpdateModelImpl(
      id: json['id'] as String,
      session: json['session'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      distanceFromLast: (json['distance_from_last'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$LocationUpdateModelImplToJson(
        _$LocationUpdateModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session': instance.session,
      'timestamp': instance.timestamp.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'speed': instance.speed,
      'heading': instance.heading,
      'altitude': instance.altitude,
      'distance_from_last': instance.distanceFromLast,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
