/// lib/presentation/blocs/reset_password/reset_password_state.dart

part of 'reset_password_cubit.dart'; // Link to the Cubit file

/// Base abstract class for all states related to the password reset finalization process.
/// Uses [Equatable] for value comparison.
abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the user attempts to reset the password using a token.
class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial();
}

/// State indicating that the password reset request is being processed.
class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();
}

/// State indicating that the password was successfully reset.
/// The UI should typically navigate the user to the login screen after this.
class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess();
}

/// State indicating that an error occurred during the password reset attempt.
class ResetPasswordFailure extends ResetPasswordState {
  /// The error message describing the failure (e.g., invalid token, password mismatch).
  final String message;

  const ResetPasswordFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'ResetPasswordFailure(message: $message)';
}

