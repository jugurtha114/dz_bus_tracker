/// lib/presentation/blocs/notification_list/notification_list_bloc.dart

import 'dart:async';
import 'dart:convert'; // For jsonEncode/Decode

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For transformers
import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'package:equatable/equatable.dart';

import '../../../core/services/notification_service.dart'; // Import NotificationService and ReceivedNotification
import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/notification_entity.dart'; // Import the entity

part 'notification_list_event.dart';
part 'notification_list_state.dart';

/// Key used to store the notification list in StorageService.
const String _notificationListStorageKey = 'app_notification_list';

/// BLoC responsible for managing the state of the user's notification list.
///
/// Handles loading notifications from storage, receiving new notifications
/// from the [NotificationService], and managing read/unread status and deletion.
class NotificationListBloc extends Bloc<NotificationListEvent, NotificationListState> {
  final NotificationService _notificationService;
  final StorageService _storageService;
  StreamSubscription<ReceivedNotification>? _notificationSubscription;

  /// Creates an instance of [NotificationListBloc].
  NotificationListBloc({
    required NotificationService notificationService,
    required StorageService storageService,
  })  : _notificationService = notificationService,
        _storageService = storageService,
        super(const NotificationListInitial()) {

    // Register event handlers
    on<LoadNotifications>(
      _onLoadNotifications,
      transformer: restartable(), // Only load once at a time
    );
    on<_InternalNotificationReceived>(
      _onInternalNotificationReceived,
      transformer: sequential(), // Process received notifications sequentially
    );
    on<MarkNotificationAsRead>(
      _onMarkNotificationAsRead,
      transformer: sequential(),
    );
     on<MarkAllNotificationsAsRead>(
      _onMarkAllNotificationsAsRead,
      transformer: sequential(),
    );
    on<ClearAllNotifications>(
      _onClearAllNotifications,
      transformer: droppable(), // Ignore if already clearing
    );
     on<NotificationTapped>(
      _onNotificationTapped,
      // Tapping usually doesn't need a transformer, but sequential is safe
      transformer: sequential(),
    );

    // Subscribe to notifications from the service
    _subscribeToNotifications();

    // Trigger initial load
    add(const LoadNotifications());
  }

  /// Subscribes to the notification stream from NotificationService.
  void _subscribeToNotifications() {
    _notificationSubscription = _notificationService.notificationStream.listen(
      (receivedNotification) {
        Log.d('NotificationListBloc: Received notification from service stream.');
        // Map ReceivedNotification to NotificationEntity
        // Generate a unique ID (e.g., hashcode or timestamp based if needed)
        // Using hashcode of the received object as a simple local ID source
        final notificationEntity = NotificationEntity(
          id: receivedNotification.id.toString(), // Use ID from ReceivedNotification
          title: receivedNotification.title,
          body: receivedNotification.body,
          receivedAt: DateTime.now(), // Use current time as received time
          payload: receivedNotification.payload,
          isRead: false, // New notifications are unread
        );
        add(_InternalNotificationReceived(notification: notificationEntity));
      },
      onError: (error) {
        Log.e('Error in notification stream subscription', error: error);
        // Optionally emit an error state specific to the stream failure?
      },
    );
     Log.i('NotificationListBloc: Subscribed to notification service stream.');
  }

  @override
  Future<void> close() {
    Log.d('NotificationListBloc: Closing and cancelling notification subscription.');
    _notificationSubscription?.cancel();
    return super.close();
  }

  /// Handles the [LoadNotifications] event to load from storage.
  Future<void> _onLoadNotifications(
      LoadNotifications event, Emitter<NotificationListState> emit) async {
    Log.d('NotificationListBloc: Handling LoadNotifications event.');
    emit(const NotificationListLoading());
    try {
      final notifications = await _loadNotificationsFromStorage();
       Log.i('NotificationListBloc: Loaded ${notifications.length} notifications from storage.');
      emit(NotificationListLoaded(notifications: notifications));
    } catch (e, stackTrace) {
       Log.e('NotificationListBloc: Failed to load notifications from storage.', error: e, stackTrace: stackTrace);
       emit(const NotificationListError(message: 'Failed to load notifications.'));
    }
  }

  /// Handles the internal event when a new notification is received.
  Future<void> _onInternalNotificationReceived(
      _InternalNotificationReceived event, Emitter<NotificationListState> emit) async {
    Log.d('NotificationListBloc: Handling _InternalNotificationReceived event.');
    List<NotificationEntity> currentNotifications = [];
    if (state is NotificationListLoaded) {
      currentNotifications = List.from((state as NotificationListLoaded).notifications);
    } else if (state is NotificationListError) {
      // If state was error, maybe start fresh or use potentially stale data
      currentNotifications = await _loadNotificationsFromStorage(); // Reload if was error
    }

    // Avoid duplicates based on ID (if ID generation is reliable)
    final existingIndex = currentNotifications.indexWhere((n) => n.id == event.notification.id);
    if (existingIndex == -1) {
       // Add new notification to the top of the list
      final updatedList = [event.notification, ...currentNotifications];
      await _saveNotificationsToStorage(updatedList);
      emit(NotificationListLoaded(notifications: updatedList));
      Log.i('NotificationListBloc: Added new notification (${event.notification.id}) and updated state.');
    } else {
        Log.w('NotificationListBloc: Duplicate notification received (ID: ${event.notification.id}). Ignoring.');
         // Optionally update existing notification if needed?
         // If state wasn't loaded, ensure we emit loaded state now
         if(state is! NotificationListLoaded) {
            emit(NotificationListLoaded(notifications: currentNotifications));
         }
    }
  }

  /// Handles the [MarkNotificationAsRead] event.
  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsRead event, Emitter<NotificationListState> emit) async {
    if (state is NotificationListLoaded) {
       Log.d('NotificationListBloc: Handling MarkNotificationAsRead event for ID: ${event.notificationId}');
       final currentState = state as NotificationListLoaded;
       final notificationIndex = currentState.notifications.indexWhere((n) => n.id == event.notificationId);

       if (notificationIndex != -1 && !currentState.notifications[notificationIndex].isRead) {
         final updatedList = List<NotificationEntity>.from(currentState.notifications);
         updatedList[notificationIndex] = updatedList[notificationIndex].copyWith(isRead: true);
         await _saveNotificationsToStorage(updatedList);
         emit(currentState.copyWith(notifications: updatedList));
         Log.i('NotificationListBloc: Marked notification ${event.notificationId} as read.');
       } else {
         Log.w('NotificationListBloc: Notification ${event.notificationId} not found or already read.');
       }
    } else {
       Log.w('NotificationListBloc: MarkNotificationAsRead event received while not in loaded state.');
    }
  }

   /// Handles the [MarkAllNotificationsAsRead] event.
  Future<void> _onMarkAllNotificationsAsRead(
      MarkAllNotificationsAsRead event, Emitter<NotificationListState> emit) async {
     if (state is NotificationListLoaded) {
       Log.d('NotificationListBloc: Handling MarkAllNotificationsAsRead event.');
       final currentState = state as NotificationListLoaded;
       bool changed = false;
       final updatedList = currentState.notifications.map((n) {
          if (!n.isRead) {
            changed = true;
            return n.copyWith(isRead: true);
          }
          return n;
       }).toList();

       if (changed) {
          await _saveNotificationsToStorage(updatedList);
          emit(currentState.copyWith(notifications: updatedList));
          Log.i('NotificationListBloc: Marked all notifications as read.');
       } else {
          Log.d('NotificationListBloc: No unread notifications to mark.');
       }
    } else {
       Log.w('NotificationListBloc: MarkAllNotificationsAsRead event received while not in loaded state.');
    }
  }

  /// Handles the [ClearAllNotifications] event.
  Future<void> _onClearAllNotifications(
      ClearAllNotifications event, Emitter<NotificationListState> emit) async {
     Log.d('NotificationListBloc: Handling ClearAllNotifications event.');
     // Optionally show loading state
     // emit(const NotificationListLoading());
     try {
        await _saveNotificationsToStorage([]); // Save empty list
        emit(const NotificationListLoaded(notifications: [])); // Emit empty loaded state
        Log.i('NotificationListBloc: Cleared all notifications.');
     } catch (e, stackTrace) {
        Log.e('NotificationListBloc: Failed to clear notifications.', error: e, stackTrace: stackTrace);
         // Revert to previous state? Or emit error?
         // Re-load to be safe, or emit error based on current state
         if (state is NotificationListLoaded) {
             emit(NotificationListError(message: 'Failed to clear notifications.'));
             // Keep old list in UI while showing error?
             // emit((state as NotificationListLoaded)); // Re-emit old state
         } else {
             emit(const NotificationListError(message: 'Failed to clear notifications.'));
         }
     }
  }

   /// Handles the [NotificationTapped] event.
  Future<void> _onNotificationTapped(
      NotificationTapped event, Emitter<NotificationListState> emit) async {
      Log.d('NotificationListBloc: Handling NotificationTapped event for ID: ${event.notification.id}');
      // Mark notification as read when tapped
      add(MarkNotificationAsRead(notificationId: event.notification.id));

      // Navigation or action logic based on payload should happen in the UI layer
      // listening to the BLoC or potentially via a separate "SideEffect" stream/mechanism.
      // This BLoC primarily focuses on managing the state of the list itself.
      Log.i('Notification tapped payload: ${event.notification.payload}');
      // Example: Push navigation event if using a navigation service/stream
      // _navigationService.navigateTo(routeFromPayload(event.notification.payload));
  }


  // --- Internal Storage Helpers ---

  /// Saves the current list of notifications to persistent storage.
  Future<void> _saveNotificationsToStorage(List<NotificationEntity> notifications) async {
    try {
      final List<Map<String, dynamic>> jsonList = notifications.map((n) => n.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await _storageService.saveData<String>(_notificationListStorageKey, jsonString);
    } catch (e, stackTrace) {
      Log.e('Failed to save notifications to storage', error: e, stackTrace:stackTrace);
      // Throw or handle? Depends on requirements. For now, just log.
    }
  }

  /// Loads the list of notifications from persistent storage.
  Future<List<NotificationEntity>> _loadNotificationsFromStorage() async {
    try {
      final jsonString = await _storageService.getData<String>(_notificationListStorageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        return decodedList
            .map((json) => NotificationEntity.fromJson(json as Map<String, dynamic>))
            // Sort by receivedAt descending (newest first)
            .sorted((a, b) => b.receivedAt.compareTo(a.receivedAt))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      Log.e('Failed to load or parse notifications from storage', error: e, stackTrace: stackTrace);
      // Clear potentially corrupted data on parse error?
      await _storageService.deleteData(_notificationListStorageKey);
      return []; // Return empty list on error
    }
  }
}
