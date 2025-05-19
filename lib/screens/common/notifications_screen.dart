// lib/screens/common/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../config/theme_config.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../helpers/error_handler.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.fetchNotifications();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
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

  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final success = await notificationProvider.markAllAsRead();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked all notifications as read'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
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

  Future<void> _markAsRead(String notificationId) async {
    try {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.markAsRead(notificationId);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.deleteNotification(notificationId);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;

    return Scaffold(
      appBar: DzAppBar(
        title: 'Notifications',
        actions: [
          if (notificationProvider.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark All as Read',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: LoadingIndicator(),
      )
          : notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];

            return _buildNotificationItem(notification);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: AppColors.mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final id = notification['id'] ?? '';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final isRead = notification['is_read'] == true;
    final type = notification['notification_type'] ?? 'system';

    // Format time
    final createdAt = notification['created_at'] != null
        ? DateTime.parse(notification['created_at'].toString())
        : DateTime.now();
    final timeAgo = timeago.format(createdAt);

    // Determine icon based on type
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'driver_approved':
      case 'bus_approved':
        icon = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case 'driver_rejected':
        icon = Icons.cancel;
        iconColor = AppColors.error;
        break;
      case 'bus_arriving':
        icon = Icons.directions_bus;
        iconColor = AppColors.primary;
        break;
      case 'bus_delayed':
        icon = Icons.access_time;
        iconColor = AppColors.warning;
        break;
      case 'bus_cancelled':
        icon = Icons.cancel;
        iconColor = AppColors.error;
        break;
      default:
        icon = Icons.notifications;
        iconColor = AppColors.primary;
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _markAsRead(id),
            backgroundColor: AppColors.info,
            foregroundColor: AppColors.white,
            icon: Icons.done,
            label: 'Mark Read',
          ),
          SlidableAction(
            onPressed: (context) => _deleteNotification(id),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        elevation: isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isRead
              ? BorderSide.none
              : BorderSide(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          title: Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                message,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mediumGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          // Show unread indicator
          trailing: isRead
              ? null
              : Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          onTap: () {
            // Mark as read when tapped
            if (!isRead) {
              _markAsRead(id);
            }

            // Show full notification
            _showNotificationDetails(notification);
          },
        ),
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final type = notification['notification_type'] ?? 'system';

    // Format time
    final createdAt = notification['created_at'] != null
        ? DateTime.parse(notification['created_at'].toString())
        : DateTime.now();
    final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              'Received: $formattedDate',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mediumGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              'Type: $type',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mediumGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}