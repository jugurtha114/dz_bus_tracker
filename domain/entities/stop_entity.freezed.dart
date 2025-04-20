// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stop_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StopEntity {
  /// Unique identifier for the stop (UUID).
  String get id => throw _privateConstructorUsedError;

  /// The display name of the bus stop (e.g., "Place des Martyrs"). Required.
  String get name => throw _privateConstructorUsedError;

  /// An optional code identifying the stop (e.g., used on signs).
  String? get code => throw _privateConstructorUsedError;

  /// Physical address or general location description of the stop. Optional.
  String? get address => throw _privateConstructorUsedError;

  /// URL to an image associated with the stop. Optional.
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Additional description for the stop. Optional.
  String? get description => throw _privateConstructorUsedError;

  /// The geographical latitude of the stop. Required.
  double get latitude => throw _privateConstructorUsedError;

  /// The geographical longitude of the stop. Required.
  double get longitude => throw _privateConstructorUsedError;

  /// Positional accuracy radius in meters, if available. Optional.
  double? get accuracy => throw _privateConstructorUsedError;

  /// Flag indicating if the stop is currently active or in use.
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the stop record was created.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the stop record was last updated.
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of StopEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StopEntityCopyWith<StopEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StopEntityCopyWith<$Res> {
  factory $StopEntityCopyWith(
          StopEntity value, $Res Function(StopEntity) then) =
      _$StopEntityCopyWithImpl<$Res, StopEntity>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? code,
      String? address,
      String? imageUrl,
      String? description,
      double latitude,
      double longitude,
      double? accuracy,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$StopEntityCopyWithImpl<$Res, $Val extends StopEntity>
    implements $StopEntityCopyWith<$Res> {
  _$StopEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StopEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = freezed,
    Object? address = freezed,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracy: freezed == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StopEntityImplCopyWith<$Res>
    implements $StopEntityCopyWith<$Res> {
  factory _$$StopEntityImplCopyWith(
          _$StopEntityImpl value, $Res Function(_$StopEntityImpl) then) =
      __$$StopEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? code,
      String? address,
      String? imageUrl,
      String? description,
      double latitude,
      double longitude,
      double? accuracy,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$StopEntityImplCopyWithImpl<$Res>
    extends _$StopEntityCopyWithImpl<$Res, _$StopEntityImpl>
    implements _$$StopEntityImplCopyWith<$Res> {
  __$$StopEntityImplCopyWithImpl(
      _$StopEntityImpl _value, $Res Function(_$StopEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of StopEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = freezed,
    Object? address = freezed,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$StopEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      accuracy: freezed == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
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
    ));
  }
}

/// @nodoc

class _$StopEntityImpl extends _StopEntity {
  const _$StopEntityImpl(
      {required this.id,
      required this.name,
      this.code,
      this.address,
      this.imageUrl,
      this.description,
      required this.latitude,
      required this.longitude,
      this.accuracy,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();

  /// Unique identifier for the stop (UUID).
  @override
  final String id;

  /// The display name of the bus stop (e.g., "Place des Martyrs"). Required.
  @override
  final String name;

  /// An optional code identifying the stop (e.g., used on signs).
  @override
  final String? code;

  /// Physical address or general location description of the stop. Optional.
  @override
  final String? address;

  /// URL to an image associated with the stop. Optional.
  @override
  final String? imageUrl;

  /// Additional description for the stop. Optional.
  @override
  final String? description;

  /// The geographical latitude of the stop. Required.
  @override
  final double latitude;

  /// The geographical longitude of the stop. Required.
  @override
  final double longitude;

  /// Positional accuracy radius in meters, if available. Optional.
  @override
  final double? accuracy;

  /// Flag indicating if the stop is currently active or in use.
  @override
  final bool isActive;

  /// Timestamp when the stop record was created.
  @override
  final DateTime createdAt;

  /// Timestamp when the stop record was last updated.
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'StopEntity(id: $id, name: $name, code: $code, address: $address, imageUrl: $imageUrl, description: $description, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StopEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      code,
      address,
      imageUrl,
      description,
      latitude,
      longitude,
      accuracy,
      isActive,
      createdAt,
      updatedAt);

  /// Create a copy of StopEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StopEntityImplCopyWith<_$StopEntityImpl> get copyWith =>
      __$$StopEntityImplCopyWithImpl<_$StopEntityImpl>(this, _$identity);
}

abstract class _StopEntity extends StopEntity {
  const factory _StopEntity(
      {required final String id,
      required final String name,
      final String? code,
      final String? address,
      final String? imageUrl,
      final String? description,
      required final double latitude,
      required final double longitude,
      final double? accuracy,
      required final bool isActive,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$StopEntityImpl;
  const _StopEntity._() : super._();

  /// Unique identifier for the stop (UUID).
  @override
  String get id;

  /// The display name of the bus stop (e.g., "Place des Martyrs"). Required.
  @override
  String get name;

  /// An optional code identifying the stop (e.g., used on signs).
  @override
  String? get code;

  /// Physical address or general location description of the stop. Optional.
  @override
  String? get address;

  /// URL to an image associated with the stop. Optional.
  @override
  String? get imageUrl;

  /// Additional description for the stop. Optional.
  @override
  String? get description;

  /// The geographical latitude of the stop. Required.
  @override
  double get latitude;

  /// The geographical longitude of the stop. Required.
  @override
  double get longitude;

  /// Positional accuracy radius in meters, if available. Optional.
  @override
  double? get accuracy;

  /// Flag indicating if the stop is currently active or in use.
  @override
  bool get isActive;

  /// Timestamp when the stop record was created.
  @override
  DateTime get createdAt;

  /// Timestamp when the stop record was last updated.
  @override
  DateTime get updatedAt;

  /// Create a copy of StopEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StopEntityImplCopyWith<_$StopEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
