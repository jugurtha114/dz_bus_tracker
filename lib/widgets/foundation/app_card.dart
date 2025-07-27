// lib/widgets/foundation/app_card.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Modern, optimized card component following Material You design
/// Replaces all legacy card components with a single, consistent implementation
class AppCard extends StatelessWidget {
  /// Standard card with subtle elevation
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.color,
    this.borderRadius,
  }) : variant = AppCardVariant.elevated;

  /// Filled card with background color
  const AppCard.filled({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.color,
    this.borderRadius,
  }) : variant = AppCardVariant.filled;

  /// Outlined card with border
  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.color,
    this.borderRadius,
  }) : variant = AppCardVariant.outlined;

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final AppCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? _getDefaultColor(context);
    final cardElevation = elevation ?? _getDefaultElevation();
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(DesignSystem.radiusMedium);
    final cardPadding = padding ?? const EdgeInsets.all(DesignSystem.space16);
    final cardMargin = margin ?? EdgeInsets.zero;

    Widget cardChild = Padding(
      padding: cardPadding,
      child: child,
    );

    Widget card = switch (variant) {
      AppCardVariant.elevated => Card(
        color: cardColor,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: cardChild,
      ),
      AppCardVariant.filled => Card.filled(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: cardChild,
      ),
      AppCardVariant.outlined => Card.outlined(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: cardChild,
      ),
    };

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: card,
      );
    }

    if (cardMargin != EdgeInsets.zero) {
      card = Padding(
        padding: cardMargin,
        child: card,
      );
    }

    return card;
  }

  Color _getDefaultColor(BuildContext context) {
    return switch (variant) {
      AppCardVariant.elevated => context.colors.surface,
      AppCardVariant.filled => context.colors.surfaceContainerHighest,
      AppCardVariant.outlined => context.colors.surface,
    };
  }

  double _getDefaultElevation() {
    return switch (variant) {
      AppCardVariant.elevated => DesignSystem.elevation1,
      AppCardVariant.filled => DesignSystem.elevation0,
      AppCardVariant.outlined => DesignSystem.elevation0,
    };
  }
}

/// Information card with icon, title, and content
class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    this.icon,
    this.title,
    required this.content,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
  });

  final IconData? icon;
  final String? title;
  final String content;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(DesignSystem.space8),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
              ),
              child: Icon(
                icon,
                color: context.colors.onPrimaryContainer,
                size: DesignSystem.iconMedium,
              ),
            ),
            const SizedBox(width: DesignSystem.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: context.textStyles.titleMedium?.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                Text(
                  content,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: DesignSystem.space12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Status card with colored indicator
class AppStatusCard extends StatelessWidget {
  const AppStatusCard({
    super.key,
    required this.status,
    required this.title,
    required this.content,
    this.subtitle,
    this.onTap,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
  });

  final AppStatus status;
  final String title;
  final String content;
  final String? subtitle;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);
    
    return AppCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: DesignSystem.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.textStyles.titleMedium?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                Text(
                  content,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.space8,
              vertical: DesignSystem.space4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            ),
            child: Text(
              _getStatusText(),
              style: context.textStyles.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    return switch (status) {
      AppStatus.success => context.successColor,
      AppStatus.warning => context.warningColor,
      AppStatus.error => context.errorColor,
      AppStatus.info => context.infoColor,
      AppStatus.active => DesignSystem.busActive,
      AppStatus.inactive => DesignSystem.busInactive,
    };
  }

  String _getStatusText() {
    return switch (status) {
      AppStatus.success => 'Success',
      AppStatus.warning => 'Warning',
      AppStatus.error => 'Error',
      AppStatus.info => 'Info',
      AppStatus.active => 'Active',
      AppStatus.inactive => 'Inactive',
    };
  }
}

/// Card variants following Material You design
enum AppCardVariant {
  elevated,
  filled,
  outlined,
}

/// Status types for status cards
enum AppStatus {
  success,
  warning,
  error,
  info,
  active,
  inactive,
}