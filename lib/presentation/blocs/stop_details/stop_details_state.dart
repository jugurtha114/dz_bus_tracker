/// lib/presentation/blocs/stop_details/stop_details_state.dart

part of 'stop_details_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to fetching stop details.
/// Uses [Equatable] for value comparison.
abstract class StopDetailsState extends Equatable {
  const StopDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any stop details have been requested.
class StopDetailsInitial extends StopDetailsState {
  const StopDetailsInitial();
}

/// State indicating that the details for the stop are currently being fetched.
class StopDetailsLoading extends StopDetailsState {
  const StopDetailsLoading();
}

/// State indicating that the stop details, serving lines, and ETAs
/// have been successfully loaded.
class StopDetailsLoaded extends StopDetailsState {
  /// The details of the requested bus stop.
  final StopEntity stopDetails;
  /// The list of lines that serve this stop.
  final List<LineEntity> servingLines;
  /// The list of current ETAs for buses arriving at this stop.
  final List<EtaEntity> etas;

  const StopDetailsLoaded({
    required this.stopDetails,
    required this.servingLines,
    required this.etas,
  });

  /// Creates a copy of the current loaded state with updated values.
  StopDetailsLoaded copyWith({
    StopEntity? stopDetails,
    List<LineEntity>? servingLines,
    List<EtaEntity>? etas,
  }) {
    return StopDetailsLoaded(
      stopDetails: stopDetails ?? this.stopDetails,
      servingLines: servingLines ?? this.servingLines,
      etas: etas ?? this.etas,
    );
  }

  @override
  List<Object?> get props => [stopDetails, servingLines, etas];

  @override
  String toString() =>
      'StopDetailsLoaded(stop: ${stopDetails.name}, lines: ${servingLines.length}, etas: ${etas.length})';
}

/// State indicating that an error occurred while fetching the stop details.
class StopDetailsError extends StopDetailsState {
  /// The error message describing the failure.
  final String message;
  /// The ID of the stop that failed to load (for context).
  final String stopId;

  const StopDetailsError({required this.message, required this.stopId});

  @override
  List<Object?> get props => [message, stopId];

  @override
  String toString() => 'StopDetailsError(stopId: $stopId, message: $message)';
}
