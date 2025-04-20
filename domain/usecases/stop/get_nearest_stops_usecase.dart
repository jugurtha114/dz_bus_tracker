/// lib/domain/usecases/stop/get_nearest_stops_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart'; // For default radius
import '../../../core/error/failures.dart';
import '../../entities/stop_entity.dart';
import '../../repositories/line_repository.dart'; // Use LineRepository as it holds stop logic
import '../base_usecase.dart';

/// Use Case for finding bus stops near a given geographical coordinate.
///
/// This class retrieves a list of nearby stops by calling the corresponding
/// method in the [LineRepository].
class GetNearestStopsUseCase
    implements UseCase<List<StopEntity>, GetNearestStopsParams> {
  /// The repository instance responsible for line and stop data operations.
  final LineRepository repository;

  /// Creates a [GetNearestStopsUseCase] instance that requires a [LineRepository].
  const GetNearestStopsUseCase(this.repository);

  /// Executes the logic to find nearest stops.
  ///
  /// Takes [GetNearestStopsParams] containing the latitude, longitude, and optional radius,
  /// calls the repository's getNearestStops method, and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or a list of nearby [StopEntity] objects (usually sorted by distance) on success.
  @override
  Future<Either<Failure, List<StopEntity>>> call(
      GetNearestStopsParams params) async {
    return await repository.getNearestStops(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusMeters: params.radiusMeters,
    );
  }
}

/// Parameters required for the [GetNearestStopsUseCase].
///
/// Contains the geographical coordinates (latitude, longitude) around which
/// to search for stops, and an optional search radius.
class GetNearestStopsParams extends Equatable {
  /// The latitude of the search center point.
  final double latitude;

  /// The longitude of the search center point.
  final double longitude;

  /// Optional: The search radius in meters. If null, a default radius
  /// (defined in AppConstants or by the backend) will be used.
  final double? radiusMeters;

  /// Creates a [GetNearestStopsParams] instance.
  const GetNearestStopsParams({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = AppConstants.nearbySearchRadiusMeters, // Use default from constants
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        radiusMeters,
      ];
}
