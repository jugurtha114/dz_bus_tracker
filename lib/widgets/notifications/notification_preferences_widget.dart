// lib/widgets/notifications/notification_preferences_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../common/glassy_container.dart';
import '../common/loading_indicator.dart';

/// Comprehensive notification preferences management widget
class NotificationPreferencesWidget extends StatefulWidget {
  final bool showHeader;
  final EdgeInsets? padding;
  final Function(NotificationType, bool)? onPreferenceChanged;

  const NotificationPreferencesWidget({
    super.key,
    this.showHeader = true,
    this.padding,
    this.onPreferenceChanged,
  });

  @override
  State<NotificationPreferencesWidget> createState() => _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState extends State<NotificationPreferencesWidget> {
  final Map<NotificationType, bool> _pendingChanges = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notificationPreferences.isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        return SingleChildScrollView(
          padding: widget.padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              if (widget.showHeader) _buildHeader(context),
              
              // Global notification toggle
              _buildGlobalToggle(context, provider),
              
              const SizedBox(height: 24),
              
              // Notification type preferences
              _buildNotificationTypePreferences(context, provider),
              
              const SizedBox(height: 24),
              
              // Device tokens section
              _buildDeviceTokensSection(context, provider),
              
              const SizedBox(height: 24),
              
              // Advanced settings
              _buildAdvancedSettings(context, provider),
            ],
          ),
        );
      },
    );
  }

  /// Build header section
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Preferences',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customize how and when you receive notifications',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Build global notification toggle
  Widget _buildGlobalToggle(BuildContext context, NotificationProvider provider) {
    final theme = Theme.of(context);
    
    return GlassyContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: provider.permissionGranted 
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              provider.permissionGranted ? Icons.notifications_active : Icons.notifications_off,
              color: provider.permissionGranted 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.permissionGranted 
                      ? 'Notifications are enabled'
                      : 'Notifications are disabled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: provider.permissionGranted 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          if (!provider.permissionGranted)
            TextButton(
              onPressed: () => provider.initialize(),
              child: const Text('Enable'),
            ),
        ],
      ),
    );
  }

  /// Build notification type preferences
  Widget _buildNotificationTypePreferences(BuildContext context, NotificationProvider provider) {
    final theme = Theme.of(context);
    
    // Group notification types by category
    final transportTypes = NotificationType.values.where((t) => t.isTransport).toList();
    final adminTypes = NotificationType.values.where((t) => t.isAdmin).toList();
    final gamificationTypes = NotificationType.values.where((t) => t.isGamification).toList();
    final tripTypes = NotificationType.values.where((t) => t.isTrip).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Types',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Transport notifications
        if (transportTypes.isNotEmpty) ...[
          _buildCategorySection(
            context,
            provider,
            'Transport & Arrivals',
            Icons.directions_bus,
            theme.colorScheme.primary,
            transportTypes,
          ),
          const SizedBox(height: 16),
        ],
        
        // Trip notifications
        if (tripTypes.isNotEmpty) ...[
          _buildCategorySection(
            context,
            provider,
            'Trip Updates',
            Icons.route,
            Colors.blue,
            tripTypes,
          ),
          const SizedBox(height: 16),
        ],
        
        // Admin notifications
        if (adminTypes.isNotEmpty) ...[
          _buildCategorySection(
            context,
            provider,
            'Admin & System',
            Icons.admin_panel_settings,
            Colors.orange,
            adminTypes,
          ),
          const SizedBox(height: 16),
        ],
        
        // Gamification notifications
        if (gamificationTypes.isNotEmpty) ...[
          _buildCategorySection(
            context,
            provider,
            'Rewards & Achievements',
            Icons.emoji_events,
            Colors.amber,
            gamificationTypes,
          ),
        ],
      ],
    );
  }

  /// Build category section for notification types
  Widget _buildCategorySection(
    BuildContext context,
    NotificationProvider provider,
    String title,
    IconData icon,
    Color color,
    List<NotificationType> types,
  ) {
    final theme = Theme.of(context);
    
    return GlassyContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Notification type toggles
          ...types.map((type) => _buildNotificationTypeToggle(context, provider, type)),
        ],
      ),
    );
  }

  /// Build individual notification type toggle
  Widget _buildNotificationTypeToggle(
    BuildContext context,
    NotificationProvider provider,
    NotificationType type,
  ) {
    final theme = Theme.of(context);
    final preference = provider.getPreferenceForType(type);
    final isEnabled = _pendingChanges[type] ?? (preference?.enabled ?? true);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Type icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              type.icon,
              color: type.color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          // Type info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (preference != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Channels
                      ...preference.channels.take(3).map((channel) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          channel.icon,
                          size: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      )),
                      if (preference.channels.length > 3)
                        Text(
                          '+${preference.channels.length - 3}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Toggle switch
          Switch(
            value: isEnabled,
            onChanged: provider.permissionGranted ? (value) {
              setState(() {
                _pendingChanges[type] = value;
              });
              
              provider.updateNotificationPreference(
                type: type,
                enabled: value,
              );
              
              widget.onPreferenceChanged?.call(type, value);
            } : null,
          ),
        ],
      ),
    );
  }

  /// Build device tokens section
  Widget _buildDeviceTokensSection(BuildContext context, NotificationProvider provider) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registered Devices',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        GlassyContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Current device
              if (provider.currentDeviceToken != null) ...[
                _buildDeviceTokenItem(context, provider, provider.currentDeviceToken!, true),
                const SizedBox(height: 12),
              ],
              
              // Other devices
              ...provider.deviceTokens
                  .where((token) => token.id != provider.currentDeviceToken?.id)
                  .map((token) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _buildDeviceTokenItem(context, provider, token, false),
                      )),
              
              // No devices message
              if (provider.deviceTokens.isEmpty)
                Column(
                  children: [
                    Icon(
                      Icons.smartphone,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No devices registered',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build device token item
  Widget _buildDeviceTokenItem(BuildContext context, NotificationProvider provider, DeviceToken token, bool isCurrent) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Device icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: token.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getDeviceIcon(token.deviceType),
            color: token.statusColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        
        // Device info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    token.deviceType.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Current',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Last used: ${token.formattedLastUsed} • ${token.statusText}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        
        // Actions
        if (!isCurrent && token.isActive)
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'deactivate':
                  provider.deactivateDeviceToken(token.id);
                  break;
                case 'delete':
                  _showDeleteTokenDialog(context, provider, token);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'deactivate',
                child: ListTile(
                  leading: Icon(Icons.pause),
                  title: Text('Deactivate'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  dense: true,
                ),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
      ],
    );
  }

  /// Build advanced settings section
  Widget _buildAdvancedSettings(BuildContext context, NotificationProvider provider) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        GlassyContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Mark all as read
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text('Mark All as Read'),
                subtitle: Text(
                  'Mark all ${provider.totalUnreadCount} unread notifications as read',
                ),
                trailing: provider.totalUnreadCount > 0
                    ? TextButton(
                        onPressed: () => _showMarkAllAsReadDialog(context, provider),
                        child: const Text('Mark All'),
                      )
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
              
              const Divider(),
              
              // Clear all notifications
              ListTile(
                leading: Icon(Icons.delete_sweep, color: theme.colorScheme.error),
                title: Text(
                  'Clear All Notifications',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text(
                  'Permanently delete all notifications',
                ),
                trailing: provider.notifications.isNotEmpty
                    ? TextButton(
                        onPressed: () => _showClearAllDialog(context, provider),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Clear All'),
                      )
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get device icon based on device type
  IconData _getDeviceIcon(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.ios:
        return Icons.phone_iphone;
      case DeviceType.android:
        return Icons.phone_android;
      case DeviceType.web:
        return Icons.computer;
    }
  }

  /// Show delete token confirmation dialog
  void _showDeleteTokenDialog(BuildContext context, NotificationProvider provider, DeviceToken token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to remove ${token.deviceType.displayName} from receiving notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.deleteDeviceToken(token.id);
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

  /// Show mark all as read confirmation dialog
  void _showMarkAllAsReadDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: Text('Mark all ${provider.totalUnreadCount} unread notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.markAllAsRead();
            },
            child: const Text('Mark All'),
          ),
        ],
      ),
    );
  }

  /// Show clear all notifications confirmation dialog
  void _showClearAllDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to permanently delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Note: This would require a batch delete method in the provider
              // For now, we'll show a message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bulk delete feature coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}