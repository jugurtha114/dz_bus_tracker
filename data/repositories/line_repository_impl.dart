/// lib/data/repositories/line_repository_impl.dart

import 'dart:async'; // Needed for mappers using DateTime
import 'dart:convert'; // Needed for mapping GeoJSON
import 'dart:io'; // Needed for mapping helper if used
import 'package:flutter/foundation.dart'; // Needed for mapping helper if used
import 'package:mime/mime.dart'; // Needed for mapping helper if used
import 'package:path/path.dart' as p; // Needed for mapping helper if used


import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // Needed for mapping helper if used

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/language.dart';
import '../../../core/enums/maintenance_type.dart'; // Needed for Bus mapping
import '../../../core/enums/photo_type.dart';
import '../../../core/enums/tracking_status.dart'; // Needed for Bus mapping
import '../../../core/enums/user_type.dart';
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/network_info.dart';
import '../../../core/typedefs/common_types.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/entities/bus_photo_entity.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/line_entity.dart';
import '../../domain/entities/paginated_list_entity.dart';
import '../../domain/entities/stop_entity.dart'; // Import the freezed entity
import '../../domain/entities/tracking_session_entity.dart'; // Needed for Bus mapping
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/line_repository.dart';
import '../data_sources/local/cache_local_data_source.dart';
import '../data_sources/remote/line_remote_data_source.dart';
import '../models/api_response.dart';
import '../models/bus_model.dart';
import '../models/bus_photo_model.dart';
import '../models/driver_model.dart';
import '../models/line_detail_model.dart';
import '../models/line_model.dart';
import '../models/stop_model.dart'; // Import the freezed model
import '../models/tracking_session_model.dart'; // Needed for Bus mapping
import '../models/user_model.dart';


/// Implementation of the [LineRepository] interface.
/// Orchestrates line and stop related data operations.
class LineRepositoryImpl implements LineRepository {
  final LineRemoteDataSource remoteDataSource;
  final CacheLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  // Define cache keys base strings locally
  static const String _linesCacheKeyBase = 'cache_lines_list';
  static const String _stopsCachePrefix = 'cache_stops_for_line_';
  static const String _stopDetailCachePrefix = 'cache_stop_detail_';
  static const String _lineDetailCachePrefix = 'cache_line_detail_';

  // Define cache durations
  static const Duration _lineListCacheDuration = Duration(hours: 1);
  static const Duration _lineDetailCacheDuration = Duration(minutes: 15);
  static const Duration _stopsForLineCacheDuration = Duration(hours: 1);
  static const Duration _stopDetailCacheDuration = Duration(hours: 1);

  const LineRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // --- Network/Cache Helpers ---
  Future<Either<Failure, T>> _performNetworkOperation<T>(Future<T> Function() operation) async {
    if (await networkInfo.isConnected) { try { final result = await operation(); return Right(result); } on AuthenticationException catch (e) { Log.w('AuthException in LineRepo', error: e); return Left(AuthenticationFailure(message: e.message, code: e.code)); } on AuthorizationException catch (e) { Log.w('AuthzException in LineRepo', error: e); return Left(AuthorizationFailure(message: e.message, code: e.code)); } on ServerException catch (e) { Log.e('ServerException in LineRepo', error: e); return Left(ServerFailure(message: e.message, code: e.statusCode?.toString())); } on NetworkException catch (e) { Log.e('NetworkException in LineRepo', error: e); return Left(NetworkFailure(message: e.message, code: e.code)); } on DataParsingException catch (e) { Log.e('DataParsingException in LineRepo', error: e); return Left(DataParsingFailure(message: e.message, code: e.code)); } catch (e, s) { Log.e('Unexpected exception in LineRepo', error: e, stackTrace: s); return Left(UnexpectedFailure(message: e.toString())); } } else { Log.w('LineRepo: Network operation skipped. Offline.'); return Left(NetworkFailure(message: 'No internet connection.')); }
  }
  Future<Either<Failure, T>> _getCachedDataElseFetch<T>({ required String cacheKey, required Duration maxAge, required Future<T> Function() fetchFunc, required Future<void> Function(T data) cacheFunc, required Future<T?> Function() getCachedFunc, }) async {
    final lastCacheTime = await localDataSource.getLastCacheTime(cacheKey); final now = DateTime.now(); if (lastCacheTime != null && now.difference(lastCacheTime) < maxAge) { Log.d('Cache hit: $cacheKey'); try { final cachedData = await getCachedFunc(); if (cachedData != null) return Right(cachedData); else Log.w('Cache hit but data null: $cacheKey'); } catch (e, s) { Log.e('Cache read error: $cacheKey', error: e, stackTrace: s); } } else { Log.d('Cache miss/stale: $cacheKey'); } final networkResult = await _performNetworkOperation<T>(fetchFunc); return networkResult.fold( (failure) => Left(failure), (data) async { try { await cacheFunc(data); } catch (e, s) { Log.e('Cache write error: $cacheKey', error: e, stackTrace: s); } return Right(data); }, );
  }


  // --- Method Implementations ---

  @override
  Future<Either<Failure, PaginatedListEntity<LineEntity>>> getLines({ int page = 1, int pageSize = AppConstants.defaultPaginationSize, String? searchQuery, bool? isActive, bool? withActiveBuses, }) async {
    // Skip caching for now
    return _performNetworkOperation(() async {
      final apiResponse = await remoteDataSource.getLines(page: page, pageSize: pageSize, searchQuery: searchQuery, isActive: isActive, withActiveBuses: withActiveBuses);
      return _mapApiResponseToPaginatedList<LineModel, LineEntity>(apiResponse, _mapLineModelToEntity);
    });
  }

  @override
  Future<Either<Failure, LineEntity>> getLineDetails(String lineId) async {
    return _performNetworkOperation<LineEntity>(() async {
      final detailModel = await remoteDataSource.getLineDetails(lineId);
      return _mapLineDetailModelToEntity(detailModel);
    });
  }

  @override
  Future<Either<Failure, List<StopEntity>>> getStopsForLine(String lineId) async {
    final cacheKey = '$_stopsCachePrefix$lineId'; // CORRECTED: Use local prefix
    return _getCachedDataElseFetch<List<StopEntity>>(
        cacheKey: cacheKey,
        maxAge: _stopsForLineCacheDuration,
        getCachedFunc: () async {
          final cachedModels = await localDataSource.getCachedStopsForLine(lineId);
          return cachedModels?.map(_mapStopModelToEntity).toList();
        },
        fetchFunc: () async {
          final stopModels = await remoteDataSource.getStopsForLine(lineId);
          return stopModels.map(_mapStopModelToEntity).toList();
        },
        cacheFunc: (data) async { Log.w('LineRepo: Caching for getStopsForLine skipped (requires E->M mapping).'); }
    );
  }

  @override
  Future<Either<Failure, StopEntity>> getStopDetails(String stopId) async {
    final cacheKey = '$_stopDetailCachePrefix$stopId'; // CORRECTED: Use local prefix
    return _getCachedDataElseFetch<StopEntity>(
        cacheKey: cacheKey,
        maxAge: _stopDetailCacheDuration,
        getCachedFunc: () async { Log.w('getCachedStopDetail not implemented in CacheLocalDataSource.'); return null; },
        fetchFunc: () async { final stopModel = await remoteDataSource.getStopDetails(stopId); return _mapStopModelToEntity(stopModel); },
        cacheFunc: (data) async { Log.w('cacheStopDetail not implemented in CacheLocalDataSource.'); }
    );
  }

  @override
  Future<Either<Failure, List<BusEntity>>> getBusesForLine(String lineId) async {
    return _performNetworkOperation<List<BusEntity>>(() async {
      final busModels = await remoteDataSource.getBusesForLine(lineId);
      return busModels.map(_mapBusModelToEntity).toList();
    });
  }
  @override
  Future<Either<Failure, List<LineEntity>>> getLinesForStop(String stopId) async {
    return _performNetworkOperation<List<LineEntity>>(() async {
      final lineModels = await remoteDataSource.getLinesForStop(stopId);
      return lineModels.map(_mapLineModelToEntity).toList();
    });
  }
  @override
  Future<Either<Failure, List<StopEntity>>> getNearestStops({required double latitude, required double longitude, double? radiusMeters}) async {
    return _performNetworkOperation<List<StopEntity>>(() async {
      final stopModels = await remoteDataSource.getNearestStops(latitude: latitude, longitude: longitude, radiusMeters: radiusMeters);
      return stopModels.map(_mapStopModelToEntity).toList();
    });
  }
  @override
  Future<Either<Failure, List<StopEntity>>> searchStops(String query) async {
    return _performNetworkOperation<List<StopEntity>>(() async {
      final stopModels = await remoteDataSource.searchStops(query);
      return stopModels.map(_mapStopModelToEntity).toList();
    });
  }

  // --- Favorites ---
  @override
  Future<Either<Failure, bool>> isLineFavorite(String lineId) async {
    return _performNetworkOperation<bool>(() => remoteDataSource.isLineFavorite(lineId));
  }
  @override
  Future<Either<Failure, void>> addFavorite(String lineId, {int? notificationThresholdMinutes}) async {
    return _performNetworkOperation<void>(() async {
      await remoteDataSource.addFavorite(lineId, notificationThresholdMinutes: notificationThresholdMinutes);
      return Future.value();
    });
  }
  @override
  Future<Either<Failure, void>> removeFavorite(String lineId) async {
    return _performNetworkOperation<void>(() async {
      await remoteDataSource.removeFavorite(lineId);
      return Future.value();
    });
  }

  // --- Admin Methods Implementation ---
  @override Future<Either<Failure, LineEntity>> createLine(JsonMap lineData) async { return _performNetworkOperation(() async => _mapLineModelToEntity(await remoteDataSource.createLine(lineData))); }
  @override Future<Either<Failure, LineEntity>> updateLine(String lineId, JsonMap updateData) async { return _performNetworkOperation(() async => _mapLineModelToEntity(await remoteDataSource.updateLine(lineId, updateData))); }
  @override Future<Either<Failure, void>> deleteLine(String lineId) async { return _performNetworkOperation(() => remoteDataSource.deleteLine(lineId)); }
  @override Future<Either<Failure, void>> addStopToLine(String lineId, String stopId, int order) async { return _performNetworkOperation(() => remoteDataSource.addStopToLine(lineId, stopId, order)); }
  @override Future<Either<Failure, void>> removeStopFromLine(String lineId, String stopId) async { return _performNetworkOperation(() => remoteDataSource.removeStopFromLine(lineId, stopId)); }
  @override Future<Either<Failure, void>> reorderStopsForLine(String lineId, List<String> orderedStopIds) async { return _performNetworkOperation(() => remoteDataSource.reorderStopsForLine(lineId, orderedStopIds)); }
  @override Future<Either<Failure, void>> addBusToLine(String lineId, String busId) async { return _performNetworkOperation(() => remoteDataSource.addBusToLine(lineId, busId)); }
  @override Future<Either<Failure, void>> removeBusFromLine(String lineId, String busId) async { return _performNetworkOperation(() => remoteDataSource.removeBusFromLine(lineId, busId)); }
  @override Future<Either<Failure, StopEntity>> createStop(JsonMap stopData) async { return _performNetworkOperation(() async => _mapStopModelToEntity(await remoteDataSource.createStop(stopData))); }
  @override Future<Either<Failure, StopEntity>> updateStop(String stopId, JsonMap updateData) async { return _performNetworkOperation(() async => _mapStopModelToEntity(await remoteDataSource.updateStop(stopId, updateData))); }
  @override Future<Either<Failure, void>> deleteStop(String stopId) async { return _performNetworkOperation(() => remoteDataSource.deleteStop(stopId)); }


  // --- Helper Mappers ---
  PaginatedListEntity<E> _mapApiResponseToPaginatedList<M, E>(ApiResponse<M> apiResponse, E Function(M model) mapper) { return PaginatedListEntity<E>(items: apiResponse.results.map(mapper).toList(), totalCount: apiResponse.count, hasMore: apiResponse.next != null); }

  StopEntity _mapStopModelToEntity(StopModel model) {
    // Use the constructor of the freezed StopEntity
    return StopEntity(
      id: model.id, name: model.name, code: model.code, address: model.address, imageUrl: model.image,
      description: model.description, latitude: double.tryParse(model.latitude) ?? 0.0, longitude: double.tryParse(model.longitude) ?? 0.0,
      accuracy: model.accuracy, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt,
    );
  }

  LineEntity _mapLineModelToEntity(LineModel model) {
    // CORRECTED: Use copyWith on the result of empty() which is now valid
    final startStop = model.startLocationDetails != null ? _mapStopModelToEntity(model.startLocationDetails!) : StopEntity.empty().copyWith(id: model.startLocation);
    final endStop = model.endLocationDetails != null ? _mapStopModelToEntity(model.endLocationDetails!) : StopEntity.empty().copyWith(id: model.endLocation);

    return LineEntity(
      id: model.id, name: model.name, description: model.description, color: model.color,
      startLocationDetails: startStop, endLocationDetails: endStop,
      path: model.path, estimatedDurationMinutes: model.estimatedDuration, distanceMeters: model.distance,
      isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt,
      stopsCount: model.stopsCount, activeBusesCount: model.activeBusesCount,
    );
  }

  LineEntity _mapLineDetailModelToEntity(LineDetailModel model) {
    // CORRECTED: Use copyWith on the result of empty() which is now valid
    final startStop = model.startLocationDetails != null ? _mapStopModelToEntity(model.startLocationDetails!) : StopEntity.empty().copyWith(id: model.startLocation);
    final endStop = model.endLocationDetails != null ? _mapStopModelToEntity(model.endLocationDetails!) : StopEntity.empty().copyWith(id: model.endLocation);

    return LineEntity(
      id: model.id, name: model.name, description: model.description, color: model.color,
      startLocationDetails: startStop, endLocationDetails: endStop,
      path: model.path, estimatedDurationMinutes: model.estimatedDuration, distanceMeters: model.distance,
      isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt,
      stopsCount: model.stopsCount, activeBusesCount: model.activeBusesCount,
    );
  }

  // --- Assume other necessary mappers exist (User, Driver, BusPhoto, Bus) ---
  // (Copied from previous implementations - centralize later)
  UserEntity _mapUserModelToEntity(UserModel model) { return UserEntity( id: model.id, email: model.email, firstName: model.firstName, lastName: model.lastName, phoneNumber: model.phoneNumber, userType: model.userType, language: model.language, isActive: model.isActive, isEmailVerified: model.isEmailVerified, isPhoneVerified: model.isPhoneVerified, dateJoined: model.dateJoined, lastLogin: model.lastLogin, ); }
  DriverEntity _mapDriverModelToEntity(DriverModel model) { double? avgRating; if(model.averageRating != null) { avgRating = double.tryParse(model.averageRating!); } return DriverEntity( id: model.id, userDetails: _mapUserModelToEntity(model.userDetails), idNumber: model.idNumber, idPhotoUrl: model.idPhoto, licenseNumber: model.licenseNumber, licensePhotoUrl: model.licensePhoto, isVerified: model.isVerified, verificationDate: model.verificationDate, experienceYears: model.experienceYears, dateOfBirth: model.dateOfBirth, address: model.address, emergencyContact: model.emergencyContact, notes: model.notes, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt, averageRating: avgRating, ); }
  BusPhotoEntity _mapBusPhotoModelToEntity(BusPhotoModel model) { return BusPhotoEntity( id: model.id, busId: model.bus, photoUrl: model.photo, photoType: model.type, description: model.description, createdAt: model.createdAt, ); }
  BusEntity _mapBusModelToEntity(BusModel model) { return BusEntity( id: model.id, driverDetails: _mapDriverModelToEntity(model.driverDetails), matricule: model.matricule, brand: model.brand, model: model.model, year: model.year, capacity: model.capacity, description: model.description, isVerified: model.isVerified, verificationDate: model.verificationDate, lastMaintenance: model.lastMaintenance, nextMaintenance: model.nextMaintenance, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt, photos: model.photos.map(_mapBusPhotoModelToEntity).toList(), isTracking: model.isTracking, ); }

}