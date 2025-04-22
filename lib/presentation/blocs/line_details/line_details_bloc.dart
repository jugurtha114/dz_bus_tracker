/// lib/presentation/blocs/line_details/line_details_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/bus_entity.dart';
import '../../../domain/entities/eta_entity.dart';
import '../../../domain/entities/line_entity.dart';
import '../../../domain/entities/stop_entity.dart';
import '../../../domain/repositories/line_repository.dart'; // Import LineRepository
import '../../../domain/usecases/eta/get_etas_for_line_usecase.dart';
import '../../../domain/usecases/line/get_buses_for_line_usecase.dart';
import '../../../domain/usecases/line/get_line_details_usecase.dart';
import '../../../domain/usecases/line/get_stops_for_line_usecase.dart';

part 'line_details_event.dart';
part 'line_details_state.dart';

/// BLoC responsible for managing the state of the Line Details screen.
///
/// Fetches line information, associated stops, active buses, ETAs, and favorite status.
class LineDetailsBloc extends Bloc<LineDetailsEvent, LineDetailsState> {
  final GetLineDetailsUseCase _getLineDetailsUseCase;
  final GetStopsForLineUseCase _getStopsForLineUseCase;
  final GetBusesForLineUseCase _getBusesForLineUseCase;
  final GetEtasForLineUseCase _getEtasForLineUseCase;
  final LineRepository _lineRepository; // Inject repository for favorite check

  /// Creates an instance of [LineDetailsBloc].
  LineDetailsBloc({
    required GetLineDetailsUseCase getLineDetailsUseCase,
    required GetStopsForLineUseCase getStopsForLineUseCase,
    required GetBusesForLineUseCase getBusesForLineUseCase,
    required GetEtasForLineUseCase getEtasForLineUseCase,
    required LineRepository lineRepository, // Inject repository
  })  : _getLineDetailsUseCase = getLineDetailsUseCase,
        _getStopsForLineUseCase = getStopsForLineUseCase,
        _getBusesForLineUseCase = getBusesForLineUseCase,
        _getEtasForLineUseCase = getEtasForLineUseCase,
        _lineRepository = lineRepository, // Assign repository
        super(const LineDetailsInitial()) {
    on<LoadLineDetails>(
      _onLoadLineDetails,
      transformer: restartable(),
    );
  }

  /// Handles the [LoadLineDetails] event to fetch all data for the screen.
  Future<void> _onLoadLineDetails(
      LoadLineDetails event, Emitter<LineDetailsState> emit) async {
    Log.d('LineDetailsBloc: Handling LoadLineDetails event for lineId: ${event.lineId}');
    emit(const LineDetailsLoading());

    // Fetch required data concurrently, including favorite status
    final results = await Future.wait([
      _getLineDetailsUseCase(GetLineDetailsParams(lineId: event.lineId)),
      _getStopsForLineUseCase(GetStopsForLineParams(lineId: event.lineId)),
      _getBusesForLineUseCase(GetBusesForLineParams(lineId: event.lineId)),
      _getEtasForLineUseCase(GetEtasForLineParams(lineId: event.lineId)),
      _lineRepository.isLineFavorite(event.lineId), // Fetch favorite status
    ]);

    // Process results
    final Either<Failure, LineEntity> lineResult = results[0] as Either<Failure, LineEntity>;
    final Either<Failure, List<StopEntity>> stopsResult = results[1] as Either<Failure, List<StopEntity>>;
    final Either<Failure, List<BusEntity>> busesResult = results[2] as Either<Failure, List<BusEntity>>;
    final Either<Failure, List<EtaEntity>> etasResult = results[3] as Either<Failure, List<EtaEntity>>;
    final Either<Failure, bool> favoriteResult = results[4] as Either<Failure, bool>;

    // Check for failures in critical data (line, stops, buses)
    Failure? criticalFailure;
    LineEntity? lineDetails;
    List<StopEntity>? stops;
    List<BusEntity>? activeBuses;

    lineResult.fold((f) => criticalFailure = f, (line) => lineDetails = line);
    if (criticalFailure != null) {
      Log.e('LineDetailsBloc: Failed to fetch line details.', error: criticalFailure);
      emit(LineDetailsError(message: criticalFailure!.message ?? 'Failed to load line details.', lineId: event.lineId));
      return;
    }

    stopsResult.fold((f) => criticalFailure = f, (list) => stops = list);
     if (criticalFailure != null) {
      Log.e('LineDetailsBloc: Failed to fetch stops.', error: criticalFailure);
      emit(LineDetailsError(message: criticalFailure!.message ?? 'Failed to load stops.', lineId: event.lineId));
      return;
    }

    busesResult.fold((f) => criticalFailure = f, (list) => activeBuses = list);
    if (criticalFailure != null) {
       Log.e('LineDetailsBloc: Failed to fetch buses.', error: criticalFailure);
       emit(LineDetailsError(message: criticalFailure!.message ?? 'Failed to load buses.', lineId: event.lineId));
       return;
    }

    // Process Favorite Status - handle failure gracefully (default to false)
    bool isFavorite = false; // Default
    favoriteResult.fold(
      (failure) {
         Log.w('LineDetailsBloc: Failed to fetch favorite status.', error: failure);
         // Proceed, assuming not favorite on error
      },
      (favStatus) => isFavorite = favStatus
    );

    // Process ETAs - handle failure gracefully (map becomes null)
    Map<String, List<EtaEntity>>? etasByStopId;
    etasResult.fold(
      (failure) {
        Log.w('LineDetailsBloc: Failed to fetch ETAs.', error: failure);
        etasByStopId = null;
      },
      (etasList) {
        Log.i('LineDetailsBloc: ETAs fetched (${etasList.length} total). Grouping...');
        try {
          etasByStopId = groupBy(etasList, (EtaEntity eta) => eta.stopId);
        } catch (e, stackTrace) {
          Log.e('LineDetailsBloc: Error grouping ETAs.', error: e, stackTrace: stackTrace);
          etasByStopId = null;
        }
      },
    );

    // Emit final loaded state if critical data is present
    if (lineDetails != null && stops != null && activeBuses != null) {
       Log.i('LineDetailsBloc: Emitting LineDetailsLoaded state (isFavorite: $isFavorite).');
       emit(LineDetailsLoaded(
         lineDetails: lineDetails!,
         stops: stops!,
         activeBuses: activeBuses!,
        etasByStopId: etasByStopId,
        isFavorite: isFavorite, // Pass favorite status to the state
      ));
    } else {
       Log.e('LineDetailsBloc: Critical data null after processing. This should not happen.');
       emit(LineDetailsError(message: 'Failed to process line details data.', lineId: event.lineId));
    }
  }
}

