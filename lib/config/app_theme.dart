// lib/config/app_theme.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern Professional Design System
/// Based on contemporary design principles with sophisticated color palette
class AppTheme {
  // Typography
  static const String fontFamily = 'Inter';
  static const String fontFamilyDisplay = 'Inter';
  
  // === MODERN COLOR SYSTEM ===
  
  // Primary - Sophisticated Sky Blue (Trust, Technology, Reliability)
  static const Color primary = Color(0xFF0284C7); // Sky blue 600
  static const Color primaryLight = Color(0xFF0EA5E9); // Sky blue 500
  static const Color primaryDark = Color(0xFF0369A1); // Sky blue 700
  static const Color primaryContainer = Color(0xFFE0F2FE); // Sky blue 50
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0C4A6E);
  
  // Secondary - Modern Emerald (Growth, Success, Innovation)
  static const Color secondary = Color(0xFF059669); // Emerald 600
  static const Color secondaryLight = Color(0xFF10B981); // Emerald 500
  static const Color secondaryDark = Color(0xFF047857); // Emerald 700
  static const Color secondaryContainer = Color(0xFFD1FAE5); // Emerald 50
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF064E3B);
  
  // Tertiary - Premium Purple (Innovation, Premium)
  static const Color tertiary = Color(0xFF7C3AED); // Violet 600
  static const Color tertiaryLight = Color(0xFF8B5CF6); // Violet 500
  static const Color tertiaryDark = Color(0xFF6D28D9); // Violet 700
  static const Color tertiaryContainer = Color(0xFFF3E8FF); // Violet 50
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF4C1D95);
  
  // Semantic Colors
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successLight = Color(0xFF22C55E); // Green 500
  static const Color successContainer = Color(0xFFDCFCE7); // Green 50
  
  static const Color warning = Color(0xFFEA580C); // Orange 600
  static const Color warningLight = Color(0xFFF97316); // Orange 500
  static const Color warningContainer = Color(0xFFFED7AA); // Orange 100
  
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFEF4444); // Red 500
  static const Color errorContainer = Color(0xFFFEE2E2); // Red 50
  
  static const Color info = Color(0xFF2563EB); // Blue 600
  static const Color infoLight = Color(0xFF3B82F6); // Blue 500
  static const Color infoContainer = Color(0xFFDBEAFE); // Blue 50
  
  // Neutral Scale (Modern Gray System)
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);
  
  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color surfaceContainerHighest = Color(0xFFCBD5E1);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  
  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF0F172A);
  
  // Outline
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFF1F5F9);
  
  // Glass Morphism Colors
  static const Color glass = Color(0x0DFFFFFF);
  static const Color glassMedium = Color(0x1AFFFFFF);
  static const Color glassStrong = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x0F000000);
  
  // === GRADIENT SYSTEM ===
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );
  
  static const LinearGradient tertiaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tertiaryLight, tertiary],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successLight, success],
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, surfaceVariant],
  );
  
  static const LinearGradient modernGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary, tertiary],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const RadialGradient glowGradient = RadialGradient(
    colors: [glassMedium, glass, Color(0x00FFFFFF)],
    stops: [0.0, 0.7, 1.0],
  );
  
  // === SPACING SYSTEM (8pt Grid) ===
  static const double spacing0 = 0.0;
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;
  static const double spacing80 = 80.0;
  static const double spacing96 = 96.0;
  
  // === BORDER RADIUS SYSTEM ===
  static const double radiusNone = 0.0;
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2xl = 20.0;
  static const double radius3xl = 24.0;
  static const double radius4xl = 32.0;
  static const double radiusFull = 9999.0;
  
  // === ELEVATION SYSTEM ===
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
  
  // === ANIMATION SYSTEM ===
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
  static const Duration animationSlower = Duration(milliseconds: 500);
  
  // === LIGHT THEME ===
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onPrimary,
        errorContainer: errorContainer,
        onErrorContainer: onTertiaryContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      
      scaffoldBackgroundColor: surface,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: elevation0,
        scrolledUnderElevation: elevation1,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onSurface,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: onSurface,
          size: 24,
        ),
        centerTitle: false,
        titleSpacing: spacing20,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: elevation0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: glassShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
          side: const BorderSide(color: outline, width: 1),
        ),
        margin: const EdgeInsets.all(spacing8),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevation0,
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: neutral300,
          disabledForegroundColor: neutral500,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          minimumSize: const Size(double.minPositive, 48),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: elevation0,
          foregroundColor: primary,
          disabledForegroundColor: neutral500,
          side: const BorderSide(color: outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          minimumSize: const Size(double.minPositive, 48),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          disabledForegroundColor: neutral500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing20,
            vertical: spacing12,
          ),
          minimumSize: const Size(double.minPositive, 40),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing20,
          vertical: spacing16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: const TextStyle(
          color: neutral500,
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: neutral700,
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: primary,
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: elevation8,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: elevation6,
        focusElevation: elevation8,
        hoverElevation: elevation8,
        highlightElevation: elevation12,
        disabledElevation: elevation0,
        shape: CircleBorder(),
      ),
      
      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: elevation16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(radius2xl),
            bottomRight: Radius.circular(radius2xl),
          ),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: elevation24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius3xl),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          height: 1.5,
        ),
      ),
      
      // Text Theme (Material 3 Design)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamilyDisplay,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: onSurface,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamilyDisplay,
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: onSurface,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamilyDisplay,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: onSurface,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamilyDisplay,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamilyDisplay,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamilyDisplay,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: onSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: onSurface,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: onSurface,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: onSurfaceVariant,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: onSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: onSurface,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: onSurface,
        ),
      ),
    );
  }
  
  // === DARK THEME ===
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: neutral900,
      
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        onPrimary: neutral900,
        primaryContainer: Color(0xFF0C4A6E),
        onPrimaryContainer: primaryContainer,
        secondary: secondaryLight,
        onSecondary: neutral900,
        secondaryContainer: Color(0xFF064E3B),
        onSecondaryContainer: secondaryContainer,
        tertiary: tertiaryLight,
        onTertiary: neutral900,
        tertiaryContainer: Color(0xFF4C1D95),
        onTertiaryContainer: tertiaryContainer,
        error: errorLight,
        onError: neutral900,
        errorContainer: Color(0xFF7F1D1D),
        onErrorContainer: errorContainer,
        surface: neutral900,
        onSurface: neutral100,
        surfaceContainerHighest: neutral700,
        onSurfaceVariant: neutral300,
        outline: neutral600,
        outlineVariant: neutral700,
      ),
      
      // Override specific components for dark theme
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: neutral900,
        foregroundColor: neutral100,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: neutral100,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: neutral300,
          size: 24,
        ),
      ),
    );
  }
  
  // === UTILITY METHODS ===
  
  /// Creates a modern glass morphism decoration
  static BoxDecoration glassDecoration({
    Color? color,
    double borderRadius = radius2xl,
    double borderWidth = 1,
    Color? borderColor,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: color ?? (isDark ? const Color(0x1AFFFFFF) : glass),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? (isDark ? const Color(0x33FFFFFF) : glassBorder),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? const Color(0x33000000) : glassShadow,
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  /// Creates a modern shadow for elevated components
  static List<BoxShadow> modernShadow({
    double elevation = elevation2,
    Color? color,
    bool isDark = false,
  }) {
    final shadowColor = color ?? (isDark ? Colors.black54 : glassShadow);
    final blur = elevation * 2;
    final offset = elevation / 2;
    
    return [
      BoxShadow(
        color: shadowColor,
        blurRadius: blur,
        offset: Offset(0, offset),
        spreadRadius: 0,
      ),
    ];
  }
  
  /// Creates a glass container with backdrop filter
  static Widget glassContainer({
    required Widget child,
    double borderRadius = radius2xl,
    Color? color,
    double blur = 10,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? height,
    double? width,
    bool isDark = false,
  }) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(spacing20),
            decoration: glassDecoration(
              color: color,
              borderRadius: borderRadius,
              isDark: isDark,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}