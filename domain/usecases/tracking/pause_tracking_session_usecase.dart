/// lib/domain/usecases/tracking/pause_tracking_session_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/tracking_session_entity.dart';
import '../../repositories/tracking_repository.dart'; // Import Tracking repo
import '../base_usecase.dart';

/// Use Case for pausing an active tracking session.
///
/// This class encapsulates the business logic required to temporarily pause
/// tracking by calling the corresponding method in the [TrackingRepository].
class PauseTrackingSessionUseCase
    implements UseCase<TrackingSessionEntity, PauseTrackingParams> {
  /// The repository instance responsible for tracking data operations.
  final TrackingRepository repository;

  /// Creates a [PauseTrackingSessionUseCase] instance that requires a [TrackingRepository].
  const PauseTrackingSessionUseCase(this.repository);

  /// Executes the logic to pause a tracking session.
  ///
  /// Takes [PauseTrackingParams] containing the ID of the session to pause,
  /// calls the repository's pauseTrackingSession method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the updated (now paused) [TrackingSessionEntity] on success.
  @override
  Future<Either<Failure, TrackingSessionEntity>> call(
      PauseTrackingParams params) async {
    return await repository.pauseTrackingSession(params.sessionId);
  }
}

/// Parameters required for the [PauseTrackingSessionUseCase].
///
/// Contains the unique identifier of the tracking session to be paused.
class PauseTrackingParams extends Equatable {
  /// The ID of the tracking session.
  final String sessionId;

  /// Creates a [PauseTrackingParams] instance.
  const PauseTrackingParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
