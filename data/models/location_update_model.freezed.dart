// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationUpdateModel _$LocationUpdateModelFromJson(Map<String, dynamic> json) {
  return _LocationUpdateModel.fromJson(json);
}

/// @nodoc
mixin _$LocationUpdateModel {
  /// Unique identifier for the location update record (UUID). Matches API 'id'. Read-only.
  String get id => throw _privateConstructorUsedError;

  /// ID of the tracking session this update belongs to. Matches API 'session'. Required.
  String get session => throw _privateConstructorUsedError; // UUID
  /// Timestamp when the location was recorded by the device. Matches API 'timestamp'. Required.
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Geographical latitude. Matches API 'latitude'. Required. Sent/Received as String.
  String get latitude => throw _privateConstructorUsedError;

  /// Geographical longitude. Matches API 'longitude'. Required. Sent/Received as String.
  String get longitude => throw _privateConstructorUsedError;

  /// Estimated horizontal accuracy in meters. Matches API 'accuracy'. Optional.
  double? get accuracy => throw _privateConstructorUsedError;

  /// Speed in meters per second. Matches API 'speed'. Optional.
  double? get speed => throw _privateConstructorUsedError;

  /// Direction of travel in degrees (0-359.9). Matches API 'heading'. Optional.
  double? get heading => throw _privateConstructorUsedError;

  /// Altitude in meters above WGS84 ellipsoid. Matches API 'altitude'. Optional.
  double? get altitude => throw _privateConstructorUsedError;

  /// Distance in meters from the previous update in the session. Matches API 'distance_from_last'. Optional. Read-only.
  @JsonKey(name: 'distance_from_last')
  double? get distanceFromLast => throw _privateConstructorUsedError;

  /// Timestamp when the record was created in the database. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the record was last updated in the database. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LocationUpdateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationUpdateModelCopyWith<LocationUpdateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationUpdateModelCopyWith<$Res> {
  factory $LocationUpdateModelCopyWith(
          LocationUpdateModel value, $Res Function(LocationUpdateModel) then) =
      _$LocationUpdateModelCopyWithImpl<$Res, LocationUpdateModel>;
  @useResult
  $Res call(
      {String id,
      String session,
      DateTime timestamp,
      String latitude,
      String longitude,
      double? accuracy,
      double? speed,
      double? heading,
      double? altitude,
      @JsonKey(name: 'distance_from_last') double? distanceFromLast,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$LocationUpdateModelCopyWithImpl<$Res, $Val extends LocationUpdateModel>
    implements $LocationUpdateModelCopyWith<$Res> {
  _$LocationUpdateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? session = null,
    Object? timestamp = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? speed = freezed,
    Object? heading = freezed,
    Object? altitude = freezed,
    Object? distanceFromLast = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      session: null == session
          ? _value.session
          : session // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _value.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      distanceFromLast: freezed == distanceFromLast
          ? _value.distanceFromLast
          : distanceFromLast // ignore: cast_nullable_to_non_nullable
              as double?,
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
abstract class _$$LocationUpdateModelImplCopyWith<$Res>
    implements $LocationUpdateModelCopyWith<$Res> {
  factory _$$LocationUpdateModelImplCopyWith(_$LocationUpdateModelImpl value,
          $Res Function(_$LocationUpdateModelImpl) then) =
      __$$LocationUpdateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String session,
      DateTime timestamp,
      String latitude,
      String longitude,
      double? accuracy,
      double? speed,
      double? heading,
      double? altitude,
      @JsonKey(name: 'distance_from_last') double? distanceFromLast,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$LocationUpdateModelImplCopyWithImpl<$Res>
    extends _$LocationUpdateModelCopyWithImpl<$Res, _$LocationUpdateModelImpl>
    implements _$$LocationUpdateModelImplCopyWith<$Res> {
  __$$LocationUpdateModelImplCopyWithImpl(_$LocationUpdateModelImpl _value,
      $Res Function(_$LocationUpdateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? session = null,
    Object? timestamp = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? speed = freezed,
    Object? heading = freezed,
    Object? altitude = freezed,
    Object? distanceFromLast = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$LocationUpdateModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      session: null == session
          ? _value.session
          : session // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      altitude: freezed == altitude
          ? _value.altitude
          : altitude // ignore: cast_nullable_to_non_nullable
              as double?,
      distanceFromLast: freezed == distanceFromLast
          ? _value.distanceFromLast
          : distanceFromLast // ignore: cast_nullable_to_non_nullable
              as double?,
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
class _$LocationUpdateModelImpl implements _LocationUpdateModel {
  const _$LocationUpdateModelImpl(
      {required this.id,
      required this.session,
      required this.timestamp,
      required this.latitude,
      required this.longitude,
      this.accuracy,
      this.speed,
      this.heading,
      this.altitude,
      @JsonKey(name: 'distance_from_last') this.distanceFromLast,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$LocationUpdateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationUpdateModelImplFromJson(json);

  /// Unique identifier for the location update record (UUID). Matches API 'id'. Read-only.
  @override
  final String id;

  /// ID of the tracking session this update belongs to. Matches API 'session'. Required.
  @override
  final String session;
// UUID
  /// Timestamp when the location was recorded by the device. Matches API 'timestamp'. Required.
  @override
  final DateTime timestamp;

  /// Geographical latitude. Matches API 'latitude'. Required. Sent/Received as String.
  @override
  final String latitude;

  /// Geographical longitude. Matches API 'longitude'. Required. Sent/Received as String.
  @override
  final String longitude;

  /// Estimated horizontal accuracy in meters. Matches API 'accuracy'. Optional.
  @override
  final double? accuracy;

  /// Speed in meters per second. Matches API 'speed'. Optional.
  @override
  final double? speed;

  /// Direction of travel in degrees (0-359.9). Matches API 'heading'. Optional.
  @override
  final double? heading;

  /// Altitude in meters above WGS84 ellipsoid. Matches API 'altitude'. Optional.
  @override
  final double? altitude;

  /// Distance in meters from the previous update in the session. Matches API 'distance_from_last'. Optional. Read-only.
  @override
  @JsonKey(name: 'distance_from_last')
  final double? distanceFromLast;

  /// Timestamp when the record was created in the database. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the record was last updated in the database. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'LocationUpdateModel(id: $id, session: $session, timestamp: $timestamp, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, speed: $speed, heading: $heading, altitude: $altitude, distanceFromLast: $distanceFromLast, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationUpdateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.session, session) || other.session == session) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.distanceFromLast, distanceFromLast) ||
                other.distanceFromLast == distanceFromLast) &&
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
      session,
      timestamp,
      latitude,
      longitude,
      accuracy,
      speed,
      heading,
      altitude,
      distanceFromLast,
      createdAt,
      updatedAt);

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationUpdateModelImplCopyWith<_$LocationUpdateModelImpl> get copyWith =>
      __$$LocationUpdateModelImplCopyWithImpl<_$LocationUpdateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationUpdateModelImplToJson(
      this,
    );
  }
}

abstract class _LocationUpdateModel implements LocationUpdateModel {
  const factory _LocationUpdateModel(
          {required final String id,
          required final String session,
          required final DateTime timestamp,
          required final String latitude,
          required final String longitude,
          final double? accuracy,
          final double? speed,
          final double? heading,
          final double? altitude,
          @JsonKey(name: 'distance_from_last') final double? distanceFromLast,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$LocationUpdateModelImpl;

  factory _LocationUpdateModel.fromJson(Map<String, dynamic> json) =
      _$LocationUpdateModelImpl.fromJson;

  /// Unique identifier for the location update record (UUID). Matches API 'id'. Read-only.
  @override
  String get id;

  /// ID of the tracking session this update belongs to. Matches API 'session'. Required.
  @override
  String get session; // UUID
  /// Timestamp when the location was recorded by the device. Matches API 'timestamp'. Required.
  @override
  DateTime get timestamp;

  /// Geographical latitude. Matches API 'latitude'. Required. Sent/Received as String.
  @override
  String get latitude;

  /// Geographical longitude. Matches API 'longitude'. Required. Sent/Received as String.
  @override
  String get longitude;

  /// Estimated horizontal accuracy in meters. Matches API 'accuracy'. Optional.
  @override
  double? get accuracy;

  /// Speed in meters per second. Matches API 'speed'. Optional.
  @override
  double? get speed;

  /// Direction of travel in degrees (0-359.9). Matches API 'heading'. Optional.
  @override
  double? get heading;

  /// Altitude in meters above WGS84 ellipsoid. Matches API 'altitude'. Optional.
  @override
  double? get altitude;

  /// Distance in meters from the previous update in the session. Matches API 'distance_from_last'. Optional. Read-only.
  @override
  @JsonKey(name: 'distance_from_last')
  double? get distanceFromLast;

  /// Timestamp when the record was created in the database. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the record was last updated in the database. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of LocationUpdateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationUpdateModelImplCopyWith<_$LocationUpdateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
