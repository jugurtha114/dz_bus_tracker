/// lib/presentation/blocs/driver_bus/driver_bus_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/bus_entity.dart';
import '../../../domain/usecases/base_usecase.dart'; // For NoParams
import '../../../domain/usecases/bus/add_bus_usecase.dart';
import '../../../domain/usecases/bus/get_driver_buses_usecase.dart'; // Renamed UseCase dependency
import '../../../domain/usecases/bus/update_bus_usecase.dart';

part 'driver_bus_event.dart';
part 'driver_bus_state.dart';

/// BLoC responsible for managing the state related to the driver's associated buses.
///
/// Handles fetching the list of buses, adding new buses, and updating existing ones.
class DriverBusBloc extends Bloc<DriverBusEvent, DriverBusState> {
  // Use the renamed use case: GetDriverBusesUseCase
  final GetDriverBusesUseCase _getDriverBusesUseCase;
  final AddBusUseCase _addBusUseCase;
  final UpdateBusUseCase _updateBusUseCase;
  // Inject DeleteBusUseCase if implementing delete functionality

  /// Creates an instance of [DriverBusBloc].
  DriverBusBloc({
    required GetDriverBusesUseCase getDriverBusesUseCase, // Updated type
    required AddBusUseCase addBusUseCase,
    required UpdateBusUseCase updateBusUseCase,
  })  : _getDriverBusesUseCase = getDriverBusesUseCase, // Updated assignment
        _addBusUseCase = addBusUseCase,
        _updateBusUseCase = updateBusUseCase,
        super(const DriverBusInitial()) {

    // Register event handlers
    on<LoadDriverBuses>(
      _onLoadDriverBuses,
      transformer: restartable(),
    );
    on<AddBusSubmitted>(
      _onAddBusSubmitted,
      transformer: droppable(), // Prevent multiple adds at once
    );
    on<UpdateBusSubmitted>(
      _onUpdateBusSubmitted,
      transformer: droppable(), // Prevent multiple updates at once
    );
    // Internal event handler to reload list after modification
    on<_DriverBusesChanged>(
      (event, emit) => add(const LoadDriverBuses()), // Trigger full reload
      transformer: restartable(), // Debounce/restart reloads
    );

    // Trigger initial load
    add(const LoadDriverBuses());
  }

  /// Handles the [LoadDriverBuses] event.
  Future<void> _onLoadDriverBuses(
      LoadDriverBuses event, Emitter<DriverBusState> emit) async {
    Log.d('DriverBusBloc: Handling LoadDriverBuses event.');
    // Emit loading state, preserving current list if available
    final List<BusEntity>? currentBuses = state is DriverBusLoaded
        ? (state as DriverBusLoaded).buses
        : (state is DriverBusLoading ? (state as DriverBusLoading).currentBuses : null);
    emit(DriverBusLoading(currentBuses: currentBuses));

    final result = await _getDriverBusesUseCase(const NoParams()); // Use correct use case

    emit(result.fold(
      (failure) {
        Log.e('DriverBusBloc: Failed to load driver buses.', error: failure);
        return DriverBusError(message: failure.message ?? 'Failed to load buses.');
      },
      (buses) {
        Log.i('DriverBusBloc: Driver buses loaded successfully (${buses.length} buses).');
        return DriverBusLoaded(buses: buses);
      },
    ));
  }

  /// Handles the [AddBusSubmitted] event.
  Future<void> _onAddBusSubmitted(
      AddBusSubmitted event, Emitter<DriverBusState> emit) async {
     Log.d('DriverBusBloc: Handling AddBusSubmitted event for matricule: ${event.matricule}');
     // Keep displaying current list while loading
     final List<BusEntity>? currentBuses = state is DriverBusLoaded
        ? (state as DriverBusLoaded).buses
        : (state is DriverBusLoading ? (state as DriverBusLoading).currentBuses : null);
     emit(DriverBusLoading(currentBuses: currentBuses));

     final result = await _addBusUseCase(AddBusParams(
        driverId: event.driverId, // Pass driverId from event
        matricule: event.matricule,
        brand: event.brand,
        model: event.model,
        year: event.year,
        capacity: event.capacity,
        description: event.description,
        photos: event.photos,
     ));

     result.fold(
        (failure) {
           Log.e('DriverBusBloc: Failed to add bus.', error: failure);
           // Emit error state, keeping previous list for context if available
           emit(DriverBusError(
              message: failure.message ?? 'Failed to add bus.',
              previousBuses: currentBuses,
           ));
        },
        (_) {
           Log.i('DriverBusBloc: Bus added successfully. Triggering list refresh.');
           // Trigger internal event to reload the list to show the new bus
           add(const _DriverBusesChanged());
           // Could potentially optimistically update the state here,
           // but reloading ensures consistency.
        }
     );
  }

  /// Handles the [UpdateBusSubmitted] event.
  Future<void> _onUpdateBusSubmitted(
      UpdateBusSubmitted event, Emitter<DriverBusState> emit) async {
      Log.d('DriverBusBloc: Handling UpdateBusSubmitted event for busId: ${event.busId}');
       final List<BusEntity>? currentBuses = state is DriverBusLoaded
        ? (state as DriverBusLoaded).buses
        : (state is DriverBusLoading ? (state as DriverBusLoading).currentBuses : null);
       emit(DriverBusLoading(currentBuses: currentBuses));

       final result = await _updateBusUseCase(UpdateBusParams(
         busId: event.busId,
         brand: event.brand,
         model: event.model,
         year: event.year,
         capacity: event.capacity,
         description: event.description,
         isActive: event.isActive,
         nextMaintenance: event.nextMaintenance,
       ));

       result.fold(
        (failure) {
           Log.e('DriverBusBloc: Failed to update bus.', error: failure);
           emit(DriverBusError(
              message: failure.message ?? 'Failed to update bus.',
              previousBuses: currentBuses,
              ));
        },
        (_) {
           Log.i('DriverBusBloc: Bus updated successfully. Triggering list refresh.');
           add(const _DriverBusesChanged());
        }
     );
  }
}
