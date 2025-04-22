/// lib/presentation/blocs/driver_dashboard/driver_dashboard_event.dart

part of 'driver_dashboard_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to the Driver Dashboard.
/// Uses [Equatable] for value comparison.
abstract class DriverDashboardEvent extends Equatable {
  const DriverDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load the initial data for the driver dashboard,
/// primarily the currently active tracking session (if any).
class LoadDriverDashboard extends DriverDashboardEvent {
  const LoadDriverDashboard();
}

/// Event triggered (likely internally or by another BLoC like TrackingControlBloc)
/// when the driver's tracking session status changes (started, stopped, paused, resumed).
class TrackingSessionUpdated extends DriverDashboardEvent {
  /// The updated tracking session entity.
  /// Null if tracking has stopped or no session is active.
  final TrackingSessionEntity? updatedSession;

  /// Creates a [TrackingSessionUpdated] event.
  const TrackingSessionUpdated({required this.updatedSession});

  @override
  List<Object?> get props => [updatedSession];

  @override
  String toString() =>
      'TrackingSessionUpdated(updatedSession: ${updatedSession != null ? updatedSession!.id : 'null'})';
}

// Add other events here if the dashboard needs to handle more actions,
// e.g., FetchDriverStats, RefreshScheduleSummary
