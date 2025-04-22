/// lib/data/repositories/eta_repository_impl.dart

import 'package:collection/collection.dart'; // For mapNotNull
import 'package:dartz/dartz.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/eta_status.dart'; // Needed for mapping
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/network_info.dart';
import '../../../core/typedefs/common_types.dart'; // For JsonMap
import '../../../core/utils/logger.dart';
import '../../domain/entities/eta_entity.dart';
import '../../domain/entities/paginated_list_entity.dart';
import '../../domain/repositories/eta_repository.dart';
import '../data_sources/remote/eta_remote_data_source.dart';
import '../models/api_response.dart';
import '../models/eta_model.dart';

/// Implementation of the [EtaRepository] interface.
///
/// Orchestrates ETA data operations by interacting with the remote data source,
/// handling network status checks, and mapping data/exceptions between layers.
/// Caching is generally avoided for highly dynamic ETA data.
class EtaRepositoryImpl implements EtaRepository {
  final EtaRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  /// Creates an instance of [EtaRepositoryImpl].
  const EtaRepositoryImpl({
    required this.remoteDataSource,
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
        Log.w('AuthenticationException caught in EtaRepository', error: e);
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } on AuthorizationException catch (e) {
        Log.w('AuthorizationException caught in EtaRepository', error: e);
        return Left(AuthorizationFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        Log.e('ServerException caught in EtaRepository', error: e);
        return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
      } on NetworkException catch (e) {
        Log.e('NetworkException caught in EtaRepository', error: e);
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on DataParsingException catch (e) {
        Log.e('DataParsingException caught in EtaRepository', error: e);
        return Left(DataParsingFailure(message: e.message, code: e.code));
      } catch (e, stackTrace) {
        Log.e('Unexpected exception caught in EtaRepository operation', error: e, stackTrace: stackTrace);
        return Left(UnexpectedFailure(message: e.toString()));
      }
    } else {
      Log.w('EtaRepository: Network operation skipped. No internet connection.');
      return Left(NetworkFailure(message: 'No internet connection.')); // TODO: Localize
    }
  }

  @override
  Future<Either<Failure, List<EtaEntity>>> getEtasForLine(
    String lineId, {
    String? stopId,
  }) async {
    return _performNetworkOperation<List<EtaEntity>>(() async {
      final models = await remoteDataSource.getEtasForLine(lineId, stopId: stopId);
      return models.map(_mapEtaModelToEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<EtaEntity>>> getEtasForStop(
    String stopId, {
    String? lineId,
  }) async {
     return _performNetworkOperation<List<EtaEntity>>(() async {
      final models = await remoteDataSource.getEtasForStop(stopId, lineId: lineId);
      return models.map(_mapEtaModelToEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<EtaEntity>>> getEtasForBus(String busId) async {
     return _performNetworkOperation<List<EtaEntity>>(() async {
      final models = await remoteDataSource.getEtasForBus(busId);
      return models.map(_mapEtaModelToEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<EtaEntity>>> getNextArrivals({
    String? lineId,
    String? stopId,
    int limit = 5,
  }) async {
     return _performNetworkOperation<List<EtaEntity>>(() async {
      final models = await remoteDataSource.getNextArrivals(
          lineId: lineId, stopId: stopId, limit: limit);
      return models.map(_mapEtaModelToEntity).toList();
    });
  }

  @override
  Future<Either<Failure, PaginatedListEntity<EtaEntity>>> getDelayedEtas({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  }) async {
     return _performNetworkOperation(() async {
       final apiResponse = await remoteDataSource.getDelayedEtas(page: page, pageSize: pageSize);
       return _mapApiResponseToPaginatedList<EtaModel, EtaEntity>(
           apiResponse, _mapEtaModelToEntity);
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

  /// Maps an [EtaModel] DTO to an [EtaEntity] domain object.
  EtaEntity _mapEtaModelToEntity(EtaModel model) {
    return EtaEntity(
      id: model.id,
      lineId: model.line,
      busId: model.bus,
      stopId: model.stop,
      trackingSessionId: model.trackingSession,
      estimatedArrivalTime: model.estimatedArrivalTime,
      actualArrivalTime: model.actualArrivalTime,
      status: model.status,
      delayMinutes: model.delayMinutes,
      accuracySeconds: model.accuracy, // API model uses integer 'accuracy' for seconds
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      lineName: model.lineName,
      busMatricule: model.busMatricule,
      stopName: model.stopName,
      minutesRemaining: model.minutesRemaining,
    );
  }
}
