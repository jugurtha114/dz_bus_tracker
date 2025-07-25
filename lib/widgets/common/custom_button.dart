// lib/widgets/common/custom_button.dart

import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, outline, text, icon }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final Color? customColor;
  final Color? color;
  final String? tooltip;

  const CustomButton({
        super.key,
        required this.text,
        this.onPressed,
        this.type = ButtonType.primary,
        this.size = ButtonSize.medium,
        this.icon,
        this.isLoading = false,
        this.isDisabled = false,
        this.fullWidth = false,
        this.customColor,
        this.color,
        this.tooltip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isEffectivelyDisabled = isDisabled || isLoading;

    Widget button = _buildButton(context, theme, colorScheme, isEffectivelyDisabled);

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  Widget _buildButton(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isEffectivelyDisabled) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: _getElevatedButtonStyle(theme, colorScheme),
          child: _buildButtonContent(context, colorScheme.onPrimary),
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: _getSecondaryButtonStyle(theme, colorScheme),
          child: _buildButtonContent(context, colorScheme.onSecondary),
        );
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: _getOutlinedButtonStyle(theme, colorScheme),
          child: _buildButtonContent(context, colorScheme.primary),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: _getTextButtonStyle(theme, colorScheme),
          child: _buildButtonContent(context, colorScheme.primary),
        );
      case ButtonType.icon:
        return IconButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: _getIconButtonStyle(theme, colorScheme),
          icon: isLoading
              ? SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color ?? customColor ?? colorScheme.primary,
                  ),
                )
              : Icon(
                  icon ?? Icons.add,
                  size: _getIconSize(),
                  color: isEffectivelyDisabled
                      ? colorScheme.onSurface.withOpacity(0.38)
                      : color ?? customColor ?? colorScheme.primary,
                ),
          tooltip: tooltip ?? text,
        );
    }
  }

  Widget _buildButtonContent(BuildContext context, Color textColor) {
    if (type == ButtonType.icon) return const SizedBox.shrink();

    final children = <Widget>[];

    if (isLoading) {
      children.add(
        SizedBox(
          width: _getLoadingSize(),
          height: _getLoadingSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: textColor.withOpacity(0.1),
          ),
        ),
      );
      if (text.isNotEmpty) {
        children.add(const SizedBox(width: 8));
      }
    } else if (icon != null) {
      children.add(
        Icon(
          icon,
          size: _getIconSize(),
          color: textColor,
        ),
      );
      if (text.isNotEmpty) {
        children.add(const SizedBox(width: 8));
      }
    }

    if (text.isNotEmpty) {
      children.add(
        Text(
          text,
          style: _getTextStyle(Theme.of(context), textColor),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();
    if (children.length == 1) return children.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getElevatedButtonStyle(ThemeData theme, ColorScheme colorScheme) {
    return ElevatedButton.styleFrom(
      backgroundColor: color ?? customColor ?? colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.1),
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.1),
      elevation: 0,
      shadowColor: (color ?? customColor ?? colorScheme.primary).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      padding: _getPadding(),
      minimumSize: _getMinimumSize(),
      textStyle: _getTextStyle(theme, colorScheme.onPrimary),
    );
  }

  ButtonStyle _getSecondaryButtonStyle(ThemeData theme, ColorScheme colorScheme) {
    return ElevatedButton.styleFrom(
      backgroundColor: color ?? customColor ?? colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.1),
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.1),
      elevation: 0,
      shadowColor: (color ?? customColor ?? colorScheme.secondary).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      padding: _getPadding(),
      minimumSize: _getMinimumSize(),
      textStyle: _getTextStyle(theme, colorScheme.onSecondary),
    );
  }

  ButtonStyle _getOutlinedButtonStyle(ThemeData theme, ColorScheme colorScheme) {
    return OutlinedButton.styleFrom(
      foregroundColor: color ?? customColor ?? colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.1),
      side: BorderSide(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      padding: _getPadding(),
      minimumSize: _getMinimumSize(),
      textStyle: _getTextStyle(theme, color ?? customColor ?? colorScheme.primary),
    );
  }

  ButtonStyle _getTextButtonStyle(ThemeData theme, ColorScheme colorScheme) {
    return TextButton.styleFrom(
      foregroundColor: color ?? customColor ?? colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      padding: _getPadding(),
      minimumSize: _getMinimumSize(),
      textStyle: _getTextStyle(theme, color ?? customColor ?? colorScheme.primary),
    );
  }

  ButtonStyle _getIconButtonStyle(ThemeData theme, ColorScheme colorScheme) {
    return IconButton.styleFrom(
      foregroundColor: color ?? customColor ?? colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.1),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      padding: _getIconPadding(),
      minimumSize: _getIconMinimumSize(),
    );
  }

  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return 8;
      case ButtonSize.medium:
        return 12;
      case ButtonSize.large:
        return 16;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  EdgeInsetsGeometry _getIconPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.all(8);
      case ButtonSize.medium:
        return const EdgeInsets.all(12);
      case ButtonSize.large:
        return const EdgeInsets.all(16);
    }
  }

  Size _getMinimumSize() {
    switch (size) {
      case ButtonSize.small:
        return const Size(64, 32);
      case ButtonSize.medium:
        return const Size(80, 40);
      case ButtonSize.large:
        return const Size(96, 48);
    }
  }

  Size _getIconMinimumSize() {
    switch (size) {
      case ButtonSize.small:
        return const Size(32, 32);
      case ButtonSize.medium:
        return const Size(40, 40);
      case ButtonSize.large:
        return const Size(48, 48);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 22;
    }
  }

  TextStyle _getTextStyle(ThemeData theme, Color color) {
    final baseStyle = theme.textTheme.labelLarge?.copyWith(color: color) ?? 
        TextStyle(color: color);

    switch (size) {
      case ButtonSize.small:
        return baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500);
      case ButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }
}