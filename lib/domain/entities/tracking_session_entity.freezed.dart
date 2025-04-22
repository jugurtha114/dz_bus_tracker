// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_session_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrackingSessionEntity {
  /// Unique identifier for the tracking session (UUID).
  String get id => throw _privateConstructorUsedError;

  /// Details of the driver conducting the session.
  DriverEntity get driverDetails => throw _privateConstructorUsedError;

  /// Details of the bus being tracked.
  BusEntity get busDetails => throw _privateConstructorUsedError;

  /// Details of the line being followed during the session.
  LineEntity get lineDetails => throw _privateConstructorUsedError;

  /// Optional identifier for a specific schedule instance associated with this session.
  String? get scheduleId => throw _privateConstructorUsedError;

  /// Timestamp when the tracking session started.
  DateTime get startTime => throw _privateConstructorUsedError;

  /// Timestamp when the tracking session ended. Null if the session is ongoing or paused.
  DateTime? get endTime => throw _privateConstructorUsedError;

  /// The current status of the tracking session (e.g., active, paused, completed).
  TrackingStatus get status => throw _privateConstructorUsedError;

  /// Timestamp of the last received location update for this session. Null if no updates yet.
  DateTime? get lastUpdate => throw _privateConstructorUsedError;

  /// Total distance covered during the session in meters. Read-only from API.
  double? get totalDistanceMeters => throw _privateConstructorUsedError;

  /// Timestamp when the session record was created.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the session record was last updated.
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Calculated duration of the session. Null if the session hasn't ended.
  /// (Parsing logic happens in repository/mapper).
  Duration? get duration => throw _privateConstructorUsedError;

  /// Create a copy of TrackingSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackingSessionEntityCopyWith<TrackingSessionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackingSessionEntityCopyWith<$Res> {
  factory $TrackingSessionEntityCopyWith(TrackingSessionEntity value,
          $Res Function(TrackingSessionEntity) then) =
      _$TrackingSessionEntityCopyWithImpl<$Res, TrackingSessionEntity>;
  @useResult
  $Res call(
      {String id,
      DriverEntity driverDetails,
      BusEntity busDetails,
      LineEntity lineDetails,
      String? scheduleId,
      DateTime startTime,
      DateTime? endTime,
      TrackingStatus status,
      DateTime? lastUpdate,
      double? totalDistanceMeters,
      DateTime createdAt,
      DateTime updatedAt,
      Duration? duration});
}

/// @nodoc
class _$TrackingSessionEntityCopyWithImpl<$Res,
        $Val extends TrackingSessionEntity>
    implements $TrackingSessionEntityCopyWith<$Res> {
  _$TrackingSessionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackingSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverDetails = null,
    Object? busDetails = null,
    Object? lineDetails = null,
    Object? scheduleId = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? status = null,
    Object? lastUpdate = freezed,
    Object? totalDistanceMeters = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? duration = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverDetails: null == driverDetails
          ? _value.driverDetails
          : driverDetails // ignore: cast_nullable_to_non_nullable
              as DriverEntity,
      busDetails: null == busDetails
          ? _value.busDetails
          : busDetails // ignore: cast_nullable_to_non_nullable
              as BusEntity,
      lineDetails: null == lineDetails
          ? _value.lineDetails
          : lineDetails // ignore: cast_nullable_to_non_nullable
              as LineEntity,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TrackingStatus,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalDistanceMeters: freezed == totalDistanceMeters
          ? _value.totalDistanceMeters
          : totalDistanceMeters // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackingSessionEntityImplCopyWith<$Res>
    implements $TrackingSessionEntityCopyWith<$Res> {
  factory _$$TrackingSessionEntityImplCopyWith(
          _$TrackingSessionEntityImpl value,
          $Res Function(_$TrackingSessionEntityImpl) then) =
      __$$TrackingSessionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DriverEntity driverDetails,
      BusEntity busDetails,
      LineEntity lineDetails,
      String? scheduleId,
      DateTime startTime,
      DateTime? endTime,
      TrackingStatus status,
      DateTime? lastUpdate,
      double? totalDistanceMeters,
      DateTime createdAt,
      DateTime updatedAt,
      Duration? duration});
}

/// @nodoc
class __$$TrackingSessionEntityImplCopyWithImpl<$Res>
    extends _$TrackingSessionEntityCopyWithImpl<$Res,
        _$TrackingSessionEntityImpl>
    implements _$$TrackingSessionEntityImplCopyWith<$Res> {
  __$$TrackingSessionEntityImplCopyWithImpl(_$TrackingSessionEntityImpl _value,
      $Res Function(_$TrackingSessionEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackingSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverDetails = null,
    Object? busDetails = null,
    Object? lineDetails = null,
    Object? scheduleId = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? status = null,
    Object? lastUpdate = freezed,
    Object? totalDistanceMeters = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? duration = freezed,
  }) {
    return _then(_$TrackingSessionEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverDetails: null == driverDetails
          ? _value.driverDetails
          : driverDetails // ignore: cast_nullable_to_non_nullable
              as DriverEntity,
      busDetails: null == busDetails
          ? _value.busDetails
          : busDetails // ignore: cast_nullable_to_non_nullable
              as BusEntity,
      lineDetails: null == lineDetails
          ? _value.lineDetails
          : lineDetails // ignore: cast_nullable_to_non_nullable
              as LineEntity,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TrackingStatus,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalDistanceMeters: freezed == totalDistanceMeters
          ? _value.totalDistanceMeters
          : totalDistanceMeters // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc

class _$TrackingSessionEntityImpl extends _TrackingSessionEntity {
  const _$TrackingSessionEntityImpl(
      {required this.id,
      required this.driverDetails,
      required this.busDetails,
      required this.lineDetails,
      this.scheduleId,
      required this.startTime,
      this.endTime,
      required this.status,
      this.lastUpdate,
      this.totalDistanceMeters,
      required this.createdAt,
      required this.updatedAt,
      this.duration})
      : super._();

  /// Unique identifier for the tracking session (UUID).
  @override
  final String id;

  /// Details of the driver conducting the session.
  @override
  final DriverEntity driverDetails;

  /// Details of the bus being tracked.
  @override
  final BusEntity busDetails;

  /// Details of the line being followed during the session.
  @override
  final LineEntity lineDetails;

  /// Optional identifier for a specific schedule instance associated with this session.
  @override
  final String? scheduleId;

  /// Timestamp when the tracking session started.
  @override
  final DateTime startTime;

  /// Timestamp when the tracking session ended. Null if the session is ongoing or paused.
  @override
  final DateTime? endTime;

  /// The current status of the tracking session (e.g., active, paused, completed).
  @override
  final TrackingStatus status;

  /// Timestamp of the last received location update for this session. Null if no updates yet.
  @override
  final DateTime? lastUpdate;

  /// Total distance covered during the session in meters. Read-only from API.
  @override
  final double? totalDistanceMeters;

  /// Timestamp when the session record was created.
  @override
  final DateTime createdAt;

  /// Timestamp when the session record was last updated.
  @override
  final DateTime updatedAt;

  /// Calculated duration of the session. Null if the session hasn't ended.
  /// (Parsing logic happens in repository/mapper).
  @override
  final Duration? duration;

  @override
  String toString() {
    return 'TrackingSessionEntity(id: $id, driverDetails: $driverDetails, busDetails: $busDetails, lineDetails: $lineDetails, scheduleId: $scheduleId, startTime: $startTime, endTime: $endTime, status: $status, lastUpdate: $lastUpdate, totalDistanceMeters: $totalDistanceMeters, createdAt: $createdAt, updatedAt: $updatedAt, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackingSessionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverDetails, driverDetails) ||
                other.driverDetails == driverDetails) &&
            (identical(other.busDetails, busDetails) ||
                other.busDetails == busDetails) &&
            (identical(other.lineDetails, lineDetails) ||
                other.lineDetails == lineDetails) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            (identical(other.totalDistanceMeters, totalDistanceMeters) ||
                other.totalDistanceMeters == totalDistanceMeters) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      driverDetails,
      busDetails,
      lineDetails,
      scheduleId,
      startTime,
      endTime,
      status,
      lastUpdate,
      totalDistanceMeters,
      createdAt,
      updatedAt,
      duration);

  /// Create a copy of TrackingSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackingSessionEntityImplCopyWith<_$TrackingSessionEntityImpl>
      get copyWith => __$$TrackingSessionEntityImplCopyWithImpl<
          _$TrackingSessionEntityImpl>(this, _$identity);
}

abstract class _TrackingSessionEntity extends TrackingSessionEntity {
  const factory _TrackingSessionEntity(
      {required final String id,
      required final DriverEntity driverDetails,
      required final BusEntity busDetails,
      required final LineEntity lineDetails,
      final String? scheduleId,
      required final DateTime startTime,
      final DateTime? endTime,
      required final TrackingStatus status,
      final DateTime? lastUpdate,
      final double? totalDistanceMeters,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final Duration? duration}) = _$TrackingSessionEntityImpl;
  const _TrackingSessionEntity._() : super._();

  /// Unique identifier for the tracking session (UUID).
  @override
  String get id;

  /// Details of the driver conducting the session.
  @override
  DriverEntity get driverDetails;

  /// Details of the bus being tracked.
  @override
  BusEntity get busDetails;

  /// Details of the line being followed during the session.
  @override
  LineEntity get lineDetails;

  /// Optional identifier for a specific schedule instance associated with this session.
  @override
  String? get scheduleId;

  /// Timestamp when the tracking session started.
  @override
  DateTime get startTime;

  /// Timestamp when the tracking session ended. Null if the session is ongoing or paused.
  @override
  DateTime? get endTime;

  /// The current status of the tracking session (e.g., active, paused, completed).
  @override
  TrackingStatus get status;

  /// Timestamp of the last received location update for this session. Null if no updates yet.
  @override
  DateTime? get lastUpdate;

  /// Total distance covered during the session in meters. Read-only from API.
  @override
  double? get totalDistanceMeters;

  /// Timestamp when the session record was created.
  @override
  DateTime get createdAt;

  /// Timestamp when the session record was last updated.
  @override
  DateTime get updatedAt;

  /// Calculated duration of the session. Null if the session hasn't ended.
  /// (Parsing logic happens in repository/mapper).
  @override
  Duration? get duration;

  /// Create a copy of TrackingSessionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackingSessionEntityImplCopyWith<_$TrackingSessionEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
