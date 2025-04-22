/// lib/domain/entities/driver_rating_entity.dart

import 'package:equatable/equatable.dart';

import 'user_entity.dart'; // Import the User entity for reporter details

/// Represents the core Driver Rating entity within the application domain.
///
/// Contains details about a rating and comment submitted by a user for a driver.
class DriverRatingEntity extends Equatable {
  /// Unique identifier for the rating record (UUID).
  final String id;

  /// ID of the driver who received the rating.
  final String driverId; // From 'driver' field in API model

  /// Details of the user who submitted the rating. Null if anonymous or user deleted.
  final UserEntity? userDetails; // From 'user_details' field in API model

  /// The numerical rating given (e.g., 1 to 5 stars). Required.
  final int rating;

  /// Optional comment provided along with the rating.
  final String? comment;

  /// Timestamp when the rating was created.
  final DateTime createdAt;

  /// Timestamp when the rating record was last updated.
  final DateTime updatedAt;

  /// Creates a [DriverRatingEntity] instance.
  const DriverRatingEntity({
    required this.id,
    required this.driverId,
    this.userDetails,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience getter for the reporter's user ID, if available.
  String? get userId => userDetails?.id;

  @override
  List<Object?> get props => [
        id,
        driverId,
        userDetails,
        rating,
        comment,
        createdAt,
        updatedAt,
      ];

  /// Creates an empty DriverRatingEntity, useful for default states or placeholders.
  static DriverRatingEntity empty() => DriverRatingEntity(
        id: '',
        driverId: '',
        rating: 0,
        createdAt: DateTime(0),
        updatedAt: DateTime(0),
      );
}
