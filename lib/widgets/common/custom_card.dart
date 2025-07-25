// lib/widgets/common/custom_card.dart

import 'package:flutter/material.dart';

enum CardType { elevated, outlined, filled }
enum CardSize { small, medium, large }

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardType type;
  final CardSize size;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? elevation;
  final bool hasShadow;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.type = CardType.elevated,
    this.size = CardSize.medium,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.elevation,
    this.hasShadow = true,
    this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectivePadding = padding ?? _getDefaultPadding();
    final effectiveMargin = margin ?? _getDefaultMargin();
    final effectiveBorderRadius = borderRadius ?? _getDefaultBorderRadius();
    
    Widget card = Container(
      margin: effectiveMargin,
      decoration: _getDecoration(colorScheme, effectiveBorderRadius),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: Padding(
            padding: effectivePadding,
            child: child,
          ),
        ),
      ),
    );

    if (hasShadow && type == CardType.elevated) {
      card = Container(
        margin: effectiveMargin,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: _getElevationBlur(),
              offset: Offset(0, _getElevationOffset()),
            ),
          ],
        ),
        child: Container(
          decoration: _getDecoration(colorScheme, effectiveBorderRadius),
          child: Material(
            color: Colors.transparent,
            borderRadius: effectiveBorderRadius,
            child: InkWell(
              onTap: onTap,
              borderRadius: effectiveBorderRadius,
              child: Padding(
                padding: effectivePadding,
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    return card;
  }

  BoxDecoration _getDecoration(ColorScheme colorScheme, BorderRadius borderRadius) {
    switch (type) {
      case CardType.elevated:
        return BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: borderRadius,
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
            width: 0.5,
          ),
        );
      case CardType.outlined:
        return BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor ?? colorScheme.outline,
            width: borderWidth ?? 1,
          ),
        );
      case CardType.filled:
        return BoxDecoration(
          color: backgroundColor ?? colorScheme.surfaceVariant,
          borderRadius: borderRadius,
        );
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (size) {
      case CardSize.small:
        return const EdgeInsets.all(12);
      case CardSize.medium:
        return const EdgeInsets.all(16);
      case CardSize.large:
        return const EdgeInsets.all(20);
    }
  }

  EdgeInsetsGeometry _getDefaultMargin() {
    switch (size) {
      case CardSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case CardSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case CardSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  BorderRadius _getDefaultBorderRadius() {
    switch (size) {
      case CardSize.small:
        return BorderRadius.circular(8);
      case CardSize.medium:
        return BorderRadius.circular(12);
      case CardSize.large:
        return BorderRadius.circular(16);
    }
  }

  double _getElevationBlur() {
    switch (size) {
      case CardSize.small:
        return 4;
      case CardSize.medium:
        return 8;
      case CardSize.large:
        return 12;
    }
  }

  double _getElevationOffset() {
    switch (size) {
      case CardSize.small:
        return 2;
      case CardSize.medium:
        return 4;
      case CardSize.large:
        return 6;
    }
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final CardSize size;
  final Color? backgroundColor;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.size = CardSize.medium,
    this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      type: CardType.elevated,
      size: size,
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Row(
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;
  final CardSize size;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.onTap,
    this.size = CardSize.medium});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return CustomCard(
      type: CardType.elevated,
      size: size,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: valueColor ?? colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final CardSize size;

  const ActionCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = CardSize.medium});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return CustomCard(
      type: CardType.elevated,
      size: size,
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor ?? colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.1),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}