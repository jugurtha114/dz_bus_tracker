import 'package:flutter/foundation.dart'; // For kDebugMode and String.fromEnvironment

/// Enum representing the different build environments for the application.
enum Environment {
  development,
  staging,
  production,
}

/// Centralized configuration class for the application.
///
/// Reads environment variables defined at compile time using `--dart-define`.
/// Provides easy access to environment-specific settings like API base URLs.
class AppConfig {
  /// The current build environment (development, staging, production).
  final Environment environment;

  /// The base URL for the backend API corresponding to the current environment.
  final String baseUrl;

  // --- Add other configuration variables as needed ---
  // Example:
  // final String googleMapsApiKey;

  // Private constructor to prevent direct instantiation.
  AppConfig._({
    required this.environment,
    required this.baseUrl,
    // required this.googleMapsApiKey,
  });

  // Static instance variable for the singleton pattern.
  static AppConfig? _instance;

  /// Factory constructor to initialize and retrieve the singleton instance.
  ///
  /// Reads 'APP_ENV' and 'BASE_URL' from compile-time definitions.
  /// Defaults to 'development' environment and a local API URL if not defined.
  factory AppConfig() {
    // Initialize only if the instance hasn't been created yet.
    _instance ??= _initialize();
    return _instance!;
  }

  /// Internal initialization logic.
  static AppConfig _initialize() {
    // Determine environment (default to development)
    const String envString =
    String.fromEnvironment('APP_ENV', defaultValue: 'development');
    Environment currentEnv = Environment.values.firstWhere(
          (e) => e.name == envString,
      orElse: () {
        debugPrint(
            "Warning: Invalid or missing APP_ENV environment variable (found '$envString'). Defaulting to 'development'.");
        return Environment.development;
      },
    );

    // Determine base URL (default to local dev URL)
    // For Android emulator accessing host machine's localhost: use 10.0.2.2
    // For iOS simulator accessing host machine's localhost: use localhost or 127.0.0.1
    // Adjust the default based on your primary development setup.
    const String defaultBaseUrl = 'http://0.0.0.0:8000'; // Common Android emulator default
    String currentBaseUrl =
    const String.fromEnvironment('BASE_URL', defaultValue: defaultBaseUrl);

    // --- Example: Load other keys ---
    // const String currentMapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
    // if (currentMapsKey.isEmpty && currentEnv != Environment.development) {
    //   // Warn if a required key is missing in non-dev environments
    //   debugPrint("Warning: GOOGLE_MAPS_API_KEY is not defined via --dart-define.");
    // }

    final config = AppConfig._(
      environment: currentEnv,
      baseUrl: currentBaseUrl,
      // googleMapsApiKey: currentMapsKey,
    );

    // Log the configuration being used (useful for debugging)
    debugPrint("--- AppConfig Initialized ---");
    debugPrint("  Environment: ${config.environment.name}");
    debugPrint("  Base URL: ${config.baseUrl}");
    // debugPrint("  Google Maps Key Loaded: ${config.googleMapsApiKey.isNotEmpty}");
    debugPrint("-----------------------------");

    return config;
  }

  /// Provides access to the singleton instance. Initializes with defaults if not already done.
  static AppConfig get instance {
    // Initialize with defaults if accessed before explicit initialization in main.dart
    _instance ??= _initialize();
    return _instance!;
  }

  /// Helper getter to check if the current environment is development.
  static bool get isDevelopment => instance.environment == Environment.development;

  /// Helper getter to check if the current environment is staging.
  static bool get isStaging => instance.environment == Environment.staging;

  /// Helper getter to check if the current environment is production.
  static bool get isProduction => instance.environment == Environment.production;

  /// Helper getter for the API base URL.
  static String get apiBaseUrl => instance.baseUrl;

// --- Example: Helper getter for other keys ---
// static String get googleMapsApiKey => instance.googleMapsApiKey;
}

/*
 * How to Use Compile-Time Variables:
 * ---------------------------------
 * You can define these variables when running or building your app.
 *
 * Example for Development (using default values):
 * flutter run
 *
 * Example for Staging:
 * flutter run \
 * --dart-define=APP_ENV=staging \
 * --dart-define=BASE_URL=https://staging.your-api.com \
 * --dart-define=GOOGLE_MAPS_API_KEY=YOUR_STAGING_MAPS_KEY
 *
 * Example for Production Build:
 * flutter build apk \
 * --dart-define=APP_ENV=production \
 * --dart-define=BASE_URL=https://api.your-domain.com \
 * --dart-define=GOOGLE_MAPS_API_KEY=YOUR_PRODUCTION_MAPS_KEY
 *
 * Note on API Keys: For sensitive keys like Google Maps API Key, using
 * --dart-define is better than hardcoding, but ideally, they should be
 * configured securely in your native Android/iOS project files or fetched
 * from a secure configuration service at runtime if possible.
 */
