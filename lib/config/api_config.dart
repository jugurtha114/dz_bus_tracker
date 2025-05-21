// lib/config/api_config.dart

/// API configuration and endpoints
class ApiConfig {
  // Base URLs for different environments
  static const bool _useLocalServer = true;

  // API Base URLs
  static const String _localBaseUrl = 'http://0.0.0.0:8001';
  static const String _devBaseUrl = 'https://dev-api.dzbusttracker.dz';
  static const String _stagingBaseUrl = 'https://staging-api.dzbusttracker.dz';
  static const String _productionBaseUrl = 'https://api.dzbusttracker.dz';

  // Select the appropriate base URL based on environment
  static String get baseUrl {
    if (_useLocalServer) return _localBaseUrl;

    const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    switch (environment) {
      case 'production':
        return _productionBaseUrl;
      case 'staging':
        return _stagingBaseUrl;
      case 'dev':
      default:
        return _devBaseUrl;
    }
  }

  // API version paths
  static const String apiV1 = '/api/v1';

  // Full base URL for API v1
  static String get baseUrlV1 => '$baseUrl$apiV1';

  // Authentication endpoints
  static const String authPrefix = '/api';
  static String get tokenUrl => '$baseUrl$authPrefix/token/';
  static String get tokenRefreshUrl => '$baseUrl$authPrefix/token/refresh/';
  static String get tokenVerifyUrl => '$baseUrl$authPrefix/token/verify/';

  // WebSocket URL for real-time updates
  static String get webSocketUrl => baseUrl.replaceFirst('http', 'ws');
  static String get locationWebSocketUrl => '$webSocketUrl/ws/locations/';
  static String get notificationWebSocketUrl => '$webSocketUrl/ws/notifications/';

  // API gateway settings
  static const int gatewayTimeout = 60000; // 60 seconds
  static const int gatewayMaxRetries = 3;
  static const bool useApiGateway = false;
  static const String apiGatewayKey = '';

  // HTTP settings
  static const bool useHttps = true;
  static const bool validateCertificate = true;
  static const bool followRedirects = true;
  static const int maxRedirects = 5;

  // Content types
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormData = 'multipart/form-data';
  static const String contentTypeTextPlain = 'text/plain';

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String acceptLanguageHeader = 'Accept-Language';
  static const String contentTypeHeader = 'Content-Type';
  static const String userAgentHeader = 'User-Agent';
  static const String deviceIdHeader = 'X-Device-Id';
  static const String appVersionHeader = 'X-App-Version';
  static const String platformHeader = 'X-Platform';
}

/// Complete API Endpoints organized by resource
class Endpoints {
  // Auth endpoints
  static final String login = ApiConfig.tokenUrl;
  static final String refreshToken = ApiConfig.tokenRefreshUrl;
  static final String verifyToken = ApiConfig.tokenVerifyUrl;

  // User endpoints
  static const String usersPrefix = '/accounts/users';
  static String get users => '${ApiConfig.baseUrlV1}$usersPrefix/';
  static String get currentUser => '${users}me/';
  static String get changePassword => '${users}change_password/';
  static String get resetPasswordRequest => '${users}reset_password_request/';
  static String get resetPasswordConfirm => '${users}reset_password_confirm/';
  static String userById(String id) => '$users$id/';

  // Profile endpoints
  static const String profilesPrefix = '/accounts/profiles';
  static String get profiles => '${ApiConfig.baseUrlV1}$profilesPrefix/';
  static String get currentProfile => '${profiles}me/';
  static String get updateProfile => '${profiles}update_me/';
  static String profileById(String id) => '$profiles$id/';

  // Buses endpoints
  static const String busesPrefix = '/buses/buses';
  static String get buses => '${ApiConfig.baseUrlV1}$busesPrefix/';
  static String busById(String id) => '$buses$id/';
  static String approveBus(String id) => '$buses$id/approve/';
  static String updateBusLocation(String id) => '$buses$id/update_location/';
  static String updatePassengerCount(String id) => '$buses$id/update_passenger_count/';

  // Bus locations endpoints
  static const String busLocationsPrefix = '/buses/locations';
  static String get busLocations => '${ApiConfig.baseUrlV1}$busLocationsPrefix/';

  // Drivers endpoints
  static const String driversPrefix = '/drivers/drivers';
  static String get drivers => '${ApiConfig.baseUrlV1}$driversPrefix/';
  static String get driverRegistration => '${drivers}register/';
  static String driverById(String id) => '$drivers$id/';
  static String approveDriver(String id) => '$drivers$id/approve/';
  static String updateDriverAvailability(String id) => '$drivers$id/update_availability/';
  static String driverRatings(String id) => '$drivers$id/ratings/';

  // Lines endpoints
  static const String linesPrefix = '/lines/lines';
  static String get lines => '${ApiConfig.baseUrlV1}$linesPrefix/';
  static String lineById(String id) => '$lines$id/';
  static String lineStops(String id) => '$lines$id/stops/';
  static String addStopToLine(String id) => '$lines$id/add_stop/';
  static String removeStopFromLine(String id) => '$lines$id/remove_stop/';
  static String addScheduleToLine(String id) => '$lines$id/add_schedule/';
  static String lineSchedule(String id) => '$lines$id/schedules/';

  // Stops endpoints
  static const String stopsPrefix = '/lines/stops';
  static String get stops => '${ApiConfig.baseUrlV1}$stopsPrefix/';
  static String stopById(String id) => '$stops$id/';
  static String get nearbyStops => '${stops}nearby/';

  // Tracking endpoints
  static const String trackingPrefix = '/tracking';

  // Bus lines tracking
  static const String busLinesPrefix = '$trackingPrefix/bus-lines';
  static String get startTracking => '${ApiConfig.baseUrlV1}$busLinesPrefix/start_tracking/';
  static String get stopTracking => '${ApiConfig.baseUrlV1}$busLinesPrefix/stop_tracking/';

  // Location tracking
  static const String locationsPrefix = '$trackingPrefix/locations';
  static String get locations => '${ApiConfig.baseUrlV1}$locationsPrefix/';
  static String get estimateArrival => '${locations}estimate_arrival/';

  // Trips
  static const String tripsPrefix = '$trackingPrefix/trips';
  static String get trips => '${ApiConfig.baseUrlV1}$tripsPrefix/';
  static String tripById(String id) => '$trips$id/';
  static String endTrip(String id) => '$trips$id/end/';
  static String tripStatistics(String id) => '$trips$id/statistics/';

  // Passenger counts
  static const String passengerCountsPrefix = '$trackingPrefix/passenger-counts';
  static String get passengerCounts => '${ApiConfig.baseUrlV1}$passengerCountsPrefix/';

  // Waiting passengers
  static const String waitingPassengersPrefix = '$trackingPrefix/waiting-passengers';
  static String get waitingPassengers => '${ApiConfig.baseUrlV1}$waitingPassengersPrefix/';

  // Anomalies
  static const String anomaliesPrefix = '$trackingPrefix/anomalies';
  static String get anomalies => '${ApiConfig.baseUrlV1}$anomaliesPrefix/';
  static String resolveAnomaly(String id) => '$anomalies$id/resolve/';

  // Notifications endpoints
  static const String notificationsPrefix = '/notifications';

  // Notifications
  static const String notificationsSubPrefix = '$notificationsPrefix/notifications';
  static String get notifications => '${ApiConfig.baseUrlV1}$notificationsSubPrefix/';
  static String get markAllAsRead => '${notifications}mark_all_as_read/';
  static String notificationById(String id) => '$notifications$id/';

  // Device tokens
  static const String deviceTokensPrefix = '$notificationsPrefix/device-tokens';
  static String get deviceTokens => '${ApiConfig.baseUrlV1}$deviceTokensPrefix/';
  static String deviceTokenById(String id) => '$deviceTokens$id/';

  // Admin endpoints
  static const String adminPrefix = '/admin';

  // Dashboard
  static const String dashboardPrefix = '$adminPrefix/dashboard';
  static String get dashboard => '${ApiConfig.baseUrlV1}$dashboardPrefix/';
  static String get dashboardStats => '${dashboard}stats/';
  static String get dashboardCharts => '${dashboard}charts/';

  // Reports
  static const String reportsPrefix = '$adminPrefix/reports';
  static String get reports => '${ApiConfig.baseUrlV1}$reportsPrefix/';
  static String get driverPerformanceReport => '${reports}driver-performance/';
  static String get lineUsageReport => '${reports}line-usage/';
  static String get busUtilizationReport => '${reports}bus-utilization/';

  // Settings
  static const String settingsPrefix = '$adminPrefix/settings';
  static String get settings => '${ApiConfig.baseUrlV1}$settingsPrefix/';
  static String get appSettings => '${settings}app/';
  static String get notificationSettings => '${settings}notifications/';
  static String get mapSettings => '${settings}map/';

  // Utilities endpoints
  static const String utilitiesPrefix = '/utilities';

  // File upload
  static const String fileUploadPrefix = '$utilitiesPrefix/file-upload';
  static String get fileUpload => '${ApiConfig.baseUrlV1}$fileUploadPrefix/';

  // Geocoding
  static const String geocodingPrefix = '$utilitiesPrefix/geocoding';
  static String get geocoding => '${ApiConfig.baseUrlV1}$geocodingPrefix/';
  static String get reverseGeocoding => '${geocoding}reverse/';

  // Location autocomplete
  static const String locationAutocompletePrefix = '$utilitiesPrefix/location-autocomplete';
  static String get locationAutocomplete => '${ApiConfig.baseUrlV1}$locationAutocompletePrefix/';

  // Weather
  static const String weatherPrefix = '$utilitiesPrefix/weather';
  static String get weather => '${ApiConfig.baseUrlV1}$weatherPrefix/';
  static String get forecast => '${weather}forecast/';

  // Feedback endpoints
  static const String feedbackPrefix = '/feedback';
  static String get feedback => '${ApiConfig.baseUrlV1}$feedbackPrefix/';
  static String get appFeedback => '${feedback}app/';
  static String get busServiceFeedback => '${feedback}bus-service/';
  static String get bugReport => '${feedback}bug-report/';
  static String get featureRequest => '${feedback}feature-request/';
}