// lib/widgets/foundation/enhanced_card.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Enhanced card widget with gradient support and glass morphism effects
class EnhancedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? borderColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const EnhancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.gradient,
    this.borderColor,
    this.elevation,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.all(DesignSystem.spacing8),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? DesignSystem.background : null,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : Border.all(color: DesignSystem.surfaceBorder),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(DesignSystem.spacing16),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          child: card,
        ),
      );
    }

    return card;
  }
}