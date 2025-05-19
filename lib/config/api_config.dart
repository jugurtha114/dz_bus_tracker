// lib/config/app_config.dart

class AppConfig {
  // App information
  static const String appName = 'DZ Bus Tracker';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Environment
  static const bool isProduction = false;

  // Default configurations
  static const String defaultLanguage = 'fr'; // French as default
  static const List<String> supportedLanguages = ['fr', 'ar', 'en'];

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Location update interval
  static const int locationUpdateInterval = 10; // in seconds

  // Feature flags
  static const bool enablePassengerCount = true;
  static const bool enableCrowdInfo = false; // Coming soon
  static const bool enableSmartPredictions = false; // Coming soon

  // Cache configuration
  static const int cacheMaxAge = 3600; // 1 hour in seconds
  static const int maxCacheSize = 10 * 1024 * 1024; // 10 MB

  // Map configuration
  static const double defaultZoomLevel = 13.0;
  static const double nearbyStopsRadius = 1000; // in meters

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const int retryDelayFactor = 1500; // in milliseconds
}