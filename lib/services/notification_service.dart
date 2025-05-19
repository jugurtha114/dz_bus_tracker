// lib/services/notification_service.dart

import '../config/api_config.dart';
import '../core/constants/api_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get user notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _apiClient.get(Endpoints.notifications);

      if (response is Map<String, dynamic> && response.containsKey(ApiConstants.resultsKey)) {
        return List<Map<String, dynamic>>.from(response[ApiConstants.resultsKey]);
      }

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }

      return [];
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get notifications: ${e.toString()}');
    }
  }

  // Mark notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.patch(
        '${Endpoints.notifications}$notificationId/',
        body: {
          'is_read': true,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _apiClient.post(Endpoints.markAllAsRead);
      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  // Register device for push notifications
  Future<Map<String, dynamic>> registerDevice({
    required String token,
    required String deviceType,
  }) async {
    try {
      final response = await _apiClient.post(
        Endpoints.deviceTokens,
        body: {
          'token': token,
          'device_type': deviceType,
        },
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to register device: ${e.toString()}');
    }
  }

  // Create a notification (for admin use)
  Future<Map<String, dynamic>> createNotification({
    required String userId,
    required String notificationType,
    required String title,
    required String message,
    required String channel,
    Map<String, dynamic>? data,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'user': userId,
        'notification_type': notificationType,
        'title': title,
        'message': message,
        'channel': channel,
      };

      if (data != null) body['data'] = data;

      final response = await _apiClient.post(
        Endpoints.notifications,
        body: body,
      );

      return response;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to create notification: ${e.toString()}');
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((notification) => notification['is_read'] == false).length;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get unread count: ${e.toString()}');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete('${Endpoints.notifications}$notificationId/');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to delete notification: ${e.toString()}');
    }
  }
}