// lib/widgets/common/bottom_nav.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import 'notification_badge.dart';

class DzBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<DzBottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final double? iconSize;
  final double? height;
  final bool showLabels;
  final bool showIndicator;
  final bool useGlassEffect;

  const DzBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.iconSize = 24,
    this.height = 60,
    this.showLabels = true,
    this.showIndicator = true,
    this.useGlassEffect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final effectiveSelectedItemColor = selectedItemColor ?? Theme.of(context).colorScheme.primary;
    final effectiveUnselectedItemColor = unselectedItemColor ?? Theme.of(context).colorScheme.primary;

    // For glass effect
    if (useGlassEffect) {
      return Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: effectiveBackgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                items.length,
                    (index) => _buildGlassNavItem(
                  context: context,
                  item: items[index],
                  index: index,
                  isSelected: currentIndex == index,
                  selectedColor: effectiveSelectedItemColor,
                  unselectedColor: effectiveUnselectedItemColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Regular bottom nav
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: _buildNavIcon(
            context,
            icon: item.icon,
            badgeCount: item.badgeCount,
            isSelected: currentIndex == items.indexOf(item),
          ),
          label: item.label,
        );
      }).toList(),
      backgroundColor: effectiveBackgroundColor,
      selectedItemColor: effectiveSelectedItemColor,
      unselectedItemColor: effectiveUnselectedItemColor,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: showLabels,
      showUnselectedLabels: showLabels,
      elevation: elevation,
      iconSize: iconSize!,
    );
  }

  Widget _buildNavIcon(
    BuildContext context, {
    required IconData icon,
    int badgeCount = 0,
    bool isSelected = false,
  }) {
    if (badgeCount > 0) {
      return NotificationBadge(
        count: badgeCount,
        size: 16,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(icon),
      );
    }

    return Icon(icon);
  }

  Widget _buildGlassNavItem({
    required BuildContext context,
    required DzBottomNavItem item,
    required int index,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicator
            if (showIndicator && isSelected)
              Container(
                width: 24,
        
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              )
            else
              const SizedBox(height: 16),

            const SizedBox(height: 16),

            // Icon with badge
            _buildNavIcon(
              context,
              icon: item.icon,
              badgeCount: item.badgeCount,
              isSelected: isSelected,
            ),

            // Label
            if (showLabels)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? selectedColor : unselectedColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DzBottomNavItem {
  final String label;
  final IconData icon;
  final int badgeCount;

  const DzBottomNavItem({
    required this.label,
    required this.icon,
    this.badgeCount = 0});
}