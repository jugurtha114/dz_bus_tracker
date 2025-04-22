// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusPhotoModelImpl _$$BusPhotoModelImplFromJson(Map<String, dynamic> json) =>
    _$BusPhotoModelImpl(
      id: json['id'] as String,
      bus: json['bus'] as String,
      photo: json['photo'] as String,
      type: $enumDecode(_$PhotoTypeEnumMap, json['type'],
          unknownValue: PhotoType.unknown),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$BusPhotoModelImplToJson(_$BusPhotoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bus': instance.bus,
      'photo': instance.photo,
      'type': _$PhotoTypeEnumMap[instance.type]!,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$PhotoTypeEnumMap = {
  PhotoType.exterior: 'exterior',
  PhotoType.interior: 'interior',
  PhotoType.document: 'document',
  PhotoType.other: 'other',
  PhotoType.unknown: 'unknown',
};
