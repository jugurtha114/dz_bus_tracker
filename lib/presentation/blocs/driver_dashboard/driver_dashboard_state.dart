/// lib/presentation/blocs/driver_dashboard/driver_dashboard_state.dart

part of 'driver_dashboard_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to the Driver Dashboard.
/// Uses [Equatable] for state comparison.
abstract class DriverDashboardState extends Equatable {
  const DriverDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any dashboard data has been loaded.
class DriverDashboardInitial extends DriverDashboardState {
  const DriverDashboardInitial();
}

/// State indicating that the essential dashboard data (like active session) is being loaded.
class DriverDashboardLoading extends DriverDashboardState {
  const DriverDashboardLoading();
}

/// State indicating that the driver dashboard data has been successfully loaded.
class DriverDashboardLoaded extends DriverDashboardState {
  /// The driver's currently active or paused tracking session, if any.
  /// Null if the driver is not currently tracking.
  final TrackingSessionEntity? activeSession;

  // Potential future additions:
  // final List<UpcomingTripSummaryEntity>? upcomingTrips;
  // final DriverStatsEntity? driverStats;

  const DriverDashboardLoaded({
    this.activeSession,
    // this.upcomingTrips,
    // this.driverStats,
  });

  /// Creates a copy of the current loaded state with updated values.
  DriverDashboardLoaded copyWith({
    // Use ValueGetter to allow explicitly setting activeSession to null
    ValueGetter<TrackingSessionEntity?>? activeSession,
    // List<UpcomingTripSummaryEntity>? upcomingTrips,
    // DriverStatsEntity? driverStats,
  }) {
    return DriverDashboardLoaded(
      activeSession: activeSession != null ? activeSession() : this.activeSession,
      // upcomingTrips: upcomingTrips ?? this.upcomingTrips,
      // driverStats: driverStats ?? this.driverStats,
    );
  }

  @override
  List<Object?> get props => [
        activeSession,
        // upcomingTrips,
        // driverStats,
      ];

  @override
  String toString() =>
      'DriverDashboardLoaded(activeSession: ${activeSession != null ? activeSession!.id : 'none'})';
}

/// State indicating that an error occurred while fetching data for the driver dashboard.
class DriverDashboardError extends DriverDashboardState {
  /// The error message describing the failure.
  final String message;

  const DriverDashboardError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'DriverDashboardError(message: $message)';
}

