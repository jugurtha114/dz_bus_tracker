/// lib/presentation/blocs/auth/auth_state.dart

part of 'auth_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all authentication states.
/// Uses [Equatable] for state comparison.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication checks have been performed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State indicating that an authentication operation (check, login, logout) is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State indicating the user is successfully authenticated.
/// Holds the authenticated user's information.
class AuthAuthenticated extends AuthState {
  /// The authenticated user's entity.
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'AuthAuthenticated(user: ${user.email})';
}

/// State indicating the user is not authenticated (logged out or never logged in).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State indicating that an error occurred during an authentication attempt
/// (e.g., network error, invalid credentials during login).
class AuthFailure extends AuthState {
  /// The error message describing the failure.
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthFailure(message: $message)';
}
