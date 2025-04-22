// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stop_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StopModel _$StopModelFromJson(Map<String, dynamic> json) {
  return _StopModel.fromJson(json);
}

/// @nodoc
mixin _$StopModel {
  /// Unique identifier for the stop (UUID). Matches API 'id'.
  String get id => throw _privateConstructorUsedError;

  /// The display name of the bus stop. Matches API 'name'. Required.
  String get name => throw _privateConstructorUsedError;

  /// An optional code identifying the stop. Matches API 'code'.
  String? get code => throw _privateConstructorUsedError;

  /// Physical address or general location description. Matches API 'address'. Optional.
  String? get address => throw _privateConstructorUsedError;

  /// URL to an image associated with the stop. Matches API 'image'. Optional.
  String? get image =>
      throw _privateConstructorUsedError; // API schema name is 'image'
  /// Additional description for the stop. Matches API 'description'. Optional.
  String? get description => throw _privateConstructorUsedError;

  /// The geographical latitude of the stop. Matches API 'latitude'. Required.
  /// API sends as String, needs parsing later if double is needed.
  String get latitude => throw _privateConstructorUsedError;

  /// The geographical longitude of the stop. Matches API 'longitude'. Required.
  /// API sends as String, needs parsing later if double is needed.
  String get longitude => throw _privateConstructorUsedError;

  /// Positional accuracy radius in meters. Matches API 'accuracy'. Optional.
  double? get accuracy => throw _privateConstructorUsedError;

  /// Flag indicating if the stop is active. Matches API 'is_active'. Required.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the stop record was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the stop record was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StopModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StopModelCopyWith<StopModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StopModelCopyWith<$Res> {
  factory $StopModelCopyWith(StopModel value, $Res Function(StopModel) then) =
      _$StopModelCopyWithImpl<$Res, StopModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? code,
      String? address,
      String? image,
      String? description,
      String latitude,
      String longitude,
      double? accuracy,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$StopModelCopyWithImpl<$Res, $Val extends StopModel>
    implements $StopModelCopyWith<$Res> {
  _$StopModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = freezed,
    Object? address = freezed,
    Object? image = freezed,
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
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as String,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$StopModelImplCopyWith<$Res>
    implements $StopModelCopyWith<$Res> {
  factory _$$StopModelImplCopyWith(
          _$StopModelImpl value, $Res Function(_$StopModelImpl) then) =
      __$$StopModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? code,
      String? address,
      String? image,
      String? description,
      String latitude,
      String longitude,
      double? accuracy,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$StopModelImplCopyWithImpl<$Res>
    extends _$StopModelCopyWithImpl<$Res, _$StopModelImpl>
    implements _$$StopModelImplCopyWith<$Res> {
  __$$StopModelImplCopyWithImpl(
      _$StopModelImpl _value, $Res Function(_$StopModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = freezed,
    Object? address = freezed,
    Object? image = freezed,
    Object? description = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$StopModelImpl(
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
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as String,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as String,
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
@JsonSerializable()
class _$StopModelImpl implements _StopModel {
  const _$StopModelImpl(
      {required this.id,
      required this.name,
      this.code,
      this.address,
      this.image,
      this.description,
      required this.latitude,
      required this.longitude,
      this.accuracy,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$StopModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StopModelImplFromJson(json);

  /// Unique identifier for the stop (UUID). Matches API 'id'.
  @override
  final String id;

  /// The display name of the bus stop. Matches API 'name'. Required.
  @override
  final String name;

  /// An optional code identifying the stop. Matches API 'code'.
  @override
  final String? code;

  /// Physical address or general location description. Matches API 'address'. Optional.
  @override
  final String? address;

  /// URL to an image associated with the stop. Matches API 'image'. Optional.
  @override
  final String? image;
// API schema name is 'image'
  /// Additional description for the stop. Matches API 'description'. Optional.
  @override
  final String? description;

  /// The geographical latitude of the stop. Matches API 'latitude'. Required.
  /// API sends as String, needs parsing later if double is needed.
  @override
  final String latitude;

  /// The geographical longitude of the stop. Matches API 'longitude'. Required.
  /// API sends as String, needs parsing later if double is needed.
  @override
  final String longitude;

  /// Positional accuracy radius in meters. Matches API 'accuracy'. Optional.
  @override
  final double? accuracy;

  /// Flag indicating if the stop is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Timestamp when the stop record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the stop record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'StopModel(id: $id, name: $name, code: $code, address: $address, image: $image, description: $description, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StopModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.image, image) || other.image == image) &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      code,
      address,
      image,
      description,
      latitude,
      longitude,
      accuracy,
      isActive,
      createdAt,
      updatedAt);

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StopModelImplCopyWith<_$StopModelImpl> get copyWith =>
      __$$StopModelImplCopyWithImpl<_$StopModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StopModelImplToJson(
      this,
    );
  }
}

abstract class _StopModel implements StopModel {
  const factory _StopModel(
          {required final String id,
          required final String name,
          final String? code,
          final String? address,
          final String? image,
          final String? description,
          required final String latitude,
          required final String longitude,
          final double? accuracy,
          @JsonKey(name: 'is_active') required final bool isActive,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$StopModelImpl;

  factory _StopModel.fromJson(Map<String, dynamic> json) =
      _$StopModelImpl.fromJson;

  /// Unique identifier for the stop (UUID). Matches API 'id'.
  @override
  String get id;

  /// The display name of the bus stop. Matches API 'name'. Required.
  @override
  String get name;

  /// An optional code identifying the stop. Matches API 'code'.
  @override
  String? get code;

  /// Physical address or general location description. Matches API 'address'. Optional.
  @override
  String? get address;

  /// URL to an image associated with the stop. Matches API 'image'. Optional.
  @override
  String? get image; // API schema name is 'image'
  /// Additional description for the stop. Matches API 'description'. Optional.
  @override
  String? get description;

  /// The geographical latitude of the stop. Matches API 'latitude'. Required.
  /// API sends as String, needs parsing later if double is needed.
  @override
  String get latitude;

  /// The geographical longitude of the stop. Matches API 'longitude'. Required.
  /// API sends as String, needs parsing later if double is needed.
  @override
  String get longitude;

  /// Positional accuracy radius in meters. Matches API 'accuracy'. Optional.
  @override
  double? get accuracy;

  /// Flag indicating if the stop is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Timestamp when the stop record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the stop record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of StopModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StopModelImplCopyWith<_$StopModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
