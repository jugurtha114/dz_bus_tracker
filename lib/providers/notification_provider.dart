// lib/providers/notification_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/utils/notification_utils.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  // State
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize notifications
  Future<void> initialize() async {
    await NotificationUtils.setupNotifications();
    await fetchNotifications();
  }

  // Fetch notifications
  Future<void> fetchNotifications() async {
    _setLoading(true);

    try {
      _notifications = await _notificationService.getNotifications();
      _updateUnreadCount();

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local notification
      final index = _notifications.indexWhere((notification) => notification['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
        _updateUnreadCount();
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update local notifications
      for (var notification in _notifications) {
        notification['is_read'] = true;
      }

      _unreadCount = 0;
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Register device for push notifications
  Future<bool> registerDevice({
    required String token,
    required String deviceType,
  }) async {
    try {
      await _notificationService.registerDevice(
        token: token,
        deviceType: deviceType,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await NotificationUtils.showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Remove from local list
      _notifications.removeWhere((notification) => notification['id'] == notificationId);
      _updateUnreadCount();
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((notification) => notification['is_read'] == false).length;
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(dynamic error) {
    if (error is AppException) {
      _error = error.message;
    } else {
      _error = error.toString();
    }
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}