// lib/widgets/common/notification_badge.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;
  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = 20,
    this.child,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If count is 0 and child is provided, just return the child without badge
    if (count == 0 && child != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Child widget (usually an icon)
          if (child != null) child!,

          // Badge
          if (count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: padding ?? EdgeInsets.all(size < 20 ? 2 : 4),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Theme.of(context).colorScheme.primary,
                  shape: count > 99 ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: count > 99 ? BorderRadius.circular(size / 2) : null,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1
                  ),
                ),
                constraints: BoxConstraints(
                  minWidth: size,
                  minHeight: size,
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: textColor ?? Theme.of(context).colorScheme.primary,
                      fontSize: size * 0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Static helper method to create a badge with an icon
  static Widget withIcon({
    required int count,
    required IconData icon,
    double iconSize = 24,
    Color? iconColor,
    Color? badgeBackgroundColor,
    Color? badgeTextColor,
    double badgeSize = 20,
    VoidCallback? onTap,
  }) {
    return NotificationBadge(
      count: count,
      backgroundColor: badgeBackgroundColor,
      textColor: badgeTextColor,
      size: badgeSize,
      onTap: onTap,
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}