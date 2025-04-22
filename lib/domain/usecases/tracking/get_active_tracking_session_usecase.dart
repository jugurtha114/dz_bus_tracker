/// lib/domain/usecases/tracking/get_active_tracking_session_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/tracking_session_entity.dart';
import '../../repositories/tracking_repository.dart'; // Import Tracking repo
import '../base_usecase.dart';

/// Use Case for fetching the currently active (or paused) tracking session
/// for the authenticated driver.
///
/// This class retrieves the active session details by calling the corresponding
/// method in the [TrackingRepository].
class GetActiveTrackingSessionUseCase
    implements UseCase<TrackingSessionEntity?, NoParams> {
  // Note the nullable TrackingSessionEntity? in the UseCase definition ^

  /// The repository instance responsible for tracking data operations.
  final TrackingRepository repository;

  /// Creates a [GetActiveTrackingSessionUseCase] instance that requires a [TrackingRepository].
  const GetActiveTrackingSessionUseCase(this.repository);

  /// Executes the logic to fetch the active tracking session.
  ///
  /// Takes [NoParams] as input, calls the repository's getActiveTrackingSession method,
  /// and returns the result. The result is an [Either] type, containing
  /// a [Failure] on error or a nullable [TrackingSessionEntity] on success.
  /// A `null` TrackingSessionEntity indicates no active or paused session was found.
  @override
  Future<Either<Failure, TrackingSessionEntity?>> call(NoParams params) async {
    return await repository.getActiveTrackingSession();
  }
}
