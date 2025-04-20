// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_maintenance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusMaintenanceModelImpl _$$BusMaintenanceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BusMaintenanceModelImpl(
      id: json['id'] as String,
      bus: json['bus'] as String,
      maintenanceType: $enumDecode(
          _$MaintenanceTypeEnumMap, json['maintenance_type'],
          unknownValue: MaintenanceType.unknown),
      datePerformed: DateTime.parse(json['date_performed'] as String),
      description: json['description'] as String,
      cost: json['cost'] as String?,
      nextMaintenanceDue: json['next_maintenance_due'] == null
          ? null
          : DateTime.parse(json['next_maintenance_due'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$BusMaintenanceModelImplToJson(
        _$BusMaintenanceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bus': instance.bus,
      'maintenance_type': _$MaintenanceTypeEnumMap[instance.maintenanceType]!,
      'date_performed': instance.datePerformed.toIso8601String(),
      'description': instance.description,
      'cost': instance.cost,
      'next_maintenance_due': instance.nextMaintenanceDue?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$MaintenanceTypeEnumMap = {
  MaintenanceType.regular: 'regular',
  MaintenanceType.repair: 'repair',
  MaintenanceType.inspection: 'inspection',
  MaintenanceType.other: 'other',
  MaintenanceType.unknown: 'unknown',
};
