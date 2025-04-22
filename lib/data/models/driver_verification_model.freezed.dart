// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_verification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverVerificationModel _$DriverVerificationModelFromJson(
    Map<String, dynamic> json) {
  return _DriverVerificationModel.fromJson(json);
}

/// @nodoc
mixin _$DriverVerificationModel {
  /// Unique identifier for the verification record (UUID). Matches API 'id'. Read-only.
  String get id => throw _privateConstructorUsedError;

  /// ID of the driver this verification applies to. Matches API 'driver'. Required.
  String get driver => throw _privateConstructorUsedError; // UUID
  /// ID of the admin user who performed the verification. Matches API 'verified_by'. Nullable.
  @JsonKey(name: 'verified_by')
  String? get verifiedBy => throw _privateConstructorUsedError; // UUID
  /// The verification status result (true = verified, false = rejected). Matches API 'is_verified'. Required.
  @JsonKey(name: 'is_verified')
  bool get isVerified => throw _privateConstructorUsedError;

  /// Optional comments from the verifier. Matches API 'comments'. Nullable.
  String? get comments => throw _privateConstructorUsedError;

  /// Timestamp when the verification action was taken. Matches API 'verification_date'. Required.
  @JsonKey(name: 'verification_date')
  DateTime get verificationDate => throw _privateConstructorUsedError;

  /// Timestamp when the record was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the record was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested Field ---
  /// Details of the user who performed the verification. Matches API 'verified_by_details'. Nullable. Read-only.
  @JsonKey(name: 'verified_by_details')
  UserModel? get verifiedByDetails => throw _privateConstructorUsedError;

  /// Serializes this DriverVerificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverVerificationModelCopyWith<DriverVerificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverVerificationModelCopyWith<$Res> {
  factory $DriverVerificationModelCopyWith(DriverVerificationModel value,
          $Res Function(DriverVerificationModel) then) =
      _$DriverVerificationModelCopyWithImpl<$Res, DriverVerificationModel>;
  @useResult
  $Res call(
      {String id,
      String driver,
      @JsonKey(name: 'verified_by') String? verifiedBy,
      @JsonKey(name: 'is_verified') bool isVerified,
      String? comments,
      @JsonKey(name: 'verification_date') DateTime verificationDate,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'verified_by_details') UserModel? verifiedByDetails});

  $UserModelCopyWith<$Res>? get verifiedByDetails;
}

/// @nodoc
class _$DriverVerificationModelCopyWithImpl<$Res,
        $Val extends DriverVerificationModel>
    implements $DriverVerificationModelCopyWith<$Res> {
  _$DriverVerificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driver = null,
    Object? verifiedBy = freezed,
    Object? isVerified = null,
    Object? comments = freezed,
    Object? verificationDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? verifiedByDetails = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driver: null == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedBy: freezed == verifiedBy
          ? _value.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      comments: freezed == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String?,
      verificationDate: null == verificationDate
          ? _value.verificationDate
          : verificationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      verifiedByDetails: freezed == verifiedByDetails
          ? _value.verifiedByDetails
          : verifiedByDetails // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ) as $Val);
  }

  /// Create a copy of DriverVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get verifiedByDetails {
    if (_value.verifiedByDetails == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.verifiedByDetails!, (value) {
      return _then(_value.copyWith(verifiedByDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DriverVerificationModelImplCopyWith<$Res>
    implements $DriverVerificationModelCopyWith<$Res> {
  factory _$$DriverVerificationModelImplCopyWith(
          _$DriverVerificationModelImpl value,
          $Res Function(_$DriverVerificationModelImpl) then) =
      __$$DriverVerificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driver,
      @JsonKey(name: 'verified_by') String? verifiedBy,
      @JsonKey(name: 'is_verified') bool isVerified,
      String? comments,
      @JsonKey(name: 'verification_date') DateTime verificationDate,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'verified_by_details') UserModel? verifiedByDetails});

  @override
  $UserModelCopyWith<$Res>? get verifiedByDetails;
}

/// @nodoc
class __$$DriverVerificationModelImplCopyWithImpl<$Res>
    extends _$DriverVerificationModelCopyWithImpl<$Res,
        _$DriverVerificationModelImpl>
    implements _$$DriverVerificationModelImplCopyWith<$Res> {
  __$$DriverVerificationModelImplCopyWithImpl(
      _$DriverVerificationModelImpl _value,
      $Res Function(_$DriverVerificationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driver = null,
    Object? verifiedBy = freezed,
    Object? isVerified = null,
    Object? comments = freezed,
    Object? verificationDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? verifiedByDetails = freezed,
  }) {
    return _then(_$DriverVerificationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driver: null == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedBy: freezed == verifiedBy
          ? _value.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      comments: freezed == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String?,
      verificationDate: null == verificationDate
          ? _value.verificationDate
          : verificationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      verifiedByDetails: freezed == verifiedByDetails
          ? _value.verifiedByDetails
          : verifiedByDetails // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverVerificationModelImpl implements _DriverVerificationModel {
  const _$DriverVerificationModelImpl(
      {required this.id,
      required this.driver,
      @JsonKey(name: 'verified_by') this.verifiedBy,
      @JsonKey(name: 'is_verified') required this.isVerified,
      this.comments,
      @JsonKey(name: 'verification_date') required this.verificationDate,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'verified_by_details') this.verifiedByDetails});

  factory _$DriverVerificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverVerificationModelImplFromJson(json);

  /// Unique identifier for the verification record (UUID). Matches API 'id'. Read-only.
  @override
  final String id;

  /// ID of the driver this verification applies to. Matches API 'driver'. Required.
  @override
  final String driver;
// UUID
  /// ID of the admin user who performed the verification. Matches API 'verified_by'. Nullable.
  @override
  @JsonKey(name: 'verified_by')
  final String? verifiedBy;
// UUID
  /// The verification status result (true = verified, false = rejected). Matches API 'is_verified'. Required.
  @override
  @JsonKey(name: 'is_verified')
  final bool isVerified;

  /// Optional comments from the verifier. Matches API 'comments'. Nullable.
  @override
  final String? comments;

  /// Timestamp when the verification action was taken. Matches API 'verification_date'. Required.
  @override
  @JsonKey(name: 'verification_date')
  final DateTime verificationDate;

  /// Timestamp when the record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested Field ---
  /// Details of the user who performed the verification. Matches API 'verified_by_details'. Nullable. Read-only.
  @override
  @JsonKey(name: 'verified_by_details')
  final UserModel? verifiedByDetails;

  @override
  String toString() {
    return 'DriverVerificationModel(id: $id, driver: $driver, verifiedBy: $verifiedBy, isVerified: $isVerified, comments: $comments, verificationDate: $verificationDate, createdAt: $createdAt, updatedAt: $updatedAt, verifiedByDetails: $verifiedByDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverVerificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.verificationDate, verificationDate) ||
                other.verificationDate == verificationDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.verifiedByDetails, verifiedByDetails) ||
                other.verifiedByDetails == verifiedByDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      driver,
      verifiedBy,
      isVerified,
      comments,
      verificationDate,
      createdAt,
      updatedAt,
      verifiedByDetails);

  /// Create a copy of DriverVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverVerificationModelImplCopyWith<_$DriverVerificationModelImpl>
      get copyWith => __$$DriverVerificationModelImplCopyWithImpl<
          _$DriverVerificationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverVerificationModelImplToJson(
      this,
    );
  }
}

abstract class _DriverVerificationModel implements DriverVerificationModel {
  const factory _DriverVerificationModel(
      {required final String id,
      required final String driver,
      @JsonKey(name: 'verified_by') final String? verifiedBy,
      @JsonKey(name: 'is_verified') required final bool isVerified,
      final String? comments,
      @JsonKey(name: 'verification_date')
      required final DateTime verificationDate,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'verified_by_details')
      final UserModel? verifiedByDetails}) = _$DriverVerificationModelImpl;

  factory _DriverVerificationModel.fromJson(Map<String, dynamic> json) =
      _$DriverVerificationModelImpl.fromJson;

  /// Unique identifier for the verification record (UUID). Matches API 'id'. Read-only.
  @override
  String get id;

  /// ID of the driver this verification applies to. Matches API 'driver'. Required.
  @override
  String get driver; // UUID
  /// ID of the admin user who performed the verification. Matches API 'verified_by'. Nullable.
  @override
  @JsonKey(name: 'verified_by')
  String? get verifiedBy; // UUID
  /// The verification status result (true = verified, false = rejected). Matches API 'is_verified'. Required.
  @override
  @JsonKey(name: 'is_verified')
  bool get isVerified;

  /// Optional comments from the verifier. Matches API 'comments'. Nullable.
  @override
  String? get comments;

  /// Timestamp when the verification action was taken. Matches API 'verification_date'. Required.
  @override
  @JsonKey(name: 'verification_date')
  DateTime get verificationDate;

  /// Timestamp when the record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Nested Field ---
  /// Details of the user who performed the verification. Matches API 'verified_by_details'. Nullable. Read-only.
  @override
  @JsonKey(name: 'verified_by_details')
  UserModel? get verifiedByDetails;

  /// Create a copy of DriverVerificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverVerificationModelImplCopyWith<_$DriverVerificationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
