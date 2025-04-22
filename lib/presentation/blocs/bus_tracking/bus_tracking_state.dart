/// lib/presentation/blocs/bus_tracking/bus_tracking_state.dart

part of 'bus_tracking_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to the bus tracking map view.
/// Uses [Equatable] for state comparison.
abstract class BusTrackingState extends Equatable {
  const BusTrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any tracking data (lines, stops, buses) has been loaded.
class BusTrackingInitial extends BusTrackingState {
  const BusTrackingInitial();
}

/// State indicating that essential data for the map view is being loaded.
/// (e.g., initial list of lines to track, stops for those lines, initial bus positions).
class BusTrackingLoading extends BusTrackingState {
  const BusTrackingLoading();
}

/// State indicating that the necessary map data (lines, stops, bus locations)
/// has been successfully loaded and is ready for display.
class BusTrackingLoaded extends BusTrackingState {
  /// The bus lines currently being displayed or tracked on the map.
  final List<LineEntity> lines;

  /// The stops associated with the currently displayed lines.
  /// Could be a flat list or grouped by line ID if needed.
  final List<StopEntity> stops;

  /// Map containing the details of buses currently active on the displayed lines.
  /// Key: Bus ID (String), Value: [BusEntity].
  final Map<String, BusEntity> activeBuses;

  /// Map containing the latest known location for each active bus.
  /// Key: Bus ID (String), Value: [LocationEntity].
  final Map<String, LocationEntity> busLocations;

  /// Optional: User's current location to display on the map.
  // final LocationEntity? userLocation; // Consider adding if needed

  const BusTrackingLoaded({
    this.lines = const [],
    this.stops = const [],
    this.activeBuses = const {},
    this.busLocations = const {},
    // this.userLocation,
  });

  /// Creates a copy of the current loaded state with updated values.
  /// Useful for updating bus locations or changing displayed lines/stops.
  BusTrackingLoaded copyWith({
    List<LineEntity>? lines,
    List<StopEntity>? stops,
    Map<String, BusEntity>? activeBuses,
    Map<String, LocationEntity>? busLocations,
    // LocationEntity? userLocation,
  }) {
    return BusTrackingLoaded(
      lines: lines ?? this.lines,
      stops: stops ?? this.stops,
      activeBuses: activeBuses ?? this.activeBuses,
      busLocations: busLocations ?? this.busLocations,
      // userLocation: userLocation ?? this.userLocation,
    );
  }

  @override
  List<Object?> get props => [
        lines,
        stops,
        activeBuses,
        busLocations,
        // userLocation,
      ];

  @override
  String toString() =>
      'BusTrackingLoaded(lines: ${lines.length}, stops: ${stops.length}, activeBuses: ${activeBuses.length}, busLocations: ${busLocations.length})';
}

/// State indicating that an error occurred while fetching data for the map view.
class BusTrackingError extends BusTrackingState {
  /// The error message describing the failure.
  final String message;

  const BusTrackingError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'BusTrackingError(message: $message)';
}
