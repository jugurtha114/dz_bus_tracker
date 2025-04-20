/// lib/presentation/blocs/tracking_control/tracking_control_event.dart

part of 'tracking_control_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to controlling the tracking session.
/// Uses [Equatable] for value comparison.
abstract class TrackingControlEvent extends Equatable {
  const TrackingControlEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to initialize the tracking control state,
/// typically by checking if there's already an active session.
class InitializeTrackingControl extends TrackingControlEvent {
  const InitializeTrackingControl();
}

/// Event triggered when the driver requests to start a new tracking session.
class StartTrackingRequested extends TrackingControlEvent {
  /// The ID of the bus the driver intends to track.
  final String busId;
  /// The ID of the line the driver intends to follow.
  final String lineId;
  /// Optional: The ID of the specific schedule instance being followed.
  final String? scheduleId;

  /// Creates a [StartTrackingRequested] event.
  const StartTrackingRequested({
    required this.busId,
    required this.lineId,
    this.scheduleId,
  });

  @override
  List<Object?> get props => [busId, lineId, scheduleId];

  @override
  String toString() => 'StartTrackingRequested(busId: $busId, lineId: $lineId, scheduleId: $scheduleId)';
}

/// Event triggered when the driver requests to stop the current tracking session.
class StopTrackingRequested extends TrackingControlEvent {
  /// The ID of the currently active or paused tracking session to stop.
  final String sessionId;

  /// Creates a [StopTrackingRequested] event.
  const StopTrackingRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];

   @override
  String toString() => 'StopTrackingRequested(sessionId: $sessionId)';
}

/// Event triggered when the driver requests to pause the current active tracking session.
class PauseTrackingRequested extends TrackingControlEvent {
  /// The ID of the currently active tracking session to pause.
  final String sessionId;

  /// Creates a [PauseTrackingRequested] event.
  const PauseTrackingRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];

   @override
  String toString() => 'PauseTrackingRequested(sessionId: $sessionId)';
}

/// Event triggered when the driver requests to resume the current paused tracking session.
class ResumeTrackingRequested extends TrackingControlEvent {
  /// The ID of the currently paused tracking session to resume.
  final String sessionId;

  /// Creates a [ResumeTrackingRequested] event.
  const ResumeTrackingRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];

   @override
  String toString() => 'ResumeTrackingRequested(sessionId: $sessionId)';
}
