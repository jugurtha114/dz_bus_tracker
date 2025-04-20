// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  /// Unique identifier (UUID). Maps to `id`.
  String get id => throw _privateConstructorUsedError;

  /// E‑mail address. Maps to `email`.
  String get email => throw _privateConstructorUsedError;

  /// First name → `first_name` (nullable).
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;

  /// Last name → `last_name` (nullable).
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;

  /// Phone number → `phone_number` (nullable).
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// User role → `user_type`. Unknown values fall back to `.unknown`.
  @JsonKey(name: 'user_type', unknownEnumValue: UserType.unknown)
  UserType get userType => throw _privateConstructorUsedError;

  /// Preferred UI language. Unknown values default to French.
  @JsonKey(unknownEnumValue: Language.fr)
  Language get language => throw _privateConstructorUsedError;

  /// Account is active → `is_active`.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// E‑mail verified flag → `is_email_verified`.
  @JsonKey(name: 'is_email_verified')
  bool get isEmailVerified => throw _privateConstructorUsedError;

  /// Phone verified flag → `is_phone_verified`.
  @JsonKey(name: 'is_phone_verified')
  bool get isPhoneVerified => throw _privateConstructorUsedError;

  /// Creation timestamp → `date_joined` (read‑only).
  @JsonKey(name: 'date_joined')
  DateTime get dateJoined => throw _privateConstructorUsedError;

  /// Last login timestamp → `last_login` (nullable, read‑only).
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String id,
      String email,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'last_name') String? lastName,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'user_type', unknownEnumValue: UserType.unknown)
      UserType userType,
      @JsonKey(unknownEnumValue: Language.fr) Language language,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'is_email_verified') bool isEmailVerified,
      @JsonKey(name: 'is_phone_verified') bool isPhoneVerified,
      @JsonKey(name: 'date_joined') DateTime dateJoined,
      @JsonKey(name: 'last_login') DateTime? lastLogin});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? userType = null,
    Object? language = null,
    Object? isActive = null,
    Object? isEmailVerified = null,
    Object? isPhoneVerified = null,
    Object? dateJoined = null,
    Object? lastLogin = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      userType: null == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as UserType,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as Language,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPhoneVerified: null == isPhoneVerified
          ? _value.isPhoneVerified
          : isPhoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      dateJoined: null == dateJoined
          ? _value.dateJoined
          : dateJoined // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'last_name') String? lastName,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'user_type', unknownEnumValue: UserType.unknown)
      UserType userType,
      @JsonKey(unknownEnumValue: Language.fr) Language language,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'is_email_verified') bool isEmailVerified,
      @JsonKey(name: 'is_phone_verified') bool isPhoneVerified,
      @JsonKey(name: 'date_joined') DateTime dateJoined,
      @JsonKey(name: 'last_login') DateTime? lastLogin});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? userType = null,
    Object? language = null,
    Object? isActive = null,
    Object? isEmailVerified = null,
    Object? isPhoneVerified = null,
    Object? dateJoined = null,
    Object? lastLogin = freezed,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      userType: null == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as UserType,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as Language,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPhoneVerified: null == isPhoneVerified
          ? _value.isPhoneVerified
          : isPhoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      dateJoined: null == dateJoined
          ? _value.dateJoined
          : dateJoined // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl(
      {required this.id,
      required this.email,
      @JsonKey(name: 'first_name') this.firstName,
      @JsonKey(name: 'last_name') this.lastName,
      @JsonKey(name: 'phone_number') this.phoneNumber,
      @JsonKey(name: 'user_type', unknownEnumValue: UserType.unknown)
      required this.userType,
      @JsonKey(unknownEnumValue: Language.fr) required this.language,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'is_email_verified') required this.isEmailVerified,
      @JsonKey(name: 'is_phone_verified') required this.isPhoneVerified,
      @JsonKey(name: 'date_joined') required this.dateJoined,
      @JsonKey(name: 'last_login') this.lastLogin})
      : super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  /// Unique identifier (UUID). Maps to `id`.
  @override
  final String id;

  /// E‑mail address. Maps to `email`.
  @override
  final String email;

  /// First name → `first_name` (nullable).
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;

  /// Last name → `last_name` (nullable).
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;

  /// Phone number → `phone_number` (nullable).
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  /// User role → `user_type`. Unknown values fall back to `.unknown`.
  @override
  @JsonKey(name: 'user_type', unknownEnumValue: UserType.unknown)
  final UserType userType;

  /// Preferred UI language. Unknown values default to French.
  @override
  @JsonKey(unknownEnumValue: Language.fr)
  final Language language;

  /// Account is active → `is_active`.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// E‑mail verified flag → `is_email_verified`.
  @override
  @JsonKey(name: 'is_email_verified')
  final bool isEmailVerified;

  /// Phone verified flag → `is_phone_verified`.
  @override
  @JsonKey(name: 'is_phone_verified')
  final bool isPhoneVerified;

  /// Creation timestamp → `date_joined` (read‑only).
  @override
  @JsonKey(name: 'date_joined')
  final DateTime dateJoined;

  /// Last login timestamp → `last_login` (nullable, read‑only).
  @override
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, userType: $userType, language: $language, isActive: $isActive, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, dateJoined: $dateJoined, lastLogin: $lastLogin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.isPhoneVerified, isPhoneVerified) ||
                other.isPhoneVerified == isPhoneVerified) &&
            (identical(other.dateJoined, dateJoined) ||
                other.dateJoined == dateJoined) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      firstName,
      lastName,
      phoneNumber,
      userType,
      language,
      isActive,
      isEmailVerified,
      isPhoneVerified,
      dateJoined,
      lastLogin);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
      {required final String id,
      required final String email,
      @JsonKey(name: 'first_name') final String? firstName,
      @JsonKey(name: 'last_name') final String? lastName,
      @JsonKey(name: 'phone_number') final String? phoneNumber,
      @JsonKey(name: 'user_type', unknownEnumValue: UserType.unknown)
      required final UserType userType,
      @JsonKey(unknownEnumValue: Language.fr) required final Language language,
      @JsonKey(name: 'is_active') required final bool isActive,
      @JsonKey(name: 'is_email_verified') required final bool isEmailVerified,
      @JsonKey(name: 'is_phone_verified') required final bool isPhoneVerified,
      @JsonKey(name: 'date_joined') required final DateTime dateJoined,
      @JsonKey(name: 'last_login')
      final DateTime? lastLogin}) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  /// Unique identifier (UUID). Maps to `id`.
  @override
  String get id;

  /// E‑mail address. Maps to `email`.
  @override
  String get email;

  /// First name → `first_name` (nullable).
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;

  /// Last name → `last_name` (nullable).
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;

  /// Phone number → `phone_number` (nullable).
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;

  /// User role → `user_type`. Unknown values fall back to `.unknown`.
  @override
  @JsonKey(name: 'user_type', unknownEnumValue: UserType.unknown)
  UserType get userType;

  /// Preferred UI language. Unknown values default to French.
  @override
  @JsonKey(unknownEnumValue: Language.fr)
  Language get language;

  /// Account is active → `is_active`.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// E‑mail verified flag → `is_email_verified`.
  @override
  @JsonKey(name: 'is_email_verified')
  bool get isEmailVerified;

  /// Phone verified flag → `is_phone_verified`.
  @override
  @JsonKey(name: 'is_phone_verified')
  bool get isPhoneVerified;

  /// Creation timestamp → `date_joined` (read‑only).
  @override
  @JsonKey(name: 'date_joined')
  DateTime get dateJoined;

  /// Last login timestamp → `last_login` (nullable, read‑only).
  @override
  @JsonKey(name: 'last_login')
  DateTime? get lastLogin;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
