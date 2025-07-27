// lib/config/api_config.dart

/// API configuration for DZ Bus Tracker
/// Handles environment-specific URLs and all API endpoints
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // Environment configuration
  static const String _environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // Base URLs for different environments
  static const Map<String, String> _baseUrls = {
    'development': 'http://192.168.114.253:8007',
    'staging':
        'http://192.168.114.253:8007', //'https://staging-api.dzbustracker.dz',
    'production':
        'http://192.168.114.253:8007', //'https://api.dzbustracker.dz',
  };

  /// Get the base URL for the current environment
  static String get baseUrl =>
      _baseUrls[_environment] ?? _baseUrls['development']!;

  /// API version prefix
  static const String apiVersion = '/api/v1';

  /// Full API base URL
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  /// WebSocket base URL for real-time features
  static String get wsBaseUrl => baseUrl.replaceFirst('http', 'ws');
  
  /// Full WebSocket URL for tracking
  static String get webSocketUrl => '$wsBaseUrl$apiVersion/tracking/ws/';
  
  /// WebSocket connection timeout
  static const Duration wsConnectionTimeout = Duration(seconds: 10);
  
  /// WebSocket heartbeat interval
  static const Duration wsHeartbeatInterval = Duration(seconds: 30);
  
  /// WebSocket max reconnection attempts
  static const int wsMaxReconnectAttempts = 5;

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
  static const String users = '/api/v1/accounts/users/';
  static String userById(String id) => '/api/v1/accounts/users/$id/';
  static const String currentUser = '/api/v1/accounts/users/me/';
  static String changePassword(String id) =>
      '/api/v1/accounts/users/$id/change_password/';
  static const String resetPasswordRequest =
      '/api/v1/accounts/users/reset_password_request/';
  static const String resetPasswordConfirm =
      '/api/v1/accounts/users/reset_password_confirm/';
  static const String logout = '/api/v1/accounts/users/logout/';

  // ==================== Profiles ====================
  static const String profiles = '/api/v1/accounts/profiles/';
  static String profileById(String id) => '/api/v1/accounts/profiles/$id/';
  static const String currentProfile = '/api/v1/accounts/profiles/me/';
  static const String updateProfile = '/api/v1/accounts/profiles/update_me/';
  static const String updateNotificationPreferences =
      '/api/v1/accounts/profiles/update_notification_preferences/';

  // ==================== Buses ====================
  static const String buses = '/api/v1/buses/buses/';
  static String busById(String id) => '/api/v1/buses/buses/$id/';
  static String approveBus(String id) => '/api/v1/buses/buses/$id/approve/';
  static String activateBus(String id) => '/api/v1/buses/buses/$id/activate/';
  static String deactivateBus(String id) =>
      '/api/v1/buses/buses/$id/deactivate/';
  static String startBusTracking(String id) =>
      '/api/v1/buses/buses/$id/start_tracking/';
  static String stopBusTracking(String id) =>
      '/api/v1/buses/buses/$id/stop_tracking/';
  static String updateBusLocation(String id) =>
      '/api/v1/buses/buses/$id/update_location/';
  static String updatePassengerCount(String id) =>
      '/api/v1/buses/buses/$id/update_passenger_count/';
  static const String busLocations = '/api/v1/buses/locations/';
  static String busLocationById(String id) => '/api/v1/buses/locations/$id/';

  // ==================== Drivers ====================
  static const String drivers = '/api/v1/drivers/drivers/';
  static String driverById(String id) => '/api/v1/drivers/drivers/$id/';
  static String approveDriver(String id) =>
      '/api/v1/drivers/drivers/$id/approve/';
  static String rejectDriver(String id) =>
      '/api/v1/drivers/drivers/$id/reject/';
  static String updateDriverAvailability(String id) =>
      '/api/v1/drivers/drivers/$id/update_availability/';
  static const String registerDriver = '/api/v1/drivers/drivers/register/';
  static String driverRatings(String driverId) =>
      '/api/v1/drivers/drivers/$driverId/ratings/';
  static String driverRatingById(String driverId, String ratingId) =>
      '/api/v1/drivers/drivers/$driverId/ratings/$ratingId/';

  // ==================== Lines ====================
  static const String lines = '/api/v1/lines/lines/';
  static String lineById(String id) => '/api/v1/lines/lines/$id/';
  static String activateLine(String id) => '/api/v1/lines/lines/$id/activate/';
  static String deactivateLine(String id) =>
      '/api/v1/lines/lines/$id/deactivate/';
  static String addStopToLine(String id) => '/api/v1/lines/lines/$id/add_stop/';
  static String removeStopFromLine(String id) =>
      '/api/v1/lines/lines/$id/remove_stop/';
  static String updateStopOrder(String id) =>
      '/api/v1/lines/lines/$id/update_stop_order/';
  static String lineStops(String id) => '/api/v1/lines/lines/$id/stops/';
  static String lineSchedules(String id) =>
      '/api/v1/lines/lines/$id/schedules/';
  static String addScheduleToLine(String id) =>
      '/api/v1/lines/lines/$id/add_schedule/';
  static const String searchLines = '/api/v1/lines/lines/search/';

  // ==================== Schedules ====================
  static const String schedules = '/api/v1/lines/schedules/';
  static String scheduleById(String id) => '/api/v1/lines/schedules/$id/';

  // ==================== Stops ====================
  static const String stops = '/api/v1/lines/stops/';
  static String stopById(String id) => '/api/v1/lines/stops/$id/';
  static String stopLines(String id) => '/api/v1/lines/stops/$id/lines/';
  static const String nearbyStops = '/api/v1/lines/stops/nearby/';

  // ==================== Tracking ====================
  static const String busLines = '/api/v1/tracking/bus-lines/';
  static String busLineById(String id) => '/api/v1/tracking/bus-lines/$id/';
  static String startTracking(String id) =>
      '/api/v1/tracking/bus-lines/$id/start_tracking/';
  static String stopTracking(String id) =>
      '/api/v1/tracking/bus-lines/$id/stop_tracking/';
  static const String locationUpdates = '/api/v1/tracking/locations/';
  static String locationUpdateById(String id) =>
      '/api/v1/tracking/locations/$id/';
  static const String estimateArrival =
      '/api/v1/tracking/locations/estimate_arrival/';

  // ==================== Trips ====================
  static const String trips = '/api/v1/tracking/trips/';
  static String tripById(String id) => '/api/v1/tracking/trips/$id/';
  static String endTrip(String id) => '/api/v1/tracking/trips/$id/end/';
  static String tripStatistics(String id) =>
      '/api/v1/tracking/trips/$id/statistics/';

  // ==================== Passenger Counts ====================
  static const String passengerCounts = '/api/v1/tracking/passenger-counts/';
  static String passengerCountById(String id) =>
      '/api/v1/tracking/passenger-counts/$id/';

  // ==================== Waiting Passengers ====================
  static const String waitingPassengers =
      '/api/v1/tracking/waiting-passengers/';
  static String waitingPassengerById(String id) =>
      '/api/v1/tracking/waiting-passengers/$id/';

  // ==================== Anomalies ====================
  static const String anomalies = '/api/v1/tracking/anomalies/';
  static String anomalyById(String id) => '/api/v1/tracking/anomalies/$id/';
  static String resolveAnomaly(String id) =>
      '/api/v1/tracking/anomalies/$id/resolve/';

  // ==================== Real-time Tracking ====================
  static const String activeBuses = '/api/v1/tracking/active-buses/';
  static const String busRoute = '/api/v1/tracking/routes/bus_route/';
  static const String routeArrivals = '/api/v1/tracking/routes/arrivals/';
  static const String trackMe = '/api/v1/tracking/routes/track_me/';
  static const String routeVisualization =
      '/api/v1/tracking/routes/visualization/';
      
  // ==================== WebSocket Endpoints ====================
  static const String wsTracking = '/tracking/';
  static const String wsNotifications = '/notifications/';
  static const String wsAdmin = '/admin/';
  static const String wsDriver = '/driver/';
  static const String wsPassenger = '/passenger/';

  // ==================== Route Segments ====================
  static const String routeSegments = '/api/v1/tracking/route-segments/';
  static String routeSegmentById(String id) => '/api/v1/tracking/route-segments/$id/';
  
  // ==================== System Notifications ====================
  static const String notifyDelay = '/api/v1/notifications/system/notify_delay/';
  
  // ==================== Notification Schedules ====================
  static const String notificationSchedules = '/api/v1/notifications/schedules/';
  static String notificationScheduleById(String id) => '/api/v1/notifications/schedules/$id/';
  static String cancelNotificationSchedule(String id) => '/api/v1/notifications/schedules/$id/cancel/';
  
  // ==================== Notifications ====================
  static const String notifications = '/api/v1/notifications/notifications/';
  static String notificationById(String id) =>
      '/api/v1/notifications/notifications/$id/';
  static String markAsRead(String id) =>
      '/api/v1/notifications/notifications/$id/mark_read/';
  static String markAsUnread(String id) =>
      '/api/v1/notifications/notifications/$id/mark_unread/';
  static const String markAllNotificationsRead =
      '/api/v1/notifications/notifications/mark_all_read/';
  static const String unreadCount =
      '/api/v1/notifications/notifications/unread_count/';
  static const String scheduleArrival =
      '/api/v1/notifications/notifications/schedule_arrival/';

  // Device token endpoints
  static const String deviceTokens = '/api/v1/notifications/device-tokens/';
  static String deviceTokenById(String id) =>
      '/api/v1/notifications/device-tokens/$id/';
  static String deactivateDeviceToken(String id) =>
      '/api/v1/notifications/device-tokens/$id/deactivate/';

  // Notification preference endpoints
  static const String notificationPreferences =
      '/api/v1/notifications/preferences/';
  static String notificationPreferenceById(String id) =>
      '/api/v1/notifications/preferences/$id/';

  // ==================== Gamification ====================

  // Achievement endpoints
  static const String achievements = '/api/v1/gamification/achievements/';
  static String achievementById(String id) =>
      '/api/v1/gamification/achievements/$id/';
  static const String achievementProgress =
      '/api/v1/gamification/achievements/progress/';
  static const String unlockedAchievements =
      '/api/v1/gamification/achievements/unlocked/';

  // Challenge endpoints
  static const String challenges = '/api/v1/gamification/challenges/';
  static String challengeById(String id) =>
      '/api/v1/gamification/challenges/$id/';
  static String joinChallenge(String id) =>
      '/api/v1/gamification/challenges/$id/join/';
  static const String myChallenges =
      '/api/v1/gamification/challenges/my_challenges/';

  // Reward endpoints
  static const String rewards = '/api/v1/gamification/rewards/';
  static String rewardById(String id) => '/api/v1/gamification/rewards/$id/';
  static String redeemReward(String id) =>
      '/api/v1/gamification/rewards/$id/redeem/';
  static const String myRewards = '/api/v1/gamification/rewards/my_rewards/';

  // Leaderboard endpoints
  static const String allTimeLeaderboard =
      '/api/v1/gamification/leaderboard/all_time/';
  static const String dailyLeaderboard =
      '/api/v1/gamification/leaderboard/daily/';
  static const String weeklyLeaderboard =
      '/api/v1/gamification/leaderboard/weekly/';
  static const String monthlyLeaderboard =
      '/api/v1/gamification/leaderboard/monthly/';
  static const String myRank = '/api/v1/gamification/leaderboard/my_rank/';

  // Profile endpoints
  static const String myProfile = '/api/v1/gamification/profile/me/';
  static const String updatePreferences =
      '/api/v1/gamification/profile/update_preferences/';
  static const String completeTrip =
      '/api/v1/gamification/profile/complete_trip/';

  // Transaction endpoints
  static const String transactions = '/api/v1/gamification/transactions/';
  static String transactionById(String id) =>
      '/api/v1/gamification/transactions/$id/';
  static const String transactionsSummary =
      '/api/v1/gamification/transactions/summary/';

  // ==================== Helper Methods ====================

  /// Build full endpoint URL
  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('/api/')) {
      return '${ApiConfig.baseUrl}$endpoint';
    }
    return '${ApiConfig.apiBaseUrl}$endpoint';
  }

  /// Build URL with query parameters
  static String buildUrlWithParams(
    String endpoint,
    Map<String, dynamic>? params,
  ) {
    final url = buildUrl(endpoint);
    if (params == null || params.isEmpty) return url;

    final uri = Uri.parse(url);
    final newUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...params.map((key, value) => MapEntry(key, value.toString())),
      },
    );

    return newUri.toString();
  }
}
