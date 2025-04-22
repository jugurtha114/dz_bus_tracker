/// lib/presentation/blocs/bus_tracking/bus_tracking_event.dart

part of 'bus_tracking_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to the bus tracking map view.
/// Uses [Equatable] for value comparison.
abstract class BusTrackingEvent extends Equatable {
  const BusTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load the initial data needed for the map display.
/// This might fetch lines with active buses, nearby lines, or default lines.
class LoadInitialMapData extends BusTrackingEvent {
  // Optional: Could include initial user location if available to center map
  // final LocationEntity? initialUserLocation;
  const LoadInitialMapData(/*{this.initialUserLocation}*/);

  // @override List<Object?> get props => [initialUserLocation];
}

/// Event triggered when the user selects or changes the specific lines to track on the map.
class SelectLinesToTrack extends BusTrackingEvent {
  /// The list of unique identifiers for the lines to be tracked.
  final List<String> lineIds;

  /// Creates a [SelectLinesToTrack] event.
  const SelectLinesToTrack({required this.lineIds});

  @override
  List<Object?> get props => [lineIds];

  @override
  String toString() => 'SelectLinesToTrack(lineIds: $lineIds)';
}

/// Event triggered internally when new location updates for active buses are available.
class UpdateBusLocations extends BusTrackingEvent {
  /// A map containing the latest location for each updated bus.
  /// Key: Bus ID (String), Value: [LocationEntity].
  final Map<String, LocationEntity> updatedLocations;

  /// Creates an [UpdateBusLocations] event.
  const UpdateBusLocations({required this.updatedLocations});

  @override
  List<Object?> get props => [updatedLocations];

   @override
  String toString() => 'UpdateBusLocations(count: ${updatedLocations.length})';
}

/// Event triggered when the user's own location is updated.
class UserLocationUpdated extends BusTrackingEvent {
  /// The user's current location.
  final LocationEntity userLocation;

  /// Creates a [UserLocationUpdated] event.
  const UserLocationUpdated({required this.userLocation});

   @override
  List<Object?> get props => [userLocation];
}

/// Event triggered periodically to refresh the list of active buses and their status
/// for the currently tracked lines.
class RefreshActiveBuses extends BusTrackingEvent {
   const RefreshActiveBuses();
}


