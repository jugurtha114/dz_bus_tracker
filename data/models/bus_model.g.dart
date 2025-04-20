// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusModelImpl _$$BusModelImplFromJson(Map<String, dynamic> json) =>
    _$BusModelImpl(
      id: json['id'] as String,
      driver: json['driver'] as String,
      matricule: json['matricule'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: (json['year'] as num?)?.toInt(),
      capacity: (json['capacity'] as num?)?.toInt(),
      description: json['description'] as String?,
      isVerified: json['is_verified'] as bool,
      verificationDate: json['verification_date'] == null
          ? null
          : DateTime.parse(json['verification_date'] as String),
      lastMaintenance: json['last_maintenance'] == null
          ? null
          : DateTime.parse(json['last_maintenance'] as String),
      nextMaintenance: json['next_maintenance'] == null
          ? null
          : DateTime.parse(json['next_maintenance'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      photos: (json['photos'] as List<dynamic>)
          .map((e) => BusPhotoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      driverDetails:
          DriverModel.fromJson(json['driver_details'] as Map<String, dynamic>),
      isTracking: json['is_tracking'] as bool,
    );

Map<String, dynamic> _$$BusModelImplToJson(_$BusModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driver': instance.driver,
      'matricule': instance.matricule,
      'brand': instance.brand,
      'model': instance.model,
      'year': instance.year,
      'capacity': instance.capacity,
      'description': instance.description,
      'is_verified': instance.isVerified,
      'verification_date': instance.verificationDate?.toIso8601String(),
      'last_maintenance': instance.lastMaintenance?.toIso8601String(),
      'next_maintenance': instance.nextMaintenance?.toIso8601String(),
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'photos': instance.photos,
      'driver_details': instance.driverDetails,
      'is_tracking': instance.isTracking,
    };
