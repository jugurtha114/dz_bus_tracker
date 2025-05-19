// lib/config/theme_config.dart

import 'package:flutter/material.dart';
import 'dart:ui';

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
  static TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
  );

  static TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
  );

  static TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
  );

  // Body text
  static TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: AppColors.darkGrey,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.mediumGrey,
  );

  // Button text
  static TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // Caption
  static TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: AppColors.mediumGrey,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      primaryColorDark: AppColors.primaryDark,
      primaryColorLight: AppColors.primaryLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.white),
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      textTheme: TextTheme(
        headline1: AppTextStyles.h1,
        headline2: AppTextStyles.h2,
        headline3: AppTextStyles.h3,
        bodyText1: AppTextStyles.body,
        bodyText2: AppTextStyles.bodySmall,
        button: AppTextStyles.button,
        caption: AppTextStyles.caption,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          primary: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: AppColors.white,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.transparent,
      ),
    );
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
          color: AppColors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 4),
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
              color: Colors.white.withOpacity(0.2),
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