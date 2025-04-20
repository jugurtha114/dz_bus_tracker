/// lib/presentation/blocs/driver_profile/driver_profile_state.dart

part of 'driver_profile_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to the driver's profile management.
/// Uses [Equatable] for state comparison.
abstract class DriverProfileState extends Equatable {
  const DriverProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the driver's profile has been loaded.
class DriverProfileInitial extends DriverProfileState {
  const DriverProfileInitial();
}

/// State indicating that the driver's profile data is currently being fetched.
class DriverProfileLoading extends DriverProfileState {
  const DriverProfileLoading();
}

/// State indicating that the driver's profile data has been successfully loaded.
class DriverProfileLoaded extends DriverProfileState {
  /// The loaded driver profile entity.
  final DriverEntity driverProfile;

  const DriverProfileLoaded({required this.driverProfile});

  /// Creates a copy of the current loaded state with updated values.
  DriverProfileLoaded copyWith({
    DriverEntity? driverProfile,
  }) {
    return DriverProfileLoaded(
      driverProfile: driverProfile ?? this.driverProfile,
    );
  }

  @override
  List<Object?> get props => [driverProfile];

  @override
  String toString() => 'DriverProfileLoaded(driverId: ${driverProfile.id})';
}

/// State indicating that an update operation on the driver's profile is in progress.
class DriverProfileUpdating extends DriverProfileState {
   /// The driver profile state just before the update attempt began.
   /// Useful for potentially showing previous data while updating.
   final DriverEntity driverProfileBeforeUpdate;

   const DriverProfileUpdating({required this.driverProfileBeforeUpdate});

   @override
   List<Object?> get props => [driverProfileBeforeUpdate];
}

/// State indicating that an error occurred while fetching or updating the driver's profile.
class DriverProfileError extends DriverProfileState {
  /// The error message describing the failure.
  final String message;
  /// Optional: The profile data from before the error occurred, for context or retry.
  final DriverEntity? driverProfile;

  const DriverProfileError({required this.message, this.driverProfile});

  @override
  List<Object?> get props => [message, driverProfile];

   @override
  String toString() => 'DriverProfileError(message: $message)';
}

// Note: A specific 'DriverProfileUpdateSuccess' state is omitted for simplicity.
// Success feedback can be handled via BlocListener in the UI after transitioning
// back to DriverProfileLoaded with the updated data.

