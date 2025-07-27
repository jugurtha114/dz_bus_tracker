// lib/config/design_system.dart

import 'package:flutter/material.dart';

/// Modern Design System for DZ Bus Tracker
/// Based on Material You (Material Design 3) principles
/// Optimized for performance and consistency
class DesignSystem {
  DesignSystem._();

  // === COLOR SYSTEM ===
  
  // Primary Colors - Bolt Green for modern mobility
  static const Color primary = Color(0xFF34D186); // Bolt signature green
  static const Color primaryContainer = Color(0xFFE8F8F1); // Light green container
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF003A1A); // Dark green for text

  // Secondary Colors - Bolt Dark Green for depth
  static const Color secondary = Color(0xFF1A7A3E); // Darker Bolt green
  static const Color secondaryContainer = Color(0xFFE1F4E8); // Light secondary container
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF002910); // Very dark green for text

  // Tertiary Colors - Bolt Orange for accents
  static const Color tertiary = Color(0xFFFF6B35); // Bolt orange accent
  static const Color tertiaryContainer = Color(0xFFFFF4F1); // Light orange container
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF8B1A00); // Dark orange for text

  // Surface Colors - Bolt clean design
  static const Color surface = Color(0xFFFFFFFF); // Pure white like Bolt
  static const Color surfaceContainerHighest = Color(0xFFF7F8FA); // Very light gray
  static const Color onSurface = Color(0xFF1A1A1A); // Almost black for text
  static const Color onSurfaceVariant = Color(0xFF737373); // Medium gray for secondary text

  // Outline Colors - Bolt style
  static const Color outline = Color(0xFFE0E0E0); // Light gray borders
  static const Color outlineVariant = Color(0xFFF0F0F0); // Very light borders

  // Semantic Colors - Bolt style
  static const Color error = Color(0xFFFF3B30); // Bolt red for errors
  static const Color errorContainer = Color(0xFFFFF0F0);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF8B0000);

  static const Color success = Color(0xFF34D186); // Use Bolt green for success
  static const Color successContainer = Color(0xFFE8F8F1);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF003A1A);

  static const Color warning = Color(0xFFFFB800); // Bolt yellow for warnings
  static const Color warningContainer = Color(0xFFFFFAE6);
  static const Color onWarning = Color(0xFF000000); // Dark text on yellow
  static const Color onWarningContainer = Color(0xFF8B5A00);

  static const Color info = Color(0xFF007AFF); // Bolt blue for info
  static const Color infoContainer = Color(0xFFE6F3FF);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF003366);
  
  // Additional Bolt colors for consistency
  static const Color boltGreen = Color(0xFF34D186); // Primary Bolt green
  static const Color boltDarkGreen = Color(0xFF1A7A3E); // Darker variant
  static const Color boltLightGreen = Color(0xFFE8F8F1); // Light variant
  static const Color boltOrange = Color(0xFFFF6B35); // Accent orange
  static const Color boltYellow = Color(0xFFFFB800); // Warning yellow
  static const Color boltBlue = Color(0xFF007AFF); // Info blue
  static const Color boltRed = Color(0xFFFF3B30); // Error red
  static const Color boltGray = Color(0xFF737373); // Text gray
  static const Color boltLightGray = Color(0xFFF7F8FA); // Background gray

  // Bus Status Colors
  static const Color busActive = success;
  static const Color busInactive = Color(0xFF9E9E9E);
  static const Color busLowOccupancy = success;
  static const Color busMediumOccupancy = warning;
  static const Color busHighOccupancy = error;

  // Additional Color Properties for Widget Compatibility
  static const Color textDisabled = Color(0xFFB0B0B0);
  static const Color accentColor = tertiary;
  static const Color secondaryColor = secondary;

  // === TYPOGRAPHY SYSTEM ===
  
  static const String fontFamily = 'SF Pro Display'; // More like Bolt's modern font
  
  // Display Text Styles - Enhanced with colors
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.25,
    color: onSurface, // Dark text for large displays
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: onSurface, // Dark text for medium displays
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.29,
    color: onSurface, // Dark text for small displays
  );

  // Headline Text Styles - Enhanced with colors
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: onSurface, // Dark text for headlines
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: onSurface, // Dark text for headlines
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.44,
    color: onSurface, // Dark text for headlines
  );

  // Title Text Styles - Enhanced with colors
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
    color: onSurface, // Dark text for titles
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: onSurface, // Dark text for titles
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.1,
    color: onSurface, // Dark text for titles
  );

  // Body Text Styles - Enhanced for better readability
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
    color: onSurface, // Dark text for good contrast
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: onSurface, // Dark text for good contrast
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: onSurfaceVariant, // Medium gray for secondary text
  );

  // Label Text Styles - Enhanced with colors
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
    color: onSurface, // Dark text for labels
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
    color: onSurfaceVariant, // Medium gray for secondary labels
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: onSurfaceVariant, // Medium gray for small labels
  );

  // === SPACING SYSTEM ===
  
  // Based on 8dp grid system
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

  // === RADIUS SYSTEM - Bolt Style ===
  
  static const double radiusSmall = 12.0; // More rounded like Bolt
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 30.0; // Very rounded for pills
  
  // === ELEVATION SYSTEM ===
  
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 3.0;
  static const double elevation3 = 6.0;
  static const double elevation4 = 8.0;
  static const double elevation5 = 12.0;

  // === COMPONENT SIZES ===
  
  // Button Sizes - Bolt Style
  static const double buttonHeightSmall = 36.0; // Slightly taller for better touch
  static const double buttonHeightMedium = 44.0; // Bolt standard button height
  static const double buttonHeightLarge = 52.0; // Larger for primary actions
  
  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  
  // Touch Target
  static const double touchTarget = 48.0;

  // === COMPATIBILITY ALIASES ===
  // For backward compatibility with enhanced screens
  
  // Color aliases
  static const Color primaryColor = primary;
  static const Color primaryLightColor = primaryContainer;
  static const Color successColor = success;
  static const Color errorColor = error;
  static const Color warningColor = warning;
  static const Color infoColor = info;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color background = surface;
  static const Color surfaceVariant = surfaceContainerHighest;
  static const Color surfaceBorder = outline;
  
  // Spacing aliases
  static const double spacing2 = space2;
  static const double spacing4 = space4;
  static const double spacing6 = space6;
  static const double spacing8 = space8;
  static const double spacing12 = space12;
  static const double spacing16 = space16;
  static const double spacing20 = space20;
  static const double spacing24 = space24;
  static const double spacing32 = space32;
  static const double spacing40 = space40;
  static const double spacing48 = space48;
  static const double spacing56 = space56;
  static const double spacing64 = space64;
  
  // Radius aliases - using existing values
  // static const double radiusSmall = radiusSmall; // Already defined above
  // static const double radiusMedium = radiusMedium; // Already defined above  
  // static const double radiusLarge = radiusLarge; // Already defined above

  // === THEME DATA ===
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        onSecondary: onSecondary,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiary: onTertiary,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        errorContainer: errorContainer,
        onError: onError,
        onErrorContainer: onErrorContainer,
        surface: surface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      
      scaffoldBackgroundColor: surface,
      
      // App Bar Theme - Enhanced readability
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: elevation1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22, // Slightly larger for better readability
          fontWeight: FontWeight.w700, // Bolder for better contrast
          color: onSurface,
        ),
        iconTheme: IconThemeData(
          color: onSurface, // Dark icons in app bar
          size: 24,
        ),
      ),
      
      // Card Theme - Bolt Style
      cardTheme: CardThemeData(
        color: surface,
        elevation: elevation0, // Flat cards like Bolt
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge), // More rounded
          side: BorderSide(color: outline, width: 1), // Light border
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: space8, vertical: space4),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Bolt green
          foregroundColor: onPrimary,
          elevation: elevation0, // Flat design like Bolt
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusRound), // Very rounded like Bolt
          ),
          minimumSize: const Size(64, buttonHeightLarge),
          padding: const EdgeInsets.symmetric(horizontal: space24),
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          minimumSize: const Size(64, buttonHeightLarge),
          padding: const EdgeInsets.symmetric(horizontal: space24),
          textStyle: labelLarge,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: primary, width: 2), // Bolt green border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusRound), // Very rounded
          ),
          minimumSize: const Size(64, buttonHeightLarge),
          padding: const EdgeInsets.symmetric(horizontal: space24),
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary, // Bolt green for text buttons
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          minimumSize: const Size(64, buttonHeightMedium),
          padding: const EdgeInsets.symmetric(horizontal: space16),
          textStyle: labelLarge.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      
      // Input Decoration Theme - Bolt Style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge), // More rounded
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: primary, width: 2), // Bolt green focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space20, // More padding like Bolt
          vertical: space16,
        ),
        hintStyle: bodyMedium.copyWith(color: onSurfaceVariant),
        labelStyle: bodyMedium.copyWith(color: onSurfaceVariant),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      
      // Icon Theme - Enhanced for better visibility
      iconTheme: const IconThemeData(
        color: onSurface, // Darker icons for better contrast
        size: iconMedium,
      ),
      primaryIconTheme: const IconThemeData(
        color: onPrimary, // White icons on primary background
        size: iconMedium,
      ),
      
      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: elevation2,
        indicatorColor: secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(labelMedium),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: onSecondaryContainer);
          }
          return const IconThemeData(color: onSurfaceVariant);
        }),
      ),
      
      // FAB Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryContainer,
        foregroundColor: onPrimaryContainer,
        elevation: elevation3,
        shape: CircleBorder(),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF90CAF9), // Blue 200
        primaryContainer: Color(0xFF1565C0),
        onPrimary: Color(0xFF0D47A1),
        onPrimaryContainer: Color(0xFFE3F2FD),
        secondary: Color(0xFF81C784), // Green 300
        secondaryContainer: Color(0xFF2E7D32),
        onSecondary: Color(0xFF1B5E20),
        onSecondaryContainer: Color(0xFFE8F5E8),
        tertiary: Color(0xFFFFB74D), // Orange 300
        tertiaryContainer: Color(0xFFE65100),
        onTertiary: Color(0xFFBF360C),
        onTertiaryContainer: Color(0xFFFFF3E0),
        error: Color(0xFFEF5350), // Red 400
        errorContainer: Color(0xFFBA1A1A),
        onError: Color(0xFF410002),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF121212),
        surfaceContainerHighest: Color(0xFF1E1E1E),
        onSurface: Color(0xFFE0E0E0),
        onSurfaceVariant: Color(0xFFBDBDBD),
        outline: Color(0xFF757575),
        outlineVariant: Color(0xFF424242),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
    );
  }
}

/// Extension for easy access to design system values
extension DesignSystemExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  
  // Semantic colors
  Color get successColor => DesignSystem.success;
  Color get warningColor => DesignSystem.warning;
  Color get errorColor => DesignSystem.error;
  Color get infoColor => DesignSystem.info;
  
  // Bolt brand colors for easy access
  Color get boltGreen => DesignSystem.boltGreen;
  Color get boltDarkGreen => DesignSystem.boltDarkGreen;
  Color get boltLightGreen => DesignSystem.boltLightGreen;
  Color get boltOrange => DesignSystem.boltOrange;
  Color get boltYellow => DesignSystem.boltYellow;
  Color get boltBlue => DesignSystem.boltBlue;
  Color get boltRed => DesignSystem.boltRed;
  Color get boltGray => DesignSystem.boltGray;
  Color get boltLightGray => DesignSystem.boltLightGray;
}