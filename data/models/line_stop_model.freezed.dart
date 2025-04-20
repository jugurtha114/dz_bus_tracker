// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_stop_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LineStopModel _$LineStopModelFromJson(Map<String, dynamic> json) {
  return _LineStopModel.fromJson(json);
}

/// @nodoc
mixin _$LineStopModel {
  /// Unique identifier for the line-stop association (UUID). Matches API 'id'.
  String get id => throw _privateConstructorUsedError;

  /// ID of the associated Line. Matches API 'line'. Required.
  String get line =>
      throw _privateConstructorUsedError; // Keep as 'line' matching the API field name (UUID)
  /// ID of the associated Stop. Matches API 'stop'. Required.
  String get stop =>
      throw _privateConstructorUsedError; // Keep as 'stop' matching the API field name (UUID)
  /// The order of this stop within the line sequence (starting from 0 or 1 based on API). Matches API 'order'. Required.
  int get order => throw _privateConstructorUsedError;

  /// Optional distance from the start of the line to this stop in meters. Matches API 'distance_from_start'.
  @JsonKey(name: 'distance_from_start')
  double? get distanceFromStart => throw _privateConstructorUsedError;

  /// Optional estimated time from the start of the line to this stop in minutes. Matches API 'estimated_time_from_start'.
  @JsonKey(name: 'estimated_time_from_start')
  int? get estimatedTimeFromStart => throw _privateConstructorUsedError;

  /// Timestamp when the association was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the association was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested Field ---
  /// Detailed information about the associated stop. Matches API 'stop_details'. Optional (nullable). Read-only.
  @JsonKey(name: 'stop_details')
  StopModel? get stopDetails => throw _privateConstructorUsedError;

  /// Serializes this LineStopModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LineStopModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LineStopModelCopyWith<LineStopModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LineStopModelCopyWith<$Res> {
  factory $LineStopModelCopyWith(
          LineStopModel value, $Res Function(LineStopModel) then) =
      _$LineStopModelCopyWithImpl<$Res, LineStopModel>;
  @useResult
  $Res call(
      {String id,
      String line,
      String stop,
      int order,
      @JsonKey(name: 'distance_from_start') double? distanceFromStart,
      @JsonKey(name: 'estimated_time_from_start') int? estimatedTimeFromStart,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'stop_details') StopModel? stopDetails});

  $StopModelCopyWith<$Res>? get stopDetails;
}

/// @nodoc
class _$LineStopModelCopyWithImpl<$Res, $Val extends LineStopModel>
    implements $LineStopModelCopyWith<$Res> {
  _$LineStopModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LineStopModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? line = null,
    Object? stop = null,
    Object? order = null,
    Object? distanceFromStart = freezed,
    Object? estimatedTimeFromStart = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? stopDetails = freezed,
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
      stop: null == stop
          ? _value.stop
          : stop // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      distanceFromStart: freezed == distanceFromStart
          ? _value.distanceFromStart
          : distanceFromStart // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedTimeFromStart: freezed == estimatedTimeFromStart
          ? _value.estimatedTimeFromStart
          : estimatedTimeFromStart // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      stopDetails: freezed == stopDetails
          ? _value.stopDetails
          : stopDetails // ignore: cast_nullable_to_non_nullable
              as StopModel?,
    ) as $Val);
  }

  /// Create a copy of LineStopModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StopModelCopyWith<$Res>? get stopDetails {
    if (_value.stopDetails == null) {
      return null;
    }

    return $StopModelCopyWith<$Res>(_value.stopDetails!, (value) {
      return _then(_value.copyWith(stopDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LineStopModelImplCopyWith<$Res>
    implements $LineStopModelCopyWith<$Res> {
  factory _$$LineStopModelImplCopyWith(
          _$LineStopModelImpl value, $Res Function(_$LineStopModelImpl) then) =
      __$$LineStopModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String line,
      String stop,
      int order,
      @JsonKey(name: 'distance_from_start') double? distanceFromStart,
      @JsonKey(name: 'estimated_time_from_start') int? estimatedTimeFromStart,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'stop_details') StopModel? stopDetails});

  @override
  $StopModelCopyWith<$Res>? get stopDetails;
}

/// @nodoc
class __$$LineStopModelImplCopyWithImpl<$Res>
    extends _$LineStopModelCopyWithImpl<$Res, _$LineStopModelImpl>
    implements _$$LineStopModelImplCopyWith<$Res> {
  __$$LineStopModelImplCopyWithImpl(
      _$LineStopModelImpl _value, $Res Function(_$LineStopModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LineStopModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? line = null,
    Object? stop = null,
    Object? order = null,
    Object? distanceFromStart = freezed,
    Object? estimatedTimeFromStart = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? stopDetails = freezed,
  }) {
    return _then(_$LineStopModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as String,
      stop: null == stop
          ? _value.stop
          : stop // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      distanceFromStart: freezed == distanceFromStart
          ? _value.distanceFromStart
          : distanceFromStart // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedTimeFromStart: freezed == estimatedTimeFromStart
          ? _value.estimatedTimeFromStart
          : estimatedTimeFromStart // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      stopDetails: freezed == stopDetails
          ? _value.stopDetails
          : stopDetails // ignore: cast_nullable_to_non_nullable
              as StopModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LineStopModelImpl implements _LineStopModel {
  const _$LineStopModelImpl(
      {required this.id,
      required this.line,
      required this.stop,
      required this.order,
      @JsonKey(name: 'distance_from_start') this.distanceFromStart,
      @JsonKey(name: 'estimated_time_from_start') this.estimatedTimeFromStart,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'stop_details') this.stopDetails});

  factory _$LineStopModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineStopModelImplFromJson(json);

  /// Unique identifier for the line-stop association (UUID). Matches API 'id'.
  @override
  final String id;

  /// ID of the associated Line. Matches API 'line'. Required.
  @override
  final String line;
// Keep as 'line' matching the API field name (UUID)
  /// ID of the associated Stop. Matches API 'stop'. Required.
  @override
  final String stop;
// Keep as 'stop' matching the API field name (UUID)
  /// The order of this stop within the line sequence (starting from 0 or 1 based on API). Matches API 'order'. Required.
  @override
  final int order;

  /// Optional distance from the start of the line to this stop in meters. Matches API 'distance_from_start'.
  @override
  @JsonKey(name: 'distance_from_start')
  final double? distanceFromStart;

  /// Optional estimated time from the start of the line to this stop in minutes. Matches API 'estimated_time_from_start'.
  @override
  @JsonKey(name: 'estimated_time_from_start')
  final int? estimatedTimeFromStart;

  /// Timestamp when the association was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the association was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested Field ---
  /// Detailed information about the associated stop. Matches API 'stop_details'. Optional (nullable). Read-only.
  @override
  @JsonKey(name: 'stop_details')
  final StopModel? stopDetails;

  @override
  String toString() {
    return 'LineStopModel(id: $id, line: $line, stop: $stop, order: $order, distanceFromStart: $distanceFromStart, estimatedTimeFromStart: $estimatedTimeFromStart, createdAt: $createdAt, updatedAt: $updatedAt, stopDetails: $stopDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineStopModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.line, line) || other.line == line) &&
            (identical(other.stop, stop) || other.stop == stop) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.distanceFromStart, distanceFromStart) ||
                other.distanceFromStart == distanceFromStart) &&
            (identical(other.estimatedTimeFromStart, estimatedTimeFromStart) ||
                other.estimatedTimeFromStart == estimatedTimeFromStart) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.stopDetails, stopDetails) ||
                other.stopDetails == stopDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      line,
      stop,
      order,
      distanceFromStart,
      estimatedTimeFromStart,
      createdAt,
      updatedAt,
      stopDetails);

  /// Create a copy of LineStopModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LineStopModelImplCopyWith<_$LineStopModelImpl> get copyWith =>
      __$$LineStopModelImplCopyWithImpl<_$LineStopModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LineStopModelImplToJson(
      this,
    );
  }
}

abstract class _LineStopModel implements LineStopModel {
  const factory _LineStopModel(
          {required final String id,
          required final String line,
          required final String stop,
          required final int order,
          @JsonKey(name: 'distance_from_start') final double? distanceFromStart,
          @JsonKey(name: 'estimated_time_from_start')
          final int? estimatedTimeFromStart,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt,
          @JsonKey(name: 'stop_details') final StopModel? stopDetails}) =
      _$LineStopModelImpl;

  factory _LineStopModel.fromJson(Map<String, dynamic> json) =
      _$LineStopModelImpl.fromJson;

  /// Unique identifier for the line-stop association (UUID). Matches API 'id'.
  @override
  String get id;

  /// ID of the associated Line. Matches API 'line'. Required.
  @override
  String get line; // Keep as 'line' matching the API field name (UUID)
  /// ID of the associated Stop. Matches API 'stop'. Required.
  @override
  String get stop; // Keep as 'stop' matching the API field name (UUID)
  /// The order of this stop within the line sequence (starting from 0 or 1 based on API). Matches API 'order'. Required.
  @override
  int get order;

  /// Optional distance from the start of the line to this stop in meters. Matches API 'distance_from_start'.
  @override
  @JsonKey(name: 'distance_from_start')
  double? get distanceFromStart;

  /// Optional estimated time from the start of the line to this stop in minutes. Matches API 'estimated_time_from_start'.
  @override
  @JsonKey(name: 'estimated_time_from_start')
  int? get estimatedTimeFromStart;

  /// Timestamp when the association was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the association was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Nested Field ---
  /// Detailed information about the associated stop. Matches API 'stop_details'. Optional (nullable). Read-only.
  @override
  @JsonKey(name: 'stop_details')
  StopModel? get stopDetails;

  /// Create a copy of LineStopModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineStopModelImplCopyWith<_$LineStopModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
