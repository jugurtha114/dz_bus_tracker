// lib/screens/screens.dart

/// Screen library for DZ Bus Tracker
/// 
/// This library provides all screen components for the app, organized by
/// user role and functionality. All screens follow Material You design
/// principles and are optimized for performance.

library screens;

// Common screens (shared across roles)
export 'common/splash_screen.dart';
export 'common/onboarding_screen.dart';
export 'common/settings_screen.dart';
export 'common/notifications_screen.dart';
export 'common/profile_screen.dart';
export 'common/about_screen.dart';
export 'common/error_screen.dart';

// Authentication screens
export 'auth/login_screen.dart';
export 'auth/register_screen.dart';
export 'auth/driver_register_screen.dart';
export 'auth/forgot_password_screen.dart';

// Passenger screens
export 'passenger/passenger_home_screen.dart';
export 'passenger/bus_tracking_screen.dart';
export 'passenger/trip_history_screen.dart';
export 'passenger/payment_screen.dart';
export 'passenger/line_search_screen.dart';
export 'passenger/line_details_screen.dart';
export 'passenger/stop_search_screen.dart';
export 'passenger/stop_details_screen.dart';
export 'passenger/bus_details_screen.dart';
export 'passenger/rate_driver_screen.dart';

// Driver screens  
export 'driver/driver_home_screen.dart';
export 'driver/driver_profile_screen.dart';
export 'driver/bus_management_screen.dart';
export 'driver/tracking_screen.dart';
export 'driver/driver_performance_dashboard.dart';
export 'driver/line_selection_screen.dart';
export 'driver/passenger_counter_screen.dart';
export 'driver/rating_screen.dart';
export 'driver/schedules_screen.dart';
export 'driver/trips_screen.dart';

// Admin screens
export 'admin/admin_dashboard_screen.dart';
export 'admin/driver_approval_screen.dart';
export 'admin/bus_approval_screen.dart';
export 'admin/fleet_management_screen.dart';
export 'admin/user_management_screen.dart';
export 'admin/line_management_screen.dart';
export 'admin/stop_management_screen.dart';
export 'admin/schedule_management_screen.dart';
export 'admin/trip_statistics_screen.dart';
export 'admin/anomaly_management_screen.dart';