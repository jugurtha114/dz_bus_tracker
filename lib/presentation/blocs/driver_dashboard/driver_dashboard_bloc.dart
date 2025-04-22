/// lib/presentation/blocs/driver_dashboard/driver_dashboard_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For restartable transformer
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // for ValueGetter used in copyWith

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/tracking_session_entity.dart';
import '../../../domain/usecases/base_usecase.dart'; // For NoParams
import '../../../domain/usecases/tracking/get_active_tracking_session_usecase.dart';

part 'driver_dashboard_event.dart';
part 'driver_dashboard_state.dart';

/// BLoC responsible for managing the state of the Driver Dashboard screen.
///
/// Fetches the driver's active tracking session and updates the state
/// when the session status changes.
class DriverDashboardBloc extends Bloc<DriverDashboardEvent, DriverDashboardState> {
  final GetActiveTrackingSessionUseCase _getActiveTrackingSessionUseCase;

  /// Creates an instance of [DriverDashboardBloc].
  /// Requires [GetActiveTrackingSessionUseCase].
  DriverDashboardBloc({
    required GetActiveTrackingSessionUseCase getActiveTrackingSessionUseCase,
  })  : _getActiveTrackingSessionUseCase = getActiveTrackingSessionUseCase,
        super(const DriverDashboardInitial()) {

    // Register event handlers
    on<LoadDriverDashboard>(
      _onLoadDriverDashboard,
      transformer: restartable(), // Cancel previous load if triggered again quickly
    );
    on<TrackingSessionUpdated>(
      _onTrackingSessionUpdated,
      // Process updates sequentially as they come in
      transformer: sequential(),
    );

    // Trigger initial data load
    add(const LoadDriverDashboard());
  }

  /// Handles the [LoadDriverDashboard] event to fetch the initial dashboard state.
  Future<void> _onLoadDriverDashboard(
      LoadDriverDashboard event, Emitter<DriverDashboardState> emit) async {
    Log.d('DriverDashboardBloc: Handling LoadDriverDashboard event.');
    emit(const DriverDashboardLoading());

    final result = await _getActiveTrackingSessionUseCase(const NoParams());

    emit(result.fold(
      (failure) {
        Log.e('DriverDashboardBloc: Failed to load active session.', error: failure);
        // If loading fails, show an error state
        return DriverDashboardError(message: failure.message ?? 'Failed to load dashboard data.');
      },
      (activeSession) {
        Log.i('DriverDashboardBloc: Active session loaded (Session ID: ${activeSession?.id ?? 'None'}).');
        // Emit loaded state with the nullable active session
        return DriverDashboardLoaded(activeSession: activeSession);
      },
    ));
  }

  /// Handles the [TrackingSessionUpdated] event, typically dispatched from another
  /// BLoC (like TrackingControlBloc) or service when the session state changes.
  Future<void> _onTrackingSessionUpdated(
      TrackingSessionUpdated event, Emitter<DriverDashboardState> emit) async {
    Log.d('DriverDashboardBloc: Handling TrackingSessionUpdated event (New session: ${event.updatedSession?.id})');

    // Update the state directly with the new session information, regardless of the current state.
    // This ensures the dashboard always reflects the latest known session status.
    emit(DriverDashboardLoaded(activeSession: event.updatedSession));
    Log.i('DriverDashboardBloc: State updated with new session status.');
  }
}

