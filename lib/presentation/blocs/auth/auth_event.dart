/// lib/presentation/blocs/auth/auth_event.dart

part of 'auth_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all authentication-related events.
/// Uses [Equatable] for value comparison.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the application starts, initiating an authentication status check.
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Event triggered when the user attempts to log in with credentials.
class LoggedIn extends AuthEvent {
  /// The email provided by the user.
  final String email;
  /// The password provided by the user.
  final String password;

  const LoggedIn({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];

  @override
  String toString() => 'LoggedIn(email: $email, password: ***)'; // Avoid logging password
}

/// Event triggered when the user requests to log out.
class LoggedOut extends AuthEvent {
  const LoggedOut();
}

// Add other potential events here if needed later, for example:
// class PasswordResetRequested extends AuthEvent { ... }
// class RegistrationAttempted extends AuthEvent { ... }

