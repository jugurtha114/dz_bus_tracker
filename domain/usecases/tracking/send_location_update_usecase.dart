/// lib/domain/usecases/tracking/send_location_update_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/services/location_service.dart'; // For LocationUpdateData
import '../../repositories/tracking_repository.dart'; // Import Tracking repo
import '../base_usecase.dart';

/// Use Case for sending a single location update for an active tracking session.
///
/// This class encapsulates the business logic required to transmit a location point
/// to the backend via the [TrackingRepository]. The repository implementation
/// should handle potential offline queueing.
class SendLocationUpdateUseCase
    implements UseCase<void, SendLocationUpdateParams> {
  /// The repository instance responsible for tracking data operations.
  final TrackingRepository repository;

  /// Creates a [SendLocationUpdateUseCase] instance that requires a [TrackingRepository].
  const SendLocationUpdateUseCase(this.repository);

  /// Executes the logic to send a location update.
  ///
  /// Takes [SendLocationUpdateParams] containing the session ID and location data,
  /// calls the repository's sendLocationUpdate method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or `void` (represented as `Right(null)`) on successful submission or queueing.
  @override
  Future<Either<Failure, void>> call(SendLocationUpdateParams params) async {
    // Validation could ensure location data is reasonable (e.g., valid coords)
    return await repository.sendLocationUpdate(
      sessionId: params.sessionId,
      locationData: params.locationData,
    );
  }
}

/// Parameters required for the [SendLocationUpdateUseCase].
///
/// Contains the ID of the active tracking session and the location data point to send.
class SendLocationUpdateParams extends Equatable {
  /// The ID of the tracking session this update belongs to.
  final String sessionId;

  /// The location data captured by the device.
  final LocationUpdateData locationData;

  /// Creates a [SendLocationUpdateParams] instance.
  const SendLocationUpdateParams({
    required this.sessionId,
    required this.locationData,
  });

  @override
  List<Object?> get props => [
        sessionId,
        locationData, // Assumes LocationUpdateData implements Equatable or has value equality
      ];
}
