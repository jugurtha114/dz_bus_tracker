// lib/widgets/notifications/notification_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../common/empty_state_widget.dart' as empty_state;
import '../common/loading_indicator.dart';
import '../common/error_widget.dart';
import 'notification_card.dart';

/// Layout types for notification list
enum NotificationListLayout {
  standard,  // Standard card layout
  compact,   // Compact card layout
  list,      // List tile layout
}

/// Filter types for notifications
enum NotificationFilter {
  all,
  unread,
  read,
  recent,
  transport,
  admin,
  gamification,
}

/// Comprehensive notification list widget
class NotificationList extends StatefulWidget {
  final NotificationListLayout layout;
  final NotificationFilter filter;
  final bool showFilterChips;
  final bool showSearch;
  final bool enablePullToRefresh;
  final bool enableInfiniteScroll;
  final VoidCallback? onNotificationTap;
  final Function(AppNotification)? onNotificationSelected;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;

  const NotificationList({
    super.key,
    this.layout = NotificationListLayout.standard,
    this.filter = NotificationFilter.all,
    this.showFilterChips = true,
    this.showSearch = false,
    this.enablePullToRefresh = true,
    this.enableInfiniteScroll = true,
    this.onNotificationTap,
    this.onNotificationSelected,
    this.padding,
    this.header,
    this.footer,
  });

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  NotificationFilter _currentFilter = NotificationFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    
    // Setup infinite scroll
    if (widget.enableInfiniteScroll) {
      _scrollController.addListener(_onScroll);
    }
    
    // Setup search
    if (widget.showSearch) {
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<NotificationProvider>();
      if (provider.hasMorePages && !provider.isLoading) {
        provider.loadMoreNotifications();
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        if (provider.error != null && provider.notifications.isEmpty) {
          return Center(
            child: ErrorDisplayWidget(
              message: provider.error!,
              actionText: 'Retry',
              onAction: () => provider.loadNotifications(),
            ),
          );
        }

        final filteredNotifications = _filterNotifications(provider.notifications);

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Header
            if (widget.header != null) widget.header!,
            
            // Search bar
            if (widget.showSearch) _buildSearchBar(),
            
            // Filter chips
            if (widget.showFilterChips) _buildFilterChips(),
            
            // Notification list
            Expanded(
              child: widget.enablePullToRefresh
                  ? RefreshIndicator(
                      onRefresh: () => provider.refreshData(),
                      child: _buildNotificationList(filteredNotifications, provider),
                    )
                  : _buildNotificationList(filteredNotifications, provider),
            ),
            
            // Footer
            if (widget.footer != null) widget.footer!,
          ],
        );
      },
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: NotificationFilter.values.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = filter;
                });
              },
              avatar: Icon(
                _getFilterIcon(filter),
                size: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build notification list
  Widget _buildNotificationList(
    List<AppNotification> notifications,
    NotificationProvider provider,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length + (provider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index >= notifications.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: LoadingIndicator()),
          );
        }

        final notification = notifications[index];
        
        return NotificationCard(
          notification: notification,
          displayMode: _getDisplayMode(),
          onTap: () {
            widget.onNotificationTap?.call();
            widget.onNotificationSelected?.call(notification);
          },
          onMarkAsRead: () {
            // Optional callback when notification is marked as read
          },
          onDelete: () {
            // Optional callback when notification is deleted
          },
        );
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return empty_state.EmptyStateWidget(
      icon: _getEmptyStateIcon(),
      title: _getEmptyStateTitle(),
      message: _getEmptyStateSubtitle(),
      buttonText: 'Refresh',
      onButtonPressed: () {
        final provider = context.read<NotificationProvider>();
        provider.refreshData();
      },
    );
  }

  /// Filter notifications based on current filter and search query
  List<AppNotification> _filterNotifications(List<AppNotification> notifications) {
    var filtered = notifications;

    // Apply filter
    switch (_currentFilter) {
      case NotificationFilter.unread:
        filtered = filtered.where((n) => n.isUnread).toList();
        break;
      case NotificationFilter.read:
        filtered = filtered.where((n) => n.isRead).toList();
        break;
      case NotificationFilter.recent:
        filtered = filtered.where((n) => n.isRecent).toList();
        break;
      case NotificationFilter.transport:
        filtered = filtered.where((n) => n.notificationType.isTransport).toList();
        break;
      case NotificationFilter.admin:
        filtered = filtered.where((n) => n.notificationType.isAdmin).toList();
        break;
      case NotificationFilter.gamification:
        filtered = filtered.where((n) => n.notificationType.isGamification).toList();
        break;
      case NotificationFilter.all:
      default:
        // No filtering
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((notification) {
        return notification.title.toLowerCase().contains(query) ||
               notification.message.toLowerCase().contains(query) ||
               notification.typeDisplayName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  /// Get display mode for notification cards
  NotificationDisplayMode _getDisplayMode() {
    switch (widget.layout) {
      case NotificationListLayout.compact:
        return NotificationDisplayMode.compact;
      case NotificationListLayout.list:
        return NotificationDisplayMode.list;
      default:
        return NotificationDisplayMode.standard;
    }
  }

  /// Get filter label
  String _getFilterLabel(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.unread:
        return 'Unread';
      case NotificationFilter.read:
        return 'Read';
      case NotificationFilter.recent:
        return 'Recent';
      case NotificationFilter.transport:
        return 'Transport';
      case NotificationFilter.admin:
        return 'Admin';
      case NotificationFilter.gamification:
        return 'Rewards';
    }
  }

  /// Get filter icon
  IconData _getFilterIcon(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return Icons.all_inbox;
      case NotificationFilter.unread:
        return Icons.circle;
      case NotificationFilter.read:
        return Icons.check_circle;
      case NotificationFilter.recent:
        return Icons.access_time;
      case NotificationFilter.transport:
        return Icons.directions_bus;
      case NotificationFilter.admin:
        return Icons.admin_panel_settings;
      case NotificationFilter.gamification:
        return Icons.emoji_events;
    }
  }

  /// Get empty state icon
  IconData _getEmptyStateIcon() {
    switch (_currentFilter) {
      case NotificationFilter.unread:
        return Icons.mark_email_read;
      case NotificationFilter.transport:
        return Icons.directions_bus;
      case NotificationFilter.admin:
        return Icons.admin_panel_settings;
      case NotificationFilter.gamification:
        return Icons.emoji_events;
      default:
        return Icons.notifications_none;
    }
  }

  /// Get empty state title
  String _getEmptyStateTitle() {
    if (_searchQuery.isNotEmpty) {
      return 'No Results Found';
    }
    
    switch (_currentFilter) {
      case NotificationFilter.unread:
        return 'No Unread Notifications';
      case NotificationFilter.read:
        return 'No Read Notifications';
      case NotificationFilter.recent:
        return 'No Recent Notifications';
      case NotificationFilter.transport:
        return 'No Transport Notifications';
      case NotificationFilter.admin:
        return 'No Admin Notifications';
      case NotificationFilter.gamification:
        return 'No Reward Notifications';
      default:
        return 'No Notifications';
    }
  }

  /// Get empty state subtitle
  String _getEmptyStateSubtitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Try adjusting your search terms or filters.';
    }
    
    switch (_currentFilter) {
      case NotificationFilter.unread:
        return 'All your notifications have been read.';
      case NotificationFilter.recent:
        return 'No notifications in the last 24 hours.';
      case NotificationFilter.transport:
        return 'No bus or transport updates available.';
      case NotificationFilter.admin:
        return 'No admin notifications at this time.';
      case NotificationFilter.gamification:
        return 'Complete actions to earn rewards!';
      default:
        return 'You\'ll see notifications here when they arrive.';
    }
  }
}

/// Simple notification counter widget
class NotificationCounter extends StatelessWidget {
  final NotificationFilter filter;
  final TextStyle? textStyle;

  const NotificationCounter({
    super.key,
    this.filter = NotificationFilter.unread,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        int count;
        
        switch (filter) {
          case NotificationFilter.unread:
            count = provider.totalUnreadCount;
            break;
          case NotificationFilter.all:
            count = provider.notifications.length;
            break;
          case NotificationFilter.recent:
            count = provider.recentNotifications.length;
            break;
          case NotificationFilter.transport:
            count = provider.notifications
                .where((n) => n.notificationType.isTransport)
                .length;
            break;
          case NotificationFilter.admin:
            count = provider.notifications
                .where((n) => n.notificationType.isAdmin)
                .length;
            break;
          case NotificationFilter.gamification:
            count = provider.notifications
                .where((n) => n.notificationType.isGamification)
                .length;
            break;
          default:
            count = provider.notifications.length;
        }

        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Text(
          count > 99 ? '99+' : count.toString(),
          style: textStyle ?? Theme.of(context).textTheme.labelSmall,
        );
      },
    );
  }
}

/// Notification badge widget for app bars
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final NotificationFilter filter;

  const NotificationBadge({
    super.key,
    required this.child,
    this.filter = NotificationFilter.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        int count;
        
        switch (filter) {
          case NotificationFilter.unread:
            count = provider.totalUnreadCount;
            break;
          default:
            count = provider.notifications.length;
        }

        if (count == 0) {
          return child;
        }

        return Badge(
          label: Text(count > 99 ? '99+' : count.toString()),
          child: child,
        );
      },
    );
  }
}