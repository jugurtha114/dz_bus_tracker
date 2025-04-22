/// lib/presentation/blocs/registration/registration_state.dart

part of 'registration_cubit.dart'; // Link to the Cubit file

/// Base abstract class for all states related to the user registration process.
/// Uses [Equatable] for value comparison.
abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the user starts the registration process.
class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();
}

/// State indicating that the registration request is being processed.
class RegistrationLoading extends RegistrationState {
  const RegistrationLoading();
}

/// State indicating that the user registration was successful.
class RegistrationSuccess extends RegistrationState {
  // Optionally include the created UserEntity if needed immediately after registration
  // final UserEntity registeredUser;
  // const RegistrationSuccess({required this.registeredUser});
  const RegistrationSuccess();

  // @override List<Object?> get props => [registeredUser];
}

/// State indicating that an error occurred during the registration process.
class RegistrationFailure extends RegistrationState {
  /// The error message describing the failure.
  final String message;

  const RegistrationFailure({required this.message});

  @override
  List<Object?> get props => [message];

   @override
  String toString() => 'RegistrationFailure(message: $message)';
}
