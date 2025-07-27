// lib/widgets/layout/section_layout.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Section layout for organizing content within pages
/// Provides consistent spacing and structure for content sections
class SectionLayout extends StatelessWidget {
  const SectionLayout({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.margin,
    this.actions,
    this.showDivider = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Widget>? actions;
  final bool showDivider;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || actions != null) _buildHeader(context),
        if (showDivider) const Divider(),
        child,
      ],
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }

  Widget _buildHeader(BuildContext context) {
    if (title == null && actions == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space16),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: context.textStyles.headlineSmall,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: DesignSystem.space4),
                    Text(
                      subtitle!,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (actions != null) ...[
            const SizedBox(width: DesignSystem.space16),
            Row(children: actions!),
          ],
        ],
      ),
    );
  }
}

/// Card section with elevated background
class CardSection extends StatelessWidget {
  const CardSection({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.margin,
    this.actions,
    this.onTap,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Widget>? actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(DesignSystem.space8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        child: SectionLayout(
          title: title,
          subtitle: subtitle,
          actions: actions,
          padding: padding ?? const EdgeInsets.all(DesignSystem.space16),
          child: child,
        ),
      ),
    );
  }
}

/// List section for displaying lists with consistent styling
class ListSection extends StatelessWidget {
  const ListSection({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.padding,
    this.margin,
    this.actions,
    this.separator,
    this.shrinkWrap = true,
    this.physics,
  });

  final String? title;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Widget>? actions;
  final Widget? separator;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    Widget listContent;

    if (separator != null) {
      final separatedChildren = <Widget>[];
      for (int i = 0; i < children.length; i++) {
        separatedChildren.add(children[i]);
        if (i < children.length - 1) {
          separatedChildren.add(separator!);
        }
      }
      listContent = Column(children: separatedChildren);
    } else {
      listContent = Column(children: children);
    }

    if (!shrinkWrap) {
      listContent = Expanded(child: SingleChildScrollView(
        physics: physics,
        child: listContent,
      ));
    }

    return SectionLayout(
      title: title,
      subtitle: subtitle,
      actions: actions,
      padding: padding,
      margin: margin,
      child: listContent,
    );
  }
}

/// Grid section for displaying items in a grid
class GridSection extends StatelessWidget {
  const GridSection({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.padding,
    this.margin,
    this.actions,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = DesignSystem.space8,
    this.mainAxisSpacing = DesignSystem.space8,
    this.shrinkWrap = true,
    this.physics,
  });

  final String? title;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Widget>? actions;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    Widget gridContent = GridView.count(
      shrinkWrap: shrinkWrap,
      physics: physics,
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      children: children,
    );

    return SectionLayout(
      title: title,
      subtitle: subtitle,
      actions: actions,
      padding: padding,
      margin: margin,
      child: gridContent,
    );
  }
}

/// Stats section for displaying key metrics
class StatsSection extends StatelessWidget {
  const StatsSection({
    super.key,
    this.title,
    this.subtitle,
    required this.stats,
    this.padding,
    this.margin,
    this.actions,
    this.crossAxisCount = 2,
  });

  final String? title;
  final String? subtitle;
  final List<StatItem> stats;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Widget>? actions;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final statWidgets = stats
        .map((stat) => _buildStatCard(context, stat))
        .toList();

    return GridSection(
      title: title,
      subtitle: subtitle,
      actions: actions,
      padding: padding,
      margin: margin,
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1.2,
      children: statWidgets,
    );
  }

  Widget _buildStatCard(BuildContext context, StatItem stat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (stat.icon != null) ...[
              Icon(
                stat.icon,
                size: DesignSystem.iconLarge,
                color: stat.color ?? context.colors.primary,
              ),
              const SizedBox(height: DesignSystem.space8),
            ],
            Text(
              stat.value,
              style: context.textStyles.headlineMedium?.copyWith(
                color: stat.color ?? context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.space4),
            Text(
              stat.label,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (stat.subtitle != null) ...[
              const SizedBox(height: DesignSystem.space4),
              Text(
                stat.subtitle!,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Action section for buttons and actions
class ActionSection extends StatelessWidget {
  const ActionSection({
    super.key,
    this.title,
    this.subtitle,
    required this.actions,
    this.padding,
    this.margin,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.direction = Axis.horizontal,
    this.spacing = DesignSystem.space8,
  });

  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Axis direction;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    Widget actionContent;

    if (direction == Axis.horizontal) {
      actionContent = Wrap(
        spacing: spacing,
        children: actions,
      );
    } else {
      final children = <Widget>[];
      for (int i = 0; i < actions.length; i++) {
        children.add(actions[i]);
        if (i < actions.length - 1) {
          children.add(SizedBox(height: spacing));
        }
      }
      actionContent = Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }

    return SectionLayout(
      title: title,
      subtitle: subtitle,
      padding: padding,
      margin: margin,
      child: actionContent,
    );
  }
}

/// Data class for stats
class StatItem {
  const StatItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.color,
  });

  final String value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
}