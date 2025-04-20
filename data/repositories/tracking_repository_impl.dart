/// lib/data/repositories/tracking_repository_impl.dart

import 'package:collection/collection.dart'; // For mapNotNull
import 'package:dartz/dartz.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/photo_type.dart'; // Needed for BusPhotoEntity mapping
import '../../../core/enums/tracking_status.dart'; // Needed for mapping
import '../../../core/enums/user_type.dart'; // Needed for mapping
import '../../../core/enums/language.dart'; // Needed for mapping
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/network_info.dart';
import '../../../core/services/location_service.dart'; // For LocationUpdateData
import '../../../core/services/offline_sync_service.dart'; // For queueing
import '../../../core/utils/logger.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/entities/bus_photo_entity.dart'; // Needed for bus mapping
import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/line_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/paginated_list_entity.dart';
import '../../domain/entities/stop_entity.dart'; // Needed for line mapping
import '../../domain/entities/tracking_session_entity.dart';
import '../../domain/entities/user_entity.dart'; // Needed for driver mapping
import '../../domain/repositories/tracking_repository.dart';
import '../data_sources/remote/tracking_remote_data_source.dart';
import '../models/api_response.dart';
import '../models/bus_model.dart';
import '../models/bus_photo_model.dart'; // Needed for bus mapping
import '../models/driver_model.dart';
import '../models/line_model.dart';
import '../models/location_update_model.dart';
import '../models/stop_model.dart'; // Needed for line mapping
import '../models/tracking_session_model.dart';
import '../models/user_model.dart'; // Needed for driver mapping

/// Implementation of the [TrackingRepository] interface.
///
/// Orchestrates tracking-related data operations by interacting with remote
/// data sources and the offline sync service, handling network status checks,
/// mapping data/exceptions between layers, and queueing location updates when offline.
class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource remoteDataSource;
  final OfflineSyncService offlineSyncService; // Inject offline service
  final NetworkInfo networkInfo;

  /// Creates an instance of [TrackingRepositoryImpl].
  const TrackingRepositoryImpl({
    required this.remoteDataSource,
    required this.offlineSyncService,
    required this.networkInfo,
  });

  /// Helper function to safely execute network-dependent operations.
  /// Checks connectivity and handles common exceptions, mapping them to Failures.
  Future<Either<Failure, T>> _performNetworkOperation<T>(
      Future<T> Function() operation) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await operation();
        return Right(result);
      } on AuthenticationException catch (e) {
        Log.w('AuthenticationException caught in TrackingRepository', error: e);
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } on AuthorizationException catch (e) {
        Log.w('AuthorizationException caught in TrackingRepository', error: e);
        return Left(AuthorizationFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        Log.e('ServerException caught in TrackingRepository', error: e);
        return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
      } on NetworkException catch (e) {
        Log.e('NetworkException caught in TrackingRepository', error: e);
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on DataParsingException catch (e) {
        Log.e('DataParsingException caught in TrackingRepository', error: e);
        return Left(DataParsingFailure(message: e.message, code: e.code));
      } catch (e, stackTrace) {
        Log.e('Unexpected exception caught in TrackingRepository operation', error: e, stackTrace: stackTrace);
        return Left(UnexpectedFailure(message: e.toString()));
      }
    } else {
      Log.w('TrackingRepository: Network operation skipped. No internet connection.');
      return Left(NetworkFailure(message: 'No internet connection.')); // TODO: Localize
    }
  }

  @override
  Future<Either<Failure, TrackingSessionEntity>> startTrackingSession({
    required String busId,
    required String lineId,
    String? scheduleId,
  }) async {
    return _performNetworkOperation(() async {
      final model = await remoteDataSource.startTrackingSession(
        busId: busId,
        lineId: lineId,
        scheduleId: scheduleId,
      );
      return _mapTrackingSessionModelToEntity(model);
    });
  }

  @override
  Future<Either<Failure, TrackingSessionEntity>> stopTrackingSession(String sessionId) async {
    return _performNetworkOperation(() async {
      final model = await remoteDataSource.stopTrackingSession(sessionId);
      return _mapTrackingSessionModelToEntity(model);
    });
  }

  @override
  Future<Either<Failure, TrackingSessionEntity>> pauseTrackingSession(String sessionId) async {
     return _performNetworkOperation(() async {
      final model = await remoteDataSource.pauseTrackingSession(sessionId);
      return _mapTrackingSessionModelToEntity(model);
    });
  }

  @override
  Future<Either<Failure, TrackingSessionEntity>> resumeTrackingSession(String sessionId) async {
      return _performNetworkOperation(() async {
      final model = await remoteDataSource.resumeTrackingSession(sessionId);
      return _mapTrackingSessionModelToEntity(model);
    });
  }

  @override
  Future<Either<Failure, TrackingSessionEntity?>> getActiveTrackingSession() async {
      // Check network first, although remoteDataSource might return null if none found
      if (!await networkInfo.isConnected) {
          return Left(NetworkFailure(message: 'Cannot fetch active session while offline.'));
      }
      // Use performNetworkOperation for error handling
      return _performNetworkOperation<TrackingSessionEntity?>(() async {
        final model = await remoteDataSource.getActiveTrackingSession();
        return model != null ? _mapTrackingSessionModelToEntity(model) : null;
    });
  }

  @override
  Future<Either<Failure, void>> sendLocationUpdate({
    required String sessionId,
    required LocationUpdateData locationData,
  }) async {
    // Special handling: Queue if offline, otherwise send immediately.
    if (await networkInfo.isConnected) {
      Log.d('Network connected, sending location update directly.');
      return _performNetworkOperation<void>(() async {
        // Although remote returns model, repo interface returns void
        await remoteDataSource.sendLocationUpdate(
            sessionId: sessionId, locationData: locationData);
        return Future.value(); // Return void on success
      });
    } else {
      Log.i('Network offline, queueing location update for session $sessionId.');
      try {
        // Use the OfflineSyncService to queue the update
        await offlineSyncService.queueLocationUpdate(sessionId, locationData);
        // Return success even when queued
        return const Right(null);
      } catch (e, stackTrace) {
        Log.e('Failed to queue location update', error: e, stackTrace: stackTrace);
        // Map potential queueing errors to a Failure
        return Left(CacheFailure(message: 'Failed to queue location update locally.'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> sendBatchLocationUpdates({
    required String sessionId,
    required List<LocationUpdateData> locations,
  }) async {
     // This is typically called by the OfflineSyncService when *online*,
     // so we use the standard network operation helper.
     return _performNetworkOperation<void>(() async {
        await remoteDataSource.sendBatchLocationUpdates(
            sessionId: sessionId, locations: locations);
        return Future.value(); // Return void on success
     });
  }

  @override
  Future<Either<Failure, LocationEntity?>> getCurrentTrackingLocation(String sessionId) async {
     return _performNetworkOperation<LocationEntity?>(() async {
        final model = await remoteDataSource.getCurrentTrackingLocation(sessionId);
        return model != null ? _mapLocationUpdateModelToEntity(model) : null;
     });
  }

  @override
  Future<Either<Failure, PaginatedListEntity<TrackingSessionEntity>>> getTrackingSessionHistory({
    String? driverId,
    String? busId,
    String? lineId,
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  }) async {
     return _performNetworkOperation(() async {
        final apiResponse = await remoteDataSource.getTrackingSessionHistory(
            driverId: driverId, busId: busId, lineId: lineId, page: page, pageSize: pageSize);
        return _mapApiResponseToPaginatedList<TrackingSessionModel, TrackingSessionEntity>(
            apiResponse, _mapTrackingSessionModelToEntity);
     });
  }

  @override
  Future<Either<Failure, PaginatedListEntity<LocationEntity>>> getTrackingSessionLocationUpdates(
    String sessionId, {
    int page = 1,
    int pageSize = 50,
  }) async {
     return _performNetworkOperation(() async {
        final apiResponse = await remoteDataSource.getTrackingSessionLocationUpdates(
            sessionId, page: page, pageSize: pageSize);
        return _mapApiResponseToPaginatedList<LocationUpdateModel, LocationEntity>(
            apiResponse, _mapLocationUpdateModelToEntity);
     });
  }


  // --- Helper Mappers ---

  /// Maps an [ApiResponse] DTO to a [PaginatedListEntity] domain object.
  PaginatedListEntity<E> _mapApiResponseToPaginatedList<M, E>(
      ApiResponse<M> apiResponse, E Function(M model) mapper) {
    return PaginatedListEntity<E>(
      items: apiResponse.results.map(mapper).toList(),
      totalCount: apiResponse.count,
      hasMore: apiResponse.next != null,
    );
  }

  /// Maps a [TrackingSessionModel] DTO to a [TrackingSessionEntity] domain object.
  TrackingSessionEntity _mapTrackingSessionModelToEntity(TrackingSessionModel model) {
    Duration? duration;
    if (model.duration != null) {
       // TODO: Implement robust ISO 8601 duration string parsing
       // Example placeholder - replace with actual parsing logic
       try {
          // Basic parsing - assumes format like P...T(n)H(n)M(n)S - very limited
          final matches = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?').firstMatch(model.duration!);
          if(matches != null){
             final hours = int.tryParse(matches.group(1) ?? '0') ?? 0;
             final minutes = int.tryParse(matches.group(2) ?? '0') ?? 0;
             final seconds = int.tryParse(matches.group(3) ?? '0') ?? 0;
             duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
          }
       } catch(e) {
          Log.e('Failed to parse ISO 8601 duration string: ${model.duration}', error: e);
       }
    }

    return TrackingSessionEntity(
      id: model.id,
      driverDetails: _mapDriverModelToEntity(model.driverDetails),
      busDetails: _mapBusModelToEntity(model.busDetails),
      lineDetails: _mapLineModelToEntity(model.lineDetails),
      scheduleId: model.schedule,
      startTime: model.startTime,
      endTime: model.endTime,
      status: model.status,
      lastUpdate: model.lastUpdate,
      totalDistanceMeters: model.totalDistance,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      duration: duration,
    );
  }

  /// Maps a [LocationUpdateModel] DTO to a [LocationEntity] domain object.
  LocationEntity _mapLocationUpdateModelToEntity(LocationUpdateModel model) {
    // Parse latitude/longitude strings from model to double for entity
    final double latitude = double.tryParse(model.latitude) ?? 0.0;
    final double longitude = double.tryParse(model.longitude) ?? 0.0;

    return LocationEntity(
      latitude: latitude,
      longitude: longitude,
      timestamp: model.timestamp,
      accuracy: model.accuracy,
      speed: model.speed,
      heading: model.heading,
      altitude: model.altitude,
      // Note: LocationEntity doesn't include DB id, sessionId, created/updated etc.
    );
  }

  // --- Mappers for Nested Entities (Copied/Adapted from other Repos) ---
  // Consider centralizing these mappers in a dedicated mapping layer later.

  LineEntity _mapLineModelToEntity(LineModel model) {
    return LineEntity(
      id: model.id, name: model.name, description: model.description, color: model.color,
      startLocationDetails: model.startLocationDetails != null ? _mapStopModelToEntity(model.startLocationDetails!) : StopEntity.empty().copyWith(id: model.startLocation),
      endLocationDetails: model.endLocationDetails != null ? _mapStopModelToEntity(model.endLocationDetails!) : StopEntity.empty().copyWith(id: model.endLocation),
      path: model.path, estimatedDurationMinutes: model.estimatedDuration, distanceMeters: model.distance, isActive: model.isActive,
      createdAt: model.createdAt, updatedAt: model.updatedAt, stopsCount: model.stopsCount, activeBusesCount: model.activeBusesCount,
    );
  }

  StopEntity _mapStopModelToEntity(StopModel model) {
    final double latitude = double.tryParse(model.latitude) ?? 0.0;
    final double longitude = double.tryParse(model.longitude) ?? 0.0;
    return StopEntity(
      id: model.id, name: model.name, code: model.code, address: model.address, imageUrl: model.image, description: model.description,
      latitude: latitude, longitude: longitude, accuracy: model.accuracy, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt,
    );
  }

  BusEntity _mapBusModelToEntity(BusModel model) {
    return BusEntity(
      id: model.id, driverDetails: _mapDriverModelToEntity(model.driverDetails), matricule: model.matricule, brand: model.brand, model: model.model,
      year: model.year, capacity: model.capacity, description: model.description, isVerified: model.isVerified, verificationDate: model.verificationDate,
      lastMaintenance: model.lastMaintenance, nextMaintenance: model.nextMaintenance, isActive: model.isActive, createdAt: model.createdAt,
      updatedAt: model.updatedAt, photos: model.photos.map(_mapBusPhotoModelToEntity).toList(), isTracking: model.isTracking,
    );
  }

  BusPhotoEntity _mapBusPhotoModelToEntity(BusPhotoModel model) {
    return BusPhotoEntity(
      id: model.id, busId: model.bus, photoUrl: model.photo, photoType: model.type, description: model.description, createdAt: model.createdAt,
    );
  }

  DriverEntity _mapDriverModelToEntity(DriverModel model) {
    double? avgRating;
    if(model.averageRating != null) { avgRating = double.tryParse(model.averageRating!); }
    return DriverEntity(
      id: model.id, userDetails: _mapUserModelToEntity(model.userDetails), idNumber: model.idNumber, idPhotoUrl: model.idPhoto,
      licenseNumber: model.licenseNumber, licensePhotoUrl: model.licensePhoto, isVerified: model.isVerified, verificationDate: model.verificationDate,
      experienceYears: model.experienceYears, dateOfBirth: model.dateOfBirth, address: model.address, emergencyContact: model.emergencyContact,
      notes: model.notes, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt, averageRating: avgRating,
    );
  }

  UserEntity _mapUserModelToEntity(UserModel model) {
    return UserEntity(
      id: model.id, email: model.email, firstName: model.firstName, lastName: model.lastName, phoneNumber: model.phoneNumber,
      userType: model.userType, language: model.language, isActive: model.isActive, isEmailVerified: model.isEmailVerified,
      isPhoneVerified: model.isPhoneVerified, dateJoined: model.dateJoined, lastLogin: model.lastLogin,
    );
  }
}
