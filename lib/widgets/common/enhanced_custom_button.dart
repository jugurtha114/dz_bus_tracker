// lib/widgets/common/enhanced_custom_button.dart

import 'package:flutter/material.dart';

/// Enhanced button types with more options
enum EnhancedButtonType { 
  primary, 
  secondary, 
  outline, 
  text, 
  icon, 
  success, 
  warning, 
  error,
  gradient
}

/// Button size enumeration
enum EnhancedButtonSize { small, medium, large, extraLarge }

/// Enhanced custom button with comprehensive functionality
class EnhancedCustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final EnhancedButtonType type;
  final EnhancedButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final Color? customColor;
  final Color? textColor;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final List<Color>? gradientColors;
  final Widget? child;
  final double? elevation;
  final Duration animationDuration;

  const EnhancedCustomButton({
    Key? key,
    this.text,
    this.onPressed,
    this.type = EnhancedButtonType.primary,
    this.size = EnhancedButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.customColor,
    this.textColor,
    this.tooltip,
    this.padding,
    this.borderRadius,
    this.gradientColors,
    this.child,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : assert(text != null || child != null, 'Either text or child must be provided'),
       super(key: key);

  /// Named constructors for common button types
  const EnhancedCustomButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    EnhancedButtonSize size = EnhancedButtonSize.medium,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         type: EnhancedButtonType.primary,
         icon: icon,
         isLoading: isLoading,
         fullWidth: fullWidth,
         size: size,
       );

  const EnhancedCustomButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    EnhancedButtonSize size = EnhancedButtonSize.medium,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         type: EnhancedButtonType.secondary,
         icon: icon,
         isLoading: isLoading,
         fullWidth: fullWidth,
         size: size,
       );

  const EnhancedCustomButton.outline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    EnhancedButtonSize size = EnhancedButtonSize.medium,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         type: EnhancedButtonType.outline,
         icon: icon,
         isLoading: isLoading,
         fullWidth: fullWidth,
         size: size,
       );

  const EnhancedCustomButton.success({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    EnhancedButtonSize size = EnhancedButtonSize.medium,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         type: EnhancedButtonType.success,
         icon: icon,
         isLoading: isLoading,
         fullWidth: fullWidth,
         size: size,
       );

  const EnhancedCustomButton.error({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    EnhancedButtonSize size = EnhancedButtonSize.medium,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         type: EnhancedButtonType.error,
         icon: icon,
         isLoading: isLoading,
         fullWidth: fullWidth,
         size: size,
       );

  const EnhancedCustomButton.icon({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    String? tooltip,
    EnhancedButtonSize size = EnhancedButtonSize.medium,
  }) : this(
         key: key,
         icon: icon,
         onPressed: onPressed,
         type: EnhancedButtonType.icon,
         isLoading: isLoading,
         tooltip: tooltip,
         size: size,
       );

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

    return AnimatedContainer(
      duration: animationDuration,
      child: button,
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isEffectivelyDisabled) {
    final buttonStyle = _getButtonStyle(theme, colorScheme);
    final buttonChild = _getButtonChild(context);

    switch (type) {
      case EnhancedButtonType.primary:
      case EnhancedButtonType.success:
      case EnhancedButtonType.warning:
      case EnhancedButtonType.error:
      case EnhancedButtonType.gradient:
        return ElevatedButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case EnhancedButtonType.secondary:
      case EnhancedButtonType.outline:
        return OutlinedButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case EnhancedButtonType.text:
        return TextButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case EnhancedButtonType.icon:
        return IconButton(
          onPressed: isEffectivelyDisabled ? null : onPressed,
          icon: isLoading 
            ? SizedBox(
                width: _getIconSize(),
                height: _getIconSize(),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: _getIconSize()),
          style: buttonStyle,
        );
    }
  }

  Widget _getButtonChild(BuildContext context) {
    if (child != null) return child!;

    final List<Widget> children = [];

    // Add leading icon
    if (icon != null && !isLoading) {
      children.add(Icon(icon, size: _getIconSize()));
      if (text != null) children.add(SizedBox(width: 8));
    }

    // Add loading indicator
    if (isLoading) {
      children.add(SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ));
      if (text != null) children.add(SizedBox(width: 8));
    }

    // Add text
    if (text != null) {
      children.add(Text(
        text!,
        style: _getTextStyle(context),
        textAlign: TextAlign.center,
      ));
    }

    // Add trailing icon
    if (trailingIcon != null && !isLoading) {
      if (text != null || icon != null) children.add(SizedBox(width: 8));
      children.add(Icon(trailingIcon, size: _getIconSize()));
    }

    if (children.length == 1) {
      return children.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme, ColorScheme colorScheme) {
    final effectivePadding = padding ?? _getDefaultPadding();
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(8);
    final effectiveElevation = elevation ?? _getDefaultElevation();

    Color? backgroundColor;
    Color? foregroundColor;
    Color? overlayColor;
    BorderSide? borderSide;

    switch (type) {
      case EnhancedButtonType.primary:
        backgroundColor = customColor ?? colorScheme.primary;
        foregroundColor = textColor ?? colorScheme.onPrimary;
        break;
      case EnhancedButtonType.secondary:
        backgroundColor = customColor ?? colorScheme.secondary;
        foregroundColor = textColor ?? colorScheme.onSecondary;
        break;
      case EnhancedButtonType.success:
        backgroundColor = customColor ?? Colors.green;
        foregroundColor = textColor ?? Colors.white;
        break;
      case EnhancedButtonType.warning:
        backgroundColor = customColor ?? Colors.orange;
        foregroundColor = textColor ?? Colors.white;
        break;
      case EnhancedButtonType.error:
        backgroundColor = customColor ?? colorScheme.error;
        foregroundColor = textColor ?? colorScheme.onError;
        break;
      case EnhancedButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = textColor ?? (customColor ?? colorScheme.primary);
        borderSide = BorderSide(color: customColor ?? colorScheme.primary);
        break;
      case EnhancedButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = textColor ?? (customColor ?? colorScheme.primary);
        break;
      case EnhancedButtonType.icon:
        backgroundColor = customColor;
        foregroundColor = textColor ?? colorScheme.onSurface;
        break;
      case EnhancedButtonType.gradient:
        // Gradient will be handled in a Container wrapper
        backgroundColor = Colors.transparent;
        foregroundColor = textColor ?? Colors.white;
        break;
    }

    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return colorScheme.onSurface.withOpacity(0.12);
        }
        return backgroundColor;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return colorScheme.onSurface.withOpacity(0.38);
        }
        return foregroundColor;
      }),
      overlayColor: MaterialStateProperty.all(overlayColor),
      side: borderSide != null ? MaterialStateProperty.all(borderSide) : null,
      padding: MaterialStateProperty.all(effectivePadding),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      ),
      elevation: MaterialStateProperty.all(effectiveElevation),
    );
  }

  TextStyle? _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (size) {
      case EnhancedButtonSize.small:
        return theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor,
        );
      case EnhancedButtonSize.medium:
        return theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor,
        );
      case EnhancedButtonSize.large:
        return theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        );
      case EnhancedButtonSize.extraLarge:
        return theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        );
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (size) {
      case EnhancedButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case EnhancedButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case EnhancedButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      case EnhancedButtonSize.extraLarge:
        return EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
  }

  double _getIconSize() {
    switch (size) {
      case EnhancedButtonSize.small:
        return 16;
      case EnhancedButtonSize.medium:
        return 18;
      case EnhancedButtonSize.large:
        return 20;
      case EnhancedButtonSize.extraLarge:
        return 24;
    }
  }

  double _getDefaultElevation() {
    switch (type) {
      case EnhancedButtonType.primary:
      case EnhancedButtonType.success:
      case EnhancedButtonType.warning:
      case EnhancedButtonType.error:
      case EnhancedButtonType.gradient:
        return 2;
      case EnhancedButtonType.secondary:
        return 1;
      default:
        return 0;
    }
  }
}