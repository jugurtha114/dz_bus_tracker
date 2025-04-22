/// lib/domain/entities/bus_photo_entity.dart

import 'package:equatable/equatable.dart';

import '../../core/enums/photo_type.dart'; // Import the PhotoType enum

/// Represents a single photo associated with a bus within the application domain.
class BusPhotoEntity extends Equatable {
  /// Unique identifier for the photo record (UUID).
  final String id;

  /// The ID of the bus this photo belongs to.
  final String busId; // Inferred necessity, maps from 'bus' field in BusPhoto model

  /// The URL where the photo image can be accessed.
  final String photoUrl;

  /// The type or category of the photo (e.g., exterior, interior, document).
  final PhotoType photoType;

  /// An optional description for the photo.
  final String? description;

  /// Timestamp when the photo record was created.
  final DateTime createdAt;

  /// Creates a [BusPhotoEntity] instance.
  const BusPhotoEntity({
    required this.id,
    required this.busId,
    required this.photoUrl,
    required this.photoType,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        busId,
        photoUrl,
        photoType,
        description,
        createdAt,
      ];

  /// Creates an empty BusPhotoEntity, useful for default states or placeholders.
  static BusPhotoEntity empty() => BusPhotoEntity(
        id: '',
        busId: '',
        photoUrl: '',
        photoType: PhotoType.unknown,
        createdAt: DateTime(0),
      );
}
