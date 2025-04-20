/// lib/presentation/blocs/forgot_password/forgot_password_state.dart

part of 'forgot_password_cubit.dart'; // Link to the Cubit file

/// Base abstract class for all states related to the forgot password request process.
/// Uses [Equatable] for value comparison.
abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the user attempts to request a password reset.
class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

/// State indicating that the password reset request is being sent to the backend.
class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

/// State indicating that the password reset request was successfully sent.
/// Typically, the UI will show a confirmation message asking the user to check their email.
class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess();
}

/// State indicating that an error occurred while requesting the password reset.
class ForgotPasswordFailure extends ForgotPasswordState {
  /// The error message describing the failure.
  final String message;

  const ForgotPasswordFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'ForgotPasswordFailure(message: $message)';
}
