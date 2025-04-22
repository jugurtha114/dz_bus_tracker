/// lib/presentation/blocs/tracking_control/tracking_control_state.dart

part of 'tracking_control_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to controlling the tracking session.
/// Uses [Equatable] for state comparison.
abstract class TrackingControlState extends Equatable {
  const TrackingControlState();

  @override
  List<Object?> get props => [];
}

/// Initial state, representing that tracking is currently inactive/stopped.
class TrackingControlIdle extends TrackingControlState {
  const TrackingControlIdle();
}

/// State indicating that the process of starting a new tracking session is in progress.
class TrackingStarting extends TrackingControlState {
  const TrackingStarting();
}

/// State indicating that the process of stopping the current tracking session is in progress.
class TrackingStopping extends TrackingControlState {
  /// The ID of the session being stopped.
  final String sessionId;

  const TrackingStopping({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// State indicating that the process of pausing the current tracking session is in progress.
class TrackingPausing extends TrackingControlState {
  /// The ID of the session being paused.
  final String sessionId;

  const TrackingPausing({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// State indicating that the process of resuming the current paused tracking session is in progress.
class TrackingResuming extends TrackingControlState {
  /// The ID of the session being resumed.
  final String sessionId;

  const TrackingResuming({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// State indicating that tracking is currently active.
class TrackingControlActive extends TrackingControlState {
  /// The details of the currently active tracking session.
  final TrackingSessionEntity activeSession;

  const TrackingControlActive({required this.activeSession});

  @override
  List<Object?> get props => [activeSession];

  @override
  String toString() => 'TrackingControlActive(sessionId: ${activeSession.id})';
}

/// State indicating that tracking is currently paused.
class TrackingControlPaused extends TrackingControlState {
  /// The details of the currently paused tracking session.
  final TrackingSessionEntity pausedSession;

  const TrackingControlPaused({required this.pausedSession});

  @override
  List<Object?> get props => [pausedSession];

   @override
  String toString() => 'TrackingControlPaused(sessionId: ${pausedSession.id})';
}

/// State indicating that an error occurred during a tracking control operation
/// (start, stop, pause, resume).
class TrackingControlError extends TrackingControlState {
  /// The error message describing the failure.
  final String message;
  /// Optionally, the session details from before the error occurred, for context.
  final TrackingSessionEntity? sessionBeforeError;

  const TrackingControlError({required this.message, this.sessionBeforeError});

  @override
  List<Object?> get props => [message, sessionBeforeError];

  @override
  String toString() => 'TrackingControlError(message: $message, previousSessionId: ${sessionBeforeError?.id})';
}
