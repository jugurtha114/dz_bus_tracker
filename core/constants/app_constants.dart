/// lib/core/constants/app_constants.dart

import 'package:flutter/material.dart';
// ADDED: Import for LatLng
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Contains general application-wide constant values and settings.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'DZ Bus Tracker';
  static const String appVersion = '1.0.0+1'; // Example versioning (version+build)

  // Feature Settings
  static const int locationUpdateIntervalSeconds = 20; // Driver GPS update frequency
  static const double defaultMapZoom = 14.0; // Initial zoom level for maps
  static const double nearbySearchRadiusMeters = 1000; // Radius for searching nearby stops (1km)
  static const int defaultPaginationSize = 20; // Default number of items per page in API responses
  static const int defaultApiTimeoutMs = 15000; // Default network timeout (15 seconds)
  static const int defaultCacheDurationDays = 7; // Default duration to keep cached data

  // Default Locale (French as per requirement)
  static const Locale defaultLocale = Locale('fr', 'FR');

  // Default Values
  static const String defaultApiError = 'An unexpected error occurred. Please try again.'; // TODO: Localize this key
  static const String defaultNetworkError = 'Please check your internet connection and try again.'; // TODO: Localize this key
  static const double defaultMapLatitude = 36.7753; // Default map center (Algiers)
  static const double defaultMapLongitude = 3.0603; // Default map center (Algiers)

  /// ADDED: Default LatLng center for maps.
  static const LatLng initialMapCenter = LatLng(defaultMapLatitude, defaultMapLongitude);

  // UI related defaults (can be moved to theme constants if preferred)
  static const double defaultHorizontalPadding = 16.0;
  static const double defaultVerticalPadding = 16.0;
  static const double defaultListSpacing = 8.0;


  // Storage Keys (optional, can also be managed by StorageService)
  // static const String storageKeyAuthToken = 'auth_token';
  // static const String storageKeyRefreshToken = 'refresh_token';
  // static const String storageKeyThemeMode = 'theme_mode';
  // static const String storageKeyLanguageCode = 'language_code';
}
