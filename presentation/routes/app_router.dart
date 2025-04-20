/// lib/presentation/routes/app_router.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/service_locator.dart';
import '../../core/enums/user_type.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/driver_entity.dart'; // Needed for passing extra args
import '../../domain/entities/user_entity.dart';
import '../blocs/auth/auth_bloc.dart';
// Import ALL Page Widgets
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/forgot_password_page.dart'; // Import if route exists
import '../pages/auth/reset_password_page.dart'; // Import if route exists
import '../pages/driver/driver_add_edit_bus_page.dart';
import '../pages/driver/driver_bus_management_page.dart';
import '../pages/driver/driver_dashboard_page.dart';
import '../pages/driver/driver_profile_edit_page.dart';
import '../pages/driver/driver_profile_page.dart';
import '../pages/driver/driver_start_tracking_setup_page.dart'; // Import setup page
import '../pages/onboarding/language_selection_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/passenger/line_details_page.dart';
import '../pages/passenger/passenger_home_page.dart';
import '../pages/passenger/stop_details_page.dart';
import '../pages/settings/change_password_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/settings/user_profile_edit_page.dart'; // Import user edit page
import '../pages/splash/splash_page.dart';
import '../pages/notifications/notification_list_page.dart'; // Import notifications page
import '../widgets/common/error_display.dart'; // For error builder/page
import 'route_names.dart';


/// Configures the application's routes using GoRouter.
/// Includes redirection logic based on authentication state and onboarding status.
class AppRouter {
  AppRouter._();
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter? _router;
  static GoRouter get router {
    _router ??= configureRouter();
    return _router!;
  }

  static GoRouter configureRouter() {
    final AuthBloc authBloc = sl<AuthBloc>();
    final SharedPreferences prefs = sl<SharedPreferences>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteNames.splashPath,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      // --- Redirect Logic ---
      redirect: (BuildContext context, GoRouterState state) {
        // Read the latest state at the beginning of the redirect
        final authCurrentState = authBloc.state;
        final bool onboardingComplete = prefs.getBool(StorageKeys.onboardingComplete) ?? false;
        final String location = state.matchedLocation;

        Log.d("Router Redirect Check: Location='$location', AuthState=${authCurrentState.runtimeType}, OnboardingComplete=$onboardingComplete");

        // Allow Splash Page access
        if (location == RouteNames.splashPath) {
          return null;
        }

        // Define authentication routes
        final bool onAuthRoute = location == RouteNames.loginPath ||
            location == RouteNames.registerPath ||
            location == RouteNames.forgotPasswordPath ||
            location == RouteNames.resetPasswordPath;

        // If user is authenticated and trying to access a non-auth page, allow it.
        // This check should come early to prevent the later "not logged in" redirect.
        if (authCurrentState is AuthAuthenticated && !onAuthRoute) {
          Log.d("Authenticated user allowed access to non-auth route: '$location'.");
          return null; // Allow access
        }


        // Handle Onboarding
        if (!onboardingComplete) {
          // Allow language selection and onboarding pages
          if (location != RouteNames.languageSelectionPath && location != RouteNames.onboardingPath) {
            Log.d("Redirecting to Language Selection (Onboarding Incomplete).");
            return RouteNames.languageSelectionPath;
          } else {
            // Allow staying on language/onboarding pages if not complete
            return null;
          }
        }

        // After onboarding is complete:

        // If currently on an auth route:
        if (onAuthRoute) {
          // If user IS authenticated, redirect them to their home page
          if (authCurrentState is AuthAuthenticated) {
            final userType = (authCurrentState as AuthAuthenticated).user.userType; // Cast is safe here
            final homePath = userType == UserType.driver ? RouteNames.driverDashboardPath : RouteNames.passengerHomePath;
            Log.d("Redirecting Logged In user from auth route '$location' to Home ($homePath).");
            return homePath;
          }
          // If user is NOT authenticated, stay on the auth route
          return null;
        }

        // If currently NOT on an auth route:
        // If user is NOT authenticated, redirect them to the login page
        if (!(authCurrentState is AuthAuthenticated)) {
          Log.d("Redirecting Logged Out user from non-auth route '$location' to Login.");
          return RouteNames.loginPath;
        }

        // If none of the above, no redirect needed (authenticated user on a valid non-auth page)
        Log.d("No redirect needed for location '$location' (authenticated and on valid route).");
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
      errorBuilder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')), // TODO: Localize
          body: Center(
            // Show error message and path
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${state.error?.message ?? 'Page not found'}\nPath: ${state.uri}', // TODO: Localize
                  textAlign: TextAlign.center,
                ),
              )
          )
      ),
    );
  }
}

/// Helper class to make BLoC streams listenable by GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Notify immediately on creation with current state
    _subscription = stream.asBroadcastStream().listen(
            (dynamic _) => notifyListeners(), // Notify listeners on every event
        onError: (Object error) {
          Log.e("Error in GoRouter refresh stream", error: error);
          // Still notify to ensure router updates even on errors
          notifyListeners();
        }
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Helper class for storage keys (copied/centralize later)
class StorageKeys {
  static const String onboardingComplete = 'onboarding_complete';
}