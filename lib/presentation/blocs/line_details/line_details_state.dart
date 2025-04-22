/// lib/presentation/blocs/line_details/line_details_state.dart

part of 'line_details_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to fetching bus line details.
/// Uses [Equatable] for state comparison.
abstract class LineDetailsState extends Equatable {
  const LineDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any line details have been requested.
class LineDetailsInitial extends LineDetailsState {
  const LineDetailsInitial();
}

/// State indicating that the details for the line are currently being fetched.
class LineDetailsLoading extends LineDetailsState {
  const LineDetailsLoading();
}

/// State indicating that the line details, stops, active buses, ETAs,
/// and favorite status have been successfully loaded.
class LineDetailsLoaded extends LineDetailsState {
  /// The core details of the requested bus line.
  final LineEntity lineDetails;

  /// The ordered list of stops associated with this line.
  final List<StopEntity> stops;

  /// The list of buses currently active on this line.
  final List<BusEntity> activeBuses;

  /// A map where keys are stop IDs and values are lists of ETAs for that stop.
  /// Can be null if ETAs are not available or haven't been loaded yet.
  final Map<String, List<EtaEntity>>? etasByStopId;

  /// Flag indicating if the current user has favorited this line.
  final bool isFavorite;

  const LineDetailsLoaded({
    required this.lineDetails,
    required this.stops,
    required this.activeBuses,
    required this.isFavorite, // Added isFavorite flag
    this.etasByStopId,
  });

  /// Creates a copy of the current loaded state with updated values.
  LineDetailsLoaded copyWith({
    LineEntity? lineDetails,
    List<StopEntity>? stops,
    List<BusEntity>? activeBuses,
    Map<String, List<EtaEntity>>? etasByStopId,
    bool? isFavorite, // Added isFavorite flag
    bool clearEtas = false,
  }) {
    return LineDetailsLoaded(
      lineDetails: lineDetails ?? this.lineDetails,
      stops: stops ?? this.stops,
      activeBuses: activeBuses ?? this.activeBuses,
      etasByStopId: clearEtas ? null : (etasByStopId ?? this.etasByStopId),
      isFavorite: isFavorite ?? this.isFavorite, // Added isFavorite flag
    );
  }

  @override
  List<Object?> get props => [
        lineDetails,
        stops,
        activeBuses,
        etasByStopId,
        isFavorite, // Added isFavorite flag
      ];

  @override
  String toString() =>
      'LineDetailsLoaded(line: ${lineDetails.name}, isFavorite: $isFavorite, stops: ${stops.length}, buses: ${activeBuses.length}, etas: ${etasByStopId?.length ?? 0} stops)';
}

/// State indicating that an error occurred while fetching the line details.
class LineDetailsError extends LineDetailsState {
  /// The error message describing the failure.
  final String message;
  /// The ID of the line that failed to load (for context).
  final String lineId;

  const LineDetailsError({required this.message, required this.lineId});

  @override
  List<Object?> get props => [message, lineId];

  @override
  String toString() => 'LineDetailsError(lineId: $lineId, message: $message)';
}
