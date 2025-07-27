// lib/services/navigation_service.dart

import 'package:flutter/material.dart';
import '../config/route_config.dart';
import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../screens/common/error_screen.dart';
import '../models/user_model.dart';
import '../helpers/error_handler.dart';
import 'package:provider/provider.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  // Navigation methods
  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateToReplacement<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateToAndClearStack<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack<T>([T? result]) {
    if (canGoBack()) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  static bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  // Navigate to home based on user type
  static Future<void> navigateToHome() async {
    if (context == null) return;

    final authProvider = Provider.of<AuthProvider>(context!, listen: false);
    final userType = authProvider.user?.userType;

    String homeRoute;
    switch (userType) {
      case UserType.driver:
        homeRoute = AppRoutes.driverHome;
        break;
      case UserType.admin:
        homeRoute = AppRoutes.adminDashboard;
        break;
      case UserType.passenger:
      default:
        homeRoute = AppRoutes.passengerHome;
    }

    await navigateToAndClearStack(homeRoute);
  }

  // Navigate to login and clear stack
  static Future<void> navigateToLogin() {
    return navigateToAndClearStack(AppRoutes.login);
  }

  // Navigate to profile based on user type
  static Future<void> navigateToProfile() async {
    if (context == null) return;

    final authProvider = Provider.of<AuthProvider>(context!, listen: false);
    final userType = authProvider.user?.userType;

    String profileRoute;
    switch (userType) {
      case UserType.driver:
        profileRoute = AppRoutes.driverProfile;
        break;
      case UserType.admin:
        profileRoute = AppRoutes.adminProfile;
        break;
      case UserType.passenger:
      default:
        profileRoute = AppRoutes.profile;
    }

    await navigateTo(profileRoute);
  }

  // Show error screen
  static Future<void> showError({
    required String message,
    ErrorType errorType = ErrorType.unknown,
    VoidCallback? onRetry,
    bool showHomeButton = true,
  }) {
    return navigateTo(
      AppRoutes.error,
      arguments: {
        'message': message,
        'errorType': errorType,
        'onRetry': onRetry,
        'showHomeButton': showHomeButton,
      },
    );
  }

  // Check if current route is one of the given routes
  static bool isCurrentRoute(List<String> routes) {
    final currentRoute = ModalRoute.of(context!)?.settings.name;
    return routes.contains(currentRoute);
  }

  // Get current route name
  static String? getCurrentRoute() {
    return ModalRoute.of(context!)?.settings.name;
  }

  // Navigate with authentication check
  static Future<T?> navigateWithAuth<T>(
    String routeName, {
    Object? arguments,
  }) async {
    if (context == null) return null;

    final authProvider = Provider.of<AuthProvider>(context!, listen: false);

    if (!authProvider.isAuthenticated) {
      await navigateToLogin();
      return null;
    }

    return navigateTo<T>(routeName, arguments: arguments);
  }

  // Navigate to appropriate route based on deeplink or notification
  static Future<void> handleDeepLink(
    String? route,
    Map<String, dynamic>? params,
  ) async {
    if (route == null || context == null) return;

    final authProvider = Provider.of<AuthProvider>(context!, listen: false);

    // If not authenticated, go to login first
    if (!authProvider.isAuthenticated) {
      await navigateToLogin();
      return;
    }

    // Navigate to the appropriate route
    switch (route) {
      case 'bus_tracking':
        if (params?['busId'] != null) {
          await navigateTo(AppRoutes.busTracking, arguments: params);
        }
        break;
      case 'line_details':
        if (params?['lineId'] != null) {
          await navigateTo(AppRoutes.lineDetails, arguments: params);
        }
        break;
      case 'notifications':
        await navigateTo(AppRoutes.notifications);
        break;
      case 'driver_rating':
        if (params?['driverId'] != null) {
          await navigateTo(AppRoutes.rateDriver, arguments: params);
        }
        break;
      default:
        await navigateToHome();
    }
  }
}
