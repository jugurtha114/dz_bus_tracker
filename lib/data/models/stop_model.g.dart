// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StopModelImpl _$$StopModelImplFromJson(Map<String, dynamic> json) =>
    _$StopModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      address: json['address'] as String?,
      image: json['image'] as String?,
      description: json['description'] as String?,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$StopModelImplToJson(_$StopModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'address': instance.address,
      'image': instance.image,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
