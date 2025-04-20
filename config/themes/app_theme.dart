/// lib/config/themes/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import the specific theme definitions
import 'light_theme.dart';
import 'dark_theme.dart';

/// Central class for accessing theme data, managing theme-related utilities,
/// AND defining core theme constants.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // --- Constants (Moved back here as per user request) ---

  // Main Brand Colors
  static const Color primaryColor = Color(0xFF2E8B57); // Forest Green
  static const Color secondaryColor = Color(0xFF1E5631); // Darker green
  static const Color accentColor = Color(0xFFD32F2F); // Red accent

  // Neutral Colors
  static const Color neutralDark = Color(0xFF212121);
  static const Color neutralMedium = Color(0xFF666666);
  static const Color neutralLight = Color(0xFFE0E0E0);
  static const Color neutralBackground = Color(0xFFF5F5F5); // For light theme bg

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color infoColor = Color(0xFF2196F3);

  // Typography
  static const String fontFamily = 'Poppins';
  // Define base TextTheme using the specified font family
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: fontFamily),
    titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: fontFamily),
    titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: fontFamily),
    bodyLarge: TextStyle(fontSize: 16, fontFamily: fontFamily),
    bodyMedium: TextStyle(fontSize: 14, fontFamily: fontFamily),
    bodySmall: TextStyle(fontSize: 12, fontFamily: fontFamily),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: fontFamily),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, fontFamily: fontFamily),
  );


  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;

  // Padding & Margin (Spacing)
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);


  // --- Theme Data Accessors ---

  /// Provides the configured [ThemeData] for the light theme.
  /// Defined in `light_theme.dart`.
  static final ThemeData lightTheme = getLightTheme(); // Assumes function in light_theme.dart

  /// Provides the configured [ThemeData] for the dark theme.
  /// Defined in `dark_theme.dart`.
  static final ThemeData darkTheme = getDarkTheme(); // Assumes function in dark_theme.dart

  // --- Theme Utility Methods ---

  /// Returns the appropriate [ThemeData] based on the selected [ThemeMode]
  /// and the platform's current brightness.
  static ThemeData getTheme(ThemeMode mode, {required Brightness platformBrightness}) {
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return platformBrightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }

  /// Sets the system UI overlay style (status bar, navigation bar) based on
  /// the effective brightness determined by the current [themeMode] and [platformBrightness].
  static void setSystemUIOverlayStyle(ThemeMode themeMode, Brightness platformBrightness) {
    final brightness = _getEffectiveBrightness(themeMode, platformBrightness);

    // Use constants defined within this class now
    final systemNavBarColor = brightness == Brightness.dark
        ? AppTheme.neutralDark // Use internal constant
        : Colors.white; // Or AppTheme.neutralBackground? Using white for consistency with initial example.

    final statusBarIconBrightness = brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    final systemNavBarIconBrightness = brightness == Brightness.dark ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: statusBarIconBrightness,
      statusBarBrightness: brightness == Brightness.dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: systemNavBarColor,
      systemNavigationBarIconBrightness: systemNavBarIconBrightness,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }

  /// Determines the effective brightness (light or dark) based on the theme mode
  /// and the platform's brightness setting.
  static Brightness _getEffectiveBrightness(ThemeMode mode, Brightness platformBrightness) {
    switch (mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return platformBrightness;
    }
  }
}