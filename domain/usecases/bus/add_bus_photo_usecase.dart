/// lib/domain/usecases/bus/add_bus_photo_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/photo_type.dart';
import '../../../core/error/failures.dart';
import '../../entities/bus_photo_entity.dart';
import '../../repositories/bus_repository.dart'; // Import the Bus repository
import '../base_usecase.dart';

/// Use Case for adding a photo to an existing bus.
///
/// This class encapsulates the business logic required to upload and associate
/// a new photo with a bus by calling the corresponding method in the [BusRepository].
class AddBusPhotoUseCase
    implements UseCase<BusPhotoEntity, AddBusPhotoParams> {
  /// The repository instance responsible for bus data operations.
  final BusRepository repository;

  /// Creates an [AddBusPhotoUseCase] instance that requires a [BusRepository].
  const AddBusPhotoUseCase(this.repository);

  /// Executes the logic to add a photo to a bus.
  ///
  /// Takes [AddBusPhotoParams] containing the bus ID, photo data, photo type,
  /// and optional description, calls the repository's addBusPhoto method,
  /// and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the created [BusPhotoEntity] on success.
  @override
  Future<Either<Failure, BusPhotoEntity>> call(AddBusPhotoParams params) async {
    // Input validation (e.g., check if photo data is not null/empty)
    // could happen here or in the BLoC/ViewModel.
    if (params.photo == null) {
      return Left(InvalidInputFailure(message: 'Photo data cannot be null.'));
    }
    return await repository.addBusPhoto(
      busId: params.busId,
      photo: params.photo,
      photoType: params.photoType,
      description: params.description,
    );
  }
}

/// Parameters required for the [AddBusPhotoUseCase].
///
/// Contains the necessary information to add a photo to a bus.
/// The [photo] should be a platform-specific file representation
/// (e.g., File from dart:io or Uint8List from web/memory).
class AddBusPhotoParams extends Equatable {
  /// The ID of the bus to which the photo should be added.
  final String busId;

  /// The photo data (e.g., File, Uint8List) to be uploaded.
  final dynamic photo;

  /// The type or category of the photo being added.
  final PhotoType photoType;

  /// An optional description for the photo.
  final String? description;

  /// Creates an [AddBusPhotoParams] instance.
  const AddBusPhotoParams({
    required this.busId,
    required this.photo,
    required this.photoType,
    this.description,
  });

  @override
  List<Object?> get props => [
        busId,
        photo, // Note: Equality checks on File/Uint8List might not be reliable with Equatable
        photoType,
        description,
      ];
}
