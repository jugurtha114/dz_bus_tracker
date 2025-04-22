/// lib/config/themes/light_theme.dart

import 'package:flutter/material.dart';
// CORRECTED: Import AppTheme where constants now reside
import 'app_theme.dart';
// REMOVED: No longer need ThemeConstants import
// import '../../core/constants/theme_constants.dart';

/// Returns the configured ThemeData for the Light theme.
ThemeData getLightTheme() {
  // Define colors specific to light theme based on AppTheme constants
  const ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppTheme.primaryColor, // Use AppTheme
    secondary: AppTheme.secondaryColor, // Use AppTheme
    tertiary: AppTheme.accentColor, // Use AppTheme
    error: AppTheme.errorColor, // Use AppTheme
    background: AppTheme.neutralBackground, // Use AppTheme
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: AppTheme.neutralDark, // Use AppTheme
    onSurface: AppTheme.neutralDark, // Use AppTheme
    onError: Colors.white,
    surfaceVariant: AppTheme.neutralLight, // Use AppTheme
    // outline: AppTheme.neutralMedium.withOpacity(0.5), // Use AppTheme
  );

  return ThemeData(
    brightness: Brightness.light,
    primaryColor: AppTheme.primaryColor, // Use AppTheme
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: AppTheme.neutralBackground, // Use AppTheme
    canvasColor: Colors.white,
    fontFamily: AppTheme.fontFamily, // Use AppTheme
    textTheme: AppTheme.textTheme.apply( // Use AppTheme
      bodyColor: AppTheme.neutralDark, // Use AppTheme
      displayColor: AppTheme.neutralDark, // Use AppTheme
    ),

    // --- Component Themes ---
    appBarTheme: AppBarTheme(
      backgroundColor: AppTheme.primaryColor, // Use AppTheme
      foregroundColor: lightColorScheme.onPrimary,
      elevation: AppTheme.elevationSmall, // Use AppTheme
      centerTitle: true,
      titleTextStyle: AppTheme.textTheme.titleLarge?.copyWith(color: lightColorScheme.onPrimary), // Use AppTheme
    ),

    cardTheme: CardThemeData(
      color: lightColorScheme.surface,
      elevation: AppTheme.elevationSmall, // Use AppTheme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
      ),
      margin: const EdgeInsets.all(AppTheme.spacingSmall), // Use AppTheme
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
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
        foregroundColor: lightColorScheme.primary,
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
        foregroundColor: lightColorScheme.primary,
        side: BorderSide(color: lightColorScheme.primary, width: 1.5),
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
      fillColor: Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: const BorderSide(color: AppTheme.neutralLight, width: 1.0), // Use AppTheme
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide(color: lightColorScheme.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // Use AppTheme
        borderSide: BorderSide(color: lightColorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppTheme.spacingMedium), // Use AppTheme
      labelStyle: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium), // Use AppTheme
      hintStyle: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium.withOpacity(0.7)), // Use AppTheme
      prefixIconColor: AppTheme.neutralMedium, // Use AppTheme
      suffixIconColor: AppTheme.neutralMedium, // Use AppTheme
    ),

    dividerTheme: const DividerThemeData(
      color: AppTheme.neutralLight, // Use AppTheme
      thickness: 1,
      space: 0,
      indent: AppTheme.spacingMedium, // Use AppTheme
      endIndent: AppTheme.spacingMedium, // Use AppTheme
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: lightColorScheme.primary,
      unselectedItemColor: AppTheme.neutralMedium, // Use AppTheme
      type: BottomNavigationBarType.fixed,
      elevation: AppTheme.elevationMedium, // Use AppTheme
      selectedLabelStyle: AppTheme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600), // Use AppTheme
      unselectedLabelStyle: AppTheme.textTheme.bodySmall, // Use AppTheme
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: lightColorScheme.primary,
      unselectedLabelColor: AppTheme.neutralMedium, // Use AppTheme
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: lightColorScheme.primary,
          width: 2.5,
        ),
      ),
      labelStyle: AppTheme.textTheme.labelLarge, // Use AppTheme
      unselectedLabelStyle: AppTheme.textTheme.labelLarge, // Use AppTheme
    ),

    iconTheme: const IconThemeData(
      color: AppTheme.neutralDark, // Use AppTheme
      size: 24,
    ),
    primaryIconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: lightColorScheme.secondaryContainer.withOpacity(0.6),
      labelStyle: AppTheme.textTheme.bodySmall?.copyWith(color: lightColorScheme.onSecondaryContainer), // Use AppTheme
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall)), // Use AppTheme
    ),

    listTileTheme: ListTileThemeData(
      iconColor: AppTheme.neutralMedium, // Use AppTheme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)), // Use AppTheme
    ),
  );
}