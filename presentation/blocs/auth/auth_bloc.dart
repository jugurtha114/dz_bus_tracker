/// lib/presentation/blocs/auth/auth_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart'; // Import Failure types
import '../../../core/utils/logger.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/base_usecase.dart'; // For NoParams

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC responsible for managing the application's authentication state.
///
/// Handles user login, logout, and initial authentication status checks.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  /// Creates an instance of [AuthBloc].
  ///
  /// Requires use cases for checking status, logging in, and logging out.
  /// Automatically triggers an [AppStarted] event upon creation to check
  /// the initial authentication state.
  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) { // Start with the initial state
    // Register event handlers
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);

    // Trigger the initial auth check when the BLoC is created
    add(const AppStarted());
  }

  /// Handles the [AppStarted] event to check the initial authentication state.
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    Log.d('AuthBloc: Handling AppStarted event.');
    // No loading state needed here usually, as splash screen handles UI wait
    // emit(AuthLoading()); // Optionally emit loading if check takes time

    final result = await _checkAuthStatusUseCase(const NoParams());

    emit(result.fold(
      (failure) {
        Log.w('AuthBloc: Check auth status failed.', error: failure);
        // If checking status fails (e.g., network error verifying token),
        // treat the user as unauthenticated for app startup.
        return const AuthUnauthenticated();
      },
      (userEntity) {
        if (userEntity != null) {
          Log.i('AuthBloc: User is authenticated.',);
          return AuthAuthenticated(user: userEntity);
        } else {
           Log.i('AuthBloc: User is not authenticated.');
          return const AuthUnauthenticated();
        }
      },
    ));
  }

  /// Handles the [LoggedIn] event triggered by a login attempt.
  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
     Log.d('AuthBloc: Handling LoggedIn event for email: ${event.email}');
    emit(const AuthLoading()); // Show loading indicator during login attempt

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    emit(result.fold(
      (failure) {
         Log.w('AuthBloc: Login failed.', error: failure);
        // Emit a specific failure state with the error message
        return AuthFailure(message: failure.message ?? 'Login failed. Please try again.'); // Provide default message
      },
      (userEntity) {
         Log.i('AuthBloc: Login successful for user: ${userEntity.email}');
        // Emit authenticated state with user data
        return AuthAuthenticated(user: userEntity);
      },
    ));
  }

  /// Handles the [LoggedOut] event triggered by a logout request.
  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    Log.d('AuthBloc: Handling LoggedOut event.');
    emit(const AuthLoading()); // Show loading indicator during logout

    final result = await _logoutUseCase(const NoParams());

    // Regardless of whether the backend logout call succeeds or fails,
    // the local tokens are cleared, so we always transition to unauthenticated locally.
    // We might log the failure if one occurs.
    result.fold(
      (failure) {
        Log.e('AuthBloc: Logout operation failed (local token clear might have still worked).', error: failure);
        // Emit unauthenticated even on failure, as local state is cleared.
        emit(const AuthUnauthenticated());
      },
      (_) {
         Log.i('AuthBloc: Logout successful.');
        // Emit unauthenticated state
        emit(const AuthUnauthenticated());
      },
    );
     // Ensure unauthenticated state is emitted even if fold somehow doesn't
     if (state is! AuthUnauthenticated) {
       emit(const AuthUnauthenticated());
     }
  }
}
