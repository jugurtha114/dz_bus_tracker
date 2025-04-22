/// lib/presentation/blocs/notification_list/mock_notification_list_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';
import 'notification_list_bloc.dart';


/// A mock implementation of NotificationListBloc that can be used when Firebase is not available
/// This ensures the app can still function without notifications
class MockNotificationListBloc extends Bloc<NotificationListEvent, NotificationListState> {
  final StorageService storageService;

  MockNotificationListBloc({
    required this.storageService,
  }) : super(const NotificationListInitial()) {
    on<NotificationsLoaded>(_onNotificationsLoaded);
    on<NotificationReceived>(_onNotificationReceived);
    on<NotificationRead>(_onNotificationRead);
    on<NotificationDismissed>(_onNotificationDismissed);
    on<AllNotificationsRead>(_onAllNotificationsRead);
    on<AllNotificationsDismissed>(_onAllNotificationsDismissed);

    Log.i("Created MockNotificationListBloc - notifications disabled");
  }

  /// Simulate loading notifications (returns empty list)
  void _onNotificationsLoaded(
    NotificationsLoaded event,
    Emitter<NotificationListState> emit
  ) async {
    emit(const NotificationListLoading());
    // Return empty notifications list
    emit(const NotificationListLoaded(notifications: [], unreadCount: 0));
  }

  /// No-op implementation of notification receipt
  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationListState> emit
  ) {
    // Just keep current state
    Log.d("Ignoring received notification in mock bloc");
  }

  /// No-op implementation of marking a notification as read
  void _onNotificationRead(
    NotificationRead event,
    Emitter<NotificationListState> emit
  ) {
    // Just keep current state
    Log.d("Ignoring notification read in mock bloc");
  }

  /// No-op implementation of dismissing a notification
  void _onNotificationDismissed(
    NotificationDismissed event,
    Emitter<NotificationListState> emit
  ) {
    // Just keep current state
    Log.d("Ignoring notification dismissed in mock bloc");
  }

  /// No-op implementation of marking all notifications as read
  void _onAllNotificationsRead(
    AllNotificationsRead event,
    Emitter<NotificationListState> emit
  ) {
    // Just keep current state
    Log.d("Ignoring all notifications read in mock bloc");
  }

  /// No-op implementation of dismissing all notifications
  void _onAllNotificationsDismissed(
    AllNotificationsDismissed event,
    Emitter<NotificationListState> emit
  ) {
    // Just keep current state
    Log.d("Ignoring all notifications dismissed in mock bloc");
  }
}
