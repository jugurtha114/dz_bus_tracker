/// lib/presentation/widgets/common/themed_button.dart

import 'package:flutter/material.dart';
import '../../../config/themes/app_theme.dart'; // For default styling

/// Defines the visual style variants for the [ThemedButton].
enum ThemedButtonVariant { primary, secondary, text }

/// A reusable button widget with predefined themes and loading state integration.
class ThemedButton extends StatelessWidget {
  /// Callback executed when the button is pressed. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// The text label displayed on the button.
  final String text;

  /// Optional icon displayed before the text label.
  final IconData? icon;

  /// If true, shows a loading indicator instead of the label/icon and disables the button.
  final bool isLoading;

  /// If true, the button attempts to expand to the full available width.
  final bool isFullWidth;

  /// The visual style variant of the button. Defaults to [ThemedButtonVariant.primary].
  final ThemedButtonVariant variant;

  /// Optional custom [ButtonStyle] to override or merge with the default variant style.
  final ButtonStyle? style;

  /// Optional explicit height for the button.
  final double? height;

  const ThemedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.variant = ThemedButtonVariant.primary,
    this.style,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveOnPressed = isLoading ? null : onPressed; // Disable interactions when loading

    // Determine the child widget based on loading state and icon presence
    Widget child = isLoading
        ? SizedBox(
            width: 20, // Consistent size for indicator
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(theme, colorScheme, variant, effectiveOnPressed == null),
              ),
            ),
          )
        : (icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min, // Prevent row from expanding unnecessarily
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18), // Adjust icon size as needed
                  const SizedBox(width: AppTheme.spacingSmall),
                  Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
                ],
              )
            : Text(text));

    // Determine base style based on variant
    ButtonStyle baseStyle;
    switch (variant) {
      case ThemedButtonVariant.secondary:
        baseStyle = OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingMedium,
            horizontal: AppTheme.spacingLarge,
          ),
          textStyle: theme.textTheme.labelLarge,
        );
        break;
      case ThemedButtonVariant.text:
        baseStyle = TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall)),
           padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingSmall, // Less padding for text buttons
            horizontal: AppTheme.spacingMedium,
          ),
           textStyle: theme.textTheme.labelLarge,
        );
        break;
      case ThemedButtonVariant.primary:
      default:
        baseStyle = ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingMedium,
            horizontal: AppTheme.spacingLarge,
          ),
          textStyle: theme.textTheme.labelLarge,
          elevation: AppTheme.elevationSmall,
        );
        break;
    }

    // Merge base style with provided custom style
    final ButtonStyle effectiveStyle = style != null ? baseStyle.merge(style) : baseStyle;

     // Apply minimum size constraint for height if provided
    final Size? minimumSize = height != null ? Size(isFullWidth ? double.infinity : 0, height!) : null;
    final finalStyle = effectiveStyle.copyWith(minimumSize: MaterialStateProperty.all(minimumSize));


    // Build the specific button type
    Widget button;
    switch (variant) {
      case ThemedButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: finalStyle,
          child: child,
        );
        break;
      case ThemedButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: finalStyle,
          child: child,
        );
        break;
      case ThemedButtonVariant.primary:
      default:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: finalStyle,
          child: child,
        );
        break;
    }

    // Apply full width if requested
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    } else {
      return button;
    }
  }

   /// Helper to determine the appropriate foreground color for the loading indicator.
   Color _getForegroundColor(ThemeData theme, ColorScheme colorScheme, ThemedButtonVariant variant, bool isDisabled) {
     if (isDisabled) {
         return colorScheme.onSurface.withOpacity(0.38);
     }
     switch(variant) {
        case ThemedButtonVariant.primary:
           return colorScheme.onPrimary;
        case ThemedButtonVariant.secondary:
        case ThemedButtonVariant.text:
            return colorScheme.primary;
        default:
           return colorScheme.primary;
     }
   }
}
