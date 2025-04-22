/// lib/presentation/blocs/notification_list/notification_list_state.dart

part of 'notification_list_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to the notification list.
/// Uses [Equatable] for state comparison.
abstract class NotificationListState extends Equatable {
  const NotificationListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any notifications have been loaded.
class NotificationListInitial extends NotificationListState {
  const NotificationListInitial();
}

/// State indicating that the list of notifications is currently being loaded
/// (e.g., from local storage or potentially a backend source).
class NotificationListLoading extends NotificationListState {
  const NotificationListLoading();
}

/// State indicating that the list of notifications has been successfully loaded.
class NotificationListLoaded extends NotificationListState {
  /// The list of loaded notification entities.
  final List<NotificationEntity> notifications;

  /// Optional: Could add properties for filtering (e.g., unread only) if needed.
  // final bool unreadOnlyFilter;

  const NotificationListLoaded({
    this.notifications = const [], // Default to empty list
    // this.unreadOnlyFilter = false,
  });

  /// Creates a copy of the current loaded state with updated values.
  NotificationListLoaded copyWith({
    List<NotificationEntity>? notifications,
    // bool? unreadOnlyFilter,
  }) {
    return NotificationListLoaded(
      notifications: notifications ?? this.notifications,
      // unreadOnlyFilter: unreadOnlyFilter ?? this.unreadOnlyFilter,
    );
  }

  /// Helper getter to count unread notifications.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [
        notifications,
        // unreadOnlyFilter
        ];

  @override
  String toString() =>
      'NotificationListLoaded(count: ${notifications.length}, unread: $unreadCount)';
}

/// State indicating that an error occurred while loading notifications.
class NotificationListError extends NotificationListState {
  /// The error message describing the failure.
  final String message;

  const NotificationListError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'NotificationListError(message: $message)';
}

