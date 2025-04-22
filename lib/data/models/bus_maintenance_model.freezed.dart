// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_maintenance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BusMaintenanceModel _$BusMaintenanceModelFromJson(Map<String, dynamic> json) {
  return _BusMaintenanceModel.fromJson(json);
}

/// @nodoc
mixin _$BusMaintenanceModel {
  /// Unique identifier for the maintenance record (UUID). Matches API 'id'. Read-only.
  String get id => throw _privateConstructorUsedError;

  /// ID of the bus this maintenance record belongs to. Matches API 'bus'. Required.
  String get bus => throw _privateConstructorUsedError; // UUID
  /// The type of maintenance performed. Matches API 'maintenance_type'. Required.
  /// Uses [MaintenanceType.unknown] as a fallback.
  @JsonKey(name: 'maintenance_type', unknownEnumValue: MaintenanceType.unknown)
  MaintenanceType get maintenanceType => throw _privateConstructorUsedError;

  /// The date the maintenance was performed. Matches API 'date_performed'. Required.
  @JsonKey(name: 'date_performed')
  DateTime get datePerformed => throw _privateConstructorUsedError;

  /// Description of the work done. Matches API 'description'. Required.
  String get description => throw _privateConstructorUsedError;

  /// Optional cost associated with the maintenance. Matches API 'cost'. API shows string format (decimal).
  String? get cost =>
      throw _privateConstructorUsedError; // Keep as String to match API, parse later if needed
  /// Optional date when the next maintenance is due. Matches API 'next_maintenance_due'. Nullable.
  @JsonKey(name: 'next_maintenance_due')
  DateTime? get nextMaintenanceDue => throw _privateConstructorUsedError;

  /// Timestamp when the record was created. Matches API 'created_at'. Read-only.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when the record was last updated. Matches API 'updated_at'. Read-only.
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BusMaintenanceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusMaintenanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusMaintenanceModelCopyWith<BusMaintenanceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusMaintenanceModelCopyWith<$Res> {
  factory $BusMaintenanceModelCopyWith(
          BusMaintenanceModel value, $Res Function(BusMaintenanceModel) then) =
      _$BusMaintenanceModelCopyWithImpl<$Res, BusMaintenanceModel>;
  @useResult
  $Res call(
      {String id,
      String bus,
      @JsonKey(
          name: 'maintenance_type', unknownEnumValue: MaintenanceType.unknown)
      MaintenanceType maintenanceType,
      @JsonKey(name: 'date_performed') DateTime datePerformed,
      String description,
      String? cost,
      @JsonKey(name: 'next_maintenance_due') DateTime? nextMaintenanceDue,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$BusMaintenanceModelCopyWithImpl<$Res, $Val extends BusMaintenanceModel>
    implements $BusMaintenanceModelCopyWith<$Res> {
  _$BusMaintenanceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusMaintenanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bus = null,
    Object? maintenanceType = null,
    Object? datePerformed = null,
    Object? description = null,
    Object? cost = freezed,
    Object? nextMaintenanceDue = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      maintenanceType: null == maintenanceType
          ? _value.maintenanceType
          : maintenanceType // ignore: cast_nullable_to_non_nullable
              as MaintenanceType,
      datePerformed: null == datePerformed
          ? _value.datePerformed
          : datePerformed // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as String?,
      nextMaintenanceDue: freezed == nextMaintenanceDue
          ? _value.nextMaintenanceDue
          : nextMaintenanceDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$BusMaintenanceModelImplCopyWith<$Res>
    implements $BusMaintenanceModelCopyWith<$Res> {
  factory _$$BusMaintenanceModelImplCopyWith(_$BusMaintenanceModelImpl value,
          $Res Function(_$BusMaintenanceModelImpl) then) =
      __$$BusMaintenanceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String bus,
      @JsonKey(
          name: 'maintenance_type', unknownEnumValue: MaintenanceType.unknown)
      MaintenanceType maintenanceType,
      @JsonKey(name: 'date_performed') DateTime datePerformed,
      String description,
      String? cost,
      @JsonKey(name: 'next_maintenance_due') DateTime? nextMaintenanceDue,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$BusMaintenanceModelImplCopyWithImpl<$Res>
    extends _$BusMaintenanceModelCopyWithImpl<$Res, _$BusMaintenanceModelImpl>
    implements _$$BusMaintenanceModelImplCopyWith<$Res> {
  __$$BusMaintenanceModelImplCopyWithImpl(_$BusMaintenanceModelImpl _value,
      $Res Function(_$BusMaintenanceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusMaintenanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bus = null,
    Object? maintenanceType = null,
    Object? datePerformed = null,
    Object? description = null,
    Object? cost = freezed,
    Object? nextMaintenanceDue = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$BusMaintenanceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as String,
      maintenanceType: null == maintenanceType
          ? _value.maintenanceType
          : maintenanceType // ignore: cast_nullable_to_non_nullable
              as MaintenanceType,
      datePerformed: null == datePerformed
          ? _value.datePerformed
          : datePerformed // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as String?,
      nextMaintenanceDue: freezed == nextMaintenanceDue
          ? _value.nextMaintenanceDue
          : nextMaintenanceDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$BusMaintenanceModelImpl implements _BusMaintenanceModel {
  const _$BusMaintenanceModelImpl(
      {required this.id,
      required this.bus,
      @JsonKey(
          name: 'maintenance_type', unknownEnumValue: MaintenanceType.unknown)
      required this.maintenanceType,
      @JsonKey(name: 'date_performed') required this.datePerformed,
      required this.description,
      this.cost,
      @JsonKey(name: 'next_maintenance_due') this.nextMaintenanceDue,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$BusMaintenanceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusMaintenanceModelImplFromJson(json);

  /// Unique identifier for the maintenance record (UUID). Matches API 'id'. Read-only.
  @override
  final String id;

  /// ID of the bus this maintenance record belongs to. Matches API 'bus'. Required.
  @override
  final String bus;
// UUID
  /// The type of maintenance performed. Matches API 'maintenance_type'. Required.
  /// Uses [MaintenanceType.unknown] as a fallback.
  @override
  @JsonKey(name: 'maintenance_type', unknownEnumValue: MaintenanceType.unknown)
  final MaintenanceType maintenanceType;

  /// The date the maintenance was performed. Matches API 'date_performed'. Required.
  @override
  @JsonKey(name: 'date_performed')
  final DateTime datePerformed;

  /// Description of the work done. Matches API 'description'. Required.
  @override
  final String description;

  /// Optional cost associated with the maintenance. Matches API 'cost'. API shows string format (decimal).
  @override
  final String? cost;
// Keep as String to match API, parse later if needed
  /// Optional date when the next maintenance is due. Matches API 'next_maintenance_due'. Nullable.
  @override
  @JsonKey(name: 'next_maintenance_due')
  final DateTime? nextMaintenanceDue;

  /// Timestamp when the record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'BusMaintenanceModel(id: $id, bus: $bus, maintenanceType: $maintenanceType, datePerformed: $datePerformed, description: $description, cost: $cost, nextMaintenanceDue: $nextMaintenanceDue, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusMaintenanceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bus, bus) || other.bus == bus) &&
            (identical(other.maintenanceType, maintenanceType) ||
                other.maintenanceType == maintenanceType) &&
            (identical(other.datePerformed, datePerformed) ||
                other.datePerformed == datePerformed) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.nextMaintenanceDue, nextMaintenanceDue) ||
                other.nextMaintenanceDue == nextMaintenanceDue) &&
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
      bus,
      maintenanceType,
      datePerformed,
      description,
      cost,
      nextMaintenanceDue,
      createdAt,
      updatedAt);

  /// Create a copy of BusMaintenanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusMaintenanceModelImplCopyWith<_$BusMaintenanceModelImpl> get copyWith =>
      __$$BusMaintenanceModelImplCopyWithImpl<_$BusMaintenanceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusMaintenanceModelImplToJson(
      this,
    );
  }
}

abstract class _BusMaintenanceModel implements BusMaintenanceModel {
  const factory _BusMaintenanceModel(
      {required final String id,
      required final String bus,
      @JsonKey(
          name: 'maintenance_type', unknownEnumValue: MaintenanceType.unknown)
      required final MaintenanceType maintenanceType,
      @JsonKey(name: 'date_performed') required final DateTime datePerformed,
      required final String description,
      final String? cost,
      @JsonKey(name: 'next_maintenance_due') final DateTime? nextMaintenanceDue,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      required final DateTime updatedAt}) = _$BusMaintenanceModelImpl;

  factory _BusMaintenanceModel.fromJson(Map<String, dynamic> json) =
      _$BusMaintenanceModelImpl.fromJson;

  /// Unique identifier for the maintenance record (UUID). Matches API 'id'. Read-only.
  @override
  String get id;

  /// ID of the bus this maintenance record belongs to. Matches API 'bus'. Required.
  @override
  String get bus; // UUID
  /// The type of maintenance performed. Matches API 'maintenance_type'. Required.
  /// Uses [MaintenanceType.unknown] as a fallback.
  @override
  @JsonKey(name: 'maintenance_type', unknownEnumValue: MaintenanceType.unknown)
  MaintenanceType get maintenanceType;

  /// The date the maintenance was performed. Matches API 'date_performed'. Required.
  @override
  @JsonKey(name: 'date_performed')
  DateTime get datePerformed;

  /// Description of the work done. Matches API 'description'. Required.
  @override
  String get description;

  /// Optional cost associated with the maintenance. Matches API 'cost'. API shows string format (decimal).
  @override
  String? get cost; // Keep as String to match API, parse later if needed
  /// Optional date when the next maintenance is due. Matches API 'next_maintenance_due'. Nullable.
  @override
  @JsonKey(name: 'next_maintenance_due')
  DateTime? get nextMaintenanceDue;

  /// Timestamp when the record was created. Matches API 'created_at'. Read-only.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Timestamp when the record was last updated. Matches API 'updated_at'. Read-only.
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of BusMaintenanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusMaintenanceModelImplCopyWith<_$BusMaintenanceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
