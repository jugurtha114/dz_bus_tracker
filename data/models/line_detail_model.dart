/// lib/data/models/line_detail_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

import 'bus_model.dart'; // Import BusModel
import 'line_stop_model.dart'; // Import LineStopModel
import 'stop_model.dart'; // Import StopModel for start/end location details

// Required part files for code generation
part 'line_detail_model.freezed.dart';
part 'line_detail_model.g.dart';

/// Data Transfer Object (DTO) representing detailed Bus Line information,
/// mirroring the backend API's `LineDetail` schema. Includes associated stops and buses.
///
/// Uses the `freezed` package for immutability and generated boilerplate code.
@freezed
class LineDetailModel with _$LineDetailModel {
  /// Creates an instance of LineDetailModel.
  ///
  /// Field names use `@JsonKey` to map from snake_case API fields to camelCase Dart fields.
  const factory LineDetailModel({
    // Fields inherited/duplicated from LineModel schema
    required String id,
    required String name,
    String? description,
    String? color,
    @JsonKey(name: 'start_location') required String startLocation,
    @JsonKey(name: 'end_location') required String endLocation,
    Map<String, dynamic>? path,
    @JsonKey(name: 'estimated_duration') int? estimatedDuration,
    double? distance,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'start_location_details') StopModel? startLocationDetails,
    @JsonKey(name: 'end_location_details') StopModel? endLocationDetails,
    @JsonKey(name: 'stops_count') required int stopsCount,
    @JsonKey(name: 'active_buses_count') required int activeBusesCount,

    // Fields specific to LineDetail schema
    /// Ordered list of stops associated with the line, including sequence info. Matches API 'stops'. Required.
    required List<LineStopModel> stops,

    /// List of buses currently assigned to or active on this line. Matches API 'buses'. Required.
    required List<BusModel> buses,

  }) = _LineDetailModel;

  /// Creates a LineDetailModel instance from a JSON map.
  ///
  /// Delegates to the generated `_$LineDetailModelFromJson` function.
  factory LineDetailModel.fromJson(Map<String, dynamic> json) =>
      _$LineDetailModelFromJson(json);
}
