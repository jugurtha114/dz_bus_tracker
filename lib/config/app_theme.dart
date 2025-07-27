// lib/config/app_theme.dart
// DEPRECATED: Use DesignSystem instead
// This file is kept for backward compatibility only

import 'package:flutter/material.dart';
import 'design_system.dart';

/// Legacy Theme System - DEPRECATED
/// Use DesignSystem class instead for new development
class AppTheme {
  AppTheme._();

  // === MODERN COLOR PALETTE ===

  // Primary - Professional Blue (Trust, Navigation, Technology)
  static const Color primary = Color(0xFF1E40AF); // Blue 800
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF1E3A8A); // Blue 900

  // Secondary - Success Green (Active, Available, Success)
  static const Color secondary = Color(0xFF059669); // Emerald 600
  static const Color secondaryLight = Color(0xFF10B981); // Emerald 500
  static const Color secondaryDark = Color(0xFF047857); // Emerald 700

  // Accent - Warning Orange (Alerts, Notifications)
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color accentLight = Color(0xFFFBBF24); // Amber 400
  static const Color accentDark = Color(0xFFD97706); // Amber 600

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Legacy tertiary colors (mapped to accent for compatibility)
  static const Color tertiary = accent;
  static const Color tertiaryLight = Color(0xFFFBBF24);
  static const Color tertiaryDark = Color(0xFFD97706);

  // Legacy neutral colors (mapped to gray for compatibility)
  static const Color neutral50 = gray50;
  static const Color neutral100 = gray100;
  static const Color neutral200 = gray200;
  static const Color neutral300 = gray300;
  static const Color neutral400 = gray400;
  static const Color neutral500 = gray500;
  static const Color neutral600 = gray600;
  static const Color neutral700 = gray700;
  static const Color neutral800 = gray800;
  static const Color neutral900 = gray900;

  // Neutral Scale - Clean Gray System
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Surface Colors
  static const Color surface = white;
  static const Color surfaceContainerHighest = gray50;
  static const Color onSurface = gray900;
  static const Color onSurfaceVariant = gray600;

  // Border and Outline
  static const Color outline = gray300;
  static const Color outlineVariant = gray200;

  // === TYPOGRAPHY SCALE ===
  static const String fontFamily = 'Inter';

  // === SPACING SYSTEM (4pt grid) ===
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;

  // Legacy spacing names (mapped to space values for compatibility)
  static const double spacing6 = space6;
  static const double spacing8 = space8;
  static const double spacing12 = space12;
  static const double spacing16 = space16;
  static const double spacing20 = space20;
  static const double spacing24 = space24;
  static const double spacing32 = space32;

  // === BORDER RADIUS ===
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Legacy radius names (mapped to radius values for compatibility)
  static const double radiusLg = radiusLarge;
  static const double radiusXl = radiusXLarge;
  static const double radius2xl = 32.0;
  static const double radius3xl = 48.0;
  static const double radiusFull = 999.0;

  // === ELEVATION ===
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // Legacy elevation names (mapped to elevation values for compatibility)
  static const double elevation2 = elevationSmall;
  static const double elevation6 = elevationMedium;

  // === LEGACY GLASS EFFECTS (Mapped to clean alternatives) ===
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassMedium = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // === LEGACY GRADIENTS (Mapped to clean alternatives) ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === LEGACY COLORS (Mapped to new clean colors) ===
  static const Color primaryContainer = primaryLight;
  static const Color onPrimary = white;
  static const Color onPrimaryContainer = white;

  // === LEGACY ANIMATIONS (Mapped to clean durations) ===
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);

  // === LEGACY SHADOWS (Mapped to clean shadow functions) ===
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Legacy shadow method
  static List<BoxShadow> modernShadow(double elevation) => [
    BoxShadow(
      color: black.withValues(alpha: 0.1),
      blurRadius: elevation * 2,
      offset: Offset(0, elevation),
    ),
  ];

  /// Light Theme - DEPRECATED
  /// Use DesignSystem.lightTheme instead
  static ThemeData get lightTheme {
    return DesignSystem.lightTheme;
  }

  /// Dark Theme - DEPRECATED
  /// Use DesignSystem.darkTheme instead
  static ThemeData get darkTheme {
    return DesignSystem.darkTheme;
  }
}

/// Theme Extensions
extension AppThemeExtension on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  Color get successColor => AppTheme.success;
  Color get warningColor => AppTheme.warning;
  Color get errorColor => AppTheme.error;
  Color get infoColor => AppTheme.info;
}
