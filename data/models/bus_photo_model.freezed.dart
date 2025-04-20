// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_photo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BusPhotoModel _$BusPhotoModelFromJson(Map<String, dynamic> json) {
  return _BusPhotoModel.fromJson(json);
}

/// @nodoc
mixin _$BusPhotoModel {
  /// Unique identifier for the photo record (UUID). Matches API 'id'.
  String get id => throw _privateConstructorUsedError;

  /// ID of the bus this photo belongs to. Matches API 'bus'. Required.
  String get bus =>
      throw _privateConstructorUsedError; // Keep as 'bus' matching the API field name
  /// URL where the photo image can be accessed. Matches API 'photo'. Required (minLength=1).
  String get photo =>
      throw _privateConstructorUsedError; // Keep as 'photo' matching the API field name
  /// The type or category of the photo. Matches API 'type'. Required.
  /// Uses [PhotoType.unknown] as a fallback for robustness.
  @JsonKey(unknownEnumValue: PhotoType.unknown)
  PhotoType get type => throw _privateConstructorUsedError;

  /// An optional description for the photo. Matches API 'description'.
  String? get description => throw _privateConstructorUsedError;

  /// Timestamp when the photo record was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BusPhotoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusPhotoModelCopyWith<BusPhotoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusPhotoModelCopyWith<$Res> {
  factory $BusPhotoModelCopyWith(
          BusPhotoModel value, $Res Function(BusPhotoModel) then) =
      _$BusPhotoModelCopyWithImpl<$Res, BusPhotoModel>;
  @useResult
  $Res call(
      {String id,
      String bus,
      String photo,
      @JsonKey(unknownEnumValue: PhotoType.unknown) PhotoType type,
      String? description,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$BusPhotoModelCopyWithImpl<$Res, $Val extends BusPhotoModel>
    implements $BusPhotoModelCopyWith<$Res> {
  _$BusPhotoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bus = null,
    Object? photo = null,
    Object? type = null,
    Object? description = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as String,
      photo: null == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PhotoType,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusPhotoModelImplCopyWith<$Res>
    implements $BusPhotoModelCopyWith<$Res> {
  factory _$$BusPhotoModelImplCopyWith(
          _$BusPhotoModelImpl value, $Res Function(_$BusPhotoModelImpl) then) =
      __$$BusPhotoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String bus,
      String photo,
      @JsonKey(unknownEnumValue: PhotoType.unknown) PhotoType type,
      String? description,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$BusPhotoModelImplCopyWithImpl<$Res>
    extends _$BusPhotoModelCopyWithImpl<$Res, _$BusPhotoModelImpl>
    implements _$$BusPhotoModelImplCopyWith<$Res> {
  __$$BusPhotoModelImplCopyWithImpl(
      _$BusPhotoModelImpl _value, $Res Function(_$BusPhotoModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bus = null,
    Object? photo = null,
    Object? type = null,
    Object? description = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$BusPhotoModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as String,
      photo: null == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PhotoType,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusPhotoModelImpl implements _BusPhotoModel {
  const _$BusPhotoModelImpl(
      {required this.id,
      required this.bus,
      required this.photo,
      @JsonKey(unknownEnumValue: PhotoType.unknown) required this.type,
      this.description,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$BusPhotoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusPhotoModelImplFromJson(json);

  /// Unique identifier for the photo record (UUID). Matches API 'id'.
  @override
  final String id;

  /// ID of the bus this photo belongs to. Matches API 'bus'. Required.
  @override
  final String bus;
// Keep as 'bus' matching the API field name
  /// URL where the photo image can be accessed. Matches API 'photo'. Required (minLength=1).
  @override
  final String photo;
// Keep as 'photo' matching the API field name
  /// The type or category of the photo. Matches API 'type'. Required.
  /// Uses [PhotoType.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: PhotoType.unknown)
  final PhotoType type;

  /// An optional description for the photo. Matches API 'description'.
  @override
  final String? description;

  /// Timestamp when the photo record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'BusPhotoModel(id: $id, bus: $bus, photo: $photo, type: $type, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusPhotoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bus, bus) || other.bus == bus) &&
            (identical(other.photo, photo) || other.photo == photo) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, bus, photo, type, description, createdAt);

  /// Create a copy of BusPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusPhotoModelImplCopyWith<_$BusPhotoModelImpl> get copyWith =>
      __$$BusPhotoModelImplCopyWithImpl<_$BusPhotoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusPhotoModelImplToJson(
      this,
    );
  }
}

abstract class _BusPhotoModel implements BusPhotoModel {
  const factory _BusPhotoModel(
          {required final String id,
          required final String bus,
          required final String photo,
          @JsonKey(unknownEnumValue: PhotoType.unknown)
          required final PhotoType type,
          final String? description,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$BusPhotoModelImpl;

  factory _BusPhotoModel.fromJson(Map<String, dynamic> json) =
      _$BusPhotoModelImpl.fromJson;

  /// Unique identifier for the photo record (UUID). Matches API 'id'.
  @override
  String get id;

  /// ID of the bus this photo belongs to. Matches API 'bus'. Required.
  @override
  String get bus; // Keep as 'bus' matching the API field name
  /// URL where the photo image can be accessed. Matches API 'photo'. Required (minLength=1).
  @override
  String get photo; // Keep as 'photo' matching the API field name
  /// The type or category of the photo. Matches API 'type'. Required.
  /// Uses [PhotoType.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: PhotoType.unknown)
  PhotoType get type;

  /// An optional description for the photo. Matches API 'description'.
  @override
  String? get description;

  /// Timestamp when the photo record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of BusPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusPhotoModelImplCopyWith<_$BusPhotoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
