// lib/widgets/foundation/modern_card.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Modern card widget with various styles and animations
class ModernCard extends StatelessWidget {
  final Widget child;
  final ModernCardType type;
  final ModernCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showShadow;
  final double borderRadius;

  const ModernCard({
    super.key,
    required this.child,
    this.type = ModernCardType.standard,
    this.variant = ModernCardVariant.surface,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.showShadow = true,
    this.borderRadius = DesignSystem.radiusLarge,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(DesignSystem.space16),
      decoration: _getDecoration(context),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }

  BoxDecoration _getDecoration(BuildContext context) {
    switch (type) {
      case ModernCardType.standard:
        return _getStandardDecoration(context);
      case ModernCardType.glass:
        return _getGlassDecoration(context);
      case ModernCardType.gradient:
        return _getGradientDecoration(context);
      case ModernCardType.elevated:
        return _getElevatedDecoration(context);
    }
  }

  BoxDecoration _getStandardDecoration(BuildContext context) {
    return BoxDecoration(
      color: _getBackgroundColor(context),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: DesignSystem.outline,
        width: 1,
      ),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  BoxDecoration _getGlassDecoration(BuildContext context) {
    return BoxDecoration(
      color: DesignSystem.surface.withOpacity(0.8),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
    );
  }

  BoxDecoration _getGradientDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: _getGradient(context),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: _getVariantColor(context).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
    );
  }

  BoxDecoration _getElevatedDecoration(BuildContext context) {
    return BoxDecoration(
      color: _getBackgroundColor(context),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case ModernCardVariant.surface:
        return DesignSystem.surface;
      case ModernCardVariant.primary:
        return DesignSystem.primaryContainer;
      case ModernCardVariant.secondary:
        return DesignSystem.secondaryContainer;
      case ModernCardVariant.tertiary:
        return DesignSystem.tertiaryContainer;
      case ModernCardVariant.error:
        return DesignSystem.errorContainer;
      case ModernCardVariant.success:
        return DesignSystem.successContainer;
      case ModernCardVariant.warning:
        return DesignSystem.warningContainer;
      case ModernCardVariant.info:
        return DesignSystem.infoContainer;
    }
  }

  Color _getVariantColor(BuildContext context) {
    switch (variant) {
      case ModernCardVariant.surface:
        return DesignSystem.onSurface;
      case ModernCardVariant.primary:
        return DesignSystem.primary;
      case ModernCardVariant.secondary:
        return DesignSystem.secondary;
      case ModernCardVariant.tertiary:
        return DesignSystem.tertiary;
      case ModernCardVariant.error:
        return DesignSystem.error;
      case ModernCardVariant.success:
        return DesignSystem.success;
      case ModernCardVariant.warning:
        return DesignSystem.warning;
      case ModernCardVariant.info:
        return DesignSystem.info;
    }
  }

  LinearGradient? _getGradient(BuildContext context) {
    final color = _getVariantColor(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color,
        color.withOpacity(0.8),
      ],
      stops: const [0.0, 1.0],
    );
  }
}

/// Card types for different visual styles
enum ModernCardType {
  standard,  // Default card with border and subtle shadow
  glass,     // Glass morphism effect
  gradient,  // Gradient background
  elevated,  // Enhanced shadow for emphasis
}

/// Card variants for different semantic colors
enum ModernCardVariant {
  surface,
  primary,
  secondary,
  tertiary,
  error,
  success,
  warning,
  info,
}