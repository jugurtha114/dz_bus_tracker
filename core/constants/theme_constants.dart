/// lib/core/constants/theme_constants.dart

import 'package:flutter/material.dart';

/// Defines constant values used throughout the application's themes.
/// These constants ensure consistency in colors, spacing, typography, etc.
class ThemeConstants {
  // Private constructor to prevent instantiation
  ThemeConstants._();

  // --- Main Brand Colors ---
  static const Color primaryColor = Color(0xFF2E8B57); // Forest Green
  static const Color secondaryColor = Color(0xFF1E5631); // Darker green
  static const Color accentColor = Color(0xFFD32F2F); // Red accent (flag)

  // --- Neutral Colors ---
  static const Color neutralDark = Color(0xFF212121); // Very dark grey/black
  static const Color neutralMedium = Color(0xFF666666); // Medium grey
  static const Color neutralLight = Color(0xFFE0E0E0); // Light grey
  static const Color neutralBackground = Color(0xFFF5F5F5); // Very light grey for light theme background

  // --- Status Colors ---
  static const Color successColor = Color(0xFF4CAF50); // Green for success
  static const Color warningColor = Color(0xFFFFC107); // Amber for warnings
  static const Color errorColor = Color(0xFFEF5350); // Red for errors
  static const Color infoColor = Color(0xFF2196F3); // Blue for informational messages

  // --- Typography ---
  static const String fontFamily = 'Poppins'; // Selected font family
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

  // --- Border Radius ---
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;

  // --- Padding & Margin (Spacing) ---
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // --- Elevation ---
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // --- Animation Durations ---
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
}