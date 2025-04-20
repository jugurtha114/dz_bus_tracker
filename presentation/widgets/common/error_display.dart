/// lib/presentation/widgets/common/error_display.dart

import 'package:flutter/material.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/constants/assets_constants.dart'; // For error illustration
import 'themed_button.dart'; // Assuming themed button exists

/// A reusable widget for displaying an error message with an optional retry action.
class ErrorDisplay extends StatelessWidget {
  /// The primary error message to display.
  final String message;

  /// Optional callback function to execute when the retry button is pressed.
  /// If null, the retry button is not shown.
  final VoidCallback? onRetry;

  /// Optional text for the retry button. Defaults to 'Try Again'.
  final String? retryButtonText;

  /// Optional icon data to display. If null, defaults to error outline or image.
  final IconData? iconData;

  /// Optional image asset path. If null, uses iconData or default.
  final String? imageAsset;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText,
    this.iconData,
    this.imageAsset = AssetsConstants.errorIllustration, // Default to illustration
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display Image or Icon
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                height: 100,
                // Optional: Apply error color tint?
                // color: colorScheme.error.withOpacity(0.8),
              )
            else
              Icon(
                iconData ?? Icons.error_outline_rounded, // Default icon
                size: 60,
                color: colorScheme.error.withOpacity(0.8),
              ),

            const SizedBox(height: AppTheme.spacingLarge),

            // Error Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.neutralMedium,
                height: 1.4, // Improve line spacing
              ),
            ),

            // Optional Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingLarge * 1.5),
              ThemedButton(
                onPressed: onRetry,
                text: retryButtonText ?? tr('try_again'), // TODO: Localize
                icon: Icons.refresh,
                variant: ThemedButtonVariant.secondary, // Use secondary style for retry
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withOpacity(0.7)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}

