// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverModel _$DriverModelFromJson(Map<String, dynamic> json) {
  return _DriverModel.fromJson(json);
}

/// @nodoc
mixin _$DriverModel {
  /// Unique identifier for the driver record (UUID). Matches API 'id'.
  String get id => throw _privateConstructorUsedError;

  /// ID of the associated base User record. Matches API 'user'. Required.
  String get user => throw _privateConstructorUsedError;

  /// Driver's national identification number. Matches API 'id_number'. Required.
  @JsonKey(name: 'id_number')
  String get idNumber => throw _privateConstructorUsedError;

  /// URL to the driver's ID photo. Matches API 'id_photo'. Required (minLength=1).
  @JsonKey(name: 'id_photo')
  String get idPhoto => throw _privateConstructorUsedError;

  /// Driver's license number. Matches API 'license_number'. Required.
  @JsonKey(name: 'license_number')
  String get licenseNumber => throw _privateConstructorUsedError;

  /// URL to the driver's license photo. Matches API 'license_photo'. Required (minLength=1).
  @JsonKey(name: 'license_photo')
  String get licensePhoto => throw _privateConstructorUsedError;

  /// Flag indicating if the driver's profile is verified. Matches API 'is_verified'. Read-only.
  @JsonKey(name: 'is_verified')
  bool get isVerified => throw _privateConstructorUsedError;

  /// Timestamp when the driver was last verified. Matches API 'verification_date'. Optional. Read-only.
  @JsonKey(name: 'verification_date')
  DateTime? get verificationDate => throw _privateConstructorUsedError;

  /// Driver's years of professional driving experience. Matches API 'experience_years'. Optional.
  @JsonKey(name: 'experience_years')
  int? get experienceYears => throw _privateConstructorUsedError;

  /// Driver's date of birth. Matches API 'date_of_birth'. Optional.
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;

  /// Driver's residential address. Matches API 'address'. Optional.
  String? get address => throw _privateConstructorUsedError;

  /// Contact information for emergencies. Matches API 'emergency_contact'. Optional.
  @JsonKey(name: 'emergency_contact')
  String? get emergencyContact => throw _privateConstructorUsedError;

  /// Administrative notes about the driver. Matches API 'notes'. Optional.
  String? get notes => throw _privateConstructorUsedError;

  /// Flag indicating if the driver account is active. Matches API 'is_active'.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the driver record was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the driver record was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested/Calculated Fields ---
  /// Details of the associated base User record. Matches API 'user_details'. Required.
  @JsonKey(name: 'user_details')
  UserModel get userDetails => throw _privateConstructorUsedError;

  /// Driver's full name (calculated). Matches API 'full_name'. Read-only.
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;

  /// Driver's email (derived from user). Matches API 'email'. Read-only.
  String? get email => throw _privateConstructorUsedError;

  /// Driver's phone number (derived from user). Matches API 'phone_number'. Optional. Read-only.
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// Driver's average rating as a string. Matches API 'average_rating'. Optional. Read-only.
  /// Needs parsing to double later if used for calculations.
  @JsonKey(name: 'average_rating')
  String? get averageRating => throw _privateConstructorUsedError;

  /// Serializes this DriverModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverModelCopyWith<DriverModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverModelCopyWith<$Res> {
  factory $DriverModelCopyWith(
          DriverModel value, $Res Function(DriverModel) then) =
      _$DriverModelCopyWithImpl<$Res, DriverModel>;
  @useResult
  $Res call(
      {String id,
      String user,
      @JsonKey(name: 'id_number') String idNumber,
      @JsonKey(name: 'id_photo') String idPhoto,
      @JsonKey(name: 'license_number') String licenseNumber,
      @JsonKey(name: 'license_photo') String licensePhoto,
      @JsonKey(name: 'is_verified') bool isVerified,
      @JsonKey(name: 'verification_date') DateTime? verificationDate,
      @JsonKey(name: 'experience_years') int? experienceYears,
      @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
      String? address,
      @JsonKey(name: 'emergency_contact') String? emergencyContact,
      String? notes,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'user_details') UserModel userDetails,
      @JsonKey(name: 'full_name') String? fullName,
      String? email,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'average_rating') String? averageRating});

  $UserModelCopyWith<$Res> get userDetails;
}

/// @nodoc
class _$DriverModelCopyWithImpl<$Res, $Val extends DriverModel>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? idNumber = null,
    Object? idPhoto = null,
    Object? licenseNumber = null,
    Object? licensePhoto = null,
    Object? isVerified = null,
    Object? verificationDate = freezed,
    Object? experienceYears = freezed,
    Object? dateOfBirth = freezed,
    Object? address = freezed,
    Object? emergencyContact = freezed,
    Object? notes = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userDetails = null,
    Object? fullName = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? averageRating = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      idNumber: null == idNumber
          ? _value.idNumber
          : idNumber // ignore: cast_nullable_to_non_nullable
              as String,
      idPhoto: null == idPhoto
          ? _value.idPhoto
          : idPhoto // ignore: cast_nullable_to_non_nullable
              as String,
      licenseNumber: null == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String,
      licensePhoto: null == licensePhoto
          ? _value.licensePhoto
          : licensePhoto // ignore: cast_nullable_to_non_nullable
              as String,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      verificationDate: freezed == verificationDate
          ? _value.verificationDate
          : verificationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      experienceYears: freezed == experienceYears
          ? _value.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContact: freezed == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userDetails: null == userDetails
          ? _value.userDetails
          : userDetails // ignore: cast_nullable_to_non_nullable
              as UserModel,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      averageRating: freezed == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get userDetails {
    return $UserModelCopyWith<$Res>(_value.userDetails, (value) {
      return _then(_value.copyWith(userDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DriverModelImplCopyWith<$Res>
    implements $DriverModelCopyWith<$Res> {
  factory _$$DriverModelImplCopyWith(
          _$DriverModelImpl value, $Res Function(_$DriverModelImpl) then) =
      __$$DriverModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String user,
      @JsonKey(name: 'id_number') String idNumber,
      @JsonKey(name: 'id_photo') String idPhoto,
      @JsonKey(name: 'license_number') String licenseNumber,
      @JsonKey(name: 'license_photo') String licensePhoto,
      @JsonKey(name: 'is_verified') bool isVerified,
      @JsonKey(name: 'verification_date') DateTime? verificationDate,
      @JsonKey(name: 'experience_years') int? experienceYears,
      @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
      String? address,
      @JsonKey(name: 'emergency_contact') String? emergencyContact,
      String? notes,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'user_details') UserModel userDetails,
      @JsonKey(name: 'full_name') String? fullName,
      String? email,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'average_rating') String? averageRating});

  @override
  $UserModelCopyWith<$Res> get userDetails;
}

/// @nodoc
class __$$DriverModelImplCopyWithImpl<$Res>
    extends _$DriverModelCopyWithImpl<$Res, _$DriverModelImpl>
    implements _$$DriverModelImplCopyWith<$Res> {
  __$$DriverModelImplCopyWithImpl(
      _$DriverModelImpl _value, $Res Function(_$DriverModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? idNumber = null,
    Object? idPhoto = null,
    Object? licenseNumber = null,
    Object? licensePhoto = null,
    Object? isVerified = null,
    Object? verificationDate = freezed,
    Object? experienceYears = freezed,
    Object? dateOfBirth = freezed,
    Object? address = freezed,
    Object? emergencyContact = freezed,
    Object? notes = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userDetails = null,
    Object? fullName = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? averageRating = freezed,
  }) {
    return _then(_$DriverModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      idNumber: null == idNumber
          ? _value.idNumber
          : idNumber // ignore: cast_nullable_to_non_nullable
              as String,
      idPhoto: null == idPhoto
          ? _value.idPhoto
          : idPhoto // ignore: cast_nullable_to_non_nullable
              as String,
      licenseNumber: null == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String,
      licensePhoto: null == licensePhoto
          ? _value.licensePhoto
          : licensePhoto // ignore: cast_nullable_to_non_nullable
              as String,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      verificationDate: freezed == verificationDate
          ? _value.verificationDate
          : verificationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      experienceYears: freezed == experienceYears
          ? _value.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContact: freezed == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userDetails: null == userDetails
          ? _value.userDetails
          : userDetails // ignore: cast_nullable_to_non_nullable
              as UserModel,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      averageRating: freezed == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverModelImpl implements _DriverModel {
  const _$DriverModelImpl(
      {required this.id,
      required this.user,
      @JsonKey(name: 'id_number') required this.idNumber,
      @JsonKey(name: 'id_photo') required this.idPhoto,
      @JsonKey(name: 'license_number') required this.licenseNumber,
      @JsonKey(name: 'license_photo') required this.licensePhoto,
      @JsonKey(name: 'is_verified') required this.isVerified,
      @JsonKey(name: 'verification_date') this.verificationDate,
      @JsonKey(name: 'experience_years') this.experienceYears,
      @JsonKey(name: 'date_of_birth') this.dateOfBirth,
      this.address,
      @JsonKey(name: 'emergency_contact') this.emergencyContact,
      this.notes,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'user_details') required this.userDetails,
      @JsonKey(name: 'full_name') this.fullName,
      this.email,
      @JsonKey(name: 'phone_number') this.phoneNumber,
      @JsonKey(name: 'average_rating') this.averageRating});

  factory _$DriverModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverModelImplFromJson(json);

  /// Unique identifier for the driver record (UUID). Matches API 'id'.
  @override
  final String id;

  /// ID of the associated base User record. Matches API 'user'. Required.
  @override
  final String user;

  /// Driver's national identification number. Matches API 'id_number'. Required.
  @override
  @JsonKey(name: 'id_number')
  final String idNumber;

  /// URL to the driver's ID photo. Matches API 'id_photo'. Required (minLength=1).
  @override
  @JsonKey(name: 'id_photo')
  final String idPhoto;

  /// Driver's license number. Matches API 'license_number'. Required.
  @override
  @JsonKey(name: 'license_number')
  final String licenseNumber;

  /// URL to the driver's license photo. Matches API 'license_photo'. Required (minLength=1).
  @override
  @JsonKey(name: 'license_photo')
  final String licensePhoto;

  /// Flag indicating if the driver's profile is verified. Matches API 'is_verified'. Read-only.
  @override
  @JsonKey(name: 'is_verified')
  final bool isVerified;

  /// Timestamp when the driver was last verified. Matches API 'verification_date'. Optional. Read-only.
  @override
  @JsonKey(name: 'verification_date')
  final DateTime? verificationDate;

  /// Driver's years of professional driving experience. Matches API 'experience_years'. Optional.
  @override
  @JsonKey(name: 'experience_years')
  final int? experienceYears;

  /// Driver's date of birth. Matches API 'date_of_birth'. Optional.
  @override
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;

  /// Driver's residential address. Matches API 'address'. Optional.
  @override
  final String? address;

  /// Contact information for emergencies. Matches API 'emergency_contact'. Optional.
  @override
  @JsonKey(name: 'emergency_contact')
  final String? emergencyContact;

  /// Administrative notes about the driver. Matches API 'notes'. Optional.
  @override
  final String? notes;

  /// Flag indicating if the driver account is active. Matches API 'is_active'.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Timestamp when the driver record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the driver record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested/Calculated Fields ---
  /// Details of the associated base User record. Matches API 'user_details'. Required.
  @override
  @JsonKey(name: 'user_details')
  final UserModel userDetails;

  /// Driver's full name (calculated). Matches API 'full_name'. Read-only.
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;

  /// Driver's email (derived from user). Matches API 'email'. Read-only.
  @override
  final String? email;

  /// Driver's phone number (derived from user). Matches API 'phone_number'. Optional. Read-only.
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  /// Driver's average rating as a string. Matches API 'average_rating'. Optional. Read-only.
  /// Needs parsing to double later if used for calculations.
  @override
  @JsonKey(name: 'average_rating')
  final String? averageRating;

  @override
  String toString() {
    return 'DriverModel(id: $id, user: $user, idNumber: $idNumber, idPhoto: $idPhoto, licenseNumber: $licenseNumber, licensePhoto: $licensePhoto, isVerified: $isVerified, verificationDate: $verificationDate, experienceYears: $experienceYears, dateOfBirth: $dateOfBirth, address: $address, emergencyContact: $emergencyContact, notes: $notes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, userDetails: $userDetails, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, averageRating: $averageRating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.idNumber, idNumber) ||
                other.idNumber == idNumber) &&
            (identical(other.idPhoto, idPhoto) || other.idPhoto == idPhoto) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.licensePhoto, licensePhoto) ||
                other.licensePhoto == licensePhoto) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.verificationDate, verificationDate) ||
                other.verificationDate == verificationDate) &&
            (identical(other.experienceYears, experienceYears) ||
                other.experienceYears == experienceYears) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.emergencyContact, emergencyContact) ||
                other.emergencyContact == emergencyContact) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userDetails, userDetails) ||
                other.userDetails == userDetails) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        user,
        idNumber,
        idPhoto,
        licenseNumber,
        licensePhoto,
        isVerified,
        verificationDate,
        experienceYears,
        dateOfBirth,
        address,
        emergencyContact,
        notes,
        isActive,
        createdAt,
        updatedAt,
        userDetails,
        fullName,
        email,
        phoneNumber,
        averageRating
      ]);

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverModelImplCopyWith<_$DriverModelImpl> get copyWith =>
      __$$DriverModelImplCopyWithImpl<_$DriverModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverModelImplToJson(
      this,
    );
  }
}

abstract class _DriverModel implements DriverModel {
  const factory _DriverModel(
          {required final String id,
          required final String user,
          @JsonKey(name: 'id_number') required final String idNumber,
          @JsonKey(name: 'id_photo') required final String idPhoto,
          @JsonKey(name: 'license_number') required final String licenseNumber,
          @JsonKey(name: 'license_photo') required final String licensePhoto,
          @JsonKey(name: 'is_verified') required final bool isVerified,
          @JsonKey(name: 'verification_date') final DateTime? verificationDate,
          @JsonKey(name: 'experience_years') final int? experienceYears,
          @JsonKey(name: 'date_of_birth') final DateTime? dateOfBirth,
          final String? address,
          @JsonKey(name: 'emergency_contact') final String? emergencyContact,
          final String? notes,
          @JsonKey(name: 'is_active') required final bool isActive,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt,
          @JsonKey(name: 'user_details') required final UserModel userDetails,
          @JsonKey(name: 'full_name') final String? fullName,
          final String? email,
          @JsonKey(name: 'phone_number') final String? phoneNumber,
          @JsonKey(name: 'average_rating') final String? averageRating}) =
      _$DriverModelImpl;

  factory _DriverModel.fromJson(Map<String, dynamic> json) =
      _$DriverModelImpl.fromJson;

  /// Unique identifier for the driver record (UUID). Matches API 'id'.
  @override
  String get id;

  /// ID of the associated base User record. Matches API 'user'. Required.
  @override
  String get user;

  /// Driver's national identification number. Matches API 'id_number'. Required.
  @override
  @JsonKey(name: 'id_number')
  String get idNumber;

  /// URL to the driver's ID photo. Matches API 'id_photo'. Required (minLength=1).
  @override
  @JsonKey(name: 'id_photo')
  String get idPhoto;

  /// Driver's license number. Matches API 'license_number'. Required.
  @override
  @JsonKey(name: 'license_number')
  String get licenseNumber;

  /// URL to the driver's license photo. Matches API 'license_photo'. Required (minLength=1).
  @override
  @JsonKey(name: 'license_photo')
  String get licensePhoto;

  /// Flag indicating if the driver's profile is verified. Matches API 'is_verified'. Read-only.
  @override
  @JsonKey(name: 'is_verified')
  bool get isVerified;

  /// Timestamp when the driver was last verified. Matches API 'verification_date'. Optional. Read-only.
  @override
  @JsonKey(name: 'verification_date')
  DateTime? get verificationDate;

  /// Driver's years of professional driving experience. Matches API 'experience_years'. Optional.
  @override
  @JsonKey(name: 'experience_years')
  int? get experienceYears;

  /// Driver's date of birth. Matches API 'date_of_birth'. Optional.
  @override
  @JsonKey(name: 'date_of_birth')
  DateTime? get dateOfBirth;

  /// Driver's residential address. Matches API 'address'. Optional.
  @override
  String? get address;

  /// Contact information for emergencies. Matches API 'emergency_contact'. Optional.
  @override
  @JsonKey(name: 'emergency_contact')
  String? get emergencyContact;

  /// Administrative notes about the driver. Matches API 'notes'. Optional.
  @override
  String? get notes;

  /// Flag indicating if the driver account is active. Matches API 'is_active'.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Timestamp when the driver record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the driver record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Nested/Calculated Fields ---
  /// Details of the associated base User record. Matches API 'user_details'. Required.
  @override
  @JsonKey(name: 'user_details')
  UserModel get userDetails;

  /// Driver's full name (calculated). Matches API 'full_name'. Read-only.
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;

  /// Driver's email (derived from user). Matches API 'email'. Read-only.
  @override
  String? get email;

  /// Driver's phone number (derived from user). Matches API 'phone_number'. Optional. Read-only.
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;

  /// Driver's average rating as a string. Matches API 'average_rating'. Optional. Read-only.
  /// Needs parsing to double later if used for calculations.
  @override
  @JsonKey(name: 'average_rating')
  String? get averageRating;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverModelImplCopyWith<_$DriverModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
