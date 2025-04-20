// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverRatingModelImpl _$$DriverRatingModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverRatingModelImpl(
      id: json['id'] as String,
      driver: json['driver'] as String,
      user: json['user'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userDetails: json['user_details'] == null
          ? null
          : UserModel.fromJson(json['user_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DriverRatingModelImplToJson(
        _$DriverRatingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driver': instance.driver,
      'user': instance.user,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user_details': instance.userDetails,
    };
