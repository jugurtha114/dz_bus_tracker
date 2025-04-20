/// lib/domain/repositories/eta_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart'; // For default values if needed
import '../../core/error/failures.dart';
import '../entities/eta_entity.dart';
import '../entities/paginated_list_entity.dart';

/// Abstract interface defining the contract for fetching Estimated Time of Arrival (ETA) data.
///
/// This contract specifies methods for retrieving ETA information for specific lines,
/// stops, or buses, as well as fetching upcoming arrivals or delayed ETAs.
/// Implementations in the data layer will interact with the corresponding backend API endpoints.
abstract class EtaRepository {
  /// Fetches a list of ETAs for all active buses currently on a specific line.
  /// Optionally filters by a specific [stopId] on that line.
  /// Corresponds to GET /api/v1/etas/for_line/.
  ///
  /// - [lineId]: The ID of the line to fetch ETAs for.
  /// - [stopId]: Optional. If provided, only return ETAs for this specific stop on the given line.
  ///
  /// Returns a list of [EtaEntity] objects on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, List<EtaEntity>>> getEtasForLine(
    String lineId, {
    String? stopId,
  });

  /// Fetches a list of ETAs for buses arriving at a specific stop.
  /// Optionally filters by a specific [lineId] serving that stop.
  /// Corresponds to GET /api/v1/etas/for_stop/.
  ///
  /// - [stopId]: The ID of the stop to fetch ETAs for.
  /// - [lineId]: Optional. If provided, only return ETAs for this specific line at the given stop.
  ///
  /// Returns a list of [EtaEntity] objects on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, List<EtaEntity>>> getEtasForStop(
    String stopId, {
    String? lineId,
  });

  /// Fetches the current list of ETAs for a specific active bus across all stops on its route.
  /// Corresponds to GET /api/v1/etas/for_bus/.
  ///
  /// - [busId]: The ID of the bus to fetch ETAs for.
  ///
  /// Returns a list of [EtaEntity] objects representing the bus's upcoming arrivals on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, List<EtaEntity>>> getEtasForBus(String busId);

  /// Fetches the next upcoming arrivals, potentially filtered by line or stop.
  /// Corresponds to GET /api/v1/etas/next_arrivals/.
  ///
  /// - [lineId]: Optional filter for a specific line.
  /// - [stopId]: Optional filter for a specific stop.
  /// - [limit]: Optional limit on the number of arrivals to return.
  ///
  /// Returns a list of [EtaEntity] objects sorted by arrival time on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, List<EtaEntity>>> getNextArrivals({
    String? lineId,
    String? stopId,
    int limit = 5, // Default limit for next arrivals
  });

  /// Fetches a paginated list of currently delayed ETAs across the system.
  /// Corresponds to GET /api/v1/etas/delayed/.
  ///
  /// - [page]: The page number to retrieve.
  /// - [pageSize]: The number of items per page.
  ///
  /// Returns a [PaginatedListEntity] containing delayed [EtaEntity] objects on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, PaginatedListEntity<EtaEntity>>> getDelayedEtas({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  });

  // Note: Methods for creating, updating, deleting, or manually calculating ETAs
  // are generally considered backend/admin functions and are omitted from this
  // app-facing repository interface unless a specific use case requires them.
}
