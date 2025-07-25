// lib/widgets/notifications/notification_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../common/glassy_container.dart';

/// Display modes for notification cards
enum NotificationDisplayMode {
  compact,   // Minimal info, single line
  standard,  // Default card with full info
  detailed,  // Extended card with all details
  list,      // Optimized for list views
}

/// Comprehensive notification card component
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final NotificationDisplayMode displayMode;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool showTimeAgo;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const NotificationCard({
    super.key,
    required this.notification,
    this.displayMode = NotificationDisplayMode.standard,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.showActions = true,
    this.showTimeAgo = true,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (displayMode) {
      case NotificationDisplayMode.compact:
        return _buildCompactCard(context);
      case NotificationDisplayMode.detailed:
        return _buildDetailedCard(context);
      case NotificationDisplayMode.list:
        return _buildListCard(context);
      default:
        return _buildStandardCard(context);
    }
  }

  /// Build compact notification card
  Widget _buildCompactCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassyContainer(
        padding: padding ?? const EdgeInsets.all(12),
        child: InkWell(
          onTap: () {
            _handleMarkAsRead(context);
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: notification.typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification.typeIcon,
                  color: notification.typeColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: notification.isUnread ? FontWeight.w600 : FontWeight.w500,
                        color: notification.isUnread ? theme.colorScheme.onSurface : 
                               theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showTimeAgo)
                      Text(
                        notification.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Unread indicator
              if (notification.isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build standard notification card
  Widget _buildStandardCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassyContainer(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notification.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notification.typeIcon,
                    color: notification.typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: notification.isUnread ? FontWeight.w600 : FontWeight.w500,
                          color: notification.isUnread ? theme.colorScheme.onSurface : 
                                 theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.typeDisplayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: notification.typeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Time and status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showTimeAgo)
                      Text(
                        notification.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Channel icon
                        Icon(
                          notification.channelIcon,
                          size: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        // Unread indicator
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            // Message
            const SizedBox(height: 12),
            Text(
              notification.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Actions
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (notification.isUnread)
                    TextButton.icon(
                      onPressed: () => _handleMarkAsRead(context),
                      icon: const Icon(Icons.mark_email_read, size: 16),
                      label: const Text('Mark as Read'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        textStyle: theme.textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _handleDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      textStyle: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build detailed notification card
  Widget _buildDetailedCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassyContainer(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with priority badge
            Row(
              children: [
                // Type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.typeIcon,
                    color: notification.typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Title and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: notification.isUnread ? FontWeight.w600 : FontWeight.w500,
                                color: notification.isUnread ? theme.colorScheme.onSurface : 
                                       theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Priority badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: notification.priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: notification.priorityColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              notification.priority,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: notification.priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            notification.typeDisplayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: notification.typeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            notification.channelIcon,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.channelDisplayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Message
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Text(
                notification.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),
            
            // Metadata
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timestamps
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created: ${notification.formattedDateTime}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    if (notification.isRead && notification.readAt != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.mark_email_read,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Read: ${notification.readAt!.day}/${notification.readAt!.month}/${notification.readAt!.year}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: notification.isUnread 
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        notification.isUnread ? Icons.circle : Icons.check_circle,
                        size: 12,
                        color: notification.isUnread 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification.isUnread ? 'Unread' : 'Read',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: notification.isUnread 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Actions
            if (showActions) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Secondary actions
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                  
                  // Primary actions
                  Row(
                    children: [
                      if (notification.isUnread)
                        FilledButton.icon(
                          onPressed: () => _handleMarkAsRead(context),
                          icon: const Icon(Icons.mark_email_read, size: 16),
                          label: const Text('Mark as Read'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _handleDelete(context),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build list-optimized notification card
  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: notification.typeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          notification.typeIcon,
          color: notification.typeColor,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: notification.isUnread ? FontWeight.w600 : FontWeight.w500,
          color: notification.isUnread ? theme.colorScheme.onSurface : 
                 theme.colorScheme.onSurface.withOpacity(0.8),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                notification.typeDisplayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: notification.typeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showTimeAgo) ...[
                const SizedBox(width: 8),
                Text(
                  '• ${notification.timeAgo}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Unread indicator
          if (notification.isUnread) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Channel icon
          Icon(
            notification.channelIcon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
      onTap: () {
        _handleMarkAsRead(context);
        onTap?.call();
      },
    );
  }

  /// Handle mark as read action
  void _handleMarkAsRead(BuildContext context) {
    if (notification.isUnread) {
      final provider = context.read<NotificationProvider>();
      provider.markAsRead(notification.id);
      onMarkAsRead?.call();
    }
  }

  /// Handle delete action
  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = context.read<NotificationProvider>();
              provider.deleteNotification(notification.id);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for notification priority badge
class NotificationPriorityBadge extends StatelessWidget {
  final AppNotification notification;

  const NotificationPriorityBadge({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: notification.priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        notification.priority,
        style: theme.textTheme.labelSmall?.copyWith(
          color: notification.priorityColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Helper widget for notification type chip
class NotificationTypeChip extends StatelessWidget {
  final AppNotification notification;

  const NotificationTypeChip({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Chip(
      avatar: Icon(
        notification.typeIcon,
        size: 16,
        color: notification.typeColor,
      ),
      label: Text(
        notification.typeDisplayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: notification.typeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: notification.typeColor.withOpacity(0.1),
      side: BorderSide(
        color: notification.typeColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }
}