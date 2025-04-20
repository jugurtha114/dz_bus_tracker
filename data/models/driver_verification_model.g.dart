// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_verification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverVerificationModelImpl _$$DriverVerificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverVerificationModelImpl(
      id: json['id'] as String,
      driver: json['driver'] as String,
      verifiedBy: json['verified_by'] as String?,
      isVerified: json['is_verified'] as bool,
      comments: json['comments'] as String?,
      verificationDate: DateTime.parse(json['verification_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      verifiedByDetails: json['verified_by_details'] == null
          ? null
          : UserModel.fromJson(
              json['verified_by_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DriverVerificationModelImplToJson(
        _$DriverVerificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driver': instance.driver,
      'verified_by': instance.verifiedBy,
      'is_verified': instance.isVerified,
      'comments': instance.comments,
      'verification_date': instance.verificationDate.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'verified_by_details': instance.verifiedByDetails,
    };
