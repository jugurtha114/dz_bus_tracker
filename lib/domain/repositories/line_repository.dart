/// lib/domain/repositories/line_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart'; // For default values if needed
import '../../core/error/failures.dart';
import '../entities/bus_entity.dart';
import '../entities/line_entity.dart';
import '../entities/paginated_list_entity.dart';
import '../entities/stop_entity.dart';
// Import JsonMap from common types instead of defining here
import '../../core/typedefs/common_types.dart';


/// Abstract interface defining the contract for data operations related to Bus Lines and Stops.
///
/// This contract specifies methods for fetching lists and details of lines and stops,
/// searching, finding nearby stops, getting associated buses/lines, and managing favorites.
/// Implementations in the data layer will interact with the corresponding backend API endpoints.
abstract class LineRepository {
  /// Fetches a paginated list of bus lines, with optional filtering and searching.
  Future<Either<Failure, PaginatedListEntity<LineEntity>>> getLines({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
    String? searchQuery,
    bool? isActive,
    bool? withActiveBuses,
  });

  /// Fetches the detailed information for a specific bus line by its ID.
  Future<Either<Failure, LineEntity>> getLineDetails(String lineId);

  /// Fetches the list of stops associated with a specific line, in order.
  Future<Either<Failure, List<StopEntity>>> getStopsForLine(String lineId);

  /// Fetches the list of buses currently assigned to or active on a specific line.
  Future<Either<Failure, List<BusEntity>>> getBusesForLine(String lineId);

  /// Fetches the list of lines that serve a specific bus stop.
  Future<Either<Failure, List<LineEntity>>> getLinesForStop(String stopId);

  /// Fetches a list of bus stops near the given geographical coordinates.
  Future<Either<Failure, List<StopEntity>>> getNearestStops({
    required double latitude,
    required double longitude,
    double? radiusMeters,
  });

  /// Searches for bus stops based on a query string (name or code).
  Future<Either<Failure, List<StopEntity>>> searchStops(String query);

  /// Fetches the detailed information for a specific bus stop by its ID.
  Future<Either<Failure, StopEntity>> getStopDetails(String stopId);

  // --- Favorite Management ---
  Future<Either<Failure, bool>> isLineFavorite(String lineId);
  Future<Either<Failure, void>> addFavorite(
      String lineId, {
        int? notificationThresholdMinutes,
      });
  Future<Either<Failure, void>> removeFavorite(String lineId);

  // --- Admin / Line Management Methods ---
  Future<Either<Failure, LineEntity>> createLine(JsonMap lineData);
  Future<Either<Failure, LineEntity>> updateLine(String lineId, JsonMap updateData);
  Future<Either<Failure, void>> deleteLine(String lineId);
  Future<Either<Failure, void>> addStopToLine(String lineId, String stopId, int order);
  Future<Either<Failure, void>> removeStopFromLine(String lineId, String stopId);
  Future<Either<Failure, void>> reorderStopsForLine(String lineId, List<String> orderedStopIds);
  Future<Either<Failure, void>> addBusToLine(String lineId, String busId);
  Future<Either<Failure, void>> removeBusFromLine(String lineId, String busId);
  Future<Either<Failure, StopEntity>> createStop(JsonMap stopData);
  Future<Either<Failure, StopEntity>> updateStop(String stopId, JsonMap updateData);
  Future<Either<Failure, void>> deleteStop(String stopId);
}

// REMOVED Duplicate Typedef: typedef JsonMap = Map<String, dynamic>;