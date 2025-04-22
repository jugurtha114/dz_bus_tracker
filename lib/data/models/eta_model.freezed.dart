// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eta_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EtaModel _$EtaModelFromJson(Map<String, dynamic> json) {
  return _EtaModel.fromJson(json);
}

/// @nodoc
mixin _$EtaModel {
  /// Unique identifier for the ETA record (UUID). Matches API 'id'. Read-only.
  String get id => throw _privateConstructorUsedError;

  /// ID of the associated Line. Matches API 'line'. Required.
  String get line => throw _privateConstructorUsedError; // UUID
  /// ID of the associated Bus. Matches API 'bus'. Required.
  String get bus => throw _privateConstructorUsedError; // UUID
  /// ID of the associated Stop. Matches API 'stop'. Required.
  String get stop => throw _privateConstructorUsedError; // UUID
  /// ID of the associated TrackingSession. Matches API 'tracking_session'. Required.
  @JsonKey(name: 'tracking_session')
  String get trackingSession => throw _privateConstructorUsedError; // UUID
  /// The calculated estimated time of arrival. Matches API 'estimated_arrival_time'. Required.
  @JsonKey(name: 'estimated_arrival_time')
  DateTime get estimatedArrivalTime => throw _privateConstructorUsedError;

  /// The actual time the bus arrived. Matches API 'actual_arrival_time'. Nullable.
  @JsonKey(name: 'actual_arrival_time')
  DateTime? get actualArrivalTime => throw _privateConstructorUsedError;

  /// The current status of this ETA. Matches API 'status'. Required.
  /// Uses [EtaStatus.unknown] as a fallback for robustness.
  @JsonKey(unknownEnumValue: EtaStatus.unknown)
  EtaStatus get status => throw _privateConstructorUsedError;

  /// Estimated delay in minutes (negative if early). Matches API 'delay_minutes'. Nullable.
  @JsonKey(name: 'delay_minutes')
  int? get delayMinutes => throw _privateConstructorUsedError;

  /// Estimated accuracy of the ETA in seconds. Matches API 'accuracy'. Nullable.
  int? get accuracy =>
      throw _privateConstructorUsedError; // API shows integer format: seconds
  /// Flag indicating if this ETA record is active. Matches API 'is_active'. Required.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the ETA record was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the ETA record was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Convenience Fields ---
  /// Name of the associated line. Matches API 'line_name'. Nullable. Read-only.
  @JsonKey(name: 'line_name')
  String? get lineName => throw _privateConstructorUsedError;

  /// Matricule of the associated bus. Matches API 'bus_matricule'. Nullable. Read-only.
  @JsonKey(name: 'bus_matricule')
  String? get busMatricule => throw _privateConstructorUsedError;

  /// Name of the associated stop. Matches API 'stop_name'. Nullable. Read-only.
  @JsonKey(name: 'stop_name')
  String? get stopName => throw _privateConstructorUsedError;

  /// Calculated minutes remaining until arrival. Matches API 'minutes_remaining'. Nullable. Read-only.
  @JsonKey(name: 'minutes_remaining')
  int? get minutesRemaining => throw _privateConstructorUsedError;

  /// Serializes this EtaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EtaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EtaModelCopyWith<EtaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EtaModelCopyWith<$Res> {
  factory $EtaModelCopyWith(EtaModel value, $Res Function(EtaModel) then) =
      _$EtaModelCopyWithImpl<$Res, EtaModel>;
  @useResult
  $Res call(
      {String id,
      String line,
      String bus,
      String stop,
      @JsonKey(name: 'tracking_session') String trackingSession,
      @JsonKey(name: 'estimated_arrival_time') DateTime estimatedArrivalTime,
      @JsonKey(name: 'actual_arrival_time') DateTime? actualArrivalTime,
      @JsonKey(unknownEnumValue: EtaStatus.unknown) EtaStatus status,
      @JsonKey(name: 'delay_minutes') int? delayMinutes,
      int? accuracy,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'line_name') String? lineName,
      @JsonKey(name: 'bus_matricule') String? busMatricule,
      @JsonKey(name: 'stop_name') String? stopName,
      @JsonKey(name: 'minutes_remaining') int? minutesRemaining});
}

/// @nodoc
class _$EtaModelCopyWithImpl<$Res, $Val extends EtaModel>
    implements $EtaModelCopyWith<$Res> {
  _$EtaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EtaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? line = null,
    Object? bus = null,
    Object? stop = null,
    Object? trackingSession = null,
    Object? estimatedArrivalTime = null,
    Object? actualArrivalTime = freezed,
    Object? status = null,
    Object? delayMinutes = freezed,
    Object? accuracy = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lineName = freezed,
    Object? busMatricule = freezed,
    Object? stopName = freezed,
    Object? minutesRemaining = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as String,
      stop: null == stop
          ? _value.stop
          : stop // ignore: cast_nullable_to_non_nullable
              as String,
      trackingSession: null == trackingSession
          ? _value.trackingSession
          : trackingSession // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedArrivalTime: null == estimatedArrivalTime
          ? _value.estimatedArrivalTime
          : estimatedArrivalTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actualArrivalTime: freezed == actualArrivalTime
          ? _value.actualArrivalTime
          : actualArrivalTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EtaStatus,
      delayMinutes: freezed == delayMinutes
          ? _value.delayMinutes
          : delayMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      accuracy: freezed == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as int?,
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
      lineName: freezed == lineName
          ? _value.lineName
          : lineName // ignore: cast_nullable_to_non_nullable
              as String?,
      busMatricule: freezed == busMatricule
          ? _value.busMatricule
          : busMatricule // ignore: cast_nullable_to_non_nullable
              as String?,
      stopName: freezed == stopName
          ? _value.stopName
          : stopName // ignore: cast_nullable_to_non_nullable
              as String?,
      minutesRemaining: freezed == minutesRemaining
          ? _value.minutesRemaining
          : minutesRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EtaModelImplCopyWith<$Res>
    implements $EtaModelCopyWith<$Res> {
  factory _$$EtaModelImplCopyWith(
          _$EtaModelImpl value, $Res Function(_$EtaModelImpl) then) =
      __$$EtaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String line,
      String bus,
      String stop,
      @JsonKey(name: 'tracking_session') String trackingSession,
      @JsonKey(name: 'estimated_arrival_time') DateTime estimatedArrivalTime,
      @JsonKey(name: 'actual_arrival_time') DateTime? actualArrivalTime,
      @JsonKey(unknownEnumValue: EtaStatus.unknown) EtaStatus status,
      @JsonKey(name: 'delay_minutes') int? delayMinutes,
      int? accuracy,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'line_name') String? lineName,
      @JsonKey(name: 'bus_matricule') String? busMatricule,
      @JsonKey(name: 'stop_name') String? stopName,
      @JsonKey(name: 'minutes_remaining') int? minutesRemaining});
}

/// @nodoc
class __$$EtaModelImplCopyWithImpl<$Res>
    extends _$EtaModelCopyWithImpl<$Res, _$EtaModelImpl>
    implements _$$EtaModelImplCopyWith<$Res> {
  __$$EtaModelImplCopyWithImpl(
      _$EtaModelImpl _value, $Res Function(_$EtaModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EtaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? line = null,
    Object? bus = null,
    Object? stop = null,
    Object? trackingSession = null,
    Object? estimatedArrivalTime = null,
    Object? actualArrivalTime = freezed,
    Object? status = null,
    Object? delayMinutes = freezed,
    Object? accuracy = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lineName = freezed,
    Object? busMatricule = freezed,
    Object? stopName = freezed,
    Object? minutesRemaining = freezed,
  }) {
    return _then(_$EtaModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as String,
      stop: null == stop
          ? _value.stop
          : stop // ignore: cast_nullable_to_non_nullable
              as String,
      trackingSession: null == trackingSession
          ? _value.trackingSession
          : trackingSession // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedArrivalTime: null == estimatedArrivalTime
          ? _value.estimatedArrivalTime
          : estimatedArrivalTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actualArrivalTime: freezed == actualArrivalTime
          ? _value.actualArrivalTime
          : actualArrivalTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EtaStatus,
      delayMinutes: freezed == delayMinutes
          ? _value.delayMinutes
          : delayMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      accuracy: freezed == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as int?,
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
      lineName: freezed == lineName
          ? _value.lineName
          : lineName // ignore: cast_nullable_to_non_nullable
              as String?,
      busMatricule: freezed == busMatricule
          ? _value.busMatricule
          : busMatricule // ignore: cast_nullable_to_non_nullable
              as String?,
      stopName: freezed == stopName
          ? _value.stopName
          : stopName // ignore: cast_nullable_to_non_nullable
              as String?,
      minutesRemaining: freezed == minutesRemaining
          ? _value.minutesRemaining
          : minutesRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EtaModelImpl implements _EtaModel {
  const _$EtaModelImpl(
      {required this.id,
      required this.line,
      required this.bus,
      required this.stop,
      @JsonKey(name: 'tracking_session') required this.trackingSession,
      @JsonKey(name: 'estimated_arrival_time')
      required this.estimatedArrivalTime,
      @JsonKey(name: 'actual_arrival_time') this.actualArrivalTime,
      @JsonKey(unknownEnumValue: EtaStatus.unknown) required this.status,
      @JsonKey(name: 'delay_minutes') this.delayMinutes,
      this.accuracy,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'line_name') this.lineName,
      @JsonKey(name: 'bus_matricule') this.busMatricule,
      @JsonKey(name: 'stop_name') this.stopName,
      @JsonKey(name: 'minutes_remaining') this.minutesRemaining});

  factory _$EtaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EtaModelImplFromJson(json);

  /// Unique identifier for the ETA record (UUID). Matches API 'id'. Read-only.
  @override
  final String id;

  /// ID of the associated Line. Matches API 'line'. Required.
  @override
  final String line;
// UUID
  /// ID of the associated Bus. Matches API 'bus'. Required.
  @override
  final String bus;
// UUID
  /// ID of the associated Stop. Matches API 'stop'. Required.
  @override
  final String stop;
// UUID
  /// ID of the associated TrackingSession. Matches API 'tracking_session'. Required.
  @override
  @JsonKey(name: 'tracking_session')
  final String trackingSession;
// UUID
  /// The calculated estimated time of arrival. Matches API 'estimated_arrival_time'. Required.
  @override
  @JsonKey(name: 'estimated_arrival_time')
  final DateTime estimatedArrivalTime;

  /// The actual time the bus arrived. Matches API 'actual_arrival_time'. Nullable.
  @override
  @JsonKey(name: 'actual_arrival_time')
  final DateTime? actualArrivalTime;

  /// The current status of this ETA. Matches API 'status'. Required.
  /// Uses [EtaStatus.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: EtaStatus.unknown)
  final EtaStatus status;

  /// Estimated delay in minutes (negative if early). Matches API 'delay_minutes'. Nullable.
  @override
  @JsonKey(name: 'delay_minutes')
  final int? delayMinutes;

  /// Estimated accuracy of the ETA in seconds. Matches API 'accuracy'. Nullable.
  @override
  final int? accuracy;
// API shows integer format: seconds
  /// Flag indicating if this ETA record is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Timestamp when the ETA record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the ETA record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Convenience Fields ---
  /// Name of the associated line. Matches API 'line_name'. Nullable. Read-only.
  @override
  @JsonKey(name: 'line_name')
  final String? lineName;

  /// Matricule of the associated bus. Matches API 'bus_matricule'. Nullable. Read-only.
  @override
  @JsonKey(name: 'bus_matricule')
  final String? busMatricule;

  /// Name of the associated stop. Matches API 'stop_name'. Nullable. Read-only.
  @override
  @JsonKey(name: 'stop_name')
  final String? stopName;

  /// Calculated minutes remaining until arrival. Matches API 'minutes_remaining'. Nullable. Read-only.
  @override
  @JsonKey(name: 'minutes_remaining')
  final int? minutesRemaining;

  @override
  String toString() {
    return 'EtaModel(id: $id, line: $line, bus: $bus, stop: $stop, trackingSession: $trackingSession, estimatedArrivalTime: $estimatedArrivalTime, actualArrivalTime: $actualArrivalTime, status: $status, delayMinutes: $delayMinutes, accuracy: $accuracy, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, lineName: $lineName, busMatricule: $busMatricule, stopName: $stopName, minutesRemaining: $minutesRemaining)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EtaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.line, line) || other.line == line) &&
            (identical(other.bus, bus) || other.bus == bus) &&
            (identical(other.stop, stop) || other.stop == stop) &&
            (identical(other.trackingSession, trackingSession) ||
                other.trackingSession == trackingSession) &&
            (identical(other.estimatedArrivalTime, estimatedArrivalTime) ||
                other.estimatedArrivalTime == estimatedArrivalTime) &&
            (identical(other.actualArrivalTime, actualArrivalTime) ||
                other.actualArrivalTime == actualArrivalTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.delayMinutes, delayMinutes) ||
                other.delayMinutes == delayMinutes) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lineName, lineName) ||
                other.lineName == lineName) &&
            (identical(other.busMatricule, busMatricule) ||
                other.busMatricule == busMatricule) &&
            (identical(other.stopName, stopName) ||
                other.stopName == stopName) &&
            (identical(other.minutesRemaining, minutesRemaining) ||
                other.minutesRemaining == minutesRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      line,
      bus,
      stop,
      trackingSession,
      estimatedArrivalTime,
      actualArrivalTime,
      status,
      delayMinutes,
      accuracy,
      isActive,
      createdAt,
      updatedAt,
      lineName,
      busMatricule,
      stopName,
      minutesRemaining);

  /// Create a copy of EtaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EtaModelImplCopyWith<_$EtaModelImpl> get copyWith =>
      __$$EtaModelImplCopyWithImpl<_$EtaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EtaModelImplToJson(
      this,
    );
  }
}

abstract class _EtaModel implements EtaModel {
  const factory _EtaModel(
      {required final String id,
      required final String line,
      required final String bus,
      required final String stop,
      @JsonKey(name: 'tracking_session') required final String trackingSession,
      @JsonKey(name: 'estimated_arrival_time')
      required final DateTime estimatedArrivalTime,
      @JsonKey(name: 'actual_arrival_time') final DateTime? actualArrivalTime,
      @JsonKey(unknownEnumValue: EtaStatus.unknown)
      required final EtaStatus status,
      @JsonKey(name: 'delay_minutes') final int? delayMinutes,
      final int? accuracy,
      @JsonKey(name: 'is_active') required final bool isActive,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'line_name') final String? lineName,
      @JsonKey(name: 'bus_matricule') final String? busMatricule,
      @JsonKey(name: 'stop_name') final String? stopName,
      @JsonKey(name: 'minutes_remaining')
      final int? minutesRemaining}) = _$EtaModelImpl;

  factory _EtaModel.fromJson(Map<String, dynamic> json) =
      _$EtaModelImpl.fromJson;

  /// Unique identifier for the ETA record (UUID). Matches API 'id'. Read-only.
  @override
  String get id;

  /// ID of the associated Line. Matches API 'line'. Required.
  @override
  String get line; // UUID
  /// ID of the associated Bus. Matches API 'bus'. Required.
  @override
  String get bus; // UUID
  /// ID of the associated Stop. Matches API 'stop'. Required.
  @override
  String get stop; // UUID
  /// ID of the associated TrackingSession. Matches API 'tracking_session'. Required.
  @override
  @JsonKey(name: 'tracking_session')
  String get trackingSession; // UUID
  /// The calculated estimated time of arrival. Matches API 'estimated_arrival_time'. Required.
  @override
  @JsonKey(name: 'estimated_arrival_time')
  DateTime get estimatedArrivalTime;

  /// The actual time the bus arrived. Matches API 'actual_arrival_time'. Nullable.
  @override
  @JsonKey(name: 'actual_arrival_time')
  DateTime? get actualArrivalTime;

  /// The current status of this ETA. Matches API 'status'. Required.
  /// Uses [EtaStatus.unknown] as a fallback for robustness.
  @override
  @JsonKey(unknownEnumValue: EtaStatus.unknown)
  EtaStatus get status;

  /// Estimated delay in minutes (negative if early). Matches API 'delay_minutes'. Nullable.
  @override
  @JsonKey(name: 'delay_minutes')
  int? get delayMinutes;

  /// Estimated accuracy of the ETA in seconds. Matches API 'accuracy'. Nullable.
  @override
  int? get accuracy; // API shows integer format: seconds
  /// Flag indicating if this ETA record is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Timestamp when the ETA record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the ETA record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Convenience Fields ---
  /// Name of the associated line. Matches API 'line_name'. Nullable. Read-only.
  @override
  @JsonKey(name: 'line_name')
  String? get lineName;

  /// Matricule of the associated bus. Matches API 'bus_matricule'. Nullable. Read-only.
  @override
  @JsonKey(name: 'bus_matricule')
  String? get busMatricule;

  /// Name of the associated stop. Matches API 'stop_name'. Nullable. Read-only.
  @override
  @JsonKey(name: 'stop_name')
  String? get stopName;

  /// Calculated minutes remaining until arrival. Matches API 'minutes_remaining'. Nullable. Read-only.
  @override
  @JsonKey(name: 'minutes_remaining')
  int? get minutesRemaining;

  /// Create a copy of EtaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EtaModelImplCopyWith<_$EtaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
