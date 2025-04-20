/// lib/presentation/blocs/driver_profile/driver_profile_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For transformers
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For ValueGetter

import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/driver_entity.dart';
import '../../../domain/usecases/base_usecase.dart'; // For NoParams
import '../../../domain/usecases/driver/get_driver_profile_usecase.dart';
import '../../../domain/usecases/driver/update_driver_details_usecase.dart';

part 'driver_profile_event.dart';
part 'driver_profile_state.dart';

/// BLoC responsible for managing the state of the Driver's Profile screen,
/// handling fetching and updating driver-specific details.
class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final GetDriverProfileUseCase _getDriverProfileUseCase;
  final UpdateDriverDetailsUseCase _updateDriverDetailsUseCase;

  /// Creates an instance of [DriverProfileBloc].
  DriverProfileBloc({
    required GetDriverProfileUseCase getDriverProfileUseCase,
    required UpdateDriverDetailsUseCase updateDriverDetailsUseCase,
  })  : _getDriverProfileUseCase = getDriverProfileUseCase,
        _updateDriverDetailsUseCase = updateDriverDetailsUseCase,
        super(const DriverProfileInitial()) {
    // Register event handlers
    on<LoadDriverProfile>(
      _onLoadDriverProfile,
      transformer: restartable(),
    );
    on<UpdateDriverDetailsSubmitted>(
      _onUpdateDriverDetailsSubmitted,
      transformer: droppable(),
    );

    // Trigger initial load
    add(const LoadDriverProfile());
  }

  /// Handles the [LoadDriverProfile] event to fetch the driver's details.
  Future<void> _onLoadDriverProfile(
      LoadDriverProfile event, Emitter<DriverProfileState> emit) async {
    Log.d('DriverProfileBloc: Handling LoadDriverProfile event.');
    emit(const DriverProfileLoading());

    final result = await _getDriverProfileUseCase(const NoParams());

    // This fold structure is correct: it returns the state to be emitted.
    emit(result.fold(
          (failure) {
        Log.e('DriverProfileBloc: Failed to load driver profile.', error: failure);
        return DriverProfileError(message: failure.message ?? 'Failed to load profile.');
      },
          (driverProfile) {
        Log.i('DriverProfileBloc: Driver profile loaded successfully (ID: ${driverProfile.id}).');
        return DriverProfileLoaded(driverProfile: driverProfile);
      },
    ));
  }

  /// Handles the [UpdateDriverDetailsSubmitted] event to update the profile.
  Future<void> _onUpdateDriverDetailsSubmitted(
      UpdateDriverDetailsSubmitted event, Emitter<DriverProfileState> emit) async {
    Log.d('DriverProfileBloc: Handling UpdateDriverDetailsSubmitted event.');

    DriverEntity? profileBeforeUpdate;
    if (state is DriverProfileLoaded) {
      profileBeforeUpdate = (state as DriverProfileLoaded).driverProfile;
    } else if (state is DriverProfileUpdating) {
      profileBeforeUpdate = (state as DriverProfileUpdating).driverProfileBeforeUpdate;
    } else if (state is DriverProfileError) {
      profileBeforeUpdate = (state as DriverProfileError).driverProfile;
    }

    if (profileBeforeUpdate == null) {
      Log.e('DriverProfileBloc: Cannot update profile, current profile state is not loaded.');
      emit(const DriverProfileError(message: 'Cannot update profile, current data unavailable.'));
      return;
    }

    emit(DriverProfileUpdating(driverProfileBeforeUpdate: profileBeforeUpdate));

    final result = await _updateDriverDetailsUseCase(
      UpdateDriverDetailsParams(
        idPhoto: event.idPhoto, licensePhoto: event.licensePhoto,
        experienceYears: event.experienceYears, dateOfBirth: event.dateOfBirth,
        address: event.address, emergencyContact: event.emergencyContact,
        notes: event.notes, isActive: event.isActive,
      ),
    );

    // CORRECTED: Assign the result of fold to a variable, then emit it.
    final newState = result.fold(
          (failure) {
        Log.e('DriverProfileBloc: Failed to update driver details.', error: failure);
        // Return the error state
        return DriverProfileError(
            message: failure.message ?? 'Failed to update profile.',
            driverProfile: profileBeforeUpdate // Provide context
        );
      },
          (updatedDriverProfile) {
        Log.i('DriverProfileBloc: Driver profile updated successfully (ID: ${updatedDriverProfile.id}).');
        // Return the loaded state with the new profile data
        return DriverProfileLoaded(driverProfile: updatedDriverProfile);
      },
    );
    emit(newState); // Emit the state returned by fold
  }
}