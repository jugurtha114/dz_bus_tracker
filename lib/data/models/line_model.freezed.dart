// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LineModel _$LineModelFromJson(Map<String, dynamic> json) {
  return _LineModel.fromJson(json);
}

/// @nodoc
mixin _$LineModel {
  /// Unique identifier for the line (UUID). Matches API 'id'.
  String get id => throw _privateConstructorUsedError;

  /// Display name or number of the line. Matches API 'name'. Required.
  String get name => throw _privateConstructorUsedError;

  /// Optional description of the line. Matches API 'description'.
  String? get description => throw _privateConstructorUsedError;

  /// Optional color code (hex string) for the line. Matches API 'color'.
  String? get color => throw _privateConstructorUsedError;

  /// ID of the starting stop. Matches API 'start_location'. Required.
  @JsonKey(name: 'start_location')
  String get startLocation => throw _privateConstructorUsedError;

  /// ID of the ending stop. Matches API 'end_location'. Required.
  @JsonKey(name: 'end_location')
  String get endLocation => throw _privateConstructorUsedError;

  /// GeoJSON representation of the line's path. Matches API 'path'. Optional.
  /// Stored as a dynamic Map.
  Map<String, dynamic>? get path => throw _privateConstructorUsedError;

  /// Estimated duration in minutes. Matches API 'estimated_duration'. Optional.
  @JsonKey(name: 'estimated_duration')
  int? get estimatedDuration => throw _privateConstructorUsedError;

  /// Calculated distance in meters. Matches API 'distance'. Optional.
  double? get distance => throw _privateConstructorUsedError;

  /// Flag indicating if the line is active. Matches API 'is_active'. Required.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the line was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the line was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested/Calculated Fields (often included in list views) ---
  /// Details of the starting stop. Matches API 'start_location_details'. Optional (nullable). Read-only.
  @JsonKey(name: 'start_location_details')
  StopModel? get startLocationDetails => throw _privateConstructorUsedError;

  /// Details of the ending stop. Matches API 'end_location_details'. Optional (nullable). Read-only.
  @JsonKey(name: 'end_location_details')
  StopModel? get endLocationDetails => throw _privateConstructorUsedError;

  /// Total number of stops on this line. Matches API 'stops_count'. Required. Read-only.
  @JsonKey(name: 'stops_count')
  int get stopsCount => throw _privateConstructorUsedError;

  /// Number of buses currently active on this line. Matches API 'active_buses_count'. Required. Read-only.
  @JsonKey(name: 'active_buses_count')
  int get activeBusesCount => throw _privateConstructorUsedError;

  /// Serializes this LineModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LineModelCopyWith<LineModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LineModelCopyWith<$Res> {
  factory $LineModelCopyWith(LineModel value, $Res Function(LineModel) then) =
      _$LineModelCopyWithImpl<$Res, LineModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? color,
      @JsonKey(name: 'start_location') String startLocation,
      @JsonKey(name: 'end_location') String endLocation,
      Map<String, dynamic>? path,
      @JsonKey(name: 'estimated_duration') int? estimatedDuration,
      double? distance,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'start_location_details') StopModel? startLocationDetails,
      @JsonKey(name: 'end_location_details') StopModel? endLocationDetails,
      @JsonKey(name: 'stops_count') int stopsCount,
      @JsonKey(name: 'active_buses_count') int activeBusesCount});

  $StopModelCopyWith<$Res>? get startLocationDetails;
  $StopModelCopyWith<$Res>? get endLocationDetails;
}

/// @nodoc
class _$LineModelCopyWithImpl<$Res, $Val extends LineModel>
    implements $LineModelCopyWith<$Res> {
  _$LineModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LineModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? startLocation = null,
    Object? endLocation = null,
    Object? path = freezed,
    Object? estimatedDuration = freezed,
    Object? distance = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startLocationDetails = freezed,
    Object? endLocationDetails = freezed,
    Object? stopsCount = null,
    Object? activeBusesCount = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      startLocation: null == startLocation
          ? _value.startLocation
          : startLocation // ignore: cast_nullable_to_non_nullable
              as String,
      endLocation: null == endLocation
          ? _value.endLocation
          : endLocation // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
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
      startLocationDetails: freezed == startLocationDetails
          ? _value.startLocationDetails
          : startLocationDetails // ignore: cast_nullable_to_non_nullable
              as StopModel?,
      endLocationDetails: freezed == endLocationDetails
          ? _value.endLocationDetails
          : endLocationDetails // ignore: cast_nullable_to_non_nullable
              as StopModel?,
      stopsCount: null == stopsCount
          ? _value.stopsCount
          : stopsCount // ignore: cast_nullable_to_non_nullable
              as int,
      activeBusesCount: null == activeBusesCount
          ? _value.activeBusesCount
          : activeBusesCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of LineModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StopModelCopyWith<$Res>? get startLocationDetails {
    if (_value.startLocationDetails == null) {
      return null;
    }

    return $StopModelCopyWith<$Res>(_value.startLocationDetails!, (value) {
      return _then(_value.copyWith(startLocationDetails: value) as $Val);
    });
  }

  /// Create a copy of LineModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StopModelCopyWith<$Res>? get endLocationDetails {
    if (_value.endLocationDetails == null) {
      return null;
    }

    return $StopModelCopyWith<$Res>(_value.endLocationDetails!, (value) {
      return _then(_value.copyWith(endLocationDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LineModelImplCopyWith<$Res>
    implements $LineModelCopyWith<$Res> {
  factory _$$LineModelImplCopyWith(
          _$LineModelImpl value, $Res Function(_$LineModelImpl) then) =
      __$$LineModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? color,
      @JsonKey(name: 'start_location') String startLocation,
      @JsonKey(name: 'end_location') String endLocation,
      Map<String, dynamic>? path,
      @JsonKey(name: 'estimated_duration') int? estimatedDuration,
      double? distance,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'start_location_details') StopModel? startLocationDetails,
      @JsonKey(name: 'end_location_details') StopModel? endLocationDetails,
      @JsonKey(name: 'stops_count') int stopsCount,
      @JsonKey(name: 'active_buses_count') int activeBusesCount});

  @override
  $StopModelCopyWith<$Res>? get startLocationDetails;
  @override
  $StopModelCopyWith<$Res>? get endLocationDetails;
}

/// @nodoc
class __$$LineModelImplCopyWithImpl<$Res>
    extends _$LineModelCopyWithImpl<$Res, _$LineModelImpl>
    implements _$$LineModelImplCopyWith<$Res> {
  __$$LineModelImplCopyWithImpl(
      _$LineModelImpl _value, $Res Function(_$LineModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LineModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? startLocation = null,
    Object? endLocation = null,
    Object? path = freezed,
    Object? estimatedDuration = freezed,
    Object? distance = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startLocationDetails = freezed,
    Object? endLocationDetails = freezed,
    Object? stopsCount = null,
    Object? activeBusesCount = null,
  }) {
    return _then(_$LineModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      startLocation: null == startLocation
          ? _value.startLocation
          : startLocation // ignore: cast_nullable_to_non_nullable
              as String,
      endLocation: null == endLocation
          ? _value.endLocation
          : endLocation // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value._path
          : path // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      estimatedDuration: freezed == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
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
      startLocationDetails: freezed == startLocationDetails
          ? _value.startLocationDetails
          : startLocationDetails // ignore: cast_nullable_to_non_nullable
              as StopModel?,
      endLocationDetails: freezed == endLocationDetails
          ? _value.endLocationDetails
          : endLocationDetails // ignore: cast_nullable_to_non_nullable
              as StopModel?,
      stopsCount: null == stopsCount
          ? _value.stopsCount
          : stopsCount // ignore: cast_nullable_to_non_nullable
              as int,
      activeBusesCount: null == activeBusesCount
          ? _value.activeBusesCount
          : activeBusesCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LineModelImpl implements _LineModel {
  const _$LineModelImpl(
      {required this.id,
      required this.name,
      this.description,
      this.color,
      @JsonKey(name: 'start_location') required this.startLocation,
      @JsonKey(name: 'end_location') required this.endLocation,
      final Map<String, dynamic>? path,
      @JsonKey(name: 'estimated_duration') this.estimatedDuration,
      this.distance,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'start_location_details') this.startLocationDetails,
      @JsonKey(name: 'end_location_details') this.endLocationDetails,
      @JsonKey(name: 'stops_count') required this.stopsCount,
      @JsonKey(name: 'active_buses_count') required this.activeBusesCount})
      : _path = path;

  factory _$LineModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineModelImplFromJson(json);

  /// Unique identifier for the line (UUID). Matches API 'id'.
  @override
  final String id;

  /// Display name or number of the line. Matches API 'name'. Required.
  @override
  final String name;

  /// Optional description of the line. Matches API 'description'.
  @override
  final String? description;

  /// Optional color code (hex string) for the line. Matches API 'color'.
  @override
  final String? color;

  /// ID of the starting stop. Matches API 'start_location'. Required.
  @override
  @JsonKey(name: 'start_location')
  final String startLocation;

  /// ID of the ending stop. Matches API 'end_location'. Required.
  @override
  @JsonKey(name: 'end_location')
  final String endLocation;

  /// GeoJSON representation of the line's path. Matches API 'path'. Optional.
  /// Stored as a dynamic Map.
  final Map<String, dynamic>? _path;

  /// GeoJSON representation of the line's path. Matches API 'path'. Optional.
  /// Stored as a dynamic Map.
  @override
  Map<String, dynamic>? get path {
    final value = _path;
    if (value == null) return null;
    if (_path is EqualUnmodifiableMapView) return _path;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Estimated duration in minutes. Matches API 'estimated_duration'. Optional.
  @override
  @JsonKey(name: 'estimated_duration')
  final int? estimatedDuration;

  /// Calculated distance in meters. Matches API 'distance'. Optional.
  @override
  final double? distance;

  /// Flag indicating if the line is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Timestamp when the line was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the line was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested/Calculated Fields (often included in list views) ---
  /// Details of the starting stop. Matches API 'start_location_details'. Optional (nullable). Read-only.
  @override
  @JsonKey(name: 'start_location_details')
  final StopModel? startLocationDetails;

  /// Details of the ending stop. Matches API 'end_location_details'. Optional (nullable). Read-only.
  @override
  @JsonKey(name: 'end_location_details')
  final StopModel? endLocationDetails;

  /// Total number of stops on this line. Matches API 'stops_count'. Required. Read-only.
  @override
  @JsonKey(name: 'stops_count')
  final int stopsCount;

  /// Number of buses currently active on this line. Matches API 'active_buses_count'. Required. Read-only.
  @override
  @JsonKey(name: 'active_buses_count')
  final int activeBusesCount;

  @override
  String toString() {
    return 'LineModel(id: $id, name: $name, description: $description, color: $color, startLocation: $startLocation, endLocation: $endLocation, path: $path, estimatedDuration: $estimatedDuration, distance: $distance, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, startLocationDetails: $startLocationDetails, endLocationDetails: $endLocationDetails, stopsCount: $stopsCount, activeBusesCount: $activeBusesCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.startLocation, startLocation) ||
                other.startLocation == startLocation) &&
            (identical(other.endLocation, endLocation) ||
                other.endLocation == endLocation) &&
            const DeepCollectionEquality().equals(other._path, _path) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startLocationDetails, startLocationDetails) ||
                other.startLocationDetails == startLocationDetails) &&
            (identical(other.endLocationDetails, endLocationDetails) ||
                other.endLocationDetails == endLocationDetails) &&
            (identical(other.stopsCount, stopsCount) ||
                other.stopsCount == stopsCount) &&
            (identical(other.activeBusesCount, activeBusesCount) ||
                other.activeBusesCount == activeBusesCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      color,
      startLocation,
      endLocation,
      const DeepCollectionEquality().hash(_path),
      estimatedDuration,
      distance,
      isActive,
      createdAt,
      updatedAt,
      startLocationDetails,
      endLocationDetails,
      stopsCount,
      activeBusesCount);

  /// Create a copy of LineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LineModelImplCopyWith<_$LineModelImpl> get copyWith =>
      __$$LineModelImplCopyWithImpl<_$LineModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LineModelImplToJson(
      this,
    );
  }
}

abstract class _LineModel implements LineModel {
  const factory _LineModel(
      {required final String id,
      required final String name,
      final String? description,
      final String? color,
      @JsonKey(name: 'start_location') required final String startLocation,
      @JsonKey(name: 'end_location') required final String endLocation,
      final Map<String, dynamic>? path,
      @JsonKey(name: 'estimated_duration') final int? estimatedDuration,
      final double? distance,
      @JsonKey(name: 'is_active') required final bool isActive,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'start_location_details')
      final StopModel? startLocationDetails,
      @JsonKey(name: 'end_location_details')
      final StopModel? endLocationDetails,
      @JsonKey(name: 'stops_count') required final int stopsCount,
      @JsonKey(name: 'active_buses_count')
      required final int activeBusesCount}) = _$LineModelImpl;

  factory _LineModel.fromJson(Map<String, dynamic> json) =
      _$LineModelImpl.fromJson;

  /// Unique identifier for the line (UUID). Matches API 'id'.
  @override
  String get id;

  /// Display name or number of the line. Matches API 'name'. Required.
  @override
  String get name;

  /// Optional description of the line. Matches API 'description'.
  @override
  String? get description;

  /// Optional color code (hex string) for the line. Matches API 'color'.
  @override
  String? get color;

  /// ID of the starting stop. Matches API 'start_location'. Required.
  @override
  @JsonKey(name: 'start_location')
  String get startLocation;

  /// ID of the ending stop. Matches API 'end_location'. Required.
  @override
  @JsonKey(name: 'end_location')
  String get endLocation;

  /// GeoJSON representation of the line's path. Matches API 'path'. Optional.
  /// Stored as a dynamic Map.
  @override
  Map<String, dynamic>? get path;

  /// Estimated duration in minutes. Matches API 'estimated_duration'. Optional.
  @override
  @JsonKey(name: 'estimated_duration')
  int? get estimatedDuration;

  /// Calculated distance in meters. Matches API 'distance'. Optional.
  @override
  double? get distance;

  /// Flag indicating if the line is active. Matches API 'is_active'. Required.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Timestamp when the line was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the line was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime
      get updatedAt; // --- Read-only Nested/Calculated Fields (often included in list views) ---
  /// Details of the starting stop. Matches API 'start_location_details'. Optional (nullable). Read-only.
  @override
  @JsonKey(name: 'start_location_details')
  StopModel? get startLocationDetails;

  /// Details of the ending stop. Matches API 'end_location_details'. Optional (nullable). Read-only.
  @override
  @JsonKey(name: 'end_location_details')
  StopModel? get endLocationDetails;

  /// Total number of stops on this line. Matches API 'stops_count'. Required. Read-only.
  @override
  @JsonKey(name: 'stops_count')
  int get stopsCount;

  /// Number of buses currently active on this line. Matches API 'active_buses_count'. Required. Read-only.
  @override
  @JsonKey(name: 'active_buses_count')
  int get activeBusesCount;

  /// Create a copy of LineModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineModelImplCopyWith<_$LineModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
