// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverModelImpl _$$DriverModelImplFromJson(Map<String, dynamic> json) =>
    _$DriverModelImpl(
      id: json['id'] as String,
      user: json['user'] as String,
      idNumber: json['id_number'] as String,
      idPhoto: json['id_photo'] as String,
      licenseNumber: json['license_number'] as String,
      licensePhoto: json['license_photo'] as String,
      isVerified: json['is_verified'] as bool,
      verificationDate: json['verification_date'] == null
          ? null
          : DateTime.parse(json['verification_date'] as String),
      experienceYears: (json['experience_years'] as num?)?.toInt(),
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      address: json['address'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userDetails:
          UserModel.fromJson(json['user_details'] as Map<String, dynamic>),
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      averageRating: json['average_rating'] as String?,
    );

Map<String, dynamic> _$$DriverModelImplToJson(_$DriverModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'id_number': instance.idNumber,
      'id_photo': instance.idPhoto,
      'license_number': instance.licenseNumber,
      'license_photo': instance.licensePhoto,
      'is_verified': instance.isVerified,
      'verification_date': instance.verificationDate?.toIso8601String(),
      'experience_years': instance.experienceYears,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'address': instance.address,
      'emergency_contact': instance.emergencyContact,
      'notes': instance.notes,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user_details': instance.userDetails,
      'full_name': instance.fullName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'average_rating': instance.averageRating,
    };
