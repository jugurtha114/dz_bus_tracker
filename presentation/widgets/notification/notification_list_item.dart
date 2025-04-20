/// lib/presentation/widgets/notification/notification_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../../config/themes/app_theme.dart';
import '../../../core/utils/date_utils.dart'; // Using DateUtil for relative time
import '../../../domain/entities/notification_entity.dart';

/// Widget to display a single notification item in a list.
class NotificationListItem extends StatelessWidget {
  final NotificationEntity notification;
  /// Callback when the item is tapped.
  final VoidCallback? onTap;
  /// Callback when the "Mark Read/Unread" action is triggered (if implemented).
  final ValueChanged<String>? onToggleReadStatus; // Optional action

  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onToggleReadStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool isRead = notification.isRead;
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryTextColor = AppTheme.neutralMedium;
    final Color readColor = secondaryTextColor.withOpacity(0.7);

    // Determine icon based on type or default
    // TODO: Enhance icon based on notification payload type if available
    IconData leadingIconData = isRead
        ? Icons.notifications_none_outlined
        : Icons.notifications_active; // Or Icons.mark_email_unread_outlined

    return Opacity( // Fade out read notifications slightly
      opacity: isRead ? 0.75 : 1.0,
      child: ListTile(
        leading: CircleAvatar(
           backgroundColor: (isRead ? Colors.grey : primaryColor).withOpacity(0.15),
           foregroundColor: isRead ? readColor : primaryColor,
           child: Icon(leadingIconData, size: 24),
        ),
        title: Text(
          notification.title ?? 'Notification', // TODO: Localize 'Notification'
          style: textTheme.titleMedium?.copyWith(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold, // Bold for unread
            color: isRead ? readColor : theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             if (notification.body != null && notification.body!.isNotEmpty)
               Text(
                 notification.body!,
                 style: textTheme.bodyMedium?.copyWith(
                   color: isRead ? readColor : secondaryTextColor,
                 ),
                 maxLines: 2, // Show more lines for body
                 overflow: TextOverflow.ellipsis,
               ),
             if (notification.body != null && notification.body!.isNotEmpty)
                const SizedBox(height: AppTheme.spacingXSmall / 2),
              Text(
                DateUtil.timeAgoOrUntil(notification.receivedAt.toLocal()), // Show relative time
                style: textTheme.bodySmall?.copyWith(
                  color: isRead ? readColor.withOpacity(0.8) : secondaryTextColor.withOpacity(0.8),
                ),
              ),
           ],
        ),
        trailing: onToggleReadStatus != null ? // Optional trailing action
            IconButton(
               icon: Icon(
                  isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                  color: isRead ? AppTheme.successColor : AppTheme.accentColor,
               ),
               tooltip: isRead ? 'Mark as Unread' : 'Mark as Read', // TODO: Localize
               iconSize: 22,
               onPressed: () => onToggleReadStatus!(notification.id),
            )
            : null, // No trailing icon if no action provided
        onTap: onTap, // Allow tapping whole tile
        contentPadding: const EdgeInsets.symmetric(
           horizontal: AppTheme.spacingMedium,
           vertical: AppTheme.spacingSmall, // Adjust vertical padding
        ),
        // tileColor: isRead ? theme.colorScheme.surface.withOpacity(0.5) : null, // Optional subtle background for read items
        dense: false, // Use default density
      ),
    );
  }
}

