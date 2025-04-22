/// lib/presentation/blocs/auth/auth_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart'; // Import Failure types
import '../../../core/utils/auth_state_provider.dart'; // Import the auth state provider
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
    Log.d('AuthBloc created. Initial state: ${state.runtimeType}'); // Added log

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

    // Indicate loading while checking, can be used by SplashPage
    emit(const AuthLoading()); // Added emit loading state

    final result = await _checkAuthStatusUseCase(const NoParams());

    final newState = result.fold(
          (failure) {
        Log.w('AuthBloc: Check auth status failed.', error: failure);
        // If checking status fails (e.g., network error verifying token),
        // treat the user as unauthenticated for app startup.
        AuthStateProvider.instance.setUnauthenticated(); // Update global state
        return const AuthUnauthenticated();
      },
          (userEntity) {
        if (userEntity != null) {
          Log.i('AuthBloc: User is authenticated. User ID: ${userEntity.id}, Type: ${userEntity.userType}'); // Added user ID log
          AuthStateProvider.instance.setAuthenticated(userEntity); // Update global state
          return AuthAuthenticated(user: userEntity);
        } else {
          Log.i('AuthBloc: User is not authenticated.');
          AuthStateProvider.instance.setUnauthenticated(); // Update global state
          return const AuthUnauthenticated();
        }
      },
    );

    Log.d('AuthBloc: Emitting state from AppStarted: ${newState.runtimeType}'); // Added log before emit
    emit(newState);

    Log.d('AuthBloc: Finished handling AppStarted event.'); // Added log
  }

  /// Handles the [LoggedIn] event triggered by a login attempt.
  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    Log.d('AuthBloc: Handling LoggedIn event for email: ${event.email}');
    Log.d('AuthBloc: Emitting state from LoggedIn: AuthLoading'); // Added log before emit
    emit(const AuthLoading()); // Show loading indicator during login attempt

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    final newState = result.fold(
          (failure) {
        Log.w('AuthBloc: Login failed.', error: failure);
        // Set global state to unauthenticated on failure
        AuthStateProvider.instance.setUnauthenticated();
        // Emit a specific failure state with the error message
        return AuthFailure(message: failure.message ?? 'Login failed. Please try again.'); // Provide default message
      },
          (userEntity) {
        Log.i('AuthBloc: Login successful for user: ${userEntity.email}. User ID: ${userEntity.id}, Type: ${userEntity.userType}'); // Added user ID log

        // Update global state provider FIRST to ensure router can access it
        AuthStateProvider.instance.setAuthenticated(userEntity);

        // Emit authenticated state with user data
        return AuthAuthenticated(user: userEntity);
      },
    );

    Log.d('AuthBloc: Emitting state from LoggedIn: ${newState.runtimeType}'); // Added log before emit
    emit(newState);

    // Ensure router refresh happens by triggering a second emit with a slight delay
    if (newState is AuthAuthenticated) {
      Log.i('AuthBloc: Forcing router refresh after successful login');
      // Adding a tiny delay before re-emitting to ensure the router picks up the change
      await Future.delayed(const Duration(milliseconds: 50));
      Log.d('AuthBloc: Re-emitting AuthAuthenticated state to force router refresh');
      emit(newState);  // Re-emit the same state to force a router notification
    }

    Log.d('AuthBloc: Finished handling LoggedIn event.'); // Added log
  }

  /// Handles the [LoggedOut] event triggered by a logout request.
  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    Log.d('AuthBloc: Handling LoggedOut event.');
    Log.d('AuthBloc: Emitting state from LoggedOut: AuthLoading'); // Added log before emit
    emit(const AuthLoading()); // Show loading indicator during logout

    final result = await _logoutUseCase(const NoParams());

    // Update global state BEFORE emitting the new state
    AuthStateProvider.instance.setUnauthenticated();

    // Regardless of whether the backend logout call succeeds or fails,
    // the local tokens are cleared, so we always transition to unauthenticated locally.
    // We might log the failure if one occurs.
    final newState = result.fold(
          (failure) {
        Log.e('AuthBloc: Logout operation failed (local token clear might have still worked).', error: failure);
        // Emit unauthenticated even on failure, as local state is cleared.
        return const AuthUnauthenticated();
      },
          (_) {
        Log.i('AuthBloc: Logout successful.');
        // Emit unauthenticated state
        return const AuthUnauthenticated();
      },
    );

    Log.d('AuthBloc: Emitting state from LoggedOut: ${newState.runtimeType}'); // Added log before emit
    emit(newState);

    Log.d('AuthBloc: Finished handling LoggedOut event.'); // Added log

    // Ensure unauthenticated state is emitted even if fold somehow doesn't (fallback safety)
    if (state is! AuthUnauthenticated) {
      Log.w('AuthBloc: State is not AuthUnauthenticated after logout handling, forcing.'); // Added log for this case
      emit(const AuthUnauthenticated());
    }
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    super.onTransition(transition);
    Log.d('AuthBloc Transition: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType} due to ${transition.event.runtimeType}');
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    Log.d('AuthBloc Changed: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }
}


// /// lib/presentation/blocs/auth/auth_bloc.dart
//
// import 'dart:async';
//
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
//
// import '../../../core/error/failures.dart'; // Import Failure types
// import '../../../core/utils/logger.dart';
// import '../../../domain/entities/user_entity.dart';
// import '../../../domain/usecases/auth/check_auth_status_usecase.dart';
// import '../../../domain/usecases/auth/login_usecase.dart';
// import '../../../domain/usecases/auth/logout_usecase.dart';
// import '../../../domain/usecases/base_usecase.dart'; // For NoParams
//
// part 'auth_event.dart';
// part 'auth_state.dart';
//
// /// BLoC responsible for managing the application's authentication state.
// ///
// /// Handles user login, logout, and initial authentication status checks.
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final CheckAuthStatusUseCase _checkAuthStatusUseCase;
//   final LoginUseCase _loginUseCase;
//   final LogoutUseCase _logoutUseCase;
//
//   /// Creates an instance of [AuthBloc].
//   ///
//   /// Requires use cases for checking status, logging in, and logging out.
//   /// Automatically triggers an [AppStarted] event upon creation to check
//   /// the initial authentication state.
//   AuthBloc({
//     required CheckAuthStatusUseCase checkAuthStatusUseCase,
//     required LoginUseCase loginUseCase,
//     required LogoutUseCase logoutUseCase,
//   })  : _checkAuthStatusUseCase = checkAuthStatusUseCase,
//         _loginUseCase = loginUseCase,
//         _logoutUseCase = logoutUseCase,
//         super(const AuthInitial()) { // Start with the initial state
//     Log.d('AuthBloc created. Initial state: ${state.runtimeType}'); // Added log
//
//     // Register event handlers
//     on<AppStarted>(_onAppStarted);
//     on<LoggedIn>(_onLoggedIn);
//     on<LoggedOut>(_onLoggedOut);
//
//     // Trigger the initial auth check when the BLoC is created
//     add(const AppStarted());
//   }
//
//   /// Handles the [AppStarted] event to check the initial authentication state.
//   Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
//     Log.d('AuthBloc: Handling AppStarted event.');
//
//     // Indicate loading while checking, can be used by SplashPage
//     emit(const AuthLoading()); // Added emit loading state
//
//     final result = await _checkAuthStatusUseCase(const NoParams());
//
//     final newState = result.fold(
//           (failure) {
//         Log.w('AuthBloc: Check auth status failed.', error: failure);
//         // If checking status fails (e.g., network error verifying token),
//         // treat the user as unauthenticated for app startup.
//         return const AuthUnauthenticated();
//       },
//           (userEntity) {
//         if (userEntity != null) {
//           Log.i('AuthBloc: User is authenticated. User ID: ${userEntity.id}'); // Added user ID log
//           return AuthAuthenticated(user: userEntity);
//         } else {
//           Log.i('AuthBloc: User is not authenticated.');
//           return const AuthUnauthenticated();
//         }
//       },
//     );
//
//     Log.d('AuthBloc: Emitting state from AppStarted: ${newState.runtimeType}'); // Added log before emit
//     emit(newState);
//
//     Log.d('AuthBloc: Finished handling AppStarted event.'); // Added log
//   }
//
//   /// Handles the [LoggedIn] event triggered by a login attempt.
//   Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
//     Log.d('AuthBloc: Handling LoggedIn event for email: ${event.email}');
//     Log.d('AuthBloc: Emitting state from LoggedIn: AuthLoading'); // Added log before emit
//     emit(const AuthLoading()); // Show loading indicator during login attempt
//
//     final result = await _loginUseCase(
//       LoginParams(email: event.email, password: event.password),
//     );
//
//     final newState = result.fold(
//           (failure) {
//         Log.w('AuthBloc: Login failed.', error: failure);
//         // Emit a specific failure state with the error message
//         return AuthFailure(message: failure.message ?? 'Login failed. Please try again.'); // Provide default message
//       },
//           (userEntity) {
//         Log.i('AuthBloc: Login successful for user: ${userEntity.email}. User ID: ${userEntity.id}'); // Added user ID log
//         // Emit authenticated state with user data
//         return AuthAuthenticated(user: userEntity);
//       },
//     );
//
//     Log.d('AuthBloc: Emitting state from LoggedIn: ${newState.runtimeType}'); // Added log before emit
//     emit(newState);
//
//     Log.d('AuthBloc: Finished handling LoggedIn event.'); // Added log
//   }
//
//   /// Handles the [LoggedOut] event triggered by a logout request.
//   Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
//     Log.d('AuthBloc: Handling LoggedOut event.');
//     Log.d('AuthBloc: Emitting state from LoggedOut: AuthLoading'); // Added log before emit
//     emit(const AuthLoading()); // Show loading indicator during logout
//
//     final result = await _logoutUseCase(const NoParams());
//
//     // Regardless of whether the backend logout call succeeds or fails,
//     // the local tokens are cleared, so we always transition to unauthenticated locally.
//     // We might log the failure if one occurs.
//     final newState = result.fold(
//           (failure) {
//         Log.e('AuthBloc: Logout operation failed (local token clear might have still worked).', error: failure);
//         // Emit unauthenticated even on failure, as local state is cleared.
//         return const AuthUnauthenticated();
//       },
//           (_) {
//         Log.i('AuthBloc: Logout successful.');
//         // Emit unauthenticated state
//         return const AuthUnauthenticated();
//       },
//     );
//
//     Log.d('AuthBloc: Emitting state from LoggedOut: ${newState.runtimeType}'); // Added log before emit
//     emit(newState);
//
//     Log.d('AuthBloc: Finished handling LoggedOut event.'); // Added log
//
//     // Ensure unauthenticated state is emitted even if fold somehow doesn't (fallback safety)
//     if (state is! AuthUnauthenticated) {
//       Log.w('AuthBloc: State is not AuthUnauthenticated after logout handling, forcing.'); // Added log for this case
//       emit(const AuthUnauthenticated());
//     }
//   }
// }