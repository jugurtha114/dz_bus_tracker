/// lib/domain/usecases/tracking/stop_tracking_session_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/tracking_session_entity.dart';
import '../../repositories/tracking_repository.dart'; // Import Tracking repo
import '../base_usecase.dart';

/// Use Case for stopping an active tracking session for the currently authenticated driver.
///
/// This class encapsulates the business logic required to end tracking
/// by calling the corresponding method in the [TrackingRepository].
class StopTrackingSessionUseCase
    implements UseCase<TrackingSessionEntity, StopTrackingParams> {
  /// The repository instance responsible for tracking data operations.
  final TrackingRepository repository;

  /// Creates a [StopTrackingSessionUseCase] instance that requires a [TrackingRepository].
  const StopTrackingSessionUseCase(this.repository);

  /// Executes the logic to stop a tracking session.
  ///
  /// Takes [StopTrackingParams] containing the ID of the session to stop,
  /// calls the repository's stopTrackingSession method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the updated (now completed) [TrackingSessionEntity] on success.
  @override
  Future<Either<Failure, TrackingSessionEntity>> call(
      StopTrackingParams params) async {
    return await repository.stopTrackingSession(params.sessionId);
  }
}

/// Parameters required for the [StopTrackingSessionUseCase].
///
/// Contains the unique identifier of the tracking session to be stopped.
class StopTrackingParams extends Equatable {
  /// The ID of the tracking session.
  final String sessionId;

  /// Creates a [StopTrackingParams] instance.
  const StopTrackingParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
