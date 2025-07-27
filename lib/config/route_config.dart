// lib/config/route_config.dart (updated)

import 'package:flutter/material.dart';

// Import new screens (only existing ones)
import '../screens/screens.dart';

class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String driverRegister = '/driver-register';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';

  // Driver routes
  static const String driverHome = '/driver/home';
  static const String driverProfile = '/driver/profile';
  static const String busManagement = '/driver/bus-management';
  static const String enhancedBusManagement = '/driver/enhanced-bus-management';
  static const String tracking = '/driver/tracking';
  static const String enhancedTracking = '/driver/enhanced-tracking';
  static const String passengerCounter = '/driver/passenger-counter';
  static const String lineSelection = '/driver/line-selection';
  static const String ratings = '/driver/ratings';
  static const String enhancedRatings = '/driver/enhanced-ratings';
  static const String driverSchedules = '/driver/schedules';
  static const String enhancedSchedules = '/driver/enhanced-schedules';
  static const String schedules = '/driver/schedules'; // Alias for backward compatibility
  static const String driverTrips = '/driver/trips';
  static const String enhancedTrips = '/driver/enhanced-trips';
  static const String tripStatistics = '/driver/trip-statistics';
  static const String driverPerformance = '/driver/performance';
  static const String enhancedPerformance = '/driver/enhanced-performance';
  static const String driverTripStart = '/driver/trip-start';
  static const String driverTracking = '/driver/tracking';
  static const String driverSchedule = '/driver/schedule';
  static const String reportIssue = '/driver/report-issue';
  static const String tripRoute = '/driver/trip-route';

  // Passenger routes
  static const String passengerHome = '/passenger/home';
  static const String lineSearch = '/passenger/line-search';
  static const String stopSearch = '/passenger/stop-search';
  static const String busTracking = '/passenger/bus-tracking';
  static const String busDetails = '/passenger/bus-details';
  static const String lineDetails = '/passenger/line-details';
  static const String stopDetails = '/passenger/stop-details';
  static const String rateDriver = '/passenger/rate-driver';
  static const String payment = '/passenger/payment';
  static const String tripHistory = '/passenger/trip-history';
  static const String tripDetails = '/passenger/trip-details';
  static const String realtimeBusTracking = '/passenger/realtime-tracking';
  static const String routePlanner = '/passenger/route-planner';
  static const String busSearch = '/passenger/bus-search';
  static const String map = '/passenger/map';
  static const String tripPreferences = '/passenger/trip-preferences';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProfile = '/admin/profile';
  static const String userManagement = '/admin/users';
  static const String driverApproval = '/admin/driver-approval';
  static const String busApproval = '/admin/bus-approval';
  static const String lineManagement = '/admin/lines';
  static const String stopManagement = '/admin/stops';
  static const String scheduleManagement = '/admin/schedules';
  static const String anomalyManagement = '/admin/anomalies';
  static const String tripManagement = '/admin/trips';
  static const String fleetManagement = '/admin/fleet';

  // Common routes
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notification-settings';
  static const String paymentMethods = '/payment-methods';
  static const String help = '/help';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String error = '/error';
  static const String achievements = '/achievements';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      // Common routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      // Auth routes
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Driver routes
      case AppRoutes.driverHome:
        return MaterialPageRoute(builder: (_) => const DriverHomeScreen());
      case AppRoutes.driverProfile:
        return MaterialPageRoute(builder: (_) => const DriverProfileScreen());
      case AppRoutes.busManagement:
        return MaterialPageRoute(builder: (_) => const BusManagementScreen());
      case AppRoutes.enhancedBusManagement:
        return MaterialPageRoute(builder: (_) => const BusManagementScreen());
      case AppRoutes.tracking:
        return MaterialPageRoute(builder: (_) => const TrackingScreen());
      case AppRoutes.enhancedTracking:
        return MaterialPageRoute(builder: (_) => const TrackingScreen());
      case AppRoutes.enhancedRatings:
        return MaterialPageRoute(builder: (_) => const RatingScreen());
      case AppRoutes.enhancedSchedules:
        return MaterialPageRoute(builder: (_) => const SchedulesScreen());
      case AppRoutes.enhancedTrips:
        return MaterialPageRoute(builder: (_) => const TripsScreen());
      case AppRoutes.enhancedPerformance:
        return MaterialPageRoute(builder: (_) => const DriverPerformanceDashboard());

      // Passenger routes
      case AppRoutes.passengerHome:
        return MaterialPageRoute(builder: (_) => const PassengerHomeScreen());
      case AppRoutes.busTracking:
        return MaterialPageRoute(builder: (_) => const BusTrackingScreen());
      case AppRoutes.tripHistory:
        return MaterialPageRoute(builder: (_) => const TripHistoryScreen());
      case AppRoutes.payment:
        return MaterialPageRoute(builder: (_) => PaymentScreen(
          tripDetails: args?['tripDetails'] as Map<String, dynamic>?,
          fareAmount: args?['fareAmount'] as double?,
        ));
      case AppRoutes.lineSearch:
        return MaterialPageRoute(builder: (_) => const LineSearchScreen());
      case AppRoutes.lineDetails:
        return MaterialPageRoute(builder: (_) => LineDetailsScreen(
          lineId: args?['lineId'] as String? ?? '',
        ));
      case AppRoutes.stopSearch:
        return MaterialPageRoute(builder: (_) => const StopSearchScreen());
      case AppRoutes.stopDetails:
        return MaterialPageRoute(builder: (_) => const StopDetailsScreen());
      case AppRoutes.busDetails:
        return MaterialPageRoute(builder: (_) => BusDetailsScreen(
          busId: args?['busId'] as String? ?? '',
        ));
      case AppRoutes.rateDriver:
        return MaterialPageRoute(builder: (_) => RateDriverScreen(
          driverId: args?['driverId'] as String? ?? '',
          busId: args?['busId'] as String?,
          tripId: args?['tripId'] as String?,
        ));
      
      // Admin routes
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      // Default error route
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper navigation methods
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateToReplacement<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, dynamic>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateToAndClearStack<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
}
