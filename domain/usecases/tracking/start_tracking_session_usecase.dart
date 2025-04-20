/// lib/domain/usecases/tracking/start_tracking_session_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/tracking_session_entity.dart';
import '../../repositories/tracking_repository.dart'; // Import Tracking repo
import '../base_usecase.dart';

/// Use Case for starting a new tracking session for the currently authenticated driver.
///
/// This class encapsulates the business logic required to initiate tracking
/// for a specific bus on a specific line, by calling the corresponding
/// method in the [TrackingRepository].
class StartTrackingSessionUseCase
    implements UseCase<TrackingSessionEntity, StartTrackingParams> {
  /// The repository instance responsible for tracking data operations.
  final TrackingRepository repository;

  /// Creates a [StartTrackingSessionUseCase] instance that requires a [TrackingRepository].
  const StartTrackingSessionUseCase(this.repository);

  /// Executes the logic to start a tracking session.
  ///
  /// Takes [StartTrackingParams] containing the bus ID, line ID, and optional schedule ID,
  /// calls the repository's startTrackingSession method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// (e.g., another session already active, invalid IDs) or the newly created
  /// [TrackingSessionEntity] on success.
  @override
  Future<Either<Failure, TrackingSessionEntity>> call(
      StartTrackingParams params) async {
    // Input validation (e.g., ensure IDs are valid format) could happen here.
    return await repository.startTrackingSession(
      busId: params.busId,
      lineId: params.lineId,
      scheduleId: params.scheduleId,
    );
  }
}

/// Parameters required for the [StartTrackingSessionUseCase].
///
/// Contains the identifiers necessary to initiate a tracking session.
class StartTrackingParams extends Equatable {
  /// The ID of the bus being tracked.
  final String busId;

  /// The ID of the line being followed.
  final String lineId;

  /// Optional: The ID of the specific schedule instance being followed.
  final String? scheduleId;

  /// Creates a [StartTrackingParams] instance.
  const StartTrackingParams({
    required this.busId,
    required this.lineId,
    this.scheduleId,
  });

  @override
  List<Object?> get props => [
        busId,
        lineId,
        scheduleId,
      ];
}
