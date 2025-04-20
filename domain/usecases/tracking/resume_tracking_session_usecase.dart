/// lib/domain/usecases/tracking/resume_tracking_session_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/tracking_session_entity.dart';
import '../../repositories/tracking_repository.dart'; // Import Tracking repo
import '../base_usecase.dart';

/// Use Case for resuming a previously paused tracking session.
///
/// This class encapsulates the business logic required to resume tracking
/// by calling the corresponding method in the [TrackingRepository].
class ResumeTrackingSessionUseCase
    implements UseCase<TrackingSessionEntity, ResumeTrackingParams> {
  /// The repository instance responsible for tracking data operations.
  final TrackingRepository repository;

  /// Creates a [ResumeTrackingSessionUseCase] instance that requires a [TrackingRepository].
  const ResumeTrackingSessionUseCase(this.repository);

  /// Executes the logic to resume a tracking session.
  ///
  /// Takes [ResumeTrackingParams] containing the ID of the session to resume,
  /// calls the repository's resumeTrackingSession method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the updated (now active) [TrackingSessionEntity] on success.
  @override
  Future<Either<Failure, TrackingSessionEntity>> call(
      ResumeTrackingParams params) async {
    return await repository.resumeTrackingSession(params.sessionId);
  }
}

/// Parameters required for the [ResumeTrackingSessionUseCase].
///
/// Contains the unique identifier of the tracking session to be resumed.
class ResumeTrackingParams extends Equatable {
  /// The ID of the tracking session.
  final String sessionId;

  /// Creates a [ResumeTrackingParams] instance.
  const ResumeTrackingParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
