// lib/config/quick_fixes.dart

/// Quick fixes for critical compilation errors
/// This file contains temporary fixes for deprecated APIs and compile errors

import 'package:flutter/material.dart';

// Extension to fix deprecated color APIs
extension ColorFixes on ColorScheme {
  Color get backgroundCompat => surface;
  Color get onBackgroundCompat => onSurface;
  Color get surfaceVariantCompat => surfaceContainerHighest;
}

// Extension to fix deprecated Material State APIs
extension MaterialStateFixes on Set<WidgetState> {
  Set<WidgetState> get toWidgetState => this;
}

// Helper for card theme
CardThemeData get compatibleCardTheme => const CardThemeData(
  elevation: 1,
  margin: EdgeInsets.all(8),
  clipBehavior: Clip.antiAlias,
);

// Helper for navigation bar theme
NavigationBarThemeData compatibleNavigationBarTheme(ColorScheme colorScheme) {
  return NavigationBarThemeData(
    backgroundColor: colorScheme.surface,
    elevation: 2,
    indicatorColor: colorScheme.secondaryContainer,
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: colorScheme.onSecondaryContainer);
      }
      return IconThemeData(color: colorScheme.onSurfaceVariant);
    }),
  );
}