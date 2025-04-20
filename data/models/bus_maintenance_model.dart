/// lib/data/models/bus_maintenance_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/enums/maintenance_type.dart';

// Required part files for code generation
part 'bus_maintenance_model.freezed.dart';
part 'bus_maintenance_model.g.dart';

/// Data Transfer Object (DTO) representing a Bus Maintenance record,
/// mirroring the backend API's `BusMaintenance` schema.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class BusMaintenanceModel with _$BusMaintenanceModel {
  /// Creates an instance of BusMaintenanceModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory BusMaintenanceModel({
    /// Unique identifier for the maintenance record (UUID). Matches API 'id'. Read-only.
    required String id,

    /// ID of the bus this maintenance record belongs to. Matches API 'bus'. Required.
    required String bus, // UUID

    /// The type of maintenance performed. Matches API 'maintenance_type'. Required.
    /// Uses [MaintenanceType.unknown] as a fallback.
    @JsonKey(name: 'maintenance_type', unknownEnumValue: MaintenanceType.unknown)
    required MaintenanceType maintenanceType,

    /// The date the maintenance was performed. Matches API 'date_performed'. Required.
    @JsonKey(name: 'date_performed') required DateTime datePerformed,

    /// Description of the work done. Matches API 'description'. Required.
    required String description,

    /// Optional cost associated with the maintenance. Matches API 'cost'. API shows string format (decimal).
    String? cost, // Keep as String to match API, parse later if needed

    /// Optional date when the next maintenance is due. Matches API 'next_maintenance_due'. Nullable.
    @JsonKey(name: 'next_maintenance_due') DateTime? nextMaintenanceDue,

    /// Timestamp when the record was created. Matches API 'created_at'. Read-only.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp when the record was last updated. Matches API 'updated_at'. Read-only.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

  }) = _BusMaintenanceModel;

  /// Creates a BusMaintenanceModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$BusMaintenanceModelFromJson` function.
  factory BusMaintenanceModel.fromJson(Map<String, dynamic> json) =>
      _$BusMaintenanceModelFromJson(json);
}
