/// lib/domain/usecases/tracking/send_batch_location_updates_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/services/location_service.dart'; // For LocationUpdateData
import '../../repositories/tracking_repository.dart'; // Import Tracking repo
import '../base_usecase.dart';

/// Use Case for sending a batch of location updates for a specific tracking session.
///
/// This is typically used by the offline synchronization service to send multiple
/// location points collected while the device was offline.
class SendBatchLocationUpdatesUseCase
    implements UseCase<void, SendBatchLocationUpdatesParams> {
  /// The repository instance responsible for tracking data operations.
  final TrackingRepository repository;

  /// Creates a [SendBatchLocationUpdatesUseCase] instance that requires a [TrackingRepository].
  const SendBatchLocationUpdatesUseCase(this.repository);

  /// Executes the logic to send a batch of location updates.
  ///
  /// Takes [SendBatchLocationUpdatesParams] containing the session ID and the list
  /// of location data points, calls the repository's sendBatchLocationUpdates method,
  /// and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or `void` (represented as `Right(null)`) on successful submission.
  @override
  Future<Either<Failure, void>> call(
      SendBatchLocationUpdatesParams params) async {
    // Validate that the list is not empty
    if (params.locations.isEmpty) {
      return Left(InvalidInputFailure(
          message: 'Location list cannot be empty for batch update.'));
    }
    return await repository.sendBatchLocationUpdates(
      sessionId: params.sessionId,
      locations: params.locations,
    );
  }
}

/// Parameters required for the [SendBatchLocationUpdatesUseCase].
///
/// Contains the ID of the active tracking session and the list of location
/// data points to send in a single batch request.
class SendBatchLocationUpdatesParams extends Equatable {
  /// The ID of the tracking session these updates belong to.
  final String sessionId;

  /// The list of location data points captured.
  final List<LocationUpdateData> locations;

  /// Creates a [SendBatchLocationUpdatesParams] instance.
  const SendBatchLocationUpdatesParams({
    required this.sessionId,
    required this.locations,
  });

  @override
  List<Object?> get props => [
        sessionId,
        locations, // List equality works with Equatable items (if LocationUpdateData implemented it)
      ];
}
