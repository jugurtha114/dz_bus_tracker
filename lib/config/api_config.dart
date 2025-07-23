// lib/config/api_config.dart

/// API configuration for DZ Bus Tracker
/// Handles environment-specific URLs and all API endpoints
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();
  
  // Environment configuration
  static const String _environment = String.fromEnvironment('ENV', defaultValue: 'development');
  
  // Base URLs for different environments
  static const Map<String, String> _baseUrls = {
    'development': 'http://0.0.0.0:8001',
    'staging': 'https://staging-api.dzbustracker.dz',
    'production': 'https://api.dzbustracker.dz',
  };
  
  /// Get the base URL for the current environment
  static String get baseUrl => _baseUrls[_environment] ?? _baseUrls['development']!;
  
  /// API version prefix
  static const String apiVersion = '/api/v1';
  
  /// Full API base URL
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  /// WebSocket URL for real-time features
  static String get webSocketUrl => baseUrl.replaceFirst('http', 'ws');
  
  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Upload timeout duration (for file uploads)
  static const Duration uploadTimeout = Duration(minutes: 5);
  
  /// Max retry attempts for failed requests
  static const int maxRetryAttempts = 3;
  
  /// Retry delay between attempts
  static const Duration retryDelay = Duration(seconds: 2);
}

/// All API endpoints organized by feature
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();
  
  // ==================== Authentication ====================
  static const String obtainToken = '/api/token/';
  static const String refreshToken = '/api/token/refresh/';
  static const String verifyToken = '/api/token/verify/';
  
  // ==================== User Management ====================
  static const String users = '/accounts/users/';
  static String userById(String id) => '/accounts/users/$id/';
  static const String currentUser = '/accounts/users/me/';
  static String changePassword(String id) => '/accounts/users/$id/change_password/';
  static const String resetPasswordRequest = '/accounts/users/reset_password_request/';
  static const String resetPasswordConfirm = '/accounts/users/reset_password_confirm/';
  
  // ==================== Profiles ====================
  static const String currentProfile = '/accounts/profiles/me/';
  static const String updateProfile = '/accounts/profiles/update_me/';
  
  // ==================== Buses ====================
  static const String buses = '/buses/buses/';
  static String busById(String id) => '/buses/buses/$id/';
  static String approveBus(String id) => '/buses/buses/$id/approve/';
  static String updateBusLocation(String id) => '/buses/buses/$id/update_location/';
  static String updatePassengerCount(String id) => '/buses/buses/$id/update_passenger_count/';
  static const String busLocations = '/buses/locations/';
  
  // ==================== Drivers ====================
  static const String drivers = '/drivers/drivers/';
  static String driverById(String id) => '/drivers/drivers/$id/';
  static String approveDriver(String id) => '/drivers/drivers/$id/approve/';
  static String updateDriverAvailability(String id) => '/drivers/drivers/$id/update_availability/';
  static const String registerDriver = '/drivers/drivers/register/';
  static String driverRatings(String driverId) => '/drivers/drivers/$driverId/ratings/';
  
  // ==================== Lines ====================
  static const String lines = '/lines/lines/';
  static String lineById(String id) => '/lines/lines/$id/';
  static String addStopToLine(String id) => '/lines/lines/$id/add_stop/';
  static String removeStopFromLine(String id) => '/lines/lines/$id/remove_stop/';
  static String lineStops(String id) => '/lines/lines/$id/stops/';
  static String addScheduleToLine(String id) => '/lines/lines/$id/add_schedule/';
  
  // ==================== Stops ====================
  static const String stops = '/lines/stops/';
  static String stopById(String id) => '/lines/stops/$id/';
  static const String nearbyStops = '/lines/stops/nearby/';
  
  // ==================== Tracking ====================
  static const String startTracking = '/tracking/bus-lines/start_tracking/';
  static const String stopTracking = '/tracking/bus-lines/stop_tracking/';
  static const String locationUpdates = '/tracking/locations/';
  static const String estimateArrival = '/tracking/locations/estimate_arrival/';
  
  // ==================== Trips ====================
  static const String trips = '/tracking/trips/';
  static String tripById(String id) => '/tracking/trips/$id/';
  static String endTrip(String id) => '/tracking/trips/$id/end/';
  static String tripStatistics(String id) => '/tracking/trips/$id/statistics/';
  
  // ==================== Passenger Counts ====================
  static const String passengerCounts = '/tracking/passenger-counts/';
  
  // ==================== Waiting Passengers ====================
  static const String waitingPassengers = '/tracking/waiting-passengers/';
  
  // ==================== Anomalies ====================
  static const String anomalies = '/tracking/anomalies/';
  static String resolveAnomaly(String id) => '/tracking/anomalies/$id/resolve/';
  
  // ==================== Notifications ====================
  static const String notifications = '/notifications/notifications/';
  static const String markAllNotificationsRead = '/notifications/notifications/mark_all_as_read/';
  static const String deviceTokens = '/notifications/device-tokens/';
  
  // ==================== Helper Methods ====================
  
  /// Build full endpoint URL
  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('/api/')) {
      return '${ApiConfig.baseUrl}$endpoint';
    }
    return '${ApiConfig.apiBaseUrl}$endpoint';
  }
  
  /// Build URL with query parameters
  static String buildUrlWithParams(String endpoint, Map<String, dynamic>? params) {
    final url = buildUrl(endpoint);
    if (params == null || params.isEmpty) return url;
    
    final uri = Uri.parse(url);
    final newUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...params.map((key, value) => MapEntry(key, value.toString())),
    });
    
    return newUri.toString();
  }
}