// lib/config/theme_config.dart
// DEPRECATED: Use DesignSystem instead
// This file is kept for backward compatibility only

import 'package:flutter/material.dart';
import 'dart:ui';
import 'design_system.dart';

/// Legacy Color System - DEPRECATED
/// Use DesignSystem colors instead
class AppColors {
  // Main colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color accent = Color(0xFF009688);

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color darkGrey = Color(0xFF333333);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color background = Color(0xFFF5F5F5);

  // Functional colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Transparency colors for glassy effect
  static const Color glassWhite = Color(0xBBFFFFFF);
  static const Color glassDark = Color(0x88000000);

  // Occupation status colors
  static const Color lowOccupancy = Color(0xFF4CAF50);
  static const Color mediumOccupancy = Color(0xFFFFC107);
  static const Color highOccupancy = Color(0xFFE53935);
}

class AppTextStyles {
  static const String fontFamily = 'Roboto';

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: AppColors.primary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.primary,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: AppColors.primary,
  );
}

/// Legacy Theme Class - DEPRECATED
/// Use DesignSystem instead
class AppTheme {
  /// Legacy Light Theme - DEPRECATED
  /// Use DesignSystem.lightTheme instead
  static ThemeData get lightTheme {
    return DesignSystem.lightTheme;
  }

  // Helper method to create glass effect containers
  static BoxDecoration glassyContainer({
    Color color = AppColors.glassWhite,
    double borderRadius = 16,
    double blur = 10,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Glass effect container with backdrop filter - use inside a Stack
  static Widget glassContainer({
    required Widget child,
    double borderRadius = 16,
    Color color = AppColors.glassWhite,
    double blur = 10,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
