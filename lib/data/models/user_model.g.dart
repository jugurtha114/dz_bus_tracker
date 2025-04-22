// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      userType: $enumDecode(_$UserTypeEnumMap, json['user_type'],
          unknownValue: UserType.unknown),
      language: $enumDecode(_$LanguageEnumMap, json['language'],
          unknownValue: Language.fr),
      isActive: json['is_active'] as bool,
      isEmailVerified: json['is_email_verified'] as bool,
      isPhoneVerified: json['is_phone_verified'] as bool,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'user_type': _$UserTypeEnumMap[instance.userType]!,
      'language': _$LanguageEnumMap[instance.language]!,
      'is_active': instance.isActive,
      'is_email_verified': instance.isEmailVerified,
      'is_phone_verified': instance.isPhoneVerified,
      'date_joined': instance.dateJoined.toIso8601String(),
      'last_login': instance.lastLogin?.toIso8601String(),
    };

const _$UserTypeEnumMap = {
  UserType.admin: 'admin',
  UserType.driver: 'driver',
  UserType.passenger: 'passenger',
  UserType.unknown: 'unknown',
};

const _$LanguageEnumMap = {
  Language.fr: 'fr',
  Language.ar: 'ar',
  Language.en: 'en',
};
