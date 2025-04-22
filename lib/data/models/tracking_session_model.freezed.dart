// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrackingSessionModel _$TrackingSessionModelFromJson(Map<String, dynamic> json) {
  return _TrackingSessionModel.fromJson(json);
}

/// @nodoc
mixin _$TrackingSessionModel {
  /// Unique identifier for the tracking session (UUID). Matches API 'id'.
  String get id => throw _privateConstructorUsedError;

  /// ID of the associated Driver record. Matches API 'driver'. Required.
  String get driver => throw _privateConstructorUsedError; // UUID
  /// ID of the associated Bus record. Matches API 'bus'. Required.
  String get bus => throw _privateConstructorUsedError; // UUID
  /// ID of the associated Line record. Matches API 'line'. Required.
  String get line => throw _privateConstructorUsedError; // UUID
  /// Optional ID of the specific schedule instance. Matches API 'schedule'.
  String? get schedule => throw _privateConstructorUsedError; // UUID
  /// Timestamp when the session started. Matches API 'start_time'. Required.
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;

  /// Timestamp when the session ended. Matches API 'end_time'. Nullable.
  @JsonKey(name: 'end_time')
  DateTime? get endTime => throw _privateConstructorUsedError;

  /// Current status of the session. Matches API 'status'. Required.
  /// Uses [TrackingStatus.unknown] as a fallback for robustness.
  @JsonKey(unknownEnumValue: TrackingStatus.unknown)
  TrackingStatus get status => throw _privateConstructorUsedError;

  /// Timestamp of the last location update received for this session. Matches API 'last_update'. Nullable.
  @JsonKey(name: 'last_update')
  DateTime? get lastUpdate => throw _privateConstructorUsedError;

  /// Total distance covered in meters. Matches API 'total_distance'. Nullable.
  @JsonKey(name: 'total_distance')
  double? get totalDistance => throw _privateConstructorUsedError;

  /// Timestamp when the session record was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the session record was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested/Calculated Fields ---
  /// Calculated duration of the session (ISO 8601 format string). Matches API 'duration'. Nullable. Read-only.
  /// Needs parsing in the domain layer or presentation layer if needed as Duration object.
  String? get duration => throw _privateConstructorUsedError;

  /// Details of the associated Driver record. Matches API 'driver_details'. Required. Read-only.
  @JsonKey(name: 'driver_details')
  DriverModel get driverDetails => throw _privateConstructorUsedError;

  /// Details of the associated Bus record. Matches API 'bus_details'. Required. Read-only.
  @JsonKey(name: 'bus_details')
  BusModel get busDetails => throw _privateConstructorUsedError;

  /// Details of the associated Line record. Matches API 'line_details'. Required. Read-only.
  @JsonKey(name: 'line_details')
  LineModel get lineDetails => throw _privateConstructorUsedError;

  /// Serializes this TrackingSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackingSessionModelCopyWith<TrackingSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackingSessionModelCopyWith<$Res> {
  factory $TrackingSessionModelCopyWith(TrackingSessionModel value,
          $Res Function(TrackingSessionModel) then) =
      _$TrackingSessionModelCopyWithImpl<$Res, TrackingSessionModel>;
  @useResult
  $Res call(
      {String id,
      String driver,
      String bus,
      String line,
      String? schedule,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime? endTime,
      @JsonKey(unknownEnumValue: TrackingStatus.unknown) TrackingStatus status,
      @JsonKey(name: 'last_update') DateTime? lastUpdate,
      @JsonKey(name: 'total_distance') double? totalDistance,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      String? duration,
      @JsonKey(name: 'driver_details') DriverModel driverDetails,
      @JsonKey(name: 'bus_details') BusModel busDetails,
      @JsonKey(name: 'line_details') LineModel lineDetails});

  $DriverModelCopyWith<$Res> get driverDetails;
  $BusModelCopyWith<$Res> get busDetails;
  $LineModelCopyWith<$Res> get lineDetails;
}

/// @nodoc
class _$TrackingSessionModelCopyWithImpl<$Res,
        $Val extends TrackingSessionModel>
    implements $TrackingSessionModelCopyWith<$Res> {
  _$TrackingSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driver = null,
    Object? bus = null,
    Object? line = null,
    Object? schedule = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? status = null,
    Object? lastUpdate = freezed,
    Object? totalDistance = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? duration = freezed,
    Object? driverDetails = null,
    Object? busDetails = null,
    Object? lineDetails = null,
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
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as String,
      schedule: freezed == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
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
      totalDistance: freezed == totalDistance
          ? _value.totalDistance
          : totalDistance // ignore: cast_nullable_to_non_nullable
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
              as String?,
      driverDetails: null == driverDetails
          ? _value.driverDetails
          : driverDetails // ignore: cast_nullable_to_non_nullable
              as DriverModel,
      busDetails: null == busDetails
          ? _value.busDetails
          : busDetails // ignore: cast_nullable_to_non_nullable
              as BusModel,
      lineDetails: null == lineDetails
          ? _value.lineDetails
          : lineDetails // ignore: cast_nullable_to_non_nullable
              as LineModel,
    ) as $Val);
  }

  /// Create a copy of TrackingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DriverModelCopyWith<$Res> get driverDetails {
    return $DriverModelCopyWith<$Res>(_value.driverDetails, (value) {
      return _then(_value.copyWith(driverDetails: value) as $Val);
    });
  }

  /// Create a copy of TrackingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BusModelCopyWith<$Res> get busDetails {
    return $BusModelCopyWith<$Res>(_value.busDetails, (value) {
      return _then(_value.copyWith(busDetails: value) as $Val);
    });
  }

  /// Create a copy of TrackingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LineModelCopyWith<$Res> get lineDetails {
    return $LineModelCopyWith<$Res>(_value.lineDetails, (value) {
      return _then(_value.copyWith(lineDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrackingSessionModelImplCopyWith<$Res>
    implements $TrackingSessionModelCopyWith<$Res> {
  factory _$$TrackingSessionModelImplCopyWith(_$TrackingSessionModelImpl value,
          $Res Function(_$TrackingSessionModelImpl) then) =
      __$$TrackingSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driver,
      String bus,
      String line,
      String? schedule,
      @JsonKey(name: 'start_time') DateTime startTime,
      @JsonKey(name: 'end_time') DateTime? endTime,
      @JsonKey(unknownEnumValue: TrackingStatus.unknown) TrackingStatus status,
      @JsonKey(name: 'last_update') DateTime? lastUpdate,
      @JsonKey(name: 'total_distance') double? totalDistance,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      String? duration,
      @JsonKey(name: 'driver_details') DriverModel driverDetails,
      @JsonKey(name: 'bus_details') BusModel busDetails,
      @JsonKey(name: 'line_details') LineModel lineDetails});

  @override
  $DriverModelCopyWith<$Res> get driverDetails;
  @override
  $BusModelCopyWith<$Res> get busDetails;
  @override
  $LineModelCopyWith<$Res> get lineDetails;
}

/// @nodoc
class __$$TrackingSessionModelImplCopyWithImpl<$Res>
    extends _$TrackingSessionModelCopyWithImpl<$Res, _$TrackingSessionModelImpl>
    implements _$$TrackingSessionModelImplCopyWith<$Res> {
  __$$TrackingSessionModelImplCopyWithImpl(_$TrackingSessionModelImpl _value,
      $Res Function(_$TrackingSessionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driver = null,
    Object? bus = null,
    Object? line = null,
    Object? schedule = freezed,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? status = null,
    Object? lastUpdate = freezed,
    Object? totalDistance = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? duration = freezed,
    Object? driverDetails = null,
    Object? busDetails = null,
    Object? lineDetails = null,
  }) {
    return _then(_$TrackingSessionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driver: null == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as String,
      schedule: freezed == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
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
      totalDistance: freezed == totalDistance
          ? _value.totalDistance
          : totalDistance // ignore: cast_nullable_to_non_nullable
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
              as String?,
      driverDetails: null == driverDetails
          ? _value.driverDetails
          : driverDetails // ignore: cast_nullable_to_non_nullable
              as DriverModel,
      busDetails: null == busDetails
          ? _value.busDetails
          : busDetails // ignore: cast_nullable_to_non_nullable
              as BusModel,
      lineDetails: null == lineDetails
          ? _value.lineDetails
          : lineDetails // ignore: cast_nullable_to_non_nullable
              as LineModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackingSessionModelImpl implements _TrackingSessionModel {
  const _$TrackingSessionModelImpl(
      {required this.id,
      required this.driver,
      required this.bus,
      required this.line,
      this.schedule,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') this.endTime,
      @JsonKey(unknownEnumValue: TrackingStatus.unknown) required this.status,
      @JsonKey(name: 'last_update') this.lastUpdate,
      @JsonKey(name: 'total_distance') this.totalDistance,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      this.duration,
      @JsonKey(name: 'driver_details') required this.driverDetails,
      @JsonKey(name: 'bus_details') required this.busDetails,
      @JsonKey(name: 'line_details') required this.lineDetails});

  factory _$TrackingSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackingSessionModelImplFromJson(json);

  /// Unique identifier for the tracking session (UUID). Matches API 'id'.
  @override
  final String id;

  /// ID of the associated Driver record. Matches API 'driver'. Required.
  @override
  final String driver;
// UUID
  /// ID of the associated Bus record. Matches API 'bus'. Required.
  @override
  final String bus;
// UUID
  /// ID of the associated Line record. Matches API 'line'. Required.
  @override
  final String line;
// UUID
  /// Optional ID of the specific schedule instance. Matches API 'schedule'.
  @override
  final String? schedule;
// UUID
  /// Timestamp when the session started. Matches API 'start_time'. Required.
  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;

  /// Timestamp when the session ended. Matches API 'end_time'. Nullable.
  @override
  @JsonKey(name: 'end_time')
  final DateTime? endTime;

  /// Current status of the session. Matches API 'status'. Required.
  /// Uses [TrackingStatus.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: TrackingStatus.unknown)
  final TrackingStatus status;

  /// Timestamp of the last location update received for this session. Matches API 'last_update'. Nullable.
  @override
  @JsonKey(name: 'last_update')
  final DateTime? lastUpdate;

  /// Total distance covered in meters. Matches API 'total_distance'. Nullable.
  @override
  @JsonKey(name: 'total_distance')
  final double? totalDistance;

  /// Timestamp when the session record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the session record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested/Calculated Fields ---
  /// Calculated duration of the session (ISO 8601 format string). Matches API 'duration'. Nullable. Read-only.
  /// Needs parsing in the domain layer or presentation layer if needed as Duration object.
  @override
  final String? duration;

  /// Details of the associated Driver record. Matches API 'driver_details'. Required. Read-only.
  @override
  @JsonKey(name: 'driver_details')
  final DriverModel driverDetails;

  /// Details of the associated Bus record. Matches API 'bus_details'. Required. Read-only.
  @override
  @JsonKey(name: 'bus_details')
  final BusModel busDetails;

  /// Details of the associated Line record. Matches API 'line_details'. Required. Read-only.
  @override
  @JsonKey(name: 'line_details')
  final LineModel lineDetails;

  @override
  String toString() {
    return 'TrackingSessionModel(id: $id, driver: $driver, bus: $bus, line: $line, schedule: $schedule, startTime: $startTime, endTime: $endTime, status: $status, lastUpdate: $lastUpdate, totalDistance: $totalDistance, createdAt: $createdAt, updatedAt: $updatedAt, duration: $duration, driverDetails: $driverDetails, busDetails: $busDetails, lineDetails: $lineDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackingSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.bus, bus) || other.bus == bus) &&
            (identical(other.line, line) || other.line == line) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            (identical(other.totalDistance, totalDistance) ||
                other.totalDistance == totalDistance) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.driverDetails, driverDetails) ||
                other.driverDetails == driverDetails) &&
            (identical(other.busDetails, busDetails) ||
                other.busDetails == busDetails) &&
            (identical(other.lineDetails, lineDetails) ||
                other.lineDetails == lineDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      driver,
      bus,
      line,
      schedule,
      startTime,
      endTime,
      status,
      lastUpdate,
      totalDistance,
      createdAt,
      updatedAt,
      duration,
      driverDetails,
      busDetails,
      lineDetails);

  /// Create a copy of TrackingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackingSessionModelImplCopyWith<_$TrackingSessionModelImpl>
      get copyWith =>
          __$$TrackingSessionModelImplCopyWithImpl<_$TrackingSessionModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackingSessionModelImplToJson(
      this,
    );
  }
}

abstract class _TrackingSessionModel implements TrackingSessionModel {
  const factory _TrackingSessionModel(
      {required final String id,
      required final String driver,
      required final String bus,
      required final String line,
      final String? schedule,
      @JsonKey(name: 'start_time') required final DateTime startTime,
      @JsonKey(name: 'end_time') final DateTime? endTime,
      @JsonKey(unknownEnumValue: TrackingStatus.unknown)
      required final TrackingStatus status,
      @JsonKey(name: 'last_update') final DateTime? lastUpdate,
      @JsonKey(name: 'total_distance') final double? totalDistance,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      final String? duration,
      @JsonKey(name: 'driver_details') required final DriverModel driverDetails,
      @JsonKey(name: 'bus_details') required final BusModel busDetails,
      @JsonKey(name: 'line_details')
      required final LineModel lineDetails}) = _$TrackingSessionModelImpl;

  factory _TrackingSessionModel.fromJson(Map<String, dynamic> json) =
      _$TrackingSessionModelImpl.fromJson;

  /// Unique identifier for the tracking session (UUID). Matches API 'id'.
  @override
  String get id;

  /// ID of the associated Driver record. Matches API 'driver'. Required.
  @override
  String get driver; // UUID
  /// ID of the associated Bus record. Matches API 'bus'. Required.
  @override
  String get bus; // UUID
  /// ID of the associated Line record. Matches API 'line'. Required.
  @override
  String get line; // UUID
  /// Optional ID of the specific schedule instance. Matches API 'schedule'.
  @override
  String? get schedule; // UUID
  /// Timestamp when the session started. Matches API 'start_time'. Required.
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;

  /// Timestamp when the session ended. Matches API 'end_time'. Nullable.
  @override
  @JsonKey(name: 'end_time')
  DateTime? get endTime;

  /// Current status of the session. Matches API 'status'. Required.
  /// Uses [TrackingStatus.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: TrackingStatus.unknown)
  TrackingStatus get status;

  /// Timestamp of the last location update received for this session. Matches API 'last_update'. Nullable.
  @override
  @JsonKey(name: 'last_update')
  DateTime? get lastUpdate;

  /// Total distance covered in meters. Matches API 'total_distance'. Nullable.
  @override
  @JsonKey(name: 'total_distance')
  double? get totalDistance;

  /// Timestamp when the session record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the session record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Nested/Calculated Fields ---
  /// Calculated duration of the session (ISO 8601 format string). Matches API 'duration'. Nullable. Read-only.
  /// Needs parsing in the domain layer or presentation layer if needed as Duration object.
  @override
  String? get duration;

  /// Details of the associated Driver record. Matches API 'driver_details'. Required. Read-only.
  @override
  @JsonKey(name: 'driver_details')
  DriverModel get driverDetails;

  /// Details of the associated Bus record. Matches API 'bus_details'. Required. Read-only.
  @override
  @JsonKey(name: 'bus_details')
  BusModel get busDetails;

  /// Details of the associated Line record. Matches API 'line_details'. Required. Read-only.
  @override
  @JsonKey(name: 'line_details')
  LineModel get lineDetails;

  /// Create a copy of TrackingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackingSessionModelImplCopyWith<_$TrackingSessionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
