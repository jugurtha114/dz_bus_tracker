/// lib/presentation/pages/notifications/notification_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../blocs/notification_list/notification_list_bloc.dart'; // Import BLoC
import '../../widgets/common/empty_list_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/notification/notification_list_item.dart'; // Import item widget

/// Page displaying the list of received notifications.
class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  /// Refreshes the list by reloading from storage.
  Future<void> _refreshList(BuildContext context) async {
    Log.d("NotificationListPage: Refreshing list.");
    context.read<NotificationListBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('notifications')), // TODO: Localize 'Notifications'
        leading: const BackButton(),
        actions: [
           // Buttons enabled only when notifications are loaded and list is not empty
           BlocBuilder<NotificationListBloc, NotificationListState>(
             builder: (context, state) {
               final bool canModify = state is NotificationListLoaded && state.notifications.isNotEmpty;
               final bool hasUnread = canModify && (state as NotificationListLoaded).unreadCount > 0;

               return Row(
                 children: [
                   // Mark All Read Button
                   if (canModify)
                      TextButton.icon(
                        icon: Icon(Icons.mark_email_read_outlined, size: 20),
                        label: Text(tr('mark_all_read')), // TODO: Localize
                        onPressed: hasUnread ? () {
                           Log.i('Mark all notifications as read tapped.');
                           context.read<NotificationListBloc>().add(const MarkAllNotificationsAsRead());
                        } : null, // Disable if no unread messages
                        style: TextButton.styleFrom(
                           foregroundColor: hasUnread ? theme.colorScheme.primary : theme.disabledColor,
                        ),
                      ),
                   // Clear All Button
                   if (canModify)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      tooltip: tr('clear_all'), // TODO: Localize
                      onPressed: () async {
                         final confirm = await Helpers.showConfirmationDialog(
                           context,
                           title: tr('confirm_clear_all_title'), // TODO: Localize 'Clear All Notifications?'
                           content: tr('confirm_clear_all_message'), // TODO: Localize 'Are you sure you want to permanently delete all notifications?'
                           confirmText: tr('clear_all'), // TODO: Localize
                         );
                         if (confirm == true && context.mounted) {
                            Log.i('Clear all notifications confirmed.');
                            context.read<NotificationListBloc>().add(const ClearAllNotifications());
                         }
                      },
                    ),
                 ],
               );
             },
           ),
        ],
      ),
      body: BlocBuilder<NotificationListBloc, NotificationListState>(
        builder: (context, state) {
          if (state is NotificationListInitial || state is NotificationListLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is NotificationListError) {
            return Center(
              child: ErrorDisplay(
                message: state.message,
                onRetry: () => _refreshList(context),
              ),
            );
          }

          if (state is NotificationListLoaded) {
            if (state.notifications.isEmpty) {
              return RefreshIndicator( // Allow refresh even when empty
                 onRefresh: () => _refreshList(context),
                 child: LayoutBuilder(
                   builder: (context, constraints) => SingleChildScrollView(
                     physics: const AlwaysScrollableScrollPhysics(),
                     child: ConstrainedBox(
                       constraints: BoxConstraints(minHeight: constraints.maxHeight),
                       child: const EmptyListIndicator(
                         message: 'You have no notifications.', // TODO: Localize
                         iconData: Icons.notifications_off_outlined,
                       ),
                     ),
                   ),
                 ),
              );
            }

            // Display List
            return RefreshIndicator(
              onRefresh: () => _refreshList(context),
              child: ListView.separated(
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 72), // Indent divider past avatar
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationListItem(
                    notification: notification,
                    onTap: () {
                      Log.i('Tapped notification: ${notification.id}');
                      // Mark as read and potentially navigate based on payload
                      context.read<NotificationListBloc>().add(NotificationTapped(notification: notification));
                      // TODO: Implement navigation based on notification.payload in UI layer
                      // e.g., if payload indicates line detail, push that route
                       if (notification.payload?['type'] == 'eta_arrival' && notification.payload?['lineId'] != null) {
                          // Example Navigation (ensure route exists)
                          // context.pushNamed(RouteNames.lineDetails, pathParameters: {'lineId': notification.payload!['lineId']});
                          Helpers.showSnackBar(context, message: 'Navigate from ETA notification (Not Implemented)');
                       } else {
                          // Generic tap feedback
                           Helpers.showSnackBar(context, message: 'Tapped: ${notification.title ?? 'Notification'}');
                       }
                    },
                    // Optional: Add direct mark read/unread toggle
                    // onToggleReadStatus: (id) => context.read<NotificationListBloc>().add(MarkNotificationAsRead(notificationId: id)),
                  );
                },
              ),
            );
          }

          // Fallback
           return const Center(child: Text('Error: Unknown notification state.')); // TODO: Localize
        },
      ),
    );
  }
}


/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}
