// lib/widgets/common/enhanced_card.dart

import 'package:flutter/material.dart';

/// Enhanced card types
enum EnhancedCardType {
  elevated,
  outlined,
  filled,
  glass,
  gradient
}

/// Enhanced custom card with comprehensive functionality
class EnhancedCard extends StatelessWidget {
  final Widget child;
  final EnhancedCardType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final double? elevation;
  final bool isClickable;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Color>? gradientColors;
  final Gradient? gradient;
  final List<BoxShadow>? customShadows;
  final Border? border;
  final Clip clipBehavior;

  const EnhancedCard({
    Key? key,
    required this.child,
    this.type = EnhancedCardType.elevated,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.borderRadius = 12.0,
    this.elevation,
    this.isClickable = false,
    this.onTap,
    this.onLongPress,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.gradientColors,
    this.gradient,
    this.customShadows,
    this.border,
    this.clipBehavior = Clip.antiAlias,
  }) : super(key: key);

  /// Named constructors for common card types
  const EnhancedCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? color,
    double borderRadius = 12.0,
    double? elevation,
    VoidCallback? onTap,
  }) : this(
         key: key,
         child: child,
         type: EnhancedCardType.elevated,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         color: color,
         borderRadius: borderRadius,
         elevation: elevation,
         onTap: onTap,
         isClickable: onTap != null,
       );

  const EnhancedCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? color,
    Color? borderColor,
    double borderRadius = 12.0,
    VoidCallback? onTap,
  }) : this(
         key: key,
         child: child,
         type: EnhancedCardType.outlined,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         color: color,
         borderColor: borderColor,
         borderRadius: borderRadius,
         onTap: onTap,
         isClickable: onTap != null,
       );

  const EnhancedCard.filled({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? color,
    double borderRadius = 12.0,
    VoidCallback? onTap,
  }) : this(
         key: key,
         child: child,
         type: EnhancedCardType.filled,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         color: color,
         borderRadius: borderRadius,
         onTap: onTap,
         isClickable: onTap != null,
       );

  const EnhancedCard.glass({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    double borderRadius = 12.0,
    VoidCallback? onTap,
  }) : this(
         key: key,
         child: child,
         type: EnhancedCardType.glass,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         borderRadius: borderRadius,
         onTap: onTap,
         isClickable: onTap != null,
       );

  /// Card with header (title, subtitle, leading, trailing)
  const EnhancedCard.withHeader({
    Key? key,
    required Widget child,
    String? title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    EnhancedCardType type = EnhancedCardType.elevated,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? color,
    double borderRadius = 12.0,
    VoidCallback? onTap,
  }) : this(
         key: key,
         child: child,
         type: type,
         title: title,
         subtitle: subtitle,
         leading: leading,
         trailing: trailing,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         color: color,
         borderRadius: borderRadius,
         onTap: onTap,
         isClickable: onTap != null,
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveMargin = margin ?? EdgeInsets.zero;
    final effectivePadding = padding ?? EdgeInsets.all(16);

    Widget cardContent = _buildCardContent(context);

    // Add header if title is provided
    if (title != null || leading != null || trailing != null) {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (title != null || subtitle != null) SizedBox(height: 16),
          cardContent,
        ],
      );
    }

    Widget card = Container(
      width: width,
      height: height,
      margin: effectiveMargin,
      decoration: _buildDecoration(theme, colorScheme),
      clipBehavior: clipBehavior,
      child: Padding(
        padding: effectivePadding,
        child: cardContent,
      ),
    );

    // Make card clickable if needed
    if (isClickable || onTap != null || onLongPress != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildCardContent(BuildContext context) {
    return child;
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
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
          SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }

  BoxDecoration _buildDecoration(ThemeData theme, ColorScheme colorScheme) {
    Color? backgroundColor;
    Border? effectiveBorder;
    List<BoxShadow>? shadows;
    Gradient? effectiveGradient;

    switch (type) {
      case EnhancedCardType.elevated:
        backgroundColor = color ?? colorScheme.surface;
        shadows = customShadows ?? [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: elevation ?? 8,
            offset: Offset(0, elevation ?? 4),
          ),
        ];
        break;

      case EnhancedCardType.outlined:
        backgroundColor = color ?? Colors.transparent;
        effectiveBorder = border ?? Border.all(
          color: borderColor ?? colorScheme.outline.withOpacity(0.2),
          width: 1,
        );
        break;

      case EnhancedCardType.filled:
        backgroundColor = color ?? colorScheme.surfaceVariant;
        break;

      case EnhancedCardType.glass:
        backgroundColor = (color ?? colorScheme.surface).withOpacity(0.1);
        effectiveBorder = Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        );
        shadows = [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ];
        break;

      case EnhancedCardType.gradient:
        effectiveGradient = gradient ?? LinearGradient(
          colors: gradientColors ?? [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        shadows = customShadows ?? [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ];
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      gradient: effectiveGradient,
      border: effectiveBorder,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows,
    );
  }
}

/// Specialized card for list items
class EnhancedListCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final EnhancedCardType type;
  final Color? color;

  const EnhancedListCard({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.type = EnhancedCardType.outlined,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EnhancedCard(
      type: type,
      color: color,
      padding: padding ?? EdgeInsets.all(16),
      margin: margin ?? EdgeInsets.symmetric(vertical: 4),
      onTap: onTap,
      onLongPress: onLongPress,
      isClickable: onTap != null || onLongPress != null,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4),
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
            SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}