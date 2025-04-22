/// lib/presentation/routes/route_names.dart

/// Defines constant names for GoRouter routes used throughout the application.
class RouteNames {
  RouteNames._(); // Prevents instantiation

  // Initial/Onboarding Routes
  static const String splash = 'splash';
  static const String languageSelection = 'languageSelection';
  static const String onboarding = 'onboarding';

  // Auth Routes
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String resetPassword = 'resetPassword';

  // Passenger Routes
  static const String passengerHome = 'passengerHome';
  static const String lineDetails = 'lineDetails';
  static const String stopDetails = 'stopDetails';

  // Driver Routes
  static const String driverDashboard = 'driverDashboard';
  static const String driverBusManagement = 'driverBusManagement';
  static const String driverAddBus = 'driverAddBus';
  static const String driverEditBus = 'driverEditBus';
  static const String driverProfile = 'driverProfile';
  static const String driverProfileEdit = 'driverProfileEdit';
  static const String driverStartTrackingSetup = 'driverStartTrackingSetup';

  // Common Routes
  static const String settings = 'settings';
  static const String changePassword = 'changePassword'; // Nested under settings
  static const String userProfileEdit = 'userProfileEdit'; // Added, Nested under settings
  static const String notificationList = 'notificationList';

  // --- Route Paths ---
  static const String splashPath = '/';
  static const String languageSelectionPath = '/language';
  static const String onboardingPath = '/onboarding';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String resetPasswordPath = '/reset-password';

  static const String passengerHomePath = '/passenger';
  // Relative paths used within GoRoute's 'routes' parameter:
  static const String lineDetailsPath = 'line/:lineId';
  static const String stopDetailsPath = 'stop/:stopId';

  static const String driverDashboardPath = '/driver';
  static const String driverBusManagementPath = '/driver/buses';
  static const String driverAddBusPath = '/driver/buses/add';
  static const String driverEditBusPath = 'buses/:busId/edit'; // Relative path example corrected
  static const String driverProfilePath = '/driver/profile';
  static const String driverProfileEditPath = 'profile/edit'; // Added, relative path under /driver maybe? Or /settings? Let's keep under /settings as per previous router structure.
  static const String driverStartTrackingSetupPath = '/driver/start-tracking';

  static const String settingsPath = '/settings';
  // Relative paths used within GoRoute's 'routes' parameter:
  static const String changePasswordPath = 'change-password';
  static const String userProfileEditPath = 'profile/edit'; // Added path constant for user edit
  static const String notificationListPath = '/notifications';

}


// /// lib/presentation/routes/route_names.dart
//
// /// Defines constant names for GoRouter routes used throughout the application.
// class RouteNames {
//   RouteNames._(); // Prevents instantiation
//
//   // Initial/Onboarding Routes
//   static const String splash = 'splash';
//   static const String languageSelection = 'languageSelection';
//   static const String onboarding = 'onboarding';
//
//   // Auth Routes
//   static const String login = 'login';
//   static const String register = 'register';
//   static const String forgotPassword = 'forgotPassword';
//   static const String resetPassword = 'resetPassword';
//
//   // Passenger Routes
//   static const String passengerHome = 'passengerHome'; // Base for passenger tabs
//   static const String lineDetails = 'lineDetails'; // Nested under passengerHome
//   static const String stopDetails = 'stopDetails'; // Nested under passengerHome
//
//   // Driver Routes
//   static const String driverDashboard = 'driverDashboard'; // Base for driver view
//   static const String driverBusManagement = 'driverBusManagement';
//   static const String driverAddBus = 'driverAddBus';
//   static const String driverEditBus = 'driverEditBus'; // Param: busId
//   static const String driverProfile = 'driverProfile';
//   static const String driverProfileEdit = 'driverProfileEdit'; // NEW
//   static const String driverStartTrackingSetup = 'driverStartTrackingSetup';
//
//   // Common Routes
//   static const String settings = 'settings';
//   static const String changePassword = 'changePassword'; // Nested under settings
//   static const String notificationList = 'notificationList';
//
//   // --- Route Paths ---
//   // Define paths corresponding to names. Use leading '/' for top-level routes.
//   static const String splashPath = '/';
//   static const String languageSelectionPath = '/language';
//   static const String onboardingPath = '/onboarding';
//   static const String loginPath = '/login';
//   static const String registerPath = '/register';
//   static const String forgotPasswordPath = '/forgot-password';
//   static const String resetPasswordPath = '/reset-password'; // Typically requires token param
//
//   static const String passengerHomePath = '/passenger';
//   // Relative paths used within GoRoute's 'routes' parameter:
//   static const String lineDetailsPath = 'line/:lineId';
//   static const String stopDetailsPath = 'stop/:stopId';
//
//   static const String driverDashboardPath = '/driver';
//   static const String driverBusManagementPath = '/driver/buses';
//   static const String driverAddBusPath = '/driver/buses/add';
//   static const String driverEditBusPath = '/driver/buses/:busId/edit';
//   static const String driverProfilePath = '/driver/profile';
//   static const String driverProfileEditPath = '/driver/profile/edit'; // NEW
//   static const String driverStartTrackingSetupPath = '/driver/start-tracking';
//
//   static const String settingsPath = '/settings';
//   // Relative path used within GoRoute's 'routes' parameter:
//   static const String changePasswordPath = 'change-password';
//   static const String notificationListPath = '/notifications';
//
//   // Initial/Onboarding Routes
//   static const String splash = 'splash';
//   static const String languageSelection = 'languageSelection';
//   static const String onboarding = 'onboarding';
//
//   // Auth Routes
//   static const String login = 'login';
//   static const String register = 'register';
//   static const String forgotPassword = 'forgotPassword';
//   static const String resetPassword = 'resetPassword';
//
//   // Passenger Routes
//   static const String passengerHome = 'passengerHome';
//   static const String lineDetails = 'lineDetails';
//   static const String stopDetails = 'stopDetails';
//
//   // Driver Routes
//   static const String driverDashboard = 'driverDashboard';
//   static const String driverBusManagement = 'driverBusManagement';
//   static const String driverAddBus = 'driverAddBus';
//   static const String driverEditBus = 'driverEditBus';
//   static const String driverProfile = 'driverProfile';
//   static const String driverProfileEdit = 'driverProfileEdit';
//   static const String driverStartTrackingSetup = 'driverStartTrackingSetup';
//
//   // Common Routes
//   static const String settings = 'settings';
//   static const String changePassword = 'changePassword'; // Nested under settings
//   static const String userProfileEdit = 'userProfileEdit'; // Added, Nested under settings
//   static const String notificationList = 'notificationList';
//
//   // --- Route Paths ---
//   static const String splashPath = '/';
//   static const String languageSelectionPath = '/language';
//   static const String onboardingPath = '/onboarding';
//   static const String loginPath = '/login';
//   static const String registerPath = '/register';
//   static const String forgotPasswordPath = '/forgot-password';
//   static const String resetPasswordPath = '/reset-password';
//
//   static const String passengerHomePath = '/passenger';
//   // Relative paths used within GoRoute's 'routes' parameter:
//   static const String lineDetailsPath = 'line/:lineId';
//   static const String stopDetailsPath = 'stop/:stopId';
//
//   static const String driverDashboardPath = '/driver';
//   static const String driverBusManagementPath = '/driver/buses';
//   static const String driverAddBusPath = '/driver/buses/add';
//   static const String driverEditBusPath = 'buses/:busId/edit'; // Relative path example corrected
//   static const String driverProfilePath = '/driver/profile';
//   static const String driverProfileEditPath = 'profile/edit'; // Added, relative path under /driver maybe? Or /settings? Let's keep under /settings as per previous router structure.
//   static const String driverStartTrackingSetupPath = '/driver/start-tracking';
//
//   static const String settingsPath = '/settings';
//   // Relative paths used within GoRoute's 'routes' parameter:
//   static const String changePasswordPath = 'change-password';
//   static const String userProfileEditPath = 'profile/edit'; // Added path constant for user edit
//
// }
