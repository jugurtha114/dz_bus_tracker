// lib/services/notification_service.dart

import '../config/api_config.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../models/api_response_models.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Notification management methods

  /// Get all notifications with optional filtering
  Future<ApiResponse<PaginatedResponse<AppNotification>>> getNotifications({
    NotificationQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.notifications),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<AppNotification>.fromJson(
        response,
        (json) => AppNotification.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get notifications: ${e.toString()}');
    }
  }

  /// Get notification by ID
  Future<ApiResponse<AppNotification>> getNotificationById(String notificationId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.notificationById(notificationId)));
      final notification = AppNotification.fromJson(response);
      return ApiResponse.success(data: notification);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get notification details: ${e.toString()}');
    }
  }

  /// Create new notification
  Future<ApiResponse<AppNotification>> createNotification(NotificationCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.notifications),
        body: request.toJson(),
      );

      final notification = AppNotification.fromJson(response);
      return ApiResponse.success(data: notification);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to create notification: ${e.toString()}');
    }
  }

  /// Mark notification as read
  Future<ApiResponse<AppNotification>> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.markAsRead(notificationId)),
        body: {},
      );

      final notification = AppNotification.fromJson(response);
      return ApiResponse.success(data: notification);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read
  Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.markAllNotificationsRead),
        body: {},
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  /// Get unread notifications count
  Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.unreadCount));
      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get unread count: ${e.toString()}');
    }
  }

  /// Schedule arrival notification
  Future<ApiResponse<AppNotification>> scheduleArrivalNotification(BusArrivalNotificationRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.scheduleArrival),
        body: request.toJson(),
      );

      final notification = AppNotification.fromJson(response);
      return ApiResponse.success(data: notification);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to schedule arrival notification: ${e.toString()}');
    }
  }

  /// Delete notification
  Future<ApiResponse<void>> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete(ApiEndpoints.buildUrl(ApiEndpoints.notificationById(notificationId)));
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to delete notification: ${e.toString()}');
    }
  }

  // Device token management methods

  /// Get all device tokens with optional filtering
  Future<ApiResponse<PaginatedResponse<DeviceToken>>> getDeviceTokens({
    DeviceTokenQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.deviceTokens),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<DeviceToken>.fromJson(
        response,
        (json) => DeviceToken.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get device tokens: ${e.toString()}');
    }
  }

  /// Get device token by ID
  Future<ApiResponse<DeviceToken>> getDeviceTokenById(String tokenId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.deviceTokenById(tokenId)));
      final token = DeviceToken.fromJson(response);
      return ApiResponse.success(data: token);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get device token: ${e.toString()}');
    }
  }

  /// Register device token for push notifications
  Future<ApiResponse<DeviceToken>> registerDeviceToken(DeviceTokenCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.deviceTokens),
        body: request.toJson(),
      );

      final token = DeviceToken.fromJson(response);
      return ApiResponse.success(data: token);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to register device token: ${e.toString()}');
    }
  }

  /// Update device token
  Future<ApiResponse<DeviceToken>> updateDeviceToken(String tokenId, DeviceTokenUpdateRequest request) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.deviceTokenById(tokenId)),
        body: request.toJson(),
      );

      final token = DeviceToken.fromJson(response);
      return ApiResponse.success(data: token);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to update device token: ${e.toString()}');
    }
  }

  /// Deactivate device token
  Future<ApiResponse<DeviceToken>> deactivateDeviceToken(String tokenId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.deactivateDeviceToken(tokenId)),
        body: {},
      );

      final token = DeviceToken.fromJson(response);
      return ApiResponse.success(data: token);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to deactivate device token: ${e.toString()}');
    }
  }

  /// Delete device token
  Future<ApiResponse<void>> deleteDeviceToken(String tokenId) async {
    try {
      await _apiClient.delete(ApiEndpoints.buildUrl(ApiEndpoints.deviceTokenById(tokenId)));
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to delete device token: ${e.toString()}');
    }
  }

  // Notification preference methods

  /// Get all notification preferences with optional filtering
  Future<ApiResponse<PaginatedResponse<NotificationPreference>>> getNotificationPreferences({
    NotificationPreferenceQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.notificationPreferences),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<NotificationPreference>.fromJson(
        response,
        (json) => NotificationPreference.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get notification preferences: ${e.toString()}');
    }
  }

  /// Get notification preference by ID
  Future<ApiResponse<NotificationPreference>> getNotificationPreferenceById(String preferenceId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.notificationPreferenceById(preferenceId)));
      final preference = NotificationPreference.fromJson(response);
      return ApiResponse.success(data: preference);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get notification preference: ${e.toString()}');
    }
  }

  /// Create notification preference
  Future<ApiResponse<NotificationPreference>> createNotificationPreference(NotificationPreferenceUpdateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.notificationPreferences),
        body: request.toJson(),
      );

      final preference = NotificationPreference.fromJson(response);
      return ApiResponse.success(data: preference);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to create notification preference: ${e.toString()}');
    }
  }

  /// Update notification preference
  Future<ApiResponse<NotificationPreference>> updateNotificationPreference(String preferenceId, NotificationPreferenceUpdateRequest request) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.notificationPreferenceById(preferenceId)),
        body: request.toJson(),
      );

      final preference = NotificationPreference.fromJson(response);
      return ApiResponse.success(data: preference);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to update notification preference: ${e.toString()}');
    }
  }

  /// Delete notification preference
  Future<ApiResponse<void>> deleteNotificationPreference(String preferenceId) async {
    try {
      await _apiClient.delete(ApiEndpoints.buildUrl(ApiEndpoints.notificationPreferenceById(preferenceId)));
      return ApiResponse.success();
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to delete notification preference: ${e.toString()}');
    }
  }

  // Helper methods

  /// Get unread notifications
  Future<ApiResponse<List<AppNotification>>> getUnreadNotifications({int limit = 50}) async {
    final queryParams = NotificationQueryParameters(
      isRead: false,
      orderBy: ['-created_at'],
      pageSize: limit,
    );

    final response = await getNotifications(queryParams: queryParams);
    if (response.isSuccess) {
      return ApiResponse.success(data: response.data?.results ?? []);
    }
    return ApiResponse.error(message: response.message);
  }

  /// Get recent notifications (last 24 hours)
  Future<ApiResponse<List<AppNotification>>> getRecentNotifications({int limit = 20}) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final queryParams = NotificationQueryParameters(
      createdAfter: yesterday,
      orderBy: ['-created_at'],
      pageSize: limit,
    );

    final response = await getNotifications(queryParams: queryParams);
    if (response.isSuccess) {
      return ApiResponse.success(data: response.data?.results ?? []);
    }
    return ApiResponse.error(message: response.message);
  }

  /// Get notifications by type
  Future<ApiResponse<List<AppNotification>>> getNotificationsByType(NotificationType type, {int limit = 20}) async {
    final queryParams = NotificationQueryParameters(
      notificationType: [type.value],
      orderBy: ['-created_at'],
      pageSize: limit,
    );

    final response = await getNotifications(queryParams: queryParams);
    if (response.isSuccess) {
      return ApiResponse.success(data: response.data?.results ?? []);
    }
    return ApiResponse.error(message: response.message);
  }

  /// Get active device tokens for current user
  Future<ApiResponse<List<DeviceToken>>> getActiveDeviceTokens() async {
    final queryParams = DeviceTokenQueryParameters(
      isActive: true,
      orderBy: ['-last_used'],
    );

    final response = await getDeviceTokens(queryParams: queryParams);
    if (response.isSuccess) {
      return ApiResponse.success(data: response.data?.results ?? []);
    }
    return ApiResponse.error(message: response.message);
  }

  /// Get user's notification preferences
  Future<ApiResponse<List<NotificationPreference>>> getUserNotificationPreferences() async {
    final response = await getNotificationPreferences();
    if (response.isSuccess) {
      return ApiResponse.success(data: response.data?.results ?? []);
    }
    return ApiResponse.error(message: response.message);
  }

  /// Get notification preference for specific type
  Future<ApiResponse<NotificationPreference?>> getPreferenceForType(NotificationType type) async {
    final queryParams = NotificationPreferenceQueryParameters(
      notificationType: [type.value],
    );

    final response = await getNotificationPreferences(queryParams: queryParams);
    if (response.isSuccess && response.data!.results.isNotEmpty) {
      return ApiResponse.success(data: response.data!.results.first);
    }
    return ApiResponse.success(data: null);
  }

  /// Enable notifications for a specific type
  Future<ApiResponse<NotificationPreference>> enableNotificationsForType({
    required NotificationType type,
    List<NotificationChannel>? channels,
    int? minutesBefore,
  }) async {
    final existingPreference = await getPreferenceForType(type);
    
    final request = NotificationPreferenceUpdateRequest(
      notificationType: type,
      enabled: true,
      channels: channels ?? [NotificationChannel.push, NotificationChannel.inApp],
      minutesBeforeArrival: minutesBefore,
    );

    if (existingPreference.isSuccess && existingPreference.data != null) {
      // Update existing preference
      return updateNotificationPreference(existingPreference.data!.id, request);
    } else {
      // Create new preference
      return createNotificationPreference(request);
    }
  }

  /// Disable notifications for a specific type
  Future<ApiResponse<NotificationPreference>> disableNotificationsForType(NotificationType type) async {
    final existingPreference = await getPreferenceForType(type);
    
    if (existingPreference.isSuccess && existingPreference.data != null) {
      final request = NotificationPreferenceUpdateRequest(
        enabled: false,
      );
      return updateNotificationPreference(existingPreference.data!.id, request);
    }
    
    return ApiResponse.error(message: 'No existing preference found for this notification type');
  }

  /// Bulk mark notifications as read
  Future<ApiResponse<int>> markMultipleAsRead(List<String> notificationIds) async {
    int successCount = 0;
    
    for (final id in notificationIds) {
      final response = await markAsRead(id);
      if (response.isSuccess) {
        successCount++;
      }
    }
    
    return ApiResponse.success(data: successCount);
  }

  /// Get notification statistics
  Future<ApiResponse<Map<String, dynamic>>> getNotificationStatistics() async {
    try {
      // Get unread count
      final unreadResponse = await getUnreadCount();
      
      // Get recent notifications count
      final recentResponse = await getRecentNotifications();
      
      // Get notifications by type counts
      final typeCountsMap = <String, int>{};
      for (final type in NotificationType.values) {
        final typeResponse = await getNotificationsByType(type, limit: 1);
        if (typeResponse.isSuccess) {
          typeCountsMap[type.value] = typeResponse.data?.length ?? 0;
        }
      }

      final statistics = {
        'unread_count': unreadResponse.isSuccess ? (unreadResponse.data?['count'] ?? 0) : 0,
        'recent_count': recentResponse.isSuccess ? recentResponse.data!.length : 0,
        'type_counts': typeCountsMap,
        'last_updated': DateTime.now().toIso8601String(),
      };

      return ApiResponse.success(data: statistics);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get notification statistics: ${e.toString()}');
    }
  }
}