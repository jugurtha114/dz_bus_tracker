// lib/config/app_config.dart

import 'package:flutter/foundation.dart';

/// App-wide configuration settings
class AppConfig {
  // App information
  static const String appName = 'DZ Bus Tracker';
  static const String appVersion = '1.0';
  static const String appBuildNumber = '1';
  static const String appDescription = 'Smart, real-time bus tracking for Algeria – connecting passengers and drivers like never before.';
  static const String appCopyright = '© 2025 DZ Bus Tracker';
  static const String appWebsite = 'https://dzbusttracker.dz';
  static const String appSupportEmail = 'support@dzbusttracker.dz';

  // Environment
  static const bool isProduction = false;
  static const bool isDevelopment = true;
  static const bool isStaging = false;
  static const String environment = isDevelopment ? 'dev' : isStaging ? 'staging' : 'production';

  // Default configurations
  static const String defaultLanguage = 'fr'; // French as default
  static const List<String> supportedLanguages = ['fr', 'ar', 'en'];
  static const String defaultCountryCode = 'DZ'; // Algeria
  static const String defaultPhoneCode = '+213';
  static const String defaultDateFormat = 'dd/MM/yyyy';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String defaultCurrency = 'DZD';
  static const String defaultCurrencySymbol = 'دج';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
  static const int cacheMaxAge = 86400; // 24 hours in seconds
  static const int sessionTimeout = 3600; // 1 hour in seconds
  static const int tokenRefreshThreshold = 300; // 5 minutes in seconds
  static const int locationUpdateInterval = 10; // in seconds
  static const int backgroundLocationUpdateInterval = 30; // in seconds
  static const int busLocationRefreshInterval = 10; // in seconds
  static const int nearbyBusesRefreshInterval = 30; // in seconds

  // Feature flags
  static const bool enablePassengerCount = true;
  static const bool enableWaitingPassengerReporting = true;
  static const bool enableRatings = true;
  static const bool enableNotifications = true;
  static const bool enableCrowdInfo = false; // Coming soon
  static const bool enableSmartPredictions = false; // Coming soon
  static const bool enableOfflineMode = false; // Coming soon
  static const bool enableMultiLanguage = true;
  static const bool enableDarkMode = false; // Coming soon
  static const bool enableAnalytics = isProduction;
  static const bool enableCrashReporting = isProduction;
  static const bool enablePerformanceMonitoring = isProduction;

  // Cache configuration
  static const bool enableCache = true;
  static const int maxCacheSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> cachedEndpoints = [
    '/lines',
    '/stops',
    '/buses',
  ];

  // Map configuration
  static const String mapType = 'google'; // 'google' or 'osm'
  static const double defaultZoomLevel = 15;
  static const double maxZoomLevel = 19;
  static const double minZoomLevel = 5;
  static const double nearbyStopsRadius = 1000; // in meters
  static const double nearbyBusesRadius = 2000; // in meters
  static const double defaultLatitude = 36; // Algiers latitude
  static const double defaultLongitude = 3; // Algiers longitude
  static const int defaultStopDisplayCount = 10;
  static const int maxStopsToDisplay = 30;
  static const int maxBusesToTrack = 20;

  // Location configuration
  static const int locationDistanceFilter = 10; // in meters
  static const int locationRequiredAccuracy = 50; // in meters
  static const bool useHighAccuracyLocation = true;
  static const bool useBackgroundLocation = true;

  // UI configuration
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration toastDuration = Duration(seconds: 2);
  static const double buttonHeight = 50;
  static const double borderRadius = 8;
  static const double glassMorphismOpacity = 0;
  static const double glassMorphismBlur = 10;

  // Notification configuration
  static const String notificationChannelId = 'dz_bus_tracker_channel';
  static const String notificationChannelName = 'DZ Bus Tracker Notifications';
  static const String notificationChannelDescription = 'Notifications from DZ Bus Tracker app';
  static const String notificationIcon = '@mipmap/ic_launcher';
  static const bool enableFCM = true;

  // Security configuration
  static const bool enableEncryption = true;
  static const bool enableBiometricAuthentication = false; // Coming soon
  static const bool enablePinAuthentication = false; // Coming soon
  static const int maxLoginAttempts = 5;
  static const int passwordMinLength = 8;
  static const bool requireStrongPassword = true;

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const int retryDelayFactor = 1500; // in milliseconds
  static const int maxRetryDelay = 10000; // 10 seconds

  // Social media
  static const String facebookPage = 'https://facebook.com/dzbusttracker';
  static const String twitterHandle = 'https://twitter.com/dzbusttracker';
  static const String instagramAccount = 'https://instagram.com/dzbusttracker';

  // Store URLs
  static const String appStoreUrl = 'https://apps.apple.com/app/dzbusttracker';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=dz.busttracker';

  // Terms and Privacy
  static const String termsUrl = 'https://dzbusttracker.dz/terms';
  static const String privacyUrl = 'https://dzbusttracker.dz/privacy';
  static const String helpUrl = 'https://dzbusttracker.dz/help';

  // Debug configuration
  static bool get showDebugBanner => kDebugMode && !isProduction;
  static const bool enableDebugLogs = kDebugMode;
  static const bool enableNetworkLogs = kDebugMode;
  static const bool enablePerformanceLogs = kDebugMode;
}