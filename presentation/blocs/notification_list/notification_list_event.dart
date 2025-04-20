/// lib/presentation/blocs/notification_list/notification_list_event.dart

part of 'notification_list_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to the notification list.
/// Uses [Equatable] for value comparison.
abstract class NotificationListEvent extends Equatable {
  const NotificationListEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load the initial list of notifications,
/// likely from local persistence.
class LoadNotifications extends NotificationListEvent {
  const LoadNotifications();
}

/// Internal event triggered by the BLoC when a new notification is received
/// from the [NotificationService] stream.
class _InternalNotificationReceived extends NotificationListEvent {
  /// The newly received notification.
  final NotificationEntity notification;

  const _InternalNotificationReceived({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Event triggered when a specific notification is marked as read by the user.
class MarkNotificationAsRead extends NotificationListEvent {
  /// The unique ID of the notification to mark as read.
  final String notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];

  @override
  String toString() => 'MarkNotificationAsRead(id: $notificationId)';
}

/// Event triggered when the user requests to mark all notifications as read.
class MarkAllNotificationsAsRead extends NotificationListEvent {
  const MarkAllNotificationsAsRead();
}

/// Event triggered when the user requests to clear all stored notifications.
class ClearAllNotifications extends NotificationListEvent {
  const ClearAllNotifications();
}

/// Event triggered when a user taps on a notification in the list,
/// potentially to navigate or perform an action based on its payload.
class NotificationTapped extends NotificationListEvent {
  /// The notification that was tapped.
  final NotificationEntity notification;

  const NotificationTapped({required this.notification});

   @override
  List<Object?> get props => [notification];

  @override
  String toString() => 'NotificationTapped(id: ${notification.id})';
}

