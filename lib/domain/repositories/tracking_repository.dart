/// lib/domain/repositories/tracking_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/failures.dart';
import '../../core/services/location_service.dart'; // For LocationUpdateData
import '../entities/location_entity.dart';
import '../entities/paginated_list_entity.dart';
import '../entities/tracking_session_entity.dart';

/// Abstract interface defining the contract for tracking-related data operations.
///
/// This contract specifies methods for starting, stopping, pausing, resuming,
/// and managing tracking sessions, as well as sending location updates (single or batch).
/// Implementations in the data layer will interact with the corresponding backend API endpoints
/// and potentially the [OfflineSyncService] for queueing updates.
abstract class TrackingRepository {
  /// Starts a new tracking session for a driver, bus, and line.
  /// Corresponds to POST /api/v1/tracking-sessions/start_tracking/.
  ///
  /// - [busId]: The ID of the bus being tracked.
  /// - [lineId]: The ID of the line being followed.
  /// - [scheduleId]: Optional ID of the specific schedule instance.
  ///
  /// Returns the newly created [TrackingSessionEntity] on success.
  /// Returns a [Failure] if starting the session fails (e.g., already tracking, invalid IDs).
  Future<Either<Failure, TrackingSessionEntity>> startTrackingSession({
    required String busId,
    required String lineId,
    String? scheduleId,
    // Note: Driver ID is typically inferred from the authenticated user context.
  });

  /// Stops the specified tracking session.
  /// Corresponds to POST /api/v1/tracking-sessions/{id}/end_tracking/.
  ///
  /// - [sessionId]: The ID of the tracking session to stop.
  ///
  /// Returns the updated (now completed) [TrackingSessionEntity] on success.
  /// Returns a [Failure] if stopping fails.
  Future<Either<Failure, TrackingSessionEntity>> stopTrackingSession(String sessionId);

  /// Pauses the specified tracking session.
  /// Corresponds to POST /api/v1/tracking-sessions/{id}/pause_tracking/.
  ///
  /// - [sessionId]: The ID of the tracking session to pause.
  ///
  /// Returns the updated (now paused) [TrackingSessionEntity] on success.
  /// Returns a [Failure] if pausing fails.
  Future<Either<Failure, TrackingSessionEntity>> pauseTrackingSession(String sessionId);

  /// Resumes a previously paused tracking session.
  /// Corresponds to POST /api/v1/tracking-sessions/{id}/resume_tracking/.
  ///
  /// - [sessionId]: The ID of the tracking session to resume.
  ///
  /// Returns the updated (now active) [TrackingSessionEntity] on success.
  /// Returns a [Failure] if resuming fails.
  Future<Either<Failure, TrackingSessionEntity>> resumeTrackingSession(String sessionId);

  /// Fetches the currently active or paused tracking session for the authenticated driver.
  /// Corresponds to GET /api/v1/tracking-sessions/active/ (or similar logic).
  ///
  /// Returns the active [TrackingSessionEntity] if one exists, `null` otherwise.
  /// Returns a [Failure] on error.
  Future<Either<Failure, TrackingSessionEntity?>> getActiveTrackingSession();

  /// Sends a single location update to the backend for a specific tracking session.
  /// Corresponds to POST /api/v1/location-updates/.
  /// Implementation should handle offline queueing via [OfflineSyncService] if needed.
  ///
  /// - [sessionId]: The ID of the session this update belongs to.
  /// - [locationData]: The location data captured by the device.
  ///
  /// Returns `void` represented as `Right(null)` on successful submission or queueing.
  /// Returns a [Failure] if sending/queueing fails.
  Future<Either<Failure, void>> sendLocationUpdate({
    required String sessionId,
    required LocationUpdateData locationData,
  });

  /// Sends a batch of location updates to the backend for a specific tracking session.
  /// Corresponds to POST /api/v1/batch-location-update/.
  /// Typically used by the [OfflineSyncService] when sending queued data.
  ///
  /// - [sessionId]: The ID of the session these updates belong to.
  /// - [locations]: A list of location data points captured while offline.
  ///
  /// Returns `void` represented as `Right(null)` on successful submission.
  /// Returns a [Failure] if the batch submission fails.
  Future<Either<Failure, void>> sendBatchLocationUpdates({
    required String sessionId,
    required List<LocationUpdateData> locations,
  });

  /// Fetches the most recent known location for a specific tracking session.
  /// Corresponds to GET /api/v1/tracking-sessions/{id}/current_location/.
  ///
  /// - [sessionId]: The ID of the tracking session.
  ///
  /// Returns the latest [LocationEntity] if available, `null` otherwise.
  /// Returns a [Failure] on error.
  Future<Either<Failure, LocationEntity?>> getCurrentTrackingLocation(String sessionId);


  /// Fetches the history of tracking sessions, potentially filtered.
  /// Corresponds to GET /api/v1/tracking-sessions/.
  ///
  /// - [driverId], [busId], [lineId]: Optional filters.
  /// - [page], [pageSize]: For pagination.
  ///
  /// Returns a [PaginatedListEntity] of [TrackingSessionEntity] on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, PaginatedListEntity<TrackingSessionEntity>>> getTrackingSessionHistory({
    String? driverId,
    String? busId,
    String? lineId,
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  });

  /// Fetches the recorded location updates for a specific tracking session, paginated.
  /// Corresponds to GET /api/v1/tracking-sessions/{id}/location_updates/.
  ///
  /// - [sessionId]: The ID of the tracking session.
  /// - [page], [pageSize]: For pagination.
  ///
  /// Returns a [PaginatedListEntity] of [LocationEntity] on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, PaginatedListEntity<LocationEntity>>> getTrackingSessionLocationUpdates(
    String sessionId, {
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize, // Consider a larger size for location history?
  });

}
