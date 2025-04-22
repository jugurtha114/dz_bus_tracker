/// lib/presentation/blocs/bus_tracking/bus_tracking_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For mapEquals check
import 'package:stream_transform/stream_transform.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/bus_entity.dart';
import '../../../domain/entities/line_entity.dart';
import '../../../domain/entities/location_entity.dart'; // Needed for bus locations
import '../../../domain/entities/paginated_list_entity.dart'; // Needed for GetLinesUseCase result
import '../../../domain/entities/stop_entity.dart';
import '../../../domain/usecases/base_usecase.dart'; // For NoParams
import '../../../domain/usecases/line/get_buses_for_line_usecase.dart';
import '../../../domain/usecases/line/get_line_details_usecase.dart'; // Needed for fetching Line Entities
import '../../../domain/usecases/line/get_lines_usecase.dart';
import '../../../domain/usecases/line/get_stops_for_line_usecase.dart';

part 'bus_tracking_event.dart';
part 'bus_tracking_state.dart';

// Interval for periodically refreshing active bus data
const _refreshInterval = Duration(seconds: 20);

/// BLoC responsible for managing the state of the live bus tracking map view.
///
/// Fetches initial line/stop data and periodically updates active bus locations.
class BusTrackingBloc extends Bloc<BusTrackingEvent, BusTrackingState> {
  final GetLinesUseCase _getLinesUseCase;
  final GetLineDetailsUseCase _getLineDetailsUseCase; // Needed for SelectLines event
  final GetStopsForLineUseCase _getStopsForLineUseCase;
  final GetBusesForLineUseCase _getBusesForLineUseCase;

  Timer? _refreshTimer; // Timer for periodic bus refresh

  /// Creates an instance of [BusTrackingBloc].
  BusTrackingBloc({
    required GetLinesUseCase getLinesUseCase,
    required GetLineDetailsUseCase getLineDetailsUseCase, // Add dependency
    required GetStopsForLineUseCase getStopsForLineUseCase,
    required GetBusesForLineUseCase getBusesForLineUseCase,
  })  : _getLinesUseCase = getLinesUseCase,
        _getLineDetailsUseCase = getLineDetailsUseCase, // Assign dependency
        _getStopsForLineUseCase = getStopsForLineUseCase,
        _getBusesForLineUseCase = getBusesForLineUseCase,
        super(const BusTrackingInitial()) {
    // Register event handlers
    on<LoadInitialMapData>(_onLoadInitialMapData, transformer: restartable());
    on<SelectLinesToTrack>(_onSelectLinesToTrack, transformer: restartable());
    on<RefreshActiveBuses>(_onRefreshActiveBuses, transformer: droppable());
    on<UpdateBusLocations>(_onUpdateBusLocations);
    on<UserLocationUpdated>(_onUserLocationUpdated);

    // Initial load can be triggered here or from UI
    add(const LoadInitialMapData());
    // _startPeriodicRefresh(); // Start refresh only after initial load succeeds
  }

  void _startPeriodicRefresh() {
    _stopPeriodicRefresh();
    if (state is BusTrackingLoaded && (state as BusTrackingLoaded).lines.isNotEmpty) {
      Log.d('BusTrackingBloc: Starting periodic bus refresh timer ($_refreshInterval).');
      _refreshTimer = Timer.periodic(_refreshInterval, (_) {
        if (!isClosed) { add(const RefreshActiveBuses()); }
        else { _stopPeriodicRefresh(); }
      });
    } else {
      Log.d('BusTrackingBloc: Not starting periodic refresh (state is not Loaded or no lines tracked).');
    }
  }

  void _stopPeriodicRefresh() {
    if (_refreshTimer?.isActive ?? false) {
      Log.d('BusTrackingBloc: Stopping periodic bus refresh timer.');
      _refreshTimer?.cancel();
    }
    _refreshTimer = null;
  }

  @override
  Future<void> close() {
    Log.d('BusTrackingBloc: Closing and stopping timer.');
    _stopPeriodicRefresh();
    return super.close();
  }

  Future<void> _onLoadInitialMapData(
      LoadInitialMapData event, Emitter<BusTrackingState> emit) async {
    Log.d('BusTrackingBloc: Handling LoadInitialMapData event.');
    emit(const BusTrackingLoading());

    final linesResult = await _getLinesUseCase(const GetLinesParams(
      withActiveBuses: true, pageSize: 100, // Fetch initial active lines
    ));

    await linesResult.fold(
          (failure) async {
        // CORRECTED: Use named args for logging
        Log.e('BusTrackingBloc: Failed to load initial lines.', error: failure);
        emit(BusTrackingError(message: failure.message ?? 'Failed to load initial map data.'));
      },
          (paginatedLines) async {
        final initialLines = paginatedLines.items;
        if (initialLines.isEmpty) {
          Log.i('BusTrackingBloc: No initial lines with active buses found.');
          emit(const BusTrackingLoaded(lines: [], stops: [], activeBuses: {}, busLocations: {}));
          // Don't start timer if no lines found initially
          // _startPeriodicRefresh();
          return;
        }
        Log.i('BusTrackingBloc: Loaded ${initialLines.length} initial lines. Fetching stops and buses...');
        await _fetchDetailsForLines(initialLines, emit); // Fetch details for loaded lines
      },
    );
  }

  Future<void> _onSelectLinesToTrack(
      SelectLinesToTrack event, Emitter<BusTrackingState> emit) async {
    Log.d('BusTrackingBloc: Handling SelectLinesToTrack event for lines: ${event.lineIds}');
    emit(const BusTrackingLoading());

    if (event.lineIds.isEmpty) {
      Log.i('BusTrackingBloc: No lines selected.');
      emit(const BusTrackingLoaded(lines: [], stops: [], activeBuses: {}, busLocations: {}));
      _stopPeriodicRefresh();
      return;
    }

    // 1. Fetch LineEntity objects for the selected IDs
    Log.d('BusTrackingBloc: Fetching LineEntity objects for selected IDs...');
    final lineFutures = event.lineIds.map((id) =>
    // CORRECTED: Call the use case field directly
    _getLineDetailsUseCase(GetLineDetailsParams(lineId: id))
    ).toList(); // CORRECTED: .toList() is valid on the result of map()

    final lineResults = await Future.wait(lineFutures);

    // 2. Filter out failures and collect successful LineEntity results
    final List<LineEntity> fetchedLines = [];
    bool hasError = false;
    for (final result in lineResults) {
      result.fold(
              (failure) {
            hasError = true;
            // CORRECTED: Use named args for logging
            Log.w('BusTrackingBloc: Failed to fetch details for line ID during selection.', error: failure);
          },
              (line) => fetchedLines.add(line)
      );
    }

    // 3. Handle errors or proceed to fetch stops/buses
    if (hasError && fetchedLines.isEmpty) { // If ALL line fetches failed
      Log.e('BusTrackingBloc: Failed to fetch details for ALL selected lines.');
      emit(const BusTrackingError(message: 'Could not load details for selected lines.')); // TODO: Localize
      _stopPeriodicRefresh();
    } else if (fetchedLines.isEmpty) {
      Log.w('BusTrackingBloc: No valid lines found for selected IDs (might include errors).');
      emit(const BusTrackingLoaded(lines: [], stops: [], activeBuses: {}, busLocations: {})); // Emit empty state
      _stopPeriodicRefresh();
    }
    else {
      if (hasError) {
        Log.w('BusTrackingBloc: Fetched ${fetchedLines.length} lines, but some ID lookups failed.');
        // Optionally notify user via listener? Continue with successfully fetched lines.
      }
      Log.i('BusTrackingBloc: Fetched ${fetchedLines.length} selected lines. Fetching stops and buses...');
      await _fetchDetailsForLines(fetchedLines, emit); // Fetch details for successfully retrieved lines
    }
  }

  /// Common logic to fetch stops and buses for a given list of lines and update state.
  Future<void> _fetchDetailsForLines(List<LineEntity> lines, Emitter<BusTrackingState> emit) async {
    final lineIds = lines.map((l) => l.id).toList();
    if (lineIds.isEmpty) { // Should not happen if called correctly, but safety check
      emit(BusTrackingLoaded(lines: [], stops: [], activeBuses: {}, busLocations: {}));
      _startPeriodicRefresh();
      return;
    }

    Log.d('Fetching stops and buses for ${lineIds.length} lines...');
    // Use Future.wait for concurrent fetching
    final results = await Future.wait<Either<Failure, dynamic>>([ // Specify common type
      // Fetch Stops for all lines
      Future.wait(lineIds.map((id) => _getStopsForLineUseCase(GetStopsForLineParams(lineId: id)))).then(
        // Combine results: if any failed, return Left, else Right(List<List<StopEntity>>)
              (listResults) => listResults.fold<Either<Failure, List<List<StopEntity>>>> (
              const Right([]), (prev, res) => prev.fold(
                  (f) => Left(f), (acc) => res.fold((f) => Left(f), (list) => Right([...acc, list]))
          )
          )
      ),
      // Fetch Buses for all lines
      Future.wait(lineIds.map((id) => _getBusesForLineUseCase(GetBusesForLineParams(lineId: id)))).then(
              (listResults) => listResults.fold<Either<Failure, List<List<BusEntity>>>> (
              const Right([]), (prev, res) => prev.fold(
                  (f) => Left(f), (acc) => res.fold((f) => Left(f), (list) => Right([...acc, list]))
          )
          )
      ),
    ]);

    final Either<Failure, List<List<StopEntity>>> stopsResult = results[0] as Either<Failure, List<List<StopEntity>>>;
    final Either<Failure, List<List<BusEntity>>> busesResult = results[1] as Either<Failure, List<List<BusEntity>>>;

    Failure? criticalFailure;
    List<List<StopEntity>> stopsPerLine = [];
    List<List<BusEntity>> busesPerLine = [];

    stopsResult.fold((f) => criticalFailure = f, (list) => stopsPerLine = list);
    if (criticalFailure != null) { Log.e('BusTrackingBloc: Failed to fetch stops.', error: criticalFailure); emit(BusTrackingError(message: criticalFailure!.message ?? 'Failed to load stop data.')); return; }

    busesResult.fold((f) => criticalFailure = f, (list) => busesPerLine = list);
    if (criticalFailure != null) { Log.e('BusTrackingBloc: Failed to fetch buses.', error: criticalFailure); emit(BusTrackingError(message: criticalFailure!.message ?? 'Failed to load bus data.')); return; }

    // Consolidate stops (remove duplicates)
    final Map<String, StopEntity> uniqueStops = {};
    for (final stopList in stopsPerLine) { for (final stop in stopList) { uniqueStops[stop.id] = stop; } }

    // Consolidate buses (map by ID) and extract locations
    final Map<String, BusEntity> activeBusesMap = {};
    final Map<String, LocationEntity> busLocationsMap = {};
    for (final busList in busesPerLine) {
      for (final bus in busList) {
        activeBusesMap[bus.id] = bus;
        // TODO: Replace DUMMY location logic. Need a way to fetch real-time locations.
        // This likely involves calling another use case here (e.g., GetLocationsForBusesUseCase)
        // or subscribing to a location stream elsewhere and feeding it into this BLoC
        // via the UpdateBusLocations event. For now, keeping dummy data.
        busLocationsMap[bus.id] = LocationEntity(
          latitude: 36.7 + (bus.id.hashCode % 1000)/10000.0,
          longitude: 3.0 + (bus.id.hashCode % 500)/10000.0,
          timestamp: DateTime.now(),
          speed: 10.0 + (bus.id.hashCode % 10), // dummy speed m/s
          heading: (bus.id.hashCode % 360).toDouble(), // dummy heading
        );
      }
    }

    Log.i('BusTrackingBloc: Emitting loaded state with ${lines.length} lines, ${uniqueStops.length} stops, ${activeBusesMap.length} buses.');
    emit(BusTrackingLoaded(
      lines: lines,
      stops: uniqueStops.values.toList(),
      activeBuses: activeBusesMap,
      busLocations: busLocationsMap,
    ));

    // Start or restart periodic refresh now that data is loaded/updated
    _startPeriodicRefresh();
  }


  /// Handles the periodic [RefreshActiveBuses] event.
  Future<void> _onRefreshActiveBuses(
      RefreshActiveBuses event, Emitter<BusTrackingState> emit) async {

    if (state is BusTrackingLoaded) {
      final currentState = state as BusTrackingLoaded;
      if (currentState.lines.isEmpty) { Log.d('Skipping refresh: no lines tracked.'); return; }

      Log.d('BusTrackingBloc: Handling RefreshActiveBuses event.');

      final lineIds = currentState.lines.map((l) => l.id).toList();
      // Fetch ONLY buses for the current lines
      final busFutures = lineIds.map((id) => _getBusesForLineUseCase(GetBusesForLineParams(lineId: id))).toList();
      final busResults = await Future.wait(busFutures);

      final Either<Failure, List<List<BusEntity>>> busesResult = busResults
          .fold(const Right([]), (prev, res) => prev.fold( (f) => Left(f), (acc) => res.fold((f) => Left(f), (list) => Right([...acc, list])) ));

      await busesResult.fold(
              (failure) async { // Handle failure to refresh buses
            // CORRECTED: Use named args for logging
            Log.w('BusTrackingBloc: Failed to refresh active buses.', error: failure);
          },
              (busesPerLine) async { // Process successfully fetched buses
            final Map<String, BusEntity> activeBusesMap = {};
            final Map<String, LocationEntity> busLocationsMap = {};
            for (final busList in busesPerLine) {
              for (final bus in busList) {
                activeBusesMap[bus.id] = bus;
                // TODO: Replace DUMMY location logic (as above)
                busLocationsMap[bus.id] = LocationEntity(latitude: 36.7 + (bus.id.hashCode % 1000)/10000.0, longitude: 3.0 + (bus.id.hashCode % 500)/10000.0, timestamp: DateTime.now(), speed: 10.0 + (bus.id.hashCode % 10), heading: (bus.id.hashCode % 360).toDouble());
              }
            }

            // Only emit if data changed
            if (!mapEquals(currentState.activeBuses, activeBusesMap) || !mapEquals(currentState.busLocations, busLocationsMap)) {
              Log.i('BusTrackingBloc: Bus data updated after refresh, emitting new state.');
              emit(currentState.copyWith( activeBuses: activeBusesMap, busLocations: busLocationsMap, ));
            } else { Log.d('BusTrackingBloc: No changes detected in bus data after refresh.'); }
          }
      );
    } else { Log.d('BusTrackingBloc: Skipping refresh, not in loaded state.'); }
  }

  /// Handles the [UpdateBusLocations] event (if using external location stream).
  Future<void> _onUpdateBusLocations(
      UpdateBusLocations event, Emitter<BusTrackingState> emit) async {
    if (state is BusTrackingLoaded) {
      final currentState = state as BusTrackingLoaded;
      Log.d('BusTrackingBloc: Handling UpdateBusLocations event with ${event.updatedLocations.length} updates.');
      final newLocations = Map<String, LocationEntity>.from(currentState.busLocations)..addAll(event.updatedLocations);
      if (!mapEquals(currentState.busLocations, newLocations)) { emit(currentState.copyWith(busLocations: newLocations)); }
    }
  }

  /// Handles the [UserLocationUpdated] event.
  Future<void> _onUserLocationUpdated(
      UserLocationUpdated event, Emitter<BusTrackingState> emit) async {
    Log.d('BusTrackingBloc: UserLocationUpdated event received (handler not fully implemented).');
    // TODO: Add userLocation field to BusTrackingLoaded state and handle update here if needed.
    // if (state is BusTrackingLoaded) { emit((state as BusTrackingLoaded).copyWith(userLocation: event.userLocation)); }
  }
}




// /// lib/presentation/blocs/bus_tracking/bus_tracking_bloc.dart
//
// import 'dart:async';
//
// import 'package:bloc/bloc.dart';
// import 'package:bloc_concurrency/bloc_concurrency.dart'; // For transformers
// import 'package:collection/collection.dart'; // For groupBy, mapNotNull
// import 'package:dartz/dartz.dart'; // For Either
// import 'package:equatable/equatable.dart';
// import 'package:flutter/foundation.dart';
// import 'package:stream_transform/stream_transform.dart'; // For debounce
//
// import '../../../core/error/failures.dart';
// import '../../../core/utils/logger.dart';
// import '../../../domain/entities/bus_entity.dart';
// import '../../../domain/entities/line_entity.dart';
// import '../../../domain/entities/location_entity.dart'; // Needed for bus locations
// import '../../../domain/entities/stop_entity.dart';
// import '../../../domain/usecases/line/get_buses_for_line_usecase.dart';
// import '../../../domain/usecases/line/get_line_details_usecase.dart';
// import '../../../domain/usecases/line/get_lines_usecase.dart';
// import '../../../domain/usecases/line/get_stops_for_line_usecase.dart';
//
// part 'bus_tracking_event.dart';
// part 'bus_tracking_state.dart';
//
// // Debounce duration for selecting lines if needed (optional)
// // const _selectLineDebounce = Duration(milliseconds: 150);
//
// // Interval for periodically refreshing active bus data
// const _refreshInterval = Duration(seconds: 20); // Match location update freq?
//
// /// BLoC responsible for managing the state of the live bus tracking map view.
// ///
// /// Fetches initial line/stop data and periodically updates active bus locations.
// class BusTrackingBloc extends Bloc<BusTrackingEvent, BusTrackingState> {
//   final GetLinesUseCase _getLinesUseCase;
//   final GetStopsForLineUseCase _getStopsForLineUseCase;
//   final GetBusesForLineUseCase _getBusesForLineUseCase;
//
//   Timer? _refreshTimer; // Timer for periodic bus refresh
//
//   /// Creates an instance of [BusTrackingBloc].
//   BusTrackingBloc({
//     required GetLinesUseCase getLinesUseCase,
//     required GetStopsForLineUseCase getStopsForLineUseCase,
//     required GetBusesForLineUseCase getBusesForLineUseCase,
//   })  : _getLinesUseCase = getLinesUseCase,
//         _getStopsForLineUseCase = getStopsForLineUseCase,
//         _getBusesForLineUseCase = getBusesForLineUseCase,
//         super(const BusTrackingInitial()) {
//     // Register event handlers
//     on<LoadInitialMapData>(
//       _onLoadInitialMapData,
//       transformer: restartable(), // Restart if requested again quickly
//     );
//     on<SelectLinesToTrack>(
//       _onSelectLinesToTrack,
//       transformer: restartable(), // Use restartable to handle rapid selection changes
//     );
//     on<RefreshActiveBuses>(
//       _onRefreshActiveBuses,
//       transformer: droppable(), // Ignore refresh if one is already running
//     );
//     on<UpdateBusLocations>(
//         _onUpdateBusLocations); // Handles externally pushed locations (if used)
//     on<UserLocationUpdated>(_onUserLocationUpdated); // Handles user location
//
//     // Start periodic refresh if needed (optional, can be triggered by UI)
//     // _startPeriodicRefresh();
//   }
//
//   /// Starts a timer to periodically trigger the RefreshActiveBuses event.
//   void _startPeriodicRefresh() {
//     _stopPeriodicRefresh(); // Ensure previous timer is cancelled
//     if (state is BusTrackingLoaded) { // Only refresh if data is loaded
//       Log.d('BusTrackingBloc: Starting periodic bus refresh timer ($_refreshInterval).');
//       _refreshTimer = Timer.periodic(_refreshInterval, (_) {
//         // Add event only if BLoC hasn't been closed
//         if (!isClosed) {
//             add(const RefreshActiveBuses());
//         } else {
//            _stopPeriodicRefresh(); // Stop timer if bloc closed
//         }
//       });
//     }
//   }
//
//   /// Stops the periodic refresh timer.
//   void _stopPeriodicRefresh() {
//      if (_refreshTimer?.isActive ?? false) {
//        Log.d('BusTrackingBloc: Stopping periodic bus refresh timer.');
//       _refreshTimer?.cancel();
//      }
//       _refreshTimer = null;
//   }
//
//   @override
//   Future<void> close() {
//     Log.d('BusTrackingBloc: Closing and stopping timer.');
//     _stopPeriodicRefresh();
//     return super.close();
//   }
//
//   /// Fetches initial lines (e.g., those with active buses) and their stops/buses.
//   Future<void> _onLoadInitialMapData(
//       LoadInitialMapData event, Emitter<BusTrackingState> emit) async {
//     Log.d('BusTrackingBloc: Handling LoadInitialMapData event.');
//     emit(const BusTrackingLoading());
//
//     // Fetch lines (e.g., only those with active buses initially)
//     final linesResult = await _getLinesUseCase(const GetLinesParams(
//       // Consider fetching all active lines or lines with active buses
//       // isActive: true, // Optional filter
//       withActiveBuses: true, // Fetch lines known to have active buses
//       pageSize: 100, // Fetch a decent number initially if filtering
//     ));
//
//     await linesResult.fold(
//       (failure) async {
//         Log.e('BusTrackingBloc: Failed to load initial lines.', error: failure);
//         emit(BusTrackingError(message: failure.message ?? 'Failed to load initial map data.'));
//       },
//       (paginatedLines) async {
//         final initialLines = paginatedLines.items;
//         if (initialLines.isEmpty) {
//            Log.i('BusTrackingBloc: No initial lines with active buses found.');
//            emit(const BusTrackingLoaded(lines: [], stops: [], activeBuses: {}, busLocations: {})); // Emit empty loaded state
//            _startPeriodicRefresh(); // Still start refresh timer
//            return;
//         }
//
//         Log.i('BusTrackingBloc: Loaded ${initialLines.length} initial lines. Fetching stops and buses...');
//         // Fetch stops and buses for these initial lines concurrently
//         await _fetchDetailsForLines(initialLines, emit);
//       },
//     );
//   }
//
//   /// Fetches details (stops, buses) for a newly selected set of lines.
//   Future<void> _onSelectLinesToTrack(
//       SelectLinesToTrack event, Emitter<BusTrackingState> emit) async {
//     Log.d('BusTrackingBloc: Handling SelectLinesToTrack event for lines: ${event.lineIds}');
//     emit(const BusTrackingLoading()); // Show loading when changing lines
//
//     if (event.lineIds.isEmpty) {
//        Log.i('BusTrackingBloc: No lines selected.');
//        emit(const BusTrackingLoaded(lines: [], stops: [], activeBuses: {}, busLocations: {}));
//        _stopPeriodicRefresh(); // Stop refresh if no lines tracked
//        return;
//     }
//
//     // We need LineEntity objects, not just IDs. Fetch them first.
//     // Assume GetLinesUseCase can fetch specific IDs or adjust logic.
//     // For simplicity, let's assume we only track lines already fetched
//     // during initial load or modify LoadInitialMapData to accept IDs.
//     // Alternative: Fetch LineEntity for each ID here (can be slow).
//
//     // **Simplification for now:** Fetch details based on IDs.
//     // In a real app, you'd likely fetch LineEntities first.
//     List<LineEntity> selectedLines = []; // Placeholder
//     Map<String, StopEntity> uniqueStops = {};
//     Map<String, BusEntity> activeBuses = {};
//     Map<String, LocationEntity> busLocations = {};
//
//     // Example: Fetch details concurrently (inefficient if LineEntity not available)
//     final List<Future<Either<Failure, dynamic>>> futures = [];
//     for (String lineId in event.lineIds) {
//        // Fetching LineEntity details just to build the list - not ideal
//        futures.add(_getLineDetailsUseCase(GetLineDetailsParams(lineId: lineId)));
//        futures.add(_getStopsForLineUseCase(GetStopsForLineParams(lineId: lineId)));
//        futures.add(_getBusesForLineUseCase(GetBusesForLineParams(lineId: lineId)));
//     }
//
//     final results = await Future.wait(futures);
//
//     // Process results (needs careful indexing and error checking)
//     bool hasError = false;
//     String errorMessage = 'Failed to load selected line details.';
//     List<StopEntity> consolidatedStops = [];
//     List<BusEntity> consolidatedBuses = [];
//
//     // This processing is complex without having fetched LineEntities first.
//     // Refactoring _fetchDetailsForLines might be better.
//     // Let's skip the complex processing here and rely on _fetchDetailsForLines
//     // by fetching the LineEntities first (even if inefficient for now).
//
//      List<LineEntity> fetchedLines = [];
//      final lineFutures = event.lineIds.map((id) => _getLineDetailsUseCase(GetLineDetailsParams(lineId: id))).toList();
//      final lineResults = await Future.wait(lineFutures);
//
//      for(final result in lineResults) {
//         result.fold(
//             (failure) => hasError = true, // Mark error if any line fails
//             (line) => fetchedLines.add(line)
//         );
//      }
//
//      if (hasError || fetchedLines.isEmpty) {
//         Log.e('BusTrackingBloc: Failed to fetch details for selected lines.');
//         emit(BusTrackingError(message: 'Could not load details for selected lines.'));
//         _stopPeriodicRefresh();
//         return;
//      }
//
//      Log.i('BusTrackingBloc: Fetched ${fetchedLines.length} selected lines. Fetching stops and buses...');
//      // Now fetch stops and buses for these lines
//      await _fetchDetailsForLines(fetchedLines, emit);
//   }
//
//   /// Common logic to fetch stops and buses for a given list of lines.
//   Future<void> _fetchDetailsForLines(List<LineEntity> lines, Emitter<BusTrackingState> emit) async {
//      final lineIds = lines.map((l) => l.id).toList();
//      final List<Future<Either<Failure, dynamic>>> detailFutures = [];
//
//       // Fetch Stops for all lines concurrently
//       detailFutures.add(Future.wait(lineIds.map((id) => _getStopsForLineUseCase(GetStopsForLineParams(lineId: id)))).toList());
//
//       // Fetch Buses for all lines concurrently
//        detailFutures.add(Future.wait(lineIds.map((id) => _getBusesForLineUseCase(GetBusesForLineParams(lineId: id)))).toList());
//
//       // Execute concurrent fetches
//       final detailResults = await Future.wait(detailFutures);
//
//       // Process Stops results
//       final Either<Failure, List<List<StopEntity>>> stopsResult = (detailResults[0] as List<Either<Failure, List<StopEntity>>>)
//           // Combine results: If any failed, return Left(firstFailure), else Right(listOfLists)
//           .fold(const Right([]), (previous, eitherResult) {
//               return previous.fold(
//                   (failure) => Left(failure), // Propagate first failure
//                   (accList) => eitherResult.fold(
//                       (failure) => Left(failure), // Found a failure
//                       (list) => Right([...accList, list]) // Accumulate lists on success
//                   )
//               );
//           });
//
//       // Process Buses results
//       final Either<Failure, List<List<BusEntity>>> busesResult = (detailResults[1] as List<Either<Failure, List<BusEntity>>>)
//            .fold(const Right([]), (previous, eitherResult) {
//               return previous.fold(
//                   (failure) => Left(failure),
//                   (accList) => eitherResult.fold(
//                       (failure) => Left(failure),
//                       (list) => Right([...accList, list])
//                   )
//               );
//           });
//
//        // Check for critical failures
//        Failure? failure;
//        stopsResult.fold((f) => failure = f, (_) {});
//        if (failure != null) {
//          Log.e('BusTrackingBloc: Failed to fetch stops.', error: failure);
//          emit(BusTrackingError(message: failure!.message ?? 'Failed to load stop data.'));
//          return;
//        }
//         busesResult.fold((f) => failure = f, (_) {});
//         if (failure != null) {
//          Log.e('BusTrackingBloc: Failed to fetch buses.', error: failure);
//          emit(BusTrackingError(message: failure!.message ?? 'Failed to load bus data.'));
//          return;
//        }
//
//        // Extract successful results
//        final List<List<StopEntity>> stopsPerLine = stopsResult.getOrElse(() => []);
//        final List<List<BusEntity>> busesPerLine = busesResult.getOrElse(() => []);
//
//        // Consolidate stops (remove duplicates)
//        final Map<String, StopEntity> uniqueStops = {};
//        for (final stopList in stopsPerLine) {
//           for (final stop in stopList) {
//              uniqueStops[stop.id] = stop;
//           }
//        }
//
//        // Consolidate buses (map by ID) and extract locations
//        final Map<String, BusEntity> activeBusesMap = {};
//        final Map<String, LocationEntity> busLocationsMap = {};
//        for (final busList in busesPerLine) {
//          for (final bus in busList) {
//            activeBusesMap[bus.id] = bus;
//            // Assuming BusEntity has lastKnownLocation after mapping (modify mapper if needed)
//            // Or fetch location separately? BusModel has is_tracking, not location.
//            // Let's assume GetBusesForLineUseCase/Repo fetches buses *with* latest location if available.
//            // Need to adjust BusEntity and mapper if necessary. Assuming BusEntity has LocationEntity? lastLocation
//            // if (bus.lastLocation != null) {
//            //   busLocationsMap[bus.id] = bus.lastLocation!;
//            // }
//            // TEMP: If BusEntity doesn't have location, create dummy based on bus ID
//            // Remove this when location fetching is integrated
//              busLocationsMap[bus.id] = LocationEntity(latitude: 36.7 + (bus.id.hashCode % 1000)/10000.0, longitude: 3.0 + (bus.id.hashCode % 500)/10000.0, timestamp: DateTime.now());
//          }
//        }
//
//        Log.i('BusTrackingBloc: Emitting loaded state with ${lines.length} lines, ${uniqueStops.length} stops, ${activeBusesMap.length} buses.');
//        emit(BusTrackingLoaded(
//           lines: lines,
//           stops: uniqueStops.values.toList(),
//           activeBuses: activeBusesMap,
//           busLocations: busLocationsMap,
//        ));
//
//        // Start or restart periodic refresh now that lines are selected/loaded
//        _startPeriodicRefresh();
//   }
//
//
//   /// Handles the periodic [RefreshActiveBuses] event.
//   Future<void> _onRefreshActiveBuses(
//       RefreshActiveBuses event, Emitter<BusTrackingState> emit) async {
//
//     if (state is BusTrackingLoaded) {
//       final currentState = state as BusTrackingLoaded;
//       if (currentState.lines.isEmpty) {
//          Log.d('BusTrackingBloc: Skipping refresh, no lines are currently tracked.');
//          return; // No lines to refresh buses for
//       }
//
//       Log.d('BusTrackingBloc: Handling RefreshActiveBuses event.');
//
//       final lineIds = currentState.lines.map((l) => l.id).toList();
//       final List<Future<Either<Failure, List<BusEntity>>>> futures = lineIds
//           .map((id) => _getBusesForLineUseCase(GetBusesForLineParams(lineId: id)))
//           .toList();
//
//       final results = await Future.wait(futures);
//
//        // Process Buses results (similar to _fetchDetailsForLines)
//        final Either<Failure, List<List<BusEntity>>> busesResult = results
//             .fold(const Right([]), (previous, eitherResult) {
//               return previous.fold(
//                   (failure) => Left(failure),
//                   (accList) => eitherResult.fold(
//                       (failure) => Left(failure),
//                       (list) => Right([...accList, list])
//                   )
//               );
//             });
//
//        await busesResult.fold(
//          (failure) async {
//             Log.w('BusTrackingBloc: Failed to refresh active buses.', error: failure);
//             // Don't emit error state, just log failure and keep existing data
//          },
//          (busesPerLine) async {
//             final Map<String, BusEntity> activeBusesMap = {};
//             final Map<String, LocationEntity> busLocationsMap = {};
//              for (final busList in busesPerLine) {
//                for (final bus in busList) {
//                  activeBusesMap[bus.id] = bus;
//                   // TODO: Extract real location from updated bus data
//                    busLocationsMap[bus.id] = LocationEntity(latitude: 36.7 + (bus.id.hashCode % 1000)/10000.0, longitude: 3.0 + (bus.id.hashCode % 500)/10000.0, timestamp: DateTime.now());
//                }
//              }
//
//              // Only emit if bus list or locations actually changed
//              if (!mapEquals(currentState.activeBuses, activeBusesMap) ||
//                  !mapEquals(currentState.busLocations, busLocationsMap)) {
//                  Log.i('BusTrackingBloc: Bus data updated, emitting new state.');
//                 emit(currentState.copyWith(
//                    activeBuses: activeBusesMap,
//                    busLocations: busLocationsMap,
//                 ));
//              } else {
//                 Log.d('BusTrackingBloc: No changes detected in bus data after refresh.');
//              }
//          }
//        );
//
//     } else {
//        Log.d('BusTrackingBloc: Skipping refresh, not in loaded state.');
//     }
//   }
//
//   /// Handles the [UpdateBusLocations] event (if using external location stream).
//   Future<void> _onUpdateBusLocations(
//       UpdateBusLocations event, Emitter<BusTrackingState> emit) async {
//      if (state is BusTrackingLoaded) {
//         final currentState = state as BusTrackingLoaded;
//         Log.d('BusTrackingBloc: Handling UpdateBusLocations event with ${event.updatedLocations.length} updates.');
//
//         // Create a new map with updated locations merged into the existing ones
//         final newLocations = Map<String, LocationEntity>.from(currentState.busLocations);
//         newLocations.addAll(event.updatedLocations);
//
//          // Prune locations for buses that are no longer in the activeBuses map? Optional.
//          // newLocations.removeWhere((busId, _) => !currentState.activeBuses.containsKey(busId));
//
//         // Only emit if locations actually changed
//         if (!mapEquals(currentState.busLocations, newLocations)) {
//            emit(currentState.copyWith(busLocations: newLocations));
//         }
//      }
//   }
//
//    /// Handles the [UserLocationUpdated] event.
//   Future<void> _onUserLocationUpdated(
//       UserLocationUpdated event, Emitter<BusTrackingState> emit) async {
//       // if (state is BusTrackingLoaded) {
//       //    final currentState = state as BusTrackingLoaded;
//       //    Log.d('BusTrackingBloc: Handling UserLocationUpdated event.');
//       //    emit(currentState.copyWith(userLocation: event.userLocation));
//       // }
//        Log.d('BusTrackingBloc: UserLocationUpdated event received (handler not fully implemented).');
//        // Add userLocation field to BusTrackingLoaded state and handle update here if needed.
//   }
// }
//
