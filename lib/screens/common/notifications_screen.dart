// lib/screens/common/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/notification_model.dart';

/// Modern notifications screen with categorized notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationProvider = context.read<NotificationProvider>();
      await notificationProvider.fetchNotifications();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Notifications',
      actions: [
        IconButton(
          icon: const Icon(Icons.mark_email_read),
          onPressed: _markAllAsRead,
          tooltip: 'Mark all as read',
        ),
      ],
      child: Column(
        children: [
          // Tab bar
          AppTabBar(
            controller: _tabController,
            tabs: const [
              AppTab(label: 'All', icon: Icons.notifications),
              AppTab(label: 'Unread', icon: Icons.mark_email_unread),
              AppTab(label: 'Important', icon: Icons.priority_high),
            ],
          ),

          // Tab content
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                if (_isLoading && provider.notifications.isEmpty) {
                  return const LoadingState.fullScreen();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationsList(provider.notifications),
                    _buildNotificationsList(provider.unreadNotifications),
                    _buildNotificationsList(provider.importantNotifications),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const EmptyState(
        title: 'No notifications',
        message: 'You\'re all caught up! No notifications to show.',
        icon: Icons.notifications_none,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DesignSystem.space20),
        color: context.colors.error,
        child: Icon(
          Icons.delete,
          color: context.colors.onError,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: AppCard(
        margin: const EdgeInsets.symmetric(
          horizontal: DesignSystem.space16,
          vertical: DesignSystem.space4,
        ),
        child: ListTile(
          leading: _buildNotificationIcon(notification),
          title: Text(
            notification.title,
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: notification.isRead 
                  ? FontWeight.normal 
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignSystem.space4),
              Text(
                notification.message,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: DesignSystem.space8),
              Row(
                children: [
                  Text(
                    _formatTime(notification.createdAt),
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  if (!notification.isRead) ...[
                    const SizedBox(width: DesignSystem.space8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(
                      notification.isRead
                          ? Icons.mark_email_unread
                          : Icons.mark_email_read,
                    ),
                    const SizedBox(width: DesignSystem.space8),
                    Text(notification.isRead ? 'Mark as unread' : 'Mark as read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: context.colors.error),
                    const SizedBox(width: DesignSystem.space8),
                    Text(
                      'Delete',
                      style: TextStyle(color: context.colors.error),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'mark_read':
                  _toggleReadStatus(notification);
                  break;
                case 'delete':
                  _deleteNotification(notification);
                  break;
              }
            },
          ),
          onTap: () => _onNotificationTap(notification),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(AppNotification notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type.toLowerCase()) {
      case 'bus_arrival':
        iconData = Icons.directions_bus;
        iconColor = context.colors.primary;
        break;
      case 'trip_update':
        iconData = Icons.update;
        iconColor = context.infoColor;
        break;
      case 'payment':
        iconData = Icons.payment;
        iconColor = context.successColor;
        break;
      case 'alert':
        iconData = Icons.warning;
        iconColor = context.warningColor;
        break;
      case 'system':
        iconData = Icons.settings;
        iconColor = context.colors.onSurfaceVariant;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = context.colors.primary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _onNotificationTap(AppNotification notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      _toggleReadStatus(notification);
    }

    // Handle notification action based on type
    switch (notification.type.toLowerCase()) {
      case 'bus_arrival':
        // Navigate to bus tracking
        break;
      case 'trip_update':
        // Navigate to trip details
        break;
      case 'payment':
        // Navigate to payment history
        break;
      default:
        // Show notification details
        _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: DesignSystem.space16),
            Text(
              'Received: ${_formatTime(notification.createdAt)}',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          AppButton.text(
            text: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _toggleReadStatus(AppNotification notification) {
    final provider = context.read<NotificationProvider>();
    if (notification.isRead) {
      provider.markAsUnread(notification.id);
    } else {
      provider.markAsRead(notification.id);
    }
  }

  void _deleteNotification(AppNotification notification) {
    final provider = context.read<NotificationProvider>();
    provider.deleteNotification(notification.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore notification
            provider.restoreNotification(notification);
          },
        ),
      ),
    );
  }

  void _markAllAsRead() {
    final provider = context.read<NotificationProvider>();
    provider.markAllAsRead();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }
}