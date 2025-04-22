/// lib/domain/entities/favorite_entity.dart

import 'package:equatable/equatable.dart';

import 'line_entity.dart'; // Import the Line entity

/// Represents the core Favorite entity within the application domain.
///
/// Links a user to a specific bus line they have marked as a favorite,
/// optionally including notification preferences.
class FavoriteEntity extends Equatable {
  /// Unique identifier for the favorite record (UUID).
  final String id;

  /// ID of the user who created this favorite.
  final String userId;

  /// Details of the bus line that was favorited.
  final LineEntity lineDetails;

  /// The threshold in minutes before the estimated arrival time
  /// at which the user wants to be notified. Null if not set.
  final int? notificationThresholdMinutes;

  /// Flag indicating if this favorite is currently active (e.g., for notifications).
  final bool isActive;

  /// Timestamp when the favorite record was created.
  final DateTime createdAt;

  /// Timestamp when the favorite record was last updated.
  final DateTime updatedAt;

  /// Creates a [FavoriteEntity] instance.
  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.lineDetails,
    this.notificationThresholdMinutes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience getter for the favorited Line ID.
  String get lineId => lineDetails.id;

  @override
  List<Object?> get props => [
        id,
        userId,
        lineDetails,
        notificationThresholdMinutes,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Creates an empty FavoriteEntity, useful for default states or placeholders.
  /// Note: Requires a valid empty LineEntity.
  static FavoriteEntity empty() => FavoriteEntity(
        id: '',
        userId: '',
        lineDetails: LineEntity.empty(),
        isActive: false,
        createdAt: DateTime(0),
        updatedAt: DateTime(0),
      );
}
