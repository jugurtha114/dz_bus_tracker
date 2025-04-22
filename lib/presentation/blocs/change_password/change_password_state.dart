/// lib/presentation/blocs/change_password/change_password_state.dart

part of 'change_password_cubit.dart'; // Link to the Cubit file

/// Base abstract class for all states related to the change password process.
/// Uses [Equatable] for value comparison.
abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any change password attempt.
class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

/// State indicating that the change password request is being processed.
class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();
}

/// State indicating that the password was successfully changed.
class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();
}

/// State indicating that an error occurred during the password change attempt.
class ChangePasswordFailure extends ChangePasswordState {
  /// The error message describing the failure.
  final String message;

  const ChangePasswordFailure({required this.message});

  @override
  List<Object?> get props => [message];

   @override
  String toString() => 'ChangePasswordFailure(message: $message)';
}
