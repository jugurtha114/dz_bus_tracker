// lib/core/constants/app_constants.dart

class AppConstants {
  // App-wide constants
  static const String appName = 'DZ Bus Tracker';
  static const String appVersion = '1.0';

  // Shared preferences keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String firstLaunchKey = 'first_launch';

  // Time constants
  static const int tokenExpiryBuffer = 300; // 5 minutes in seconds
  static const int defaultCacheDuration = 3600; // 1 hour in seconds

  // Map constants
  static const double defaultLatitude = 36; // Algiers latitude
  static const double defaultLongitude = 3; // Algiers longitude
  static const double defaultZoom = 13;

  // User types
  static const String userTypeAdmin = 'admin';
  static const String userTypeDriver = 'driver';
  static const String userTypePassenger = 'passenger';

  // Localization
  static const String defaultLanguage = 'fr';
  static const List<String> supportedLanguages = ['fr', 'ar', 'en'];
  static const Map<String, String> languageNames = {
    'fr': 'Français',
    'ar': 'العربية',
    'en': 'English',
  };
}