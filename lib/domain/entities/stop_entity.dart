/// lib/domain/entities/stop_entity.dart

// CORRECTED: Use freezed for automatic copyWith generation
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stop_entity.freezed.dart';
// Add part for json_serializable if you want toJson generated too
// part 'stop_entity.g.dart';

/// Represents a core Bus Stop entity within the application domain.
///
/// Contains details about a specific physical bus stop location.
/// Uses freezed for immutability and helper methods like copyWith.
@freezed
class StopEntity with _$StopEntity {
  // Make fields non-final if direct modification after creation is ever needed,
  // but immutable is generally preferred for entities. Use copyWith for changes.

  /// Creates a [StopEntity] instance.
  const factory StopEntity({
    /// Unique identifier for the stop (UUID).
    required String id,

    /// The display name of the bus stop (e.g., "Place des Martyrs"). Required.
    required String name,

    /// An optional code identifying the stop (e.g., used on signs).
    String? code,

    /// Physical address or general location description of the stop. Optional.
    String? address,

    /// URL to an image associated with the stop. Optional.
    String? imageUrl,

    /// Additional description for the stop. Optional.
    String? description,

    /// The geographical latitude of the stop. Required.
    required double latitude,

    /// The geographical longitude of the stop. Required.
    required double longitude,

    /// Positional accuracy radius in meters, if available. Optional.
    double? accuracy,

    /// Flag indicating if the stop is currently active or in use.
    required bool isActive,

    /// Timestamp when the stop record was created.
    required DateTime createdAt,

    /// Timestamp when the stop record was last updated.
    required DateTime updatedAt,
  }) = _StopEntity;

  /// Private empty constructor required by freezed.
  const StopEntity._();

  /// Creates an empty StopEntity, useful for default states or placeholders.
  factory StopEntity.empty() => StopEntity(
    id: '',
    name: '',
    latitude: 0.0,
    longitude: 0.0,
    isActive: false,
    createdAt: DateTime(0),
    updatedAt: DateTime(0),
  );

// Note: fromJson would require mapping logic if the JSON structure (StopModel)
// differs significantly (e.g., lat/lon as strings).
// factory StopEntity.fromJson(Map<String, dynamic> json) => _$StopEntityFromJson(json);
}

// Previous Equatable implementation (replaced by @freezed):
// import 'package:equatable/equatable.dart';
// class StopEntity extends Equatable {
//   final String id; final String name; final String? code; ...
//   const StopEntity({ required this.id, required this.name, ... });
//   @override List<Object?> get props => [ id, name, code, ... ];
//   static StopEntity empty() => StopEntity(...);
//   // MISSING: copyWith method was not here
// }