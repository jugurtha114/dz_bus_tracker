/// lib/presentation/blocs/tracking_control/tracking_control_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For transformers
import 'package:dartz/dartz.dart'; // For Either
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart'; // For BehaviorSubject if preferred over StreamController.broadcast

import '../../../core/enums/tracking_status.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/location_service.dart'; // Import LocationService
import '../../../core/utils/logger.dart';
import '../../../domain/entities/tracking_session_entity.dart';
import '../../../domain/usecases/base_usecase.dart'; // For NoParams
import '../../../domain/usecases/tracking/get_active_tracking_session_usecase.dart';
import '../../../domain/usecases/tracking/pause_tracking_session_usecase.dart';
import '../../../domain/usecases/tracking/resume_tracking_session_usecase.dart';
import '../../../domain/usecases/tracking/start_tracking_session_usecase.dart';
import '../../../domain/usecases/tracking/stop_tracking_session_usecase.dart';

part 'tracking_control_event.dart';
part 'tracking_control_state.dart';

/// BLoC responsible for managing the state related to the driver's actions
/// of starting, stopping, pausing, and resuming a tracking session.
/// It interacts with tracking use cases and the [LocationService].
class TrackingControlBloc extends Bloc<TrackingControlEvent, TrackingControlState> {
  final GetActiveTrackingSessionUseCase _getActiveTrackingSessionUseCase;
  final StartTrackingSessionUseCase _startTrackingSessionUseCase;
  final StopTrackingSessionUseCase _stopTrackingSessionUseCase;
  final PauseTrackingSessionUseCase _pauseTrackingSessionUseCase;
  final ResumeTrackingSessionUseCase _resumeTrackingSessionUseCase;
  final LocationService _locationService;

  // Stream controller to broadcast session updates to other parts of the app (e.g., DriverDashboardBloc)
  // Using BehaviorSubject to provide the last emitted value to new listeners.
  final BehaviorSubject<TrackingSessionEntity?> _sessionUpdateController = BehaviorSubject<TrackingSessionEntity?>.seeded(null);

  /// Stream providing the latest active/paused [TrackingSessionEntity] or null if stopped.
  Stream<TrackingSessionEntity?> get sessionUpdateStream => _sessionUpdateController.stream;

  /// Creates an instance of [TrackingControlBloc].
  TrackingControlBloc({
    required GetActiveTrackingSessionUseCase getActiveTrackingSessionUseCase,
    required StartTrackingSessionUseCase startTrackingSessionUseCase,
    required StopTrackingSessionUseCase stopTrackingSessionUseCase,
    required PauseTrackingSessionUseCase pauseTrackingSessionUseCase,
    required ResumeTrackingSessionUseCase resumeTrackingSessionUseCase,
    required LocationService locationService,
  })  : _getActiveTrackingSessionUseCase = getActiveTrackingSessionUseCase,
        _startTrackingSessionUseCase = startTrackingSessionUseCase,
        _stopTrackingSessionUseCase = stopTrackingSessionUseCase,
        _pauseTrackingSessionUseCase = pauseTrackingSessionUseCase,
        _resumeTrackingSessionUseCase = resumeTrackingSessionUseCase,
        _locationService = locationService,
        super(const TrackingControlIdle()) { // Start in Idle state

    // Register event handlers
    on<InitializeTrackingControl>(
      _onInitializeTrackingControl,
      transformer: restartable(), // Only initialize once properly
    );
    on<StartTrackingRequested>(
      _onStartTrackingRequested,
      transformer: droppable(), // Prevent multiple start requests
    );
    on<StopTrackingRequested>(
      _onStopTrackingRequested,
      transformer: droppable(), // Prevent multiple stop requests
    );
    on<PauseTrackingRequested>(
      _onPauseTrackingRequested,
      transformer: droppable(), // Prevent multiple pause requests
    );
    on<ResumeTrackingRequested>(
      _onResumeTrackingRequested,
      transformer: droppable(), // Prevent multiple resume requests
    );

    // Trigger initial state check
    add(const InitializeTrackingControl());
  }

  @override
  Future<void> close() {
    Log.d('TrackingControlBloc: Closing and disposing session update stream.');
    _sessionUpdateController.close();
    // Consider stopping device location tracking if BLoC is closed while active?
    // This depends on application lifecycle requirements.
    // if (state is TrackingControlActive || state is TrackingControlPaused) {
    //   _locationService.stopTracking();
    // }
    return super.close();
  }

  /// Initializes the BLoC state by checking for an existing active/paused session.
  Future<void> _onInitializeTrackingControl(
      InitializeTrackingControl event, Emitter<TrackingControlState> emit) async {
    Log.d('TrackingControlBloc: Initializing state...');
    // Indicate loading while checking
    emit(const TrackingStarting()); // Use 'Starting' as initial loading indicator

    final result = await _getActiveTrackingSessionUseCase(const NoParams());

    await result.fold(
      (failure) async {
        Log.e('TrackingControlBloc: Failed to get initial active session.', error: failure);
        // If check fails, assume idle state but log error
        emit(const TrackingControlIdle());
         _sessionUpdateController.add(null); // Ensure stream reflects idle state
         // Ensure device tracking is off if init fails
         await _locationService.stopTracking();
      },
      (activeSession) async {
        if (activeSession != null) {
          Log.i('TrackingControlBloc: Found existing session (ID: ${activeSession.id}, Status: ${activeSession.status}).');
           // Ensure device location tracking service is running if session is active/paused
           bool trackingStarted = await _locationService.startTracking();
           if (!trackingStarted) {
               Log.e('TrackingControlBloc: Failed to start device location tracking for existing session.');
               // Emit error or revert to idle? Reverting to idle seems safer.
                emit(const TrackingControlIdle());
                 _sessionUpdateController.add(null);
           } else {
              if (activeSession.status == TrackingStatus.active) {
                emit(TrackingControlActive(activeSession: activeSession));
              } else if (activeSession.status == TrackingStatus.paused) {
                emit(TrackingControlPaused(pausedSession: activeSession));
              } else {
                 // Session exists but is completed/errored - treat as idle
                 Log.w('TrackingControlBloc: Found existing session but status is ${activeSession.status}. Treating as Idle.');
                 emit(const TrackingControlIdle());
                 await _locationService.stopTracking(); // Stop device tracking if session isn't active/paused
              }
              // Broadcast the initial session state
              _sessionUpdateController.add(activeSession);
           }
        } else {
          Log.i('TrackingControlBloc: No active session found.');
          emit(const TrackingControlIdle());
          _sessionUpdateController.add(null);
           // Ensure device tracking is off if no active session
           await _locationService.stopTracking();
        }
      },
    );
  }

  /// Handles the request to start a new tracking session.
  Future<void> _onStartTrackingRequested(
      StartTrackingRequested event, Emitter<TrackingControlState> emit) async {
    Log.d('TrackingControlBloc: Handling StartTrackingRequested event.');
    emit(const TrackingStarting());
    _sessionUpdateController.add(null); // Indicate no active session during start attempt

    // 1. Start device location service first (requires permissions)
    final bool locationServiceStarted = await _locationService.startTracking();
    if (!locationServiceStarted) {
       Log.e('TrackingControlBloc: Failed to start device location tracking service.');
       emit(const TrackingControlError(message: 'Could not start location tracking. Check permissions and settings.')); // TODO: Localize
       // No need to call backend if device tracking fails
       return;
    }

    // 2. Call the use case to start session on backend
    final result = await _startTrackingSessionUseCase(
      StartTrackingParams(
        busId: event.busId,
        lineId: event.lineId,
        scheduleId: event.scheduleId,
      ),
    );

    await result.fold(
      (failure) async {
        Log.e('TrackingControlBloc: Failed to start tracking session.', error: failure);
        emit(TrackingControlError(message: failure.message ?? 'Failed to start session.'));
        // Stop device location tracking if backend start failed
        await _locationService.stopTracking();
         _sessionUpdateController.add(null);
      },
      (newSession) async {
         Log.i('TrackingControlBloc: Tracking session started successfully (ID: ${newSession.id}).');
         // Emit active state and broadcast the new session
         emit(TrackingControlActive(activeSession: newSession));
         _sessionUpdateController.add(newSession);
      },
    );
  }

  /// Handles the request to stop the current tracking session.
  Future<void> _onStopTrackingRequested(
      StopTrackingRequested event, Emitter<TrackingControlState> emit) async {
    Log.d('TrackingControlBloc: Handling StopTrackingRequested event for session: ${event.sessionId}');
    emit(TrackingStopping(sessionId: event.sessionId));

    // 1. Call use case to stop session on backend
    final result = await _stopTrackingSessionUseCase(StopTrackingParams(sessionId: event.sessionId));

    await result.fold(
      (failure) async {
        Log.e('TrackingControlBloc: Failed to stop tracking session.', error: failure);
        // Emit error but might need to decide if we revert state or force stop locally
        emit(TrackingControlError(
            message: failure.message ?? 'Failed to stop session.',
            // Provide previous state context if possible
            sessionBeforeError: state is TrackingControlActive ? (state as TrackingControlActive).activeSession :
                                 state is TrackingControlPaused ? (state as TrackingControlPaused).pausedSession : null,
            ));
        // Should we stop device tracking even if backend call fails? Yes, probably safer.
        await _locationService.stopTracking();
         _sessionUpdateController.add(null); // Broadcast null if stopping failed server-side? Or keep last known state? Broadcast null.
      },
      (stoppedSession) async {
         Log.i('TrackingControlBloc: Tracking session stopped successfully (ID: ${stoppedSession.id}).');
         // 2. Stop device location service *after* successful backend confirmation
         await _locationService.stopTracking();
         // 3. Emit idle state and broadcast null session
         emit(const TrackingControlIdle());
          _sessionUpdateController.add(null);
      },
    );
  }

   /// Handles the request to pause the current tracking session.
  Future<void> _onPauseTrackingRequested(
      PauseTrackingRequested event, Emitter<TrackingControlState> emit) async {
    Log.d('TrackingControlBloc: Handling PauseTrackingRequested event for session: ${event.sessionId}');
    emit(TrackingPausing(sessionId: event.sessionId));

    final result = await _pauseTrackingSessionUseCase(PauseTrackingParams(sessionId: event.sessionId));

    result.fold(
      (failure) {
        Log.e('TrackingControlBloc: Failed to pause tracking session.', error: failure);
        emit(TrackingControlError(
            message: failure.message ?? 'Failed to pause session.',
             sessionBeforeError: state is TrackingControlActive ? (state as TrackingControlActive).activeSession : null,
            ));
        // Don't stop device location service on pause failure, keep previous state implicitly
      },
      (pausedSession) {
         Log.i('TrackingControlBloc: Tracking session paused successfully (ID: ${pausedSession.id}).');
         // Emit paused state and broadcast the update
         emit(TrackingControlPaused(pausedSession: pausedSession));
         _sessionUpdateController.add(pausedSession);
         // Keep device location service running during pause
      },
    );
  }

   /// Handles the request to resume a paused tracking session.
  Future<void> _onResumeTrackingRequested(
      ResumeTrackingRequested event, Emitter<TrackingControlState> emit) async {
     Log.d('TrackingControlBloc: Handling ResumeTrackingRequested event for session: ${event.sessionId}');
     emit(TrackingResuming(sessionId: event.sessionId));

     final result = await _resumeTrackingSessionUseCase(ResumeTrackingParams(sessionId: event.sessionId));

     result.fold(
      (failure) {
        Log.e('TrackingControlBloc: Failed to resume tracking session.', error: failure);
         emit(TrackingControlError(
            message: failure.message ?? 'Failed to resume session.',
             sessionBeforeError: state is TrackingControlPaused ? (state as TrackingControlPaused).pausedSession : null,
            ));
          // Keep device location service running
      },
      (resumedSession) {
         Log.i('TrackingControlBloc: Tracking session resumed successfully (ID: ${resumedSession.id}).');
          // Emit active state and broadcast the update
         emit(TrackingControlActive(activeSession: resumedSession));
         _sessionUpdateController.add(resumedSession);
          // Ensure device location service is running (should already be)
          _locationService.startTracking(); // Call start again to be sure (it handles if already running)
      },
    );
  }
}
