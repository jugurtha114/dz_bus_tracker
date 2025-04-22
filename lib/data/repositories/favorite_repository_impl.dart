/// lib/data/repositories/favorite_repository_impl.dart

import 'package:collection/collection.dart'; // For mapNotNull
import 'package:dartz/dartz.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/language.dart'; // Needed for mapping
import '../../../core/enums/photo_type.dart'; // Needed for mapping
import '../../../core/enums/user_type.dart'; // Needed for mapping
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/network_info.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/bus_entity.dart'; // Needed for mapping
import '../../domain/entities/bus_photo_entity.dart'; // Needed for mapping
import '../../domain/entities/driver_entity.dart'; // Needed for mapping
import '../../domain/entities/favorite_entity.dart';
import '../../domain/entities/line_entity.dart'; // Needed for mapping
import '../../domain/entities/paginated_list_entity.dart';
import '../../domain/entities/stop_entity.dart'; // Needed for mapping
import '../../domain/entities/user_entity.dart'; // Needed for mapping
import '../../domain/repositories/favorite_repository.dart';
import '../data_sources/remote/favorite_remote_data_source.dart';
import '../models/api_response.dart';
import '../models/bus_model.dart'; // Needed for mapping
import '../models/bus_photo_model.dart'; // Needed for mapping
import '../models/driver_model.dart'; // Needed for mapping
import '../models/favorite_model.dart';
import '../models/line_model.dart'; // Needed for mapping
import '../models/stop_model.dart'; // Needed for mapping
import '../models/user_model.dart'; // Needed for mapping

/// Implementation of the [FavoriteRepository] interface.
///
/// Orchestrates favorite-related data operations (listing, managing thresholds)
/// by interacting with the remote data source, handling network status checks,
/// and mapping data/exceptions between layers.
class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  /// Creates an instance of [FavoriteRepositoryImpl].
  const FavoriteRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Helper function to safely execute network-dependent operations.
  Future<Either<Failure, T>> _performNetworkOperation<T>(
      Future<T> Function() operation) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await operation();
        return Right(result);
      } on AuthenticationException catch (e) {
        Log.w('AuthenticationException caught in FavoriteRepository', error: e);
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } on AuthorizationException catch (e) {
        Log.w('AuthorizationException caught in FavoriteRepository', error: e);
        return Left(AuthorizationFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        Log.e('ServerException caught in FavoriteRepository', error: e);
        return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
      } on NetworkException catch (e) {
        Log.e('NetworkException caught in FavoriteRepository', error: e);
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on DataParsingException catch (e) {
        Log.e('DataParsingException caught in FavoriteRepository', error: e);
        return Left(DataParsingFailure(message: e.message, code: e.code));
      } catch (e, stackTrace) {
        Log.e('Unexpected exception caught in FavoriteRepository operation', error: e, stackTrace: stackTrace);
        return Left(UnexpectedFailure(message: e.toString()));
      }
    } else {
      Log.w('FavoriteRepository: Network operation skipped. No internet connection.');
      return Left(NetworkFailure(message: 'No internet connection.')); // TODO: Localize
    }
  }

  @override
  Future<Either<Failure, PaginatedListEntity<FavoriteEntity>>> getFavorites({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  }) async {
     return _performNetworkOperation(() async {
        final apiResponse = await remoteDataSource.getFavorites(page: page, pageSize: pageSize);
        return _mapApiResponseToPaginatedList<FavoriteModel, FavoriteEntity>(
            apiResponse, _mapFavoriteModelToEntity);
     });
  }

  @override
  Future<Either<Failure, FavoriteEntity>> updateFavoriteNotificationThreshold({
    required String favoriteId,
    int? notificationThresholdMinutes,
  }) async {
      return _performNetworkOperation(() async {
        final model = await remoteDataSource.updateFavoriteNotificationThreshold(
          favoriteId: favoriteId,
          notificationThresholdMinutes: notificationThresholdMinutes,
        );
        return _mapFavoriteModelToEntity(model);
      });
  }

   @override
  Future<Either<Failure, FavoriteEntity>> getFavoriteDetails(String favoriteId) async {
      return _performNetworkOperation(() async {
        final model = await remoteDataSource.getFavoriteDetails(favoriteId);
        return _mapFavoriteModelToEntity(model);
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

  /// Maps a [FavoriteModel] DTO to a [FavoriteEntity] domain object.
  FavoriteEntity _mapFavoriteModelToEntity(FavoriteModel model) {
    return FavoriteEntity(
      id: model.id,
      userId: model.user,
      lineDetails: _mapLineModelToEntity(model.lineDetails), // Requires nested mapping
      notificationThresholdMinutes: model.notificationThreshold,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
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
  // Note: Mappers for Bus, Driver, User, BusPhoto are technically not needed
  // directly by FavoriteEntity's mapping logic if LineModel mapping is self-contained,
  // but keeping them here for consistency if more complex logic arises.

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
