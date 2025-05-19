// lib/config/route_config.dart (updated)

import 'package:flutter/material.dart';

// Import all screens
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/driver_register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/common/splash_screen.dart';
import '../screens/common/onboarding_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/common/settings_screen.dart';
import '../screens/common/about_screen.dart';
import '../screens/common/notifications_screen.dart';
import '../screens/common/error_screen.dart';
import '../screens/driver/driver_home_screen.dart';
import '../screens/driver/driver_profile_screen.dart';
import '../screens/driver/bus_management_screen.dart';
import '../screens/driver/tracking_screen.dart';
import '../screens/driver/passenger_counter_screen.dart';
import '../screens/driver/line_selection_screen.dart';
import '../screens/driver/rating_screen.dart';
import '../screens/passenger/passenger_home_screen.dart';
import '../screens/passenger/line_search_screen.dart';
import '../screens/passenger/stop_search_screen.dart';
import '../screens/passenger/bus_tracking_screen.dart';
import '../screens/passenger/bus_details_screen.dart';
import '../screens/passenger/line_details_screen.dart';
import '../screens/passenger/stop_details_screen.dart';
import '../screens/passenger/rate_driver_screen.dart';

class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String driverRegister = '/driver-register';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';

  // Driver routes
  static const String driverHome = '/driver/home';
  static const String driverProfile = '/driver/profile';
  static const String busManagement = '/driver/bus-management';
  static const String tracking = '/driver/tracking';
  static const String passengerCounter = '/driver/passenger-counter';
  static const String lineSelection = '/driver/line-selection';
  static const String ratings = '/driver/ratings';

  // Passenger routes
  static const String passengerHome = '/passenger/home';
  static const String lineSearch = '/passenger/line-search';
  static const String stopSearch = '/passenger/stop-search';
  static const String busTracking = '/passenger/bus-tracking';
  static const String busDetails = '/passenger/bus-details';
  static const String lineDetails = '/passenger/line-details';
  static const String stopDetails = '/passenger/stop-details';
  static const String rateDriver = '/passenger/rate-driver';

  // Common routes
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String error = '/error';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
    // Auth routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.driverRegister:
        return MaterialPageRoute(builder: (_) => const DriverRegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

    // Driver routes
      case AppRoutes.driverHome:
        return MaterialPageRoute(builder: (_) => const DriverHomeScreen());
      case AppRoutes.driverProfile:
        return MaterialPageRoute(builder: (_) => const DriverProfileScreen());
      case AppRoutes.busManagement:
        return MaterialPageRoute(builder: (_) => const BusManagementScreen());
      case AppRoutes.tracking:
        return MaterialPageRoute(builder: (_) => const TrackingScreen());
      case AppRoutes.passengerCounter:
        return MaterialPageRoute(builder: (_) => const PassengerCounterScreen());
      case AppRoutes.lineSelection:
        return MaterialPageRoute(builder: (_) => const LineSelectionScreen());
      case AppRoutes.ratings:
        return MaterialPageRoute(builder: (_) => const RatingScreen());

    // Passenger routes
      case AppRoutes.passengerHome:
        return MaterialPageRoute(builder: (_) => const PassengerHomeScreen());
      case AppRoutes.lineSearch:
        return MaterialPageRoute(builder: (_) => const LineSearchScreen());
      case AppRoutes.stopSearch:
        return MaterialPageRoute(builder: (_) => const StopSearchScreen());
      case AppRoutes.busTracking:
        return MaterialPageRoute(builder: (_) => const BusTrackingScreen());
      case AppRoutes.busDetails:
        final busId = args?['busId'] as String?;
        if (busId == null) {
          return MaterialPageRoute(
            builder: (_) => const ErrorScreen(
              message: 'Bus ID is required to view details',
              errorType: ErrorType.notFound,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => BusDetailsScreen(busId: busId),
        );
      case AppRoutes.lineDetails:
        return MaterialPageRoute(builder: (_) => const LineDetailsScreen());
      case AppRoutes.stopDetails:
        return MaterialPageRoute(builder: (_) => const StopDetailsScreen());
      case AppRoutes.rateDriver:
        final driverId = args?['driverId'] as String?;
        if (driverId == null) {
          return MaterialPageRoute(
            builder: (_) => const ErrorScreen(
              message: 'Driver ID is required to submit a rating',
              errorType: ErrorType.notFound,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => RateDriverScreen(
            driverId: driverId,
            busId: args?['busId'] as String?,
            tripId: args?['tripId'] as String?,
          ),
        );

    // Common routes
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case AppRoutes.error:
        final message = args?['message'] as String? ?? 'An unexpected error occurred';
        return MaterialPageRoute(
          builder: (_) => ErrorScreen(
            message: message,
            errorType: args?['errorType'] as ErrorType? ?? ErrorType.unknown,
            onRetry: args?['onRetry'] as VoidCallback?,
            onGoBack: args?['onGoBack'] as VoidCallback?,
            showHomeButton: args?['showHomeButton'] as bool? ?? true,
          ),
        );

    // Default error route
      default:
        return MaterialPageRoute(
          builder: (_) => ErrorScreen(
            message: 'No route defined for ${settings.name}',
            errorType: ErrorType.notFound,
          ),
        );
    }
  }

  // Helper navigation methods
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateToReplacement<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, dynamic>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateToAndClearStack<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(context, routeName, (route) => false, arguments: arguments);
  }

  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
}