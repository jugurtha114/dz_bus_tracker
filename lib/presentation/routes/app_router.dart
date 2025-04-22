/// lib/presentation/routes/app_router.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/service_locator.dart';
import '../../core/enums/user_type.dart';
import '../../core/utils/auth_state_provider.dart'; // Import the global auth state provider
import '../../core/utils/logger.dart';
import '../../domain/entities/driver_entity.dart'; // Needed for passing extra args
import '../../domain/entities/user_entity.dart';
import '../blocs/auth/auth_bloc.dart';
// Import ALL Page Widgets
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/auth/reset_password_page.dart';

import '../pages/driver/driver_add_edit_bus_page.dart';
import '../pages/driver/driver_bus_management_page.dart';
import '../pages/driver/driver_dashboard_page.dart';
import '../pages/driver/driver_profile_edit_page.dart';
import '../pages/driver/driver_profile_page.dart';
import '../pages/driver/driver_start_tracking_setup_page.dart';
import '../pages/onboarding/language_selection_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/passenger/line_details_page.dart';
import '../pages/passenger/passenger_home_page.dart';
import '../pages/passenger/stop_details_page.dart';
import '../pages/settings/change_password_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/settings/user_profile_edit_page.dart';
import '../pages/splash/splash_page.dart';
import '../pages/notifications/notification_list_page.dart';
import '../widgets/common/error_display.dart';
import 'route_names.dart';


/// Configures the application's routes using GoRouter.
/// Includes redirection logic based on authentication state and onboarding status.
class AppRouter {
  AppRouter._();
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter? _router;
  static GoRouter get router {
    if (_router == null) {
      Log.i("[ROUTER INIT] Creating new router instance");
      try {
        _router = configureRouter();
      } catch (e, stackTrace) {
        Log.e("[ROUTER INIT] Failed to create router", error: e, stackTrace: stackTrace);
        throw Exception("Failed to configure router: $e");
      }
    }
    return _router!;
  }

  static GoRouter configureRouter() {
    final AuthBloc authBloc = sl<AuthBloc>();
    final SharedPreferences prefs = sl<SharedPreferences>();

    Log.i("[ROUTER INIT] Configuring router with AuthBloc state: ${authBloc.state.runtimeType}");

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteNames.splashPath,
      debugLogDiagnostics: true,  // Enable built-in GoRouter logging

      // Enhanced refresh stream with additional logging
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      // Redirect Handler with verbose logging
      redirect: (BuildContext context, GoRouterState state) {
        // Get the current auth state from the global provider for consistency
        final bool isAuthenticated = AuthStateProvider.instance.isAuthenticated;
        final UserEntity? currentUser = AuthStateProvider.instance.currentUser;
        final bool onboardingComplete = prefs.getBool(StorageKeys.onboardingComplete) ?? false;
        final String location = state.matchedLocation;

        // Log every redirect call with state information
        Log.i("--- ROUTER REDIRECT TRIGGERED ---");
        Log.d("Router Redirect: Current location='$location'");
        Log.d("Router Redirect: Global auth state=${isAuthenticated ? 'AUTHENTICATED' : 'UNAUTHENTICATED'}");
        if (isAuthenticated && currentUser != null) {
          Log.d("Router Redirect: Authenticated as user type=${currentUser.userType}, id=${currentUser.id}");
        }
        Log.d("Router Redirect: Onboarding complete=$onboardingComplete");

        // Allow Splash Page access
        if (location == RouteNames.splashPath) {
          Log.d("Router Redirect: Allowing access to Splash page.");
          return null;
        }

        // Define authentication routes
        final bool onAuthRoute = location == RouteNames.loginPath ||
            location == RouteNames.registerPath ||
            location == RouteNames.forgotPasswordPath ||
            location == RouteNames.resetPasswordPath;

        Log.d("Router Redirect: Current route is ${onAuthRoute ? 'an auth route' : 'NOT an auth route'}");

        // Handle authenticated user
        if (isAuthenticated && currentUser != null) {
          Log.i("Router Redirect: User IS authenticated");

          // If user is on an auth route, redirect to appropriate home
          if (onAuthRoute) {
            String homePath;

            // Determine home path based on user type
            if (currentUser.userType == UserType.driver) {
              homePath = RouteNames.driverDashboardPath;
            } else if (currentUser.userType == UserType.admin) {
              homePath = RouteNames.passengerHomePath; // Default admin to passenger home
              Log.i("Router Redirect: Admin user detected, redirecting to passenger home");
            } else {
              homePath = RouteNames.passengerHomePath; // Default to passenger home
            }

            Log.i("Router Redirect: Redirecting authenticated user from auth route '$location' to '$homePath'");
            return homePath;
          } else {
            Log.d("Router Redirect: Authenticated user allowed to stay on non-auth route: '$location'");
            return null; // Allow access to non-auth routes
          }
        } else {
          Log.d("Router Redirect: User is NOT authenticated");
        }

        // Handle onboarding
        if (!onboardingComplete) {
          if (location != RouteNames.languageSelectionPath && location != RouteNames.onboardingPath) {
            Log.i("Router Redirect: Redirecting to Language Selection (Onboarding Incomplete)");
            return RouteNames.languageSelectionPath;
          } else {
            Log.d("Router Redirect: Allowing access to onboarding route: '$location'");
            return null;
          }
        }

        // Redirect unauthenticated users from protected routes to login
        if (!onAuthRoute && !isAuthenticated) {
          Log.i("Router Redirect: Redirecting unauthenticated user from '$location' to login");
          return RouteNames.loginPath;
        }

        Log.d("Router Redirect: No redirection needed for location '$location'");
        return null;
      },

      // --- Route Definitions ---
      routes: <RouteBase>[
        GoRoute( name: RouteNames.splash, path: RouteNames.splashPath, builder: (c, s) => const SplashPage()),
        GoRoute( name: RouteNames.languageSelection, path: RouteNames.languageSelectionPath, builder: (c, s) => const LanguageSelectionPage()),
        GoRoute( name: RouteNames.onboarding, path: RouteNames.onboardingPath, builder: (c, s) => const OnboardingPage()),
        GoRoute( name: RouteNames.login, path: RouteNames.loginPath, builder: (c, s) => const LoginPage()),
        GoRoute( name: RouteNames.register, path: RouteNames.registerPath, builder: (c, s) => const RegisterPage()),
        GoRoute( name: RouteNames.forgotPassword, path: RouteNames.forgotPasswordPath, builder: (c, s) => const ForgotPasswordPage()),
        GoRoute(
            name: RouteNames.resetPassword,
            path: RouteNames.resetPasswordPath,
            builder: (context, state) {
              final token = state.uri.queryParameters['token'];
              if (token == null) return const ErrorDisplay(message: 'Missing reset token'); // TODO: Localize
              return ResetPasswordPage(token: token);
            }
        ),

        // Passenger Routes
        GoRoute(
            name: RouteNames.passengerHome,
            path: RouteNames.passengerHomePath, // e.g., /passenger
            builder: (c, s) => const PassengerHomePage(),
            routes: [
              GoRoute(
                  name: RouteNames.lineDetails,
                  path: RouteNames.lineDetailsPath, // e.g., /passenger/line/:lineId
                  builder: (c, s) => LineDetailsPage(lineId: s.pathParameters['lineId']!)
              ),
              GoRoute(
                  name: RouteNames.stopDetails,
                  path: RouteNames.stopDetailsPath, // e.g., /passenger/stop/:stopId
                  builder: (c, s) => StopDetailsPage(stopId: s.pathParameters['stopId']!)
              ),
              // Add other nested passenger routes here
            ]
        ),

        // Driver Routes
        GoRoute(
            name: RouteNames.driverDashboard,
            path: RouteNames.driverDashboardPath, // e.g., /driver
            builder: (c, s) => const DriverDashboardPage() // selectedBusId and selectedLineId might be passed as extra here from setup page
        ),
        GoRoute(
            name: RouteNames.driverBusManagement,
            path: RouteNames.driverBusManagementPath, // e.g., /driver/buses
            builder: (c, s) => const DriverBusManagementPage()
        ),
        GoRoute(
            name: RouteNames.driverAddBus,
            path: RouteNames.driverAddBusPath, // e.g., /driver/buses/add
            builder: (c, s) => const DriverAddEditBusPage(busId: null)
        ),
        // Note: driverEditBusPath should be relative to its parent if nested
        GoRoute(
            name: RouteNames.driverEditBus,
            path: RouteNames.driverEditBusPath, // e.g., /driver/buses/:busId/edit
            builder: (c, s) => DriverAddEditBusPage(busId: s.pathParameters['busId']!)
        ),
        GoRoute(
            name: RouteNames.driverProfile,
            path: RouteNames.driverProfilePath, // e.g., /driver/profile
            builder: (c, s) => const DriverProfilePage()
        ),
        // Note: driverProfileEditPath should be relative to its parent if nested
        GoRoute(
            name: RouteNames.driverProfileEdit,
            path: RouteNames.driverProfileEditPath, // e.g., /driver/profile/edit
            builder: (c, s) {
              // Pass profile data via 'extra' when navigating *to* this route
              final profile = s.extra as DriverEntity?;
              if (profile == null) return const ErrorDisplay(message: 'Missing driver profile data'); // TODO: Localize
              return DriverProfileEditPage(driverProfile: profile);
            }
        ),
        GoRoute(
            name: RouteNames.driverStartTrackingSetup,
            path: RouteNames.driverStartTrackingSetupPath, // e.g., /driver/start-tracking
            builder: (c, s) => const DriverStartTrackingSetupPage()
        ),
        // Add other nested driver routes here

        // Common Routes (Accessible to both roles, requires authentication generally)
        GoRoute(
            name: RouteNames.settings,
            path: RouteNames.settingsPath, // e.g., /settings
            builder: (c, s) => const SettingsPage(),
            routes: [
              GoRoute(
                  name: RouteNames.changePassword,
                  path: RouteNames.changePasswordPath, // e.g., /settings/change-password
                  builder: (c, s) => const ChangePasswordPage()
              ),
              // Add user profile edit route here if accessed via Settings
              GoRoute(
                  name: RouteNames.userProfileEdit,
                  path: RouteNames.userProfileEditPath, // e.g., /settings/profile/edit
                  builder: (c, s) {
                    // Pass profile data via 'extra' when navigating *to* this route
                    final profile = s.extra as UserEntity?;
                    if (profile == null) return const ErrorDisplay(message: 'Missing user profile data'); // TODO: Localize
                    return UserProfileEditPage(userProfile: profile);
                  }
              ),
            ]
        ),
        GoRoute(
            name: RouteNames.notificationList,
            path: RouteNames.notificationListPath, // e.g., /notifications
            builder: (c, s) => const NotificationListPage()
        ),
      ],

      // Error Handling for unknown routes
      // Improved error handling
      errorBuilder: (context, state) {
        // Log navigation errors
        Log.e("Router Error: Failed to navigate to ${state.uri}",
            error: state.error);

        return Scaffold(
          appBar: AppBar(title: const Text('Navigation Error')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.error?.message ?? 'Page not found'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Path: ${state.uri}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper class to make BLoC streams listenable by GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  AuthState? _lastAuthState;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    Log.d("[ROUTER STREAM] Initializing GoRouterRefreshStream");

    // For AuthBloc streams, track the state type
    if (stream is Stream<AuthState>) {
      _subscription = (stream as Stream<AuthState>).listen(
              (AuthState authState) {
            Log.d("[ROUTER STREAM] Received AuthState: ${authState.runtimeType}");

            if (authState is AuthAuthenticated) {
              Log.i("[ROUTER STREAM] AuthAuthenticated received for user: ${authState.user.email}, type: ${authState.user.userType}");
            }

            // Always notify listeners for auth state changes
            _lastAuthState = authState;
            Log.d("[ROUTER STREAM] Notifying router of state change");
            notifyListeners();
          },
          onError: (Object error) {
            Log.e("[ROUTER STREAM] Error in GoRouter refresh stream", error: error);
            notifyListeners();
          }
      );
    } else {
      // For other stream types, use the original implementation
      _subscription = stream.asBroadcastStream().listen(
              (dynamic event) {
            Log.d("[ROUTER STREAM] Received non-AuthState event, notifying router");
            notifyListeners();
          },
          onError: (Object error) {
            Log.e("[ROUTER STREAM] Error in GoRouter refresh stream", error: error);
            notifyListeners();
          }
      );
    }

    // Notify immediately on creation to check the current state
    Log.d("[ROUTER STREAM] Initial notification to router");
    notifyListeners();
  }

  @override
  void dispose() {
    Log.d("[ROUTER STREAM] Disposing subscription");
    _subscription.cancel();
    super.dispose();
  }
}

/// Helper class for storage keys (copied/centralize later)
class StorageKeys {
  static const String onboardingComplete = 'onboarding_complete';
}




// /// lib/presentation/routes/app_router.dart
//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../core/di/service_locator.dart';
// import '../../core/enums/user_type.dart';
// import '../../core/utils/logger.dart';
// import '../../domain/entities/driver_entity.dart'; // Needed for passing extra args
// import '../../domain/entities/user_entity.dart';
// import '../blocs/auth/auth_bloc.dart';
// // Import ALL Page Widgets
// import '../pages/auth/login_page.dart';
// import '../pages/auth/register_page.dart';
// import '../pages/auth/forgot_password_page.dart'; // Import if route exists
// import '../pages/auth/reset_password_page.dart';
//
// import '../pages/driver/driver_add_edit_bus_page.dart';
// import '../pages/driver/driver_bus_management_page.dart';
// import '../pages/driver/driver_dashboard_page.dart';
// import '../pages/driver/driver_profile_edit_page.dart';
// import '../pages/driver/driver_profile_page.dart';
// import '../pages/driver/driver_start_tracking_setup_page.dart'; // Import setup page
// import '../pages/onboarding/language_selection_page.dart';
// import '../pages/onboarding/onboarding_page.dart';
// import '../pages/passenger/line_details_page.dart';
// import '../pages/passenger/passenger_home_page.dart';
// import '../pages/passenger/stop_details_page.dart';
// import '../pages/settings/change_password_page.dart';
// import '../pages/settings/settings_page.dart';
// import '../pages/settings/user_profile_edit_page.dart'; // Import user edit page
// import '../pages/splash/splash_page.dart';
// import '../pages/notifications/notification_list_page.dart'; // Import notifications page
// import '../widgets/common/error_display.dart'; // For error builder/page
// import 'route_names.dart';
//
//
// /// Configures the application's routes using GoRouter.
// /// Includes redirection logic based on authentication state and onboarding status.
// class AppRouter {
//   AppRouter._();
//   static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
//
//   static GoRouter? _router;
//   static GoRouter get router {
//     _router ??= configureRouter();
//     return _router!;
//   }
//
//   static GoRouter configureRouter() {
//     final AuthBloc authBloc = sl<AuthBloc>();
//     final SharedPreferences prefs = sl<SharedPreferences>();
//
//     return GoRouter(
//       navigatorKey: _rootNavigatorKey,
//       initialLocation: RouteNames.splashPath,
//       debugLogDiagnostics: true,
//       refreshListenable: GoRouterRefreshStream(authBloc.stream),
//
//       // --- Redirect Logic ---
//       redirect: (BuildContext context, GoRouterState state) {
//         // Read the latest state at the beginning of the redirect
//         final authCurrentState = authBloc.state;
//         final bool onboardingComplete = prefs.getBool(StorageKeys.onboardingComplete) ?? false;
//         final String location = state.matchedLocation;
//
//         Log.d("Router Redirect Check: Location='$location', AuthState=${authCurrentState.runtimeType}, OnboardingComplete=$onboardingComplete");
//
//         // Allow Splash Page access
//         if (location == RouteNames.splashPath) {
//           Log.d("Router Redirect: Allowing access to Splash page.");
//           return null;
//         }
//
//         // Define authentication routes
//         final bool onAuthRoute = location == RouteNames.loginPath ||
//             location == RouteNames.registerPath ||
//             location == RouteNames.forgotPasswordPath ||
//             location == RouteNames.resetPasswordPath;
//
//         // If user is authenticated and trying to access a non-auth page, allow it.
//         // This check should come early to prevent the later "not logged in" redirect.
//         if (authCurrentState is AuthAuthenticated) {
//           Log.d("Router Redirect Check: User is AuthAuthenticated."); // Added log
//           if (!onAuthRoute) {
//             Log.d("Router Redirect: Authenticated user allowed access to non-auth route: '$location'.");
//             return null; // Allow access to non-auth routes if authenticated
//           }
//           // If authenticated and on an auth route, proceed to redirect them home below
//           Log.d("Router Redirect Check: Authenticated user is on an auth route."); // Added log
//         } else {
//           Log.d("Router Redirect Check: User is NOT AuthAuthenticated. Current State: ${authCurrentState.runtimeType}"); // Added log
//         }
//
//
//         // Handle Onboarding
//         if (!onboardingComplete) {
//           Log.d("Router Redirect Check: Onboarding NOT complete."); // Added log
//           // Allow language selection and onboarding pages
//           if (location != RouteNames.languageSelectionPath && location != RouteNames.onboardingPath) {
//             Log.d("Router Redirect: Redirecting to Language Selection (Onboarding Incomplete) from '$location'.");
//             return RouteNames.languageSelectionPath;
//           } else {
//             Log.d("Router Redirect: Allowing access to Onboarding/Language Selection page: '$location'.");
//             return null; // Allow staying on language/onboarding pages if not complete
//           }
//         }
//         Log.d("Router Redirect Check: Onboarding IS complete."); // Added log
//
//         // After onboarding is complete:
//
//         // If currently on an auth route:
//         if (onAuthRoute) {
//           Log.d("Router Redirect Check: Location is an auth route: '$location'."); // Added log
//           // If user IS authenticated, redirect them to their home page
//           if (authCurrentState is AuthAuthenticated) {
//             final userType = (authCurrentState as AuthAuthenticated).user.userType; // Cast is safe here
//             final homePath = userType == UserType.driver ? RouteNames.driverDashboardPath : RouteNames.passengerHomePath;
//             Log.i("Router Redirect: Redirecting Logged In user from auth route '$location' to Home ($homePath).");
//             return homePath;
//           }
//           // If user is NOT authenticated, stay on the auth route
//           Log.d("Router Redirect: Unauthenticated user allowed to stay on auth route: '$location'.");
//           return null;
//         }
//
//         // If currently NOT on an auth route:
//         Log.d("Router Redirect Check: Location is NOT an auth route: '$location'."); // Added log
//         // If user is NOT authenticated, redirect them to the login page
//         if (!(authCurrentState is AuthAuthenticated)) {
//           Log.i("Router Redirect: Redirecting Logged Out user from non-auth route '$location' to Login.");
//           return RouteNames.loginPath;
//         }
//
//         // If none of the above, no redirect needed (should be authenticated user on a valid non-auth page)
//         Log.d("Router Redirect: No redirect needed for location '$location' (authenticated and on valid route).");
//         return null;
//       },
//
//       // --- Route Definitions ---
//       routes: <RouteBase>[
//         GoRoute( name: RouteNames.splash, path: RouteNames.splashPath, builder: (c, s) => const SplashPage()),
//         GoRoute( name: RouteNames.languageSelection, path: RouteNames.languageSelectionPath, builder: (c, s) => const LanguageSelectionPage()),
//         GoRoute( name: RouteNames.onboarding, path: RouteNames.onboardingPath, builder: (c, s) => const OnboardingPage()),
//         GoRoute( name: RouteNames.login, path: RouteNames.loginPath, builder: (c, s) => const LoginPage()),
//         GoRoute( name: RouteNames.register, path: RouteNames.registerPath, builder: (c, s) => const RegisterPage()),
//         GoRoute( name: RouteNames.forgotPassword, path: RouteNames.forgotPasswordPath, builder: (c, s) => const ForgotPasswordPage()),
//         GoRoute(
//             name: RouteNames.resetPassword,
//             path: RouteNames.resetPasswordPath,
//             builder: (context, state) {
//               final token = state.uri.queryParameters['token'];
//               if (token == null) return const ErrorDisplay(message: 'Missing reset token'); // TODO: Localize
//               return ResetPasswordPage(token: token);
//             }
//         ),
//
//         // Passenger Routes
//         GoRoute(
//             name: RouteNames.passengerHome,
//             path: RouteNames.passengerHomePath, // e.g., /passenger
//             builder: (c, s) => const PassengerHomePage(),
//             routes: [
//               GoRoute(
//                   name: RouteNames.lineDetails,
//                   path: RouteNames.lineDetailsPath, // e.g., /passenger/line/:lineId
//                   builder: (c, s) => LineDetailsPage(lineId: s.pathParameters['lineId']!)
//               ),
//               GoRoute(
//                   name: RouteNames.stopDetails,
//                   path: RouteNames.stopDetailsPath, // e.g., /passenger/stop/:stopId
//                   builder: (c, s) => StopDetailsPage(stopId: s.pathParameters['stopId']!)
//               ),
//               // Add other nested passenger routes here
//             ]
//         ),
//
//         // Driver Routes
//         GoRoute(
//             name: RouteNames.driverDashboard,
//             path: RouteNames.driverDashboardPath, // e.g., /driver
//             builder: (c, s) => const DriverDashboardPage() // selectedBusId and selectedLineId might be passed as extra here from setup page
//         ),
//         GoRoute(
//             name: RouteNames.driverBusManagement,
//             path: RouteNames.driverBusManagementPath, // e.g., /driver/buses
//             builder: (c, s) => const DriverBusManagementPage()
//         ),
//         GoRoute(
//             name: RouteNames.driverAddBus,
//             path: RouteNames.driverAddBusPath, // e.g., /driver/buses/add
//             builder: (c, s) => const DriverAddEditBusPage(busId: null)
//         ),
//         // Note: driverEditBusPath should be relative to its parent if nested
//         GoRoute(
//             name: RouteNames.driverEditBus,
//             path: RouteNames.driverEditBusPath, // e.g., /driver/buses/:busId/edit
//             builder: (c, s) => DriverAddEditBusPage(busId: s.pathParameters['busId']!)
//         ),
//         GoRoute(
//             name: RouteNames.driverProfile,
//             path: RouteNames.driverProfilePath, // e.g., /driver/profile
//             builder: (c, s) => const DriverProfilePage()
//         ),
//         // Note: driverProfileEditPath should be relative to its parent if nested
//         GoRoute(
//             name: RouteNames.driverProfileEdit,
//             path: RouteNames.driverProfileEditPath, // e.g., /driver/profile/edit
//             builder: (c, s) {
//               // Pass profile data via 'extra' when navigating *to* this route
//               final profile = s.extra as DriverEntity?;
//               if (profile == null) return const ErrorDisplay(message: 'Missing driver profile data'); // TODO: Localize
//               return DriverProfileEditPage(driverProfile: profile);
//             }
//         ),
//         GoRoute(
//             name: RouteNames.driverStartTrackingSetup,
//             path: RouteNames.driverStartTrackingSetupPath, // e.g., /driver/start-tracking
//             builder: (c, s) => const DriverStartTrackingSetupPage()
//         ),
//         // Add other nested driver routes here
//
//         // Common Routes (Accessible to both roles, requires authentication generally)
//         GoRoute(
//             name: RouteNames.settings,
//             path: RouteNames.settingsPath, // e.g., /settings
//             builder: (c, s) => const SettingsPage(),
//             routes: [
//               GoRoute(
//                   name: RouteNames.changePassword,
//                   path: RouteNames.changePasswordPath, // e.g., /settings/change-password
//                   builder: (c, s) => const ChangePasswordPage()
//               ),
//               // Add user profile edit route here if accessed via Settings
//               GoRoute(
//                   name: RouteNames.userProfileEdit,
//                   path: RouteNames.userProfileEditPath, // e.g., /settings/profile/edit
//                   builder: (c, s) {
//                     // Pass profile data via 'extra' when navigating *to* this route
//                     final profile = s.extra as UserEntity?;
//                     if (profile == null) return const ErrorDisplay(message: 'Missing user profile data'); // TODO: Localize
//                     return UserProfileEditPage(userProfile: profile);
//                   }
//               ),
//             ]
//         ),
//         GoRoute(
//             name: RouteNames.notificationList,
//             path: RouteNames.notificationListPath, // e.g., /notifications
//             builder: (c, s) => const NotificationListPage()
//         ),
//       ],
//
//       // Error Handling for unknown routes
//       errorBuilder: (context, state) => Scaffold(
//           appBar: AppBar(title: const Text('Page Not Found')), // TODO: Localize
//           body: Center(
//             // Show error message and path
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'Error: ${state.error?.message ?? 'Page not found'}\nPath: ${state.uri}', // TODO: Localize
//                   textAlign: TextAlign.center,
//                 ),
//               )
//           )
//       ),
//     );
//   }
// }
//
// /// Helper class to make BLoC streams listenable by GoRouter.
// class GoRouterRefreshStream extends ChangeNotifier {
//   late final StreamSubscription<dynamic> _subscription;
//
//   GoRouterRefreshStream(Stream<dynamic> stream) {
//     notifyListeners(); // Notify immediately on creation with current state
//     _subscription = stream.asBroadcastStream().listen(
//             (dynamic _) => notifyListeners(), // Notify listeners on every event
//         onError: (Object error) {
//           Log.e("Error in GoRouter refresh stream", error: error);
//           // Still notify to ensure router updates even on errors
//           notifyListeners();
//         }
//     );
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }
//
// /// Helper class for storage keys (copied/centralize later)
// class StorageKeys {
//   static const String onboardingComplete = 'onboarding_complete';
// }