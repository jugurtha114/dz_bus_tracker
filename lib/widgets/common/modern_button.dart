// lib/widgets/common/modern_button.dart

import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Modern Button System
/// Professional, accessible buttons following Material 3 design principles
enum ModernButtonVariant {
  filled,      // Primary action button
  outlined,    // Secondary action button  
  text,        // Tertiary action button
  tonal,       // Medium emphasis button
  ghost,       // Minimal emphasis button
}

enum ModernButtonSize {
  small,       // 32px height
  medium,      // 48px height  
  large,       // 56px height
}

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonVariant variant;
  final ModernButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = ModernButtonVariant.filled,
    this.size = ModernButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationFast,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildButton(context, theme, isDark),
          ),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme, bool isDark) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: _isEnabled ? (_) => _handleTapDown() : null,
        onTapUp: _isEnabled ? (_) => _handleTapUp() : null,
        onTapCancel: _isEnabled ? _handleTapCancel : null,
        child: AnimatedContainer(
          duration: AppTheme.animationFast,
          width: widget.width,
          height: _getHeight(),
          padding: widget.padding ??_getPadding(),
          decoration: _getDecoration(theme, isDark),
          child: _buildContent(theme, isDark),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    final color = _getForegroundColor(theme, isDark);
    
    return Row(
      mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null && !widget.isLoading) ...[
          Icon(
            widget.leadingIcon,
            size: _getIconSize(),
            color: color,
          ),
          SizedBox(width: AppTheme.spacing8),
        ],
        
        if (widget.isLoading) ...[
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(width: AppTheme.spacing8),
        ],
        
        Flexible(
          child: Text(
            widget.text,
            style: _getTextStyle(theme, isDark),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        if (widget.trailingIcon != null && !widget.isLoading) ...[
          SizedBox(width: AppTheme.spacing8),
          Icon(
            widget.trailingIcon,
            size: _getIconSize(),
            color: color,
          ),
        ],
      ],
    );
  }

  BoxDecoration _getDecoration(ThemeData theme, bool isDark) {
    Color backgroundColor;
    Color? borderColor;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case ModernButtonVariant.filled:
        backgroundColor = _isEnabled 
          ? (widget.backgroundColor ?? AppTheme.primary)
          : AppTheme.neutral300;
        shadows = _isEnabled && !_isPressed ? AppTheme.modernShadow(elevation: AppTheme.elevation2) : null;
        break;
        
      case ModernButtonVariant.outlined:
        backgroundColor = _isHovered && _isEnabled 
          ? (widget.backgroundColor ?? AppTheme.primary).withValues(alpha: 0.08)
          : Colors.transparent;
        borderColor = _isEnabled 
          ? (widget.backgroundColor ?? AppTheme.primary)
          : AppTheme.neutral300;
        break;
        
      case ModernButtonVariant.text:
        backgroundColor = _isHovered && _isEnabled 
          ? (widget.backgroundColor ?? AppTheme.primary).withValues(alpha: 0.08)
          : Colors.transparent;
        break;
        
      case ModernButtonVariant.tonal:
        backgroundColor = _isEnabled 
          ? (widget.backgroundColor ?? AppTheme.primaryContainer)
          : AppTheme.neutral200;
        break;
        
      case ModernButtonVariant.ghost:
        backgroundColor = _isHovered && _isEnabled 
          ? AppTheme.neutral100
          : Colors.transparent;
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      border: borderColor != null 
        ? Border.all(color: borderColor, width: 1.5)
        : null,
      boxShadow: shadows,
    );
  }

  Color _getForegroundColor(ThemeData theme, bool isDark) {
    if (!_isEnabled) {
      return AppTheme.neutral500;
    }

    if (widget.foregroundColor != null) {
      return widget.foregroundColor!;
    }

    switch (widget.variant) {
      case ModernButtonVariant.filled:
        return AppTheme.onPrimary;
      case ModernButtonVariant.outlined:
      case ModernButtonVariant.text:
      case ModernButtonVariant.ghost:
        return widget.backgroundColor ?? AppTheme.primary;
      case ModernButtonVariant.tonal:
        return AppTheme.onPrimaryContainer;
    }
  }

  TextStyle _getTextStyle(ThemeData theme, bool isDark) {
    final fontSize = _getFontSize();
    final fontWeight = FontWeight.w600;
    final color = _getForegroundColor(theme, isDark);

    return TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.1,
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 32;
      case ModernButtonSize.medium:
        return 48;
      case ModernButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing6,
        );
      case ModernButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: AppTheme.spacing24,
          vertical: AppTheme.spacing12,
        );
      case ModernButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: AppTheme.spacing32,
          vertical: AppTheme.spacing16,
        );
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return AppTheme.radiusLg;
      case ModernButtonSize.medium:
        return AppTheme.radiusXl;
      case ModernButtonSize.large:
        return AppTheme.radius2xl;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 14;
      case ModernButtonSize.medium:
        return 16;
      case ModernButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 16;
      case ModernButtonSize.medium:
        return 20;
      case ModernButtonSize.large:
        return 24;
    }
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
  }
}

// === SPECIALIZED BUTTON COMPONENTS ===

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final ModernButtonSize size;
  final double? width;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.size = ModernButtonSize.medium,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernButton(
      text: text,
      onPressed: onPressed,
      variant: ModernButtonVariant.filled,
      size: size,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
      width: width,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final ModernButtonSize size;
  final double? width;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.size = ModernButtonSize.medium,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernButton(
      text: text,
      onPressed: onPressed,
      variant: ModernButtonVariant.outlined,
      size: size,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
      width: width,
    );
  }
}

class TertiaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final ModernButtonSize size;

  const TertiaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.size = ModernButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernButton(
      text: text,
      onPressed: onPressed,
      variant: ModernButtonVariant.text,
      size: size,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
    );
  }
}

class IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ModernButtonVariant variant;
  final ModernButtonSize size;
  final String? tooltip;
  final Color? color;

  const IconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.variant = ModernButtonVariant.ghost,
    this.size = ModernButtonSize.medium,
    this.tooltip,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = ModernButton(
      text: '',
      onPressed: onPressed,
      variant: variant,
      size: size,
      leadingIcon: icon,
      backgroundColor: color,
      padding: EdgeInsets.all(_getPadding()),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  double _getPadding() {
    switch (size) {
      case ModernButtonSize.small:
        return AppTheme.spacing8;
      case ModernButtonSize.medium:
        return AppTheme.spacing12;
      case ModernButtonSize.large:
        return AppTheme.spacing16;
    }
  }
}

// === FLOATING ACTION BUTTON ===

class ModernFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ModernFAB({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  State<ModernFAB> createState() => _ModernFABState();
}

class _ModernFABState extends State<ModernFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationFast,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget fab = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) {
              _animationController.reverse();
              widget.onPressed?.call();
            },
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              height: widget.isExtended ? 56 : 56,
              padding: widget.isExtended 
                ? EdgeInsets.symmetric(horizontal: AppTheme.spacing24, vertical: AppTheme.spacing16)
                : EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                boxShadow: AppTheme.modernShadow(elevation: AppTheme.elevation6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.foregroundColor ?? AppTheme.onPrimary,
                    size: 24,
                  ),
                  if (widget.isExtended && widget.label != null) ...[
                    SizedBox(width: AppTheme.spacing8),
                    Text(
                      widget.label!,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.foregroundColor ?? AppTheme.onPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      fab = Tooltip(
        message: widget.tooltip!,
        child: fab,
      );
    }

    return fab;
  }
}