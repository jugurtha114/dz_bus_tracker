/// lib/presentation/widgets/common/loading_indicator.dart

import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart'; // For default color

/// A reusable widget for displaying a loading state, typically a circular progress indicator.
class LoadingIndicator extends StatelessWidget {
  /// Optional message displayed below the indicator.
  final String? message;
  /// The size (diameter) of the circular indicator. Defaults to 30.0.
  final double size;
  /// The thickness of the indicator's line. Defaults to 3.0.
  final double strokeWidth;
  /// The color of the indicator. Defaults to the theme's primary color.
  final Color? color;
  /// Padding around the entire widget. Defaults to zero.
  final EdgeInsetsGeometry padding;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 30.0,
    this.strokeWidth = 3.0,
    this.color,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (message != null && message!.isNotEmpty) {
      // If message is provided, wrap indicator and text in a Column
      return Padding(
        padding: padding,
        child: Center( // Center the column content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Take minimum space needed
            children: [
              indicator,
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.neutralMedium,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // If no message, just return the indicator with padding
      return Padding(
        padding: padding,
        // Center the indicator if it's the only element
        child: Center(child: indicator),
      );
    }
  }
}
