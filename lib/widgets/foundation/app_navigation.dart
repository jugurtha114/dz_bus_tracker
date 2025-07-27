// lib/widgets/foundation/app_navigation.dart

import 'package:flutter/material.dart';
import '../../config/design_system.dart';

/// Modern navigation components following Material You design
/// Replaces all legacy navigation components with optimized implementations

/// Bottom navigation bar for main app navigation
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations
          .map((dest) => NavigationDestination(
                icon: Icon(dest.icon),
                selectedIcon: dest.selectedIcon != null 
                    ? Icon(dest.selectedIcon)
                    : Icon(dest.icon),
                label: dest.label,
              ))
          .toList(),
    );
  }
}

/// Navigation rail for larger screens
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = false,
    this.leading,
    this.trailing,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavigationDestination> destinations;
  final bool extended;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      leading: leading,
      trailing: trailing,
      destinations: destinations
          .map((dest) => NavigationRailDestination(
                icon: Icon(dest.icon),
                selectedIcon: dest.selectedIcon != null 
                    ? Icon(dest.selectedIcon)
                    : Icon(dest.icon),
                label: Text(dest.label),
              ))
          .toList(),
    );
  }
}

/// Navigation drawer for extensive navigation options
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({
    super.key,
    required this.destinations,
    this.currentIndex,
    this.onDestinationSelected,
    this.header,
    this.footer,
  });

  final List<AppNavigationDestination> destinations;
  final int? currentIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      children: [
        if (header != null) header!,
        ...destinations.map((dest) {
          
          return NavigationDrawerDestination(
            icon: Icon(dest.icon),
            selectedIcon: dest.selectedIcon != null 
                ? Icon(dest.selectedIcon)
                : Icon(dest.icon),
            label: Text(dest.label),
          );
        }),
        if (footer != null) ...[
          const Divider(),
          footer!,
        ],
      ],
    );
  }
}

/// Tab bar for section navigation
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
  });

  final List<AppTab> tabs;
  final TabController? controller;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabs: tabs
          .map((tab) => Tab(
                icon: tab.icon != null ? Icon(tab.icon) : null,
                text: tab.label,
              ))
          .toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Segmented button for toggle navigation
class AppSegmentedButton<T> extends StatelessWidget {
  const AppSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.showSelectedIcon = true,
  });

  final List<AppButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool showSelectedIcon;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments
          .map((segment) => ButtonSegment<T>(
                value: segment.value,
                label: Text(segment.label),
                icon: segment.icon != null ? Icon(segment.icon) : null,
              ))
          .toList(),
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      showSelectedIcon: showSelectedIcon,
    );
  }
}

/// Breadcrumb navigation for hierarchical navigation
class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({
    super.key,
    required this.items,
    this.divider,
    this.maxItems,
  });

  final List<AppBreadcrumbItem> items;
  final Widget? divider;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final displayItems = maxItems != null && items.length > maxItems!
        ? [
            ...items.take(1),
            AppBreadcrumbItem(
              label: '...',
              onTap: null,
            ),
            ...items.skip(items.length - maxItems! + 2),
          ]
        : items;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: displayItems.asMap().entries.expand((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == displayItems.length - 1;

          return [
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.space8,
                  vertical: DesignSystem.space4,
                ),
                child: Text(
                  item.label,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: isLast 
                        ? context.colors.onSurface
                        : context.colors.primary,
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.space4,
                ),
                child: divider ?? Icon(
                  Icons.chevron_right,
                  color: context.colors.onSurfaceVariant,
                  size: DesignSystem.iconSmall,
                ),
              ),
          ];
        }).toList(),
      ),
    );
  }
}

/// Data classes for navigation components

class AppNavigationDestination {
  const AppNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Widget? badge;
}

class AppTab {
  const AppTab({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;
}

class AppButtonSegment<T> {
  const AppButtonSegment({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class AppBreadcrumbItem {
  const AppBreadcrumbItem({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;
}