/// lib/presentation/blocs/driver_bus/driver_bus_state.dart

part of 'driver_bus_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to managing the driver's buses.
/// Uses [Equatable] for state comparison.
abstract class DriverBusState extends Equatable {
  const DriverBusState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the driver's buses have been loaded.
class DriverBusInitial extends DriverBusState {
  const DriverBusInitial();
}

/// State indicating that bus data is being loaded or an operation (add/update) is in progress.
class DriverBusLoading extends DriverBusState {
  /// Optionally holds the current list of buses while loading or performing an action,
  /// allowing the UI to still display the old list with a loading indicator.
  final List<BusEntity>? currentBuses;

  const DriverBusLoading({this.currentBuses});

  @override
  List<Object?> get props => [currentBuses];
}

/// State indicating that the driver's list of buses has been successfully loaded.
class DriverBusLoaded extends DriverBusState {
  /// The list of buses associated with the driver.
  final List<BusEntity> buses;

  const DriverBusLoaded({
    this.buses = const [], // Default to empty list
  });

  /// Creates a copy of the current loaded state with updated values.
  DriverBusLoaded copyWith({
    List<BusEntity>? buses,
  }) {
    return DriverBusLoaded(
      buses: buses ?? this.buses,
    );
  }

  @override
  List<Object?> get props => [buses];

  @override
  String toString() => 'DriverBusLoaded(count: ${buses.length})';
}

/// State indicating that an error occurred while fetching or modifying the driver's buses.
class DriverBusError extends DriverBusState {
  /// The error message describing the failure.
  final String message;
  /// Optionally holds the list of buses from before the error occurred.
  final List<BusEntity>? previousBuses;

  const DriverBusError({required this.message, this.previousBuses});

  @override
  List<Object?> get props => [message, previousBuses];

  @override
  String toString() => 'DriverBusError(message: $message)';
}

// Note: A specific 'DriverBusOperationSuccess' state is omitted for simplicity.
// Success feedback can be handled via BlocListener in the UI after transitioning
// back to DriverBusLoaded (potentially after a refresh triggered by the BLoC).
