// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LineDetailModel _$LineDetailModelFromJson(Map<String, dynamic> json) {
  return _LineDetailModel.fromJson(json);
}

/// @nodoc
mixin _$LineDetailModel {
// Fields inherited/duplicated from LineModel schema
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_location')
  String get startLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_location')
  String get endLocation => throw _privateConstructorUsedError;
  Map<String, dynamic>? get path => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_duration')
  int? get estimatedDuration => throw _privateConstructorUsedError;
  double? get distance => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_location_details')
  StopModel? get startLocationDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_location_details')
  StopModel? get endLocationDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'stops_count')
  int get stopsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_buses_count')
  int get activeBusesCount =>
      throw _privateConstructorUsedError; // Fields specific to LineDetail schema
  /// Ordered list of stops associated with the line, including sequence info. Matches API 'stops'. Required.
  List<LineStopModel> get stops => throw _privateConstructorUsedError;

  /// List of buses currently assigned to or active on this line. Matches API 'buses'. Required.
  List<BusModel> get buses => throw _privateConstructorUsedError;

  /// Serializes this LineDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LineDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LineDetailModelCopyWith<LineDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LineDetailModelCopyWith<$Res> {
  factory $LineDetailModelCopyWith(
          LineDetailModel value, $Res Function(LineDetailModel) then) =
      _$LineDetailModelCopyWithImpl<$Res, LineDetailModel>;
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
      @JsonKey(name: 'active_buses_count') int activeBusesCount,
      List<LineStopModel> stops,
      List<BusModel> buses});

  $StopModelCopyWith<$Res>? get startLocationDetails;
  $StopModelCopyWith<$Res>? get endLocationDetails;
}

/// @nodoc
class _$LineDetailModelCopyWithImpl<$Res, $Val extends LineDetailModel>
    implements $LineDetailModelCopyWith<$Res> {
  _$LineDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LineDetailModel
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
    Object? stops = null,
    Object? buses = null,
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
      stops: null == stops
          ? _value.stops
          : stops // ignore: cast_nullable_to_non_nullable
              as List<LineStopModel>,
      buses: null == buses
          ? _value.buses
          : buses // ignore: cast_nullable_to_non_nullable
              as List<BusModel>,
    ) as $Val);
  }

  /// Create a copy of LineDetailModel
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

  /// Create a copy of LineDetailModel
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
abstract class _$$LineDetailModelImplCopyWith<$Res>
    implements $LineDetailModelCopyWith<$Res> {
  factory _$$LineDetailModelImplCopyWith(_$LineDetailModelImpl value,
          $Res Function(_$LineDetailModelImpl) then) =
      __$$LineDetailModelImplCopyWithImpl<$Res>;
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
      @JsonKey(name: 'active_buses_count') int activeBusesCount,
      List<LineStopModel> stops,
      List<BusModel> buses});

  @override
  $StopModelCopyWith<$Res>? get startLocationDetails;
  @override
  $StopModelCopyWith<$Res>? get endLocationDetails;
}

/// @nodoc
class __$$LineDetailModelImplCopyWithImpl<$Res>
    extends _$LineDetailModelCopyWithImpl<$Res, _$LineDetailModelImpl>
    implements _$$LineDetailModelImplCopyWith<$Res> {
  __$$LineDetailModelImplCopyWithImpl(
      _$LineDetailModelImpl _value, $Res Function(_$LineDetailModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LineDetailModel
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
    Object? stops = null,
    Object? buses = null,
  }) {
    return _then(_$LineDetailModelImpl(
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
      stops: null == stops
          ? _value._stops
          : stops // ignore: cast_nullable_to_non_nullable
              as List<LineStopModel>,
      buses: null == buses
          ? _value._buses
          : buses // ignore: cast_nullable_to_non_nullable
              as List<BusModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LineDetailModelImpl implements _LineDetailModel {
  const _$LineDetailModelImpl(
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
      @JsonKey(name: 'active_buses_count') required this.activeBusesCount,
      required final List<LineStopModel> stops,
      required final List<BusModel> buses})
      : _path = path,
        _stops = stops,
        _buses = buses;

  factory _$LineDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineDetailModelImplFromJson(json);

// Fields inherited/duplicated from LineModel schema
  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? color;
  @override
  @JsonKey(name: 'start_location')
  final String startLocation;
  @override
  @JsonKey(name: 'end_location')
  final String endLocation;
  final Map<String, dynamic>? _path;
  @override
  Map<String, dynamic>? get path {
    final value = _path;
    if (value == null) return null;
    if (_path is EqualUnmodifiableMapView) return _path;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'estimated_duration')
  final int? estimatedDuration;
  @override
  final double? distance;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'start_location_details')
  final StopModel? startLocationDetails;
  @override
  @JsonKey(name: 'end_location_details')
  final StopModel? endLocationDetails;
  @override
  @JsonKey(name: 'stops_count')
  final int stopsCount;
  @override
  @JsonKey(name: 'active_buses_count')
  final int activeBusesCount;
// Fields specific to LineDetail schema
  /// Ordered list of stops associated with the line, including sequence info. Matches API 'stops'. Required.
  final List<LineStopModel> _stops;
// Fields specific to LineDetail schema
  /// Ordered list of stops associated with the line, including sequence info. Matches API 'stops'. Required.
  @override
  List<LineStopModel> get stops {
    if (_stops is EqualUnmodifiableListView) return _stops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stops);
  }

  /// List of buses currently assigned to or active on this line. Matches API 'buses'. Required.
  final List<BusModel> _buses;

  /// List of buses currently assigned to or active on this line. Matches API 'buses'. Required.
  @override
  List<BusModel> get buses {
    if (_buses is EqualUnmodifiableListView) return _buses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_buses);
  }

  @override
  String toString() {
    return 'LineDetailModel(id: $id, name: $name, description: $description, color: $color, startLocation: $startLocation, endLocation: $endLocation, path: $path, estimatedDuration: $estimatedDuration, distance: $distance, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, startLocationDetails: $startLocationDetails, endLocationDetails: $endLocationDetails, stopsCount: $stopsCount, activeBusesCount: $activeBusesCount, stops: $stops, buses: $buses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineDetailModelImpl &&
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
                other.activeBusesCount == activeBusesCount) &&
            const DeepCollectionEquality().equals(other._stops, _stops) &&
            const DeepCollectionEquality().equals(other._buses, _buses));
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
      activeBusesCount,
      const DeepCollectionEquality().hash(_stops),
      const DeepCollectionEquality().hash(_buses));

  /// Create a copy of LineDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LineDetailModelImplCopyWith<_$LineDetailModelImpl> get copyWith =>
      __$$LineDetailModelImplCopyWithImpl<_$LineDetailModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LineDetailModelImplToJson(
      this,
    );
  }
}

abstract class _LineDetailModel implements LineDetailModel {
  const factory _LineDetailModel(
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
      @JsonKey(name: 'active_buses_count') required final int activeBusesCount,
      required final List<LineStopModel> stops,
      required final List<BusModel> buses}) = _$LineDetailModelImpl;

  factory _LineDetailModel.fromJson(Map<String, dynamic> json) =
      _$LineDetailModelImpl.fromJson;

// Fields inherited/duplicated from LineModel schema
  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get color;
  @override
  @JsonKey(name: 'start_location')
  String get startLocation;
  @override
  @JsonKey(name: 'end_location')
  String get endLocation;
  @override
  Map<String, dynamic>? get path;
  @override
  @JsonKey(name: 'estimated_duration')
  int? get estimatedDuration;
  @override
  double? get distance;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'start_location_details')
  StopModel? get startLocationDetails;
  @override
  @JsonKey(name: 'end_location_details')
  StopModel? get endLocationDetails;
  @override
  @JsonKey(name: 'stops_count')
  int get stopsCount;
  @override
  @JsonKey(name: 'active_buses_count')
  int get activeBusesCount; // Fields specific to LineDetail schema
  /// Ordered list of stops associated with the line, including sequence info. Matches API 'stops'. Required.
  @override
  List<LineStopModel> get stops;

  /// List of buses currently assigned to or active on this line. Matches API 'buses'. Required.
  @override
  List<BusModel> get buses;

  /// Create a copy of LineDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineDetailModelImplCopyWith<_$LineDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
