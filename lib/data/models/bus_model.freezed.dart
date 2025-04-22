// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BusModel _$BusModelFromJson(Map<String, dynamic> json) {
  return _BusModel.fromJson(json);
}

/// @nodoc
mixin _$BusModel {
  /// Unique identifier for the bus (UUID). Matches API 'id'.
  String get id => throw _privateConstructorUsedError;

  /// ID of the associated driver record. Matches API 'driver'. Required.
  String get driver =>
      throw _privateConstructorUsedError; // Keep as 'driver' matching the API field name (UUID)
  /// The bus's registration number (matricule). Matches API 'matricule'. Required.
  String get matricule => throw _privateConstructorUsedError;

  /// The manufacturer/brand of the bus. Matches API 'brand'. Required.
  String get brand => throw _privateConstructorUsedError;

  /// The specific model of the bus. Matches API 'model'. Required.
  String get model => throw _privateConstructorUsedError;

  /// The manufacturing year. Matches API 'year'. Optional.
  int? get year => throw _privateConstructorUsedError;

  /// The passenger capacity. Matches API 'capacity'. Optional.
  int? get capacity => throw _privateConstructorUsedError;

  /// A general description of the bus. Matches API 'description'. Optional.
  String? get description => throw _privateConstructorUsedError;

  /// Flag indicating if the bus is verified. Matches API 'is_verified'. Read-only.
  @JsonKey(name: 'is_verified')
  bool get isVerified => throw _privateConstructorUsedError;

  /// Timestamp when the bus was last verified. Matches API 'verification_date'. Optional. Read-only.
  @JsonKey(name: 'verification_date')
  DateTime? get verificationDate => throw _privateConstructorUsedError;

  /// Timestamp of the last recorded maintenance. Matches API 'last_maintenance'. Optional. Read-only.
  @JsonKey(name: 'last_maintenance')
  DateTime? get lastMaintenance => throw _privateConstructorUsedError;

  /// Timestamp when the next maintenance is scheduled. Matches API 'next_maintenance'. Optional.
  @JsonKey(name: 'next_maintenance')
  DateTime? get nextMaintenance => throw _privateConstructorUsedError;

  /// Flag indicating if the bus is currently active. Matches API 'is_active'.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the bus record was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the bus record was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // --- Read-only Nested/Calculated Fields ---
  /// List of photos associated with this bus. Matches API 'photos'. Required (can be empty list). Read-only.
  List<BusPhotoModel> get photos => throw _privateConstructorUsedError;

  /// Details of the associated driver record. Matches API 'driver_details'. Required.
  @JsonKey(name: 'driver_details')
  DriverModel get driverDetails => throw _privateConstructorUsedError;

  /// Flag indicating if the bus is currently being tracked. Matches API 'is_tracking'. Required. Read-only.
  @JsonKey(name: 'is_tracking')
  bool get isTracking => throw _privateConstructorUsedError;

  /// Serializes this BusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusModelCopyWith<BusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusModelCopyWith<$Res> {
  factory $BusModelCopyWith(BusModel value, $Res Function(BusModel) then) =
      _$BusModelCopyWithImpl<$Res, BusModel>;
  @useResult
  $Res call(
      {String id,
      String driver,
      String matricule,
      String brand,
      String model,
      int? year,
      int? capacity,
      String? description,
      @JsonKey(name: 'is_verified') bool isVerified,
      @JsonKey(name: 'verification_date') DateTime? verificationDate,
      @JsonKey(name: 'last_maintenance') DateTime? lastMaintenance,
      @JsonKey(name: 'next_maintenance') DateTime? nextMaintenance,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      List<BusPhotoModel> photos,
      @JsonKey(name: 'driver_details') DriverModel driverDetails,
      @JsonKey(name: 'is_tracking') bool isTracking});

  $DriverModelCopyWith<$Res> get driverDetails;
}

/// @nodoc
class _$BusModelCopyWithImpl<$Res, $Val extends BusModel>
    implements $BusModelCopyWith<$Res> {
  _$BusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driver = null,
    Object? matricule = null,
    Object? brand = null,
    Object? model = null,
    Object? year = freezed,
    Object? capacity = freezed,
    Object? description = freezed,
    Object? isVerified = null,
    Object? verificationDate = freezed,
    Object? lastMaintenance = freezed,
    Object? nextMaintenance = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? photos = null,
    Object? driverDetails = null,
    Object? isTracking = null,
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
      matricule: null == matricule
          ? _value.matricule
          : matricule // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      verificationDate: freezed == verificationDate
          ? _value.verificationDate
          : verificationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastMaintenance: freezed == lastMaintenance
          ? _value.lastMaintenance
          : lastMaintenance // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextMaintenance: freezed == nextMaintenance
          ? _value.nextMaintenance
          : nextMaintenance // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<BusPhotoModel>,
      driverDetails: null == driverDetails
          ? _value.driverDetails
          : driverDetails // ignore: cast_nullable_to_non_nullable
              as DriverModel,
      isTracking: null == isTracking
          ? _value.isTracking
          : isTracking // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of BusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DriverModelCopyWith<$Res> get driverDetails {
    return $DriverModelCopyWith<$Res>(_value.driverDetails, (value) {
      return _then(_value.copyWith(driverDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BusModelImplCopyWith<$Res>
    implements $BusModelCopyWith<$Res> {
  factory _$$BusModelImplCopyWith(
          _$BusModelImpl value, $Res Function(_$BusModelImpl) then) =
      __$$BusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driver,
      String matricule,
      String brand,
      String model,
      int? year,
      int? capacity,
      String? description,
      @JsonKey(name: 'is_verified') bool isVerified,
      @JsonKey(name: 'verification_date') DateTime? verificationDate,
      @JsonKey(name: 'last_maintenance') DateTime? lastMaintenance,
      @JsonKey(name: 'next_maintenance') DateTime? nextMaintenance,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      List<BusPhotoModel> photos,
      @JsonKey(name: 'driver_details') DriverModel driverDetails,
      @JsonKey(name: 'is_tracking') bool isTracking});

  @override
  $DriverModelCopyWith<$Res> get driverDetails;
}

/// @nodoc
class __$$BusModelImplCopyWithImpl<$Res>
    extends _$BusModelCopyWithImpl<$Res, _$BusModelImpl>
    implements _$$BusModelImplCopyWith<$Res> {
  __$$BusModelImplCopyWithImpl(
      _$BusModelImpl _value, $Res Function(_$BusModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driver = null,
    Object? matricule = null,
    Object? brand = null,
    Object? model = null,
    Object? year = freezed,
    Object? capacity = freezed,
    Object? description = freezed,
    Object? isVerified = null,
    Object? verificationDate = freezed,
    Object? lastMaintenance = freezed,
    Object? nextMaintenance = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? photos = null,
    Object? driverDetails = null,
    Object? isTracking = null,
  }) {
    return _then(_$BusModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driver: null == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as String,
      matricule: null == matricule
          ? _value.matricule
          : matricule // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      verificationDate: freezed == verificationDate
          ? _value.verificationDate
          : verificationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastMaintenance: freezed == lastMaintenance
          ? _value.lastMaintenance
          : lastMaintenance // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextMaintenance: freezed == nextMaintenance
          ? _value.nextMaintenance
          : nextMaintenance // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<BusPhotoModel>,
      driverDetails: null == driverDetails
          ? _value.driverDetails
          : driverDetails // ignore: cast_nullable_to_non_nullable
              as DriverModel,
      isTracking: null == isTracking
          ? _value.isTracking
          : isTracking // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusModelImpl implements _BusModel {
  const _$BusModelImpl(
      {required this.id,
      required this.driver,
      required this.matricule,
      required this.brand,
      required this.model,
      this.year,
      this.capacity,
      this.description,
      @JsonKey(name: 'is_verified') required this.isVerified,
      @JsonKey(name: 'verification_date') this.verificationDate,
      @JsonKey(name: 'last_maintenance') this.lastMaintenance,
      @JsonKey(name: 'next_maintenance') this.nextMaintenance,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      required final List<BusPhotoModel> photos,
      @JsonKey(name: 'driver_details') required this.driverDetails,
      @JsonKey(name: 'is_tracking') required this.isTracking})
      : _photos = photos;

  factory _$BusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusModelImplFromJson(json);

  /// Unique identifier for the bus (UUID). Matches API 'id'.
  @override
  final String id;

  /// ID of the associated driver record. Matches API 'driver'. Required.
  @override
  final String driver;
// Keep as 'driver' matching the API field name (UUID)
  /// The bus's registration number (matricule). Matches API 'matricule'. Required.
  @override
  final String matricule;

  /// The manufacturer/brand of the bus. Matches API 'brand'. Required.
  @override
  final String brand;

  /// The specific model of the bus. Matches API 'model'. Required.
  @override
  final String model;

  /// The manufacturing year. Matches API 'year'. Optional.
  @override
  final int? year;

  /// The passenger capacity. Matches API 'capacity'. Optional.
  @override
  final int? capacity;

  /// A general description of the bus. Matches API 'description'. Optional.
  @override
  final String? description;

  /// Flag indicating if the bus is verified. Matches API 'is_verified'. Read-only.
  @override
  @JsonKey(name: 'is_verified')
  final bool isVerified;

  /// Timestamp when the bus was last verified. Matches API 'verification_date'. Optional. Read-only.
  @override
  @JsonKey(name: 'verification_date')
  final DateTime? verificationDate;

  /// Timestamp of the last recorded maintenance. Matches API 'last_maintenance'. Optional. Read-only.
  @override
  @JsonKey(name: 'last_maintenance')
  final DateTime? lastMaintenance;

  /// Timestamp when the next maintenance is scheduled. Matches API 'next_maintenance'. Optional.
  @override
  @JsonKey(name: 'next_maintenance')
  final DateTime? nextMaintenance;

  /// Flag indicating if the bus is currently active. Matches API 'is_active'.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Timestamp when the bus record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the bus record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// --- Read-only Nested/Calculated Fields ---
  /// List of photos associated with this bus. Matches API 'photos'. Required (can be empty list). Read-only.
  final List<BusPhotoModel> _photos;
// --- Read-only Nested/Calculated Fields ---
  /// List of photos associated with this bus. Matches API 'photos'. Required (can be empty list). Read-only.
  @override
  List<BusPhotoModel> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  /// Details of the associated driver record. Matches API 'driver_details'. Required.
  @override
  @JsonKey(name: 'driver_details')
  final DriverModel driverDetails;

  /// Flag indicating if the bus is currently being tracked. Matches API 'is_tracking'. Required. Read-only.
  @override
  @JsonKey(name: 'is_tracking')
  final bool isTracking;

  @override
  String toString() {
    return 'BusModel(id: $id, driver: $driver, matricule: $matricule, brand: $brand, model: $model, year: $year, capacity: $capacity, description: $description, isVerified: $isVerified, verificationDate: $verificationDate, lastMaintenance: $lastMaintenance, nextMaintenance: $nextMaintenance, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, photos: $photos, driverDetails: $driverDetails, isTracking: $isTracking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.matricule, matricule) ||
                other.matricule == matricule) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.verificationDate, verificationDate) ||
                other.verificationDate == verificationDate) &&
            (identical(other.lastMaintenance, lastMaintenance) ||
                other.lastMaintenance == lastMaintenance) &&
            (identical(other.nextMaintenance, nextMaintenance) ||
                other.nextMaintenance == nextMaintenance) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.driverDetails, driverDetails) ||
                other.driverDetails == driverDetails) &&
            (identical(other.isTracking, isTracking) ||
                other.isTracking == isTracking));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      driver,
      matricule,
      brand,
      model,
      year,
      capacity,
      description,
      isVerified,
      verificationDate,
      lastMaintenance,
      nextMaintenance,
      isActive,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_photos),
      driverDetails,
      isTracking);

  /// Create a copy of BusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusModelImplCopyWith<_$BusModelImpl> get copyWith =>
      __$$BusModelImplCopyWithImpl<_$BusModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusModelImplToJson(
      this,
    );
  }
}

abstract class _BusModel implements BusModel {
  const factory _BusModel(
      {required final String id,
      required final String driver,
      required final String matricule,
      required final String brand,
      required final String model,
      final int? year,
      final int? capacity,
      final String? description,
      @JsonKey(name: 'is_verified') required final bool isVerified,
      @JsonKey(name: 'verification_date') final DateTime? verificationDate,
      @JsonKey(name: 'last_maintenance') final DateTime? lastMaintenance,
      @JsonKey(name: 'next_maintenance') final DateTime? nextMaintenance,
      @JsonKey(name: 'is_active') required final bool isActive,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      required final List<BusPhotoModel> photos,
      @JsonKey(name: 'driver_details') required final DriverModel driverDetails,
      @JsonKey(name: 'is_tracking')
      required final bool isTracking}) = _$BusModelImpl;

  factory _BusModel.fromJson(Map<String, dynamic> json) =
      _$BusModelImpl.fromJson;

  /// Unique identifier for the bus (UUID). Matches API 'id'.
  @override
  String get id;

  /// ID of the associated driver record. Matches API 'driver'. Required.
  @override
  String get driver; // Keep as 'driver' matching the API field name (UUID)
  /// The bus's registration number (matricule). Matches API 'matricule'. Required.
  @override
  String get matricule;

  /// The manufacturer/brand of the bus. Matches API 'brand'. Required.
  @override
  String get brand;

  /// The specific model of the bus. Matches API 'model'. Required.
  @override
  String get model;

  /// The manufacturing year. Matches API 'year'. Optional.
  @override
  int? get year;

  /// The passenger capacity. Matches API 'capacity'. Optional.
  @override
  int? get capacity;

  /// A general description of the bus. Matches API 'description'. Optional.
  @override
  String? get description;

  /// Flag indicating if the bus is verified. Matches API 'is_verified'. Read-only.
  @override
  @JsonKey(name: 'is_verified')
  bool get isVerified;

  /// Timestamp when the bus was last verified. Matches API 'verification_date'. Optional. Read-only.
  @override
  @JsonKey(name: 'verification_date')
  DateTime? get verificationDate;

  /// Timestamp of the last recorded maintenance. Matches API 'last_maintenance'. Optional. Read-only.
  @override
  @JsonKey(name: 'last_maintenance')
  DateTime? get lastMaintenance;

  /// Timestamp when the next maintenance is scheduled. Matches API 'next_maintenance'. Optional.
  @override
  @JsonKey(name: 'next_maintenance')
  DateTime? get nextMaintenance;

  /// Flag indicating if the bus is currently active. Matches API 'is_active'.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Timestamp when the bus record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the bus record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // --- Read-only Nested/Calculated Fields ---
  /// List of photos associated with this bus. Matches API 'photos'. Required (can be empty list). Read-only.
  @override
  List<BusPhotoModel> get photos;

  /// Details of the associated driver record. Matches API 'driver_details'. Required.
  @override
  @JsonKey(name: 'driver_details')
  DriverModel get driverDetails;

  /// Flag indicating if the bus is currently being tracked. Matches API 'is_tracking'. Required. Read-only.
  @override
  @JsonKey(name: 'is_tracking')
  bool get isTracking;

  /// Create a copy of BusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusModelImplCopyWith<_$BusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
