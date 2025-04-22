/// lib/config/themes/dark_theme.dart

import 'package:flutter/material.dart';
// CORRECTED: Import AppTheme where constants now reside
import 'app_theme.dart';
// REMOVED: No longer need ThemeConstants import
// import '../../core/constants/theme_constants.dart';

/// Returns the configured ThemeData for the Dark theme.
ThemeData getDarkTheme() {
  // Define colors specific to dark theme based on AppTheme constants
  final Color darkBackground = const Color(0xFF121212);
  final Color darkSurface = const Color(0xFF1E1E1E);
  final Color darkOnSurface = Colors.white.withOpacity(0.87);
  final Color darkMediumEmphasis = Colors.white.withOpacity(0.60);

  final ColorScheme darkColorScheme = ColorScheme.dark(
    primary: AppTheme.primaryColor, // Use AppTheme
    secondary: AppTheme.secondaryColor, // Use AppTheme
    tertiary: AppTheme.accentColor, // Use AppTheme
    error: AppTheme.errorColor, // Use AppTheme
    background: darkBackground,
    surface: darkSurface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: darkOnSurface,
    onSurface: darkOnSurface,
    onError: Colors.black,
    surfaceVariant: const Color(0xFF2A2A2A),
    outline: Colors.white.withOpacity(0.3),
  );

  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppTheme.primaryColor, // Use AppTheme
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkBackground,
    canvasColor: darkSurface,
    fontFamily: AppTheme.fontFamily, // Use AppTheme
    textTheme: AppTheme.textTheme.apply( // Use AppTheme
      bodyColor: darkOnSurface,
      displayColor: darkOnSurface,
    ),

    // --- Component Themes ---
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkOnSurface,
      elevation: AppTheme.elevationSmall, // Use AppTheme
      centerTitle: true,
      titleTextStyle: AppTheme.textTheme.titleLarge?.copyWith(color: darkOnSurface), // Use AppTheme
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF2A2A2A),
      elevation: AppTheme.elevationSmall, // Use AppTheme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
      ),
      margin: const EdgeInsets.all(AppTheme.spacingSmall), // Use AppTheme
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLarge, // Use AppTheme
          vertical: AppTheme.spacingMedium, // Use AppTheme
        ),
        textStyle: AppTheme.textTheme.labelLarge, // Use AppTheme
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkColorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium, // Use AppTheme
          vertical: AppTheme.spacingSmall, // Use AppTheme
        ),
        textStyle: AppTheme.textTheme.labelLarge, // Use AppTheme
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkColorScheme.primary,
        side: BorderSide(color: darkColorScheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLarge, // Use AppTheme
          vertical: AppTheme.spacingMedium, // Use AppTheme
        ),
        textStyle: AppTheme.textTheme.labelLarge, // Use AppTheme
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide(color: darkColorScheme.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide(color: darkColorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppTheme.spacingMedium), // Use AppTheme
      labelStyle: AppTheme.textTheme.bodyMedium?.copyWith(color: darkMediumEmphasis), // Use AppTheme
      hintStyle: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.4)), // Use AppTheme
      prefixIconColor: darkMediumEmphasis,
      suffixIconColor: darkMediumEmphasis,
      errorStyle: AppTheme.textTheme.bodySmall?.copyWith(color: darkColorScheme.error), // Use AppTheme
    ),

    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.2),
      thickness: 1,
      space: 0,
      indent: AppTheme.spacingMedium, // Use AppTheme
      endIndent: AppTheme.spacingMedium, // Use AppTheme
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: darkColorScheme.primary,
      unselectedItemColor: darkMediumEmphasis,
      type: BottomNavigationBarType.fixed,
      elevation: AppTheme.elevationMedium, // Use AppTheme
      selectedLabelStyle: AppTheme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600), // Use AppTheme
      unselectedLabelStyle: AppTheme.textTheme.bodySmall, // Use AppTheme
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: darkColorScheme.primary,
      unselectedLabelColor: darkMediumEmphasis,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: darkColorScheme.primary,
          width: 2.5,
        ),
      ),
      labelStyle: AppTheme.textTheme.labelLarge, // Use AppTheme
      unselectedLabelStyle: AppTheme.textTheme.labelLarge, // Use AppTheme
    ),

    iconTheme: IconThemeData(
      color: darkOnSurface,
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: darkColorScheme.primary.withOpacity(0.2),
      labelStyle: AppTheme.textTheme.bodySmall?.copyWith(color: darkOnSurface), // Use AppTheme
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall)), // Use AppTheme
    ),

    listTileTheme: ListTileThemeData(
      iconColor: darkMediumEmphasis,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)), // Use AppTheme
    ),
  );
}