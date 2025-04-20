// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_verification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusVerificationModelImpl _$$BusVerificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BusVerificationModelImpl(
      id: json['id'] as String,
      bus: json['bus'] as String,
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

Map<String, dynamic> _$$BusVerificationModelImplToJson(
        _$BusVerificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bus': instance.bus,
      'verified_by': instance.verifiedBy,
      'is_verified': instance.isVerified,
      'comments': instance.comments,
      'verification_date': instance.verificationDate.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'verified_by_details': instance.verifiedByDetails,
    };
