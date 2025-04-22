/// lib/presentation/blocs/stop_details/stop_details_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/eta_entity.dart';
import '../../../domain/entities/line_entity.dart';
import '../../../domain/entities/stop_entity.dart';
import '../../../domain/usecases/eta/get_etas_for_stop_usecase.dart';
import '../../../domain/usecases/line/get_lines_for_stop_usecase.dart';
import '../../../domain/usecases/stop/get_stop_details_usecase.dart'; // Import new use case

part 'stop_details_event.dart';
part 'stop_details_state.dart';

/// BLoC responsible for managing the state of the Stop Details screen.
///
/// Fetches stop information, lines serving the stop, and ETAs for that stop.
class StopDetailsBloc extends Bloc<StopDetailsEvent, StopDetailsState> {
  final GetStopDetailsUseCase _getStopDetailsUseCase;
  final GetLinesForStopUseCase _getLinesForStopUseCase;
  final GetEtasForStopUseCase _getEtasForStopUseCase;

  /// Creates an instance of [StopDetailsBloc].
  StopDetailsBloc({
    required GetStopDetailsUseCase getStopDetailsUseCase,
    required GetLinesForStopUseCase getLinesForStopUseCase,
    required GetEtasForStopUseCase getEtasForStopUseCase,
  })  : _getStopDetailsUseCase = getStopDetailsUseCase,
        _getLinesForStopUseCase = getLinesForStopUseCase,
        _getEtasForStopUseCase = getEtasForStopUseCase,
        super(const StopDetailsInitial()) {

    // Register event handlers
    on<LoadStopDetails>(
      _onLoadStopDetails,
      transformer: restartable(), // Restart if requested again quickly for same stop
    );
     on<RefreshStopEtas>(
      _onRefreshStopEtas,
      transformer: droppable(), // Prevent rapid ETA refreshes
    );
  }

  /// Handles the [LoadStopDetails] event to fetch all data for the screen.
  Future<void> _onLoadStopDetails(
      LoadStopDetails event, Emitter<StopDetailsState> emit) async {
    Log.d('StopDetailsBloc: Handling LoadStopDetails for stopId: ${event.stopId}');
    emit(const StopDetailsLoading());

    // Fetch required data concurrently
    final results = await Future.wait([
      _getStopDetailsUseCase(GetStopDetailsParams(stopId: event.stopId)),
      _getLinesForStopUseCase(GetLinesForStopParams(stopId: event.stopId)),
      _getEtasForStopUseCase(GetEtasForStopParams(stopId: event.stopId, lineId: event.filterByLineId)),
    ]);

    // Process results
    final Either<Failure, StopEntity> stopResult = results[0] as Either<Failure, StopEntity>;
    final Either<Failure, List<LineEntity>> linesResult = results[1] as Either<Failure, List<LineEntity>>;
    final Either<Failure, List<EtaEntity>> etasResult = results[2] as Either<Failure, List<EtaEntity>>;

     // Check for critical failures (stop details, maybe lines)
    Failure? criticalFailure;
    StopEntity? stopDetails;
    List<LineEntity>? servingLines;

    stopResult.fold((f) => criticalFailure = f, (stop) => stopDetails = stop);
    if (criticalFailure != null) {
       Log.e('StopDetailsBloc: Failed to fetch stop details.', error: criticalFailure);
       emit(StopDetailsError(message: criticalFailure!.message ?? 'Failed to load stop details.', stopId: event.stopId));
       return;
    }

    linesResult.fold((f) => criticalFailure = f, (lines) => servingLines = lines);
     if (criticalFailure != null) {
       Log.e('StopDetailsBloc: Failed to fetch lines for stop.', error: criticalFailure);
       emit(StopDetailsError(message: criticalFailure!.message ?? 'Failed to load lines for stop.', stopId: event.stopId));
       return;
    }

    // Process ETAs - Treat failure as empty list for display
    List<EtaEntity> etas = [];
    etasResult.fold(
       (failure) {
          Log.w('StopDetailsBloc: Failed to fetch ETAs for stop.', error: failure);
          // Proceed with empty ETAs, maybe show small error indicator in UI?
       },
       (etasList) => etas = etasList
    );

    // Ensure critical data is not null
    if (stopDetails != null && servingLines != null) {
        Log.i('StopDetailsBloc: Emitting StopDetailsLoaded state for stop: ${stopDetails?.name}.');
       emit(StopDetailsLoaded(
        stopDetails: stopDetails!,
        servingLines: servingLines!,
        etas: etas,
      ));
    } else {
        Log.e('StopDetailsBloc: Critical data null after processing. This should not happen.');
        emit(StopDetailsError(message: 'Failed to process stop details data.', stopId: event.stopId));
    }
  }

  /// Handles the [RefreshStopEtas] event to only update the ETA list.
  Future<void> _onRefreshStopEtas(
      RefreshStopEtas event, Emitter<StopDetailsState> emit) async {

      // Only refresh if already loaded
      if (state is StopDetailsLoaded) {
          final currentState = state as StopDetailsLoaded;
          Log.d('StopDetailsBloc: Handling RefreshStopEtas for stopId: ${event.stopId}');

          // Re-fetch ETAs
           final etasResult = await _getEtasForStopUseCase(
               GetEtasForStopParams(stopId: event.stopId, lineId: event.filterByLineId)
            );

           List<EtaEntity> updatedEtas = currentState.etas; // Default to old ETAs on failure
           etasResult.fold(
               (failure) {
                  Log.w('StopDetailsBloc: Failed to refresh ETAs for stop.', error: failure);
                   // Optionally notify UI via listener, but keep old ETAs in state
               },
               (etasList) {
                  Log.i('StopDetailsBloc: ETAs refreshed successfully (${etasList.length} items).');
                  updatedEtas = etasList;
               }
            );

           // Emit updated state only if ETAs changed (or if needed regardless)
           if (!listEquals(currentState.etas, updatedEtas)) {
              emit(currentState.copyWith(etas: updatedEtas));
           } else {
              Log.d('StopDetailsBloc: ETAs unchanged after refresh.');
           }

      } else {
         Log.w('StopDetailsBloc: RefreshStopEtas event received but state is not loaded.');
         // Optionally trigger full load if appropriate
         // add(LoadStopDetails(stopId: event.stopId, filterByLineId: event.filterByLineId));
      }
  }
}
