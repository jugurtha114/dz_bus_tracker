// lib/widgets/foundation/app_button.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Modern, optimized button component following Material You design
/// Replaces all legacy button components with a single, consistent implementation
class AppButton extends StatelessWidget {
  /// Primary filled button (default)
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.filled;

  /// Outlined button
  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.outlined;

  /// Text button
  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.text;

  /// Tonal button
  const AppButton.tonal({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.isEnabled = true,
  }) : variant = AppButtonVariant.tonal;

  /// Icon-only button
  const AppButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.isEnabled = true,
  }) : text = '',
       variant = AppButtonVariant.text;

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final double? width;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isInteractive = isEnabled && !isLoading && onPressed != null;
    
    Widget child = _buildContent();
    
    if (isLoading) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getContentColor(context),
            ),
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(width: DesignSystem.space8),
            Text(text),
          ],
        ],
      );
    }

    Widget button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: isInteractive ? onPressed : null,
        style: _getFilledStyle(context),
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: isInteractive ? onPressed : null,
        style: _getOutlinedStyle(context),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isInteractive ? onPressed : null,
        style: _getTextButtonStyle(context),
        child: child,
      ),
      AppButtonVariant.tonal => FilledButton.tonal(
        onPressed: isInteractive ? onPressed : null,
        style: _getTonalStyle(context),
        child: child,
      ),
    };

    if (width != null) {
      button = SizedBox(width: width, child: button);
    }

    return button;
  }

  Widget _buildContent() {
    if (icon != null && text.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: DesignSystem.space8),
          Text(text),
        ],
      );
    } else if (icon != null) {
      return Icon(icon, size: _getIconSize());
    } else {
      return Text(text);
    }
  }

  ButtonStyle _getFilledStyle(BuildContext context) {
    return FilledButton.styleFrom(
      minimumSize: Size(_getMinWidth(), _getHeight()),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      textStyle: _getButtonTextStyle(),
    );
  }

  ButtonStyle _getOutlinedStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      minimumSize: Size(_getMinWidth(), _getHeight()),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      side: BorderSide(
        color: context.colors.outline,
        width: 1,
      ),
      textStyle: _getButtonTextStyle(),
    );
  }

  ButtonStyle _getTextButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: Size(_getMinWidth(), _getHeight()),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
      ),
      textStyle: _getButtonTextStyle(),
    );
  }

  ButtonStyle _getTonalStyle(BuildContext context) {
    return FilledButton.styleFrom(
      minimumSize: Size(_getMinWidth(), _getHeight()),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      backgroundColor: context.colors.secondaryContainer,
      foregroundColor: context.colors.onSecondaryContainer,
      textStyle: _getButtonTextStyle(),
    );
  }

  TextStyle _getButtonTextStyle() {
    return switch (size) {
      AppButtonSize.small => DesignSystem.labelMedium,
      AppButtonSize.medium => DesignSystem.labelLarge,
      AppButtonSize.large => DesignSystem.labelLarge,
    };
  }

  Color _getContentColor(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.filled => context.colors.onPrimary,
      AppButtonVariant.outlined => context.colors.primary,
      AppButtonVariant.text => context.colors.primary,
      AppButtonVariant.tonal => context.colors.onSecondaryContainer,
    };
  }

  double _getHeight() {
    return switch (size) {
      AppButtonSize.small => DesignSystem.buttonHeightSmall,
      AppButtonSize.medium => DesignSystem.buttonHeightMedium,
      AppButtonSize.large => DesignSystem.buttonHeightLarge,
    };
  }

  double _getMinWidth() {
    return switch (size) {
      AppButtonSize.small => 64,
      AppButtonSize.medium => 64,
      AppButtonSize.large => 64,
    };
  }

  double _getIconSize() {
    return switch (size) {
      AppButtonSize.small => DesignSystem.iconSmall,
      AppButtonSize.medium => DesignSystem.iconMedium,
      AppButtonSize.large => DesignSystem.iconMedium,
    };
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: DesignSystem.space24),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: DesignSystem.space32),
    };
  }
}

/// Button variants following Material You design
enum AppButtonVariant {
  filled,
  outlined,
  text,
  tonal,
}

/// Button sizes for different use cases
enum AppButtonSize {
  small,
  medium,
  large,
}