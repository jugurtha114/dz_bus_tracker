// lib/providers/notification_provider.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_model.dart' as models;
import '../models/api_response_models.dart';
import '../services/notification_service.dart';

/// Comprehensive notification provider with Firebase Cloud Messaging support
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // State variables
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  bool _permissionGranted = false;
  String? _fcmToken;

  // Notifications data
  List<models.AppNotification> _notifications = [];
  Map<String, int> _unreadCounts = {};
  int _totalUnreadCount = 0;

  // Device tokens data
  List<models.DeviceToken> _deviceTokens = [];
  models.DeviceToken? _currentDeviceToken;

  // Notification preferences data
  List<models.NotificationPreference> _notificationPreferences = [];
  Map<models.NotificationType, models.NotificationPreference> _preferencesByType = {};

  // Pagination and filtering
  int _currentPage = 1;
  bool _hasMorePages = false;
  NotificationQueryParameters? _currentQuery;

  // Stream controllers for real-time updates
  final StreamController<models.AppNotification> _notificationStreamController =
      StreamController<models.AppNotification>.broadcast();
  final StreamController<int> _unreadCountStreamController =
      StreamController<int>.broadcast();

  // Auto-refresh timer
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(minutes: 2);

  NotificationProvider({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get permissionGranted => _permissionGranted;
  String? get fcmToken => _fcmToken;

  List<models.AppNotification> get notifications => List.unmodifiable(_notifications);
  List<models.AppNotification> get unreadNotifications =>
      _notifications.where((n) => n.isUnread).toList();
  List<models.AppNotification> get recentNotifications =>
      _notifications.where((n) => n.isRecent).toList();
  
  List<models.AppNotification> get importantNotifications =>
      _notifications.where((n) => n.notificationType.isImportant).toList();

  Map<String, int> get unreadCounts => Map.unmodifiable(_unreadCounts);
  int get totalUnreadCount => _totalUnreadCount;

  List<models.DeviceToken> get deviceTokens => List.unmodifiable(_deviceTokens);
  models.DeviceToken? get currentDeviceToken => _currentDeviceToken;

  List<models.NotificationPreference> get notificationPreferences =>
      List.unmodifiable(_notificationPreferences);
  Map<models.NotificationType, models.NotificationPreference> get preferencesByType =>
      Map.unmodifiable(_preferencesByType);

  bool get hasMorePages => _hasMorePages;
  int get currentPage => _currentPage;

  // Streams
  Stream<models.AppNotification> get notificationStream =>
      _notificationStreamController.stream;
  Stream<int> get unreadCountStream => _unreadCountStreamController.stream;

  /// Initialize Firebase messaging and local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _clearError();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Initialize Firebase messaging if permissions granted
      if (_permissionGranted) {
        await _initializeFirebaseMessaging();
      }

      // Load initial data
      await _loadInitialData();

      // Start auto-refresh
      _startAutoRefresh();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize notifications: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // High priority channel for urgent notifications
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'high_priority',
          'High Priority Notifications',
          description: 'Channel for urgent bus notifications',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      // Default channel for regular notifications
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'default',
          'Default Notifications',
          description: 'Channel for regular bus notifications',
          importance: Importance.defaultImportance,
        ),
      );

      // Transport channel for bus arrival notifications
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'transport',
          'Transport Notifications',
          description: 'Channel for bus arrival and transport updates',
          importance: Importance.high,
          enableVibration: true,
        ),
      );
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request Firebase messaging permissions
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _permissionGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    // Request local notification permissions for iOS
    if (Platform.isIOS) {
      final localPermission = await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _permissionGranted = _permissionGranted && (localPermission ?? false);
    }

    notifyListeners();
  }

  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();

    if (_fcmToken != null) {
      // Register device token with backend
      await _registerDeviceToken();
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      _fcmToken = token;
      await _registerDeviceToken();
      notifyListeners();
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle initial message (app opened from terminated state)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  /// Register device token with backend
  Future<void> _registerDeviceToken() async {
    if (_fcmToken == null) return;

    try {
      models.DeviceType deviceType;
      if (Platform.isIOS) {
        deviceType = models.DeviceType.ios;
      } else if (Platform.isAndroid) {
        deviceType = models.DeviceType.android;
      } else {
        deviceType = models.DeviceType.web;
      }

      final success = await _notificationService.registerDeviceToken(
        _fcmToken!,
        deviceType: deviceType.value,
      );
      if (success) {
        // Create a mock device token since the service doesn't return one
        _currentDeviceToken = models.DeviceToken(
          id: 'token_${DateTime.now().millisecondsSinceEpoch}',
          token: _fcmToken!,
          deviceType: deviceType,
          isActive: true,
          lastUsed: DateTime.now(),
          createdAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  /// Handle foreground Firebase messages
  void _handleForegroundMessage(RemoteMessage message) {
    _processFirebaseMessage(message);
    _showLocalNotification(message);
  }

  /// Handle background Firebase messages
  void _handleBackgroundMessage(RemoteMessage message) {
    _processFirebaseMessage(message);
  }

  /// Process Firebase message data
  void _processFirebaseMessage(RemoteMessage message) {
    try {
      final data = models.FCMNotificationData.fromStringMap(
        message.data.cast<String, String>(),
      );

      // Create local notification object
      final notification = models.AppNotification(
        id: data.notificationId,
        user: models.UserBrief(
          id: message.data['user_id'] ?? '',
          email: message.data['user_email'] ?? '',
          fullName: message.data['user_name'] ?? '',
        ),
        notificationType: data.type,
        title: message.notification?.title ?? '',
        message: message.notification?.body ?? '',
        channel: models.NotificationChannel.push,
        isRead: false,
        data: message.data,
        createdAt: DateTime.now(),
      );

      // Add to notifications list
      _notifications.insert(0, notification);
      _totalUnreadCount++;

      // Update type counts
      final typeKey = data.type.value;
      _unreadCounts[typeKey] = (_unreadCounts[typeKey] ?? 0) + 1;

      // Notify listeners
      _notificationStreamController.add(notification);
      _unreadCountStreamController.add(_totalUnreadCount);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to process Firebase message: $e');
    }
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Determine notification channel and priority
    final notificationType = models.NotificationType.fromValue(
      message.data['type'] ?? 'system',
    );

    String channelId = 'default';
    NotificationDetails notificationDetails;

    if (notificationType.isTransport) {
      channelId = 'transport';
    } else if ([
      models.NotificationType.busCancelled,
      models.NotificationType.busDelayed,
      models.NotificationType.driverRejected,
    ].contains(notificationType)) {
      channelId = 'high_priority';
    }

    notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId == 'high_priority'
            ? 'High Priority Notifications'
            : channelId == 'transport'
            ? 'Transport Notifications'
            : 'Default Notifications',
        importance: channelId == 'high_priority'
            ? Importance.high
            : Importance.defaultImportance,
        priority: channelId == 'high_priority'
            ? Priority.high
            : Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: notificationType.color,
        enableVibration: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: message.data['notification_id'],
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final notificationId = response.payload;
    if (notificationId != null) {
      markAsRead(notificationId);
      // TODO: Navigate to appropriate screen based on notification type
    }
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadNotifications(),
      loadUnreadCount(),
      loadDeviceTokens(),
      loadNotificationPreferences(),
    ]);
  }

  /// Start auto-refresh timer
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_isLoading) {
        refreshData();
      }
    });
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await _loadInitialData();
  }

  // ==================== Notification Management ====================

  /// Load notifications with optional filtering
  Future<void> loadNotifications({
    NotificationQueryParameters? queryParams,
    bool resetPagination = true,
  }) async {
    try {
      if (resetPagination) {
        _currentPage = 1;
        _currentQuery = queryParams;
      }

      final params =
          queryParams ??
          _currentQuery ??
          NotificationQueryParameters(
            orderBy: ['-created_at'],
            pageSize: 20,
            page: _currentPage,
          );

      final notificationData = await _notificationService.getNotifications(
        limit: params.toMap()['page_size'] ?? 20,
        offset: ((params.toMap()['page'] ?? 1) - 1) * (params.toMap()['page_size'] ?? 20),
        unreadOnly: params.toMap()['unread_only'] ?? false,
      );

      // Convert NotificationData to AppNotification
      final notifications = notificationData.map((data) => _convertToAppNotification(data)).toList();

      if (resetPagination) {
        _notifications = notifications;
      } else {
        _notifications.addAll(notifications);
      }

      _hasMorePages = notifications.length >= (params.toMap()['page_size'] ?? 20);
      _clearError();
    } catch (e) {
      _setError('Failed to load notifications: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (!_hasMorePages || _isLoading) return;

    _currentPage++;
    await loadNotifications(resetPagination: false);
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      _totalUnreadCount = count;
      _unreadCountStreamController.add(_totalUnreadCount);
      _clearError();
    } catch (e) {
      _setError('Failed to load unread count: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && _notifications[index].isUnread) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );

          // Update counts
          _totalUnreadCount = (_totalUnreadCount - 1)
              .clamp(0, double.infinity)
              .toInt();
          final typeKey = _notifications[index].notificationType.value;
          _unreadCounts[typeKey] = ((_unreadCounts[typeKey] ?? 1) - 1)
              .clamp(0, double.infinity)
              .toInt();

          _unreadCountStreamController.add(_totalUnreadCount);
        }
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError('Failed to mark notification as read');
        return false;
      }
    } catch (e) {
      _setError('Failed to mark notification as read: ${e.toString()}');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      _setLoading(true);
      final success = await _notificationService.markAllAsRead();
      if (success) {
        // Update local state
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
            .toList();

        _totalUnreadCount = 0;
        _unreadCounts.clear();
        _unreadCountStreamController.add(0);
        _clearError();
        return true;
      } else {
        _setError('Failed to mark all notifications as read');
        return false;
      }
    } catch (e) {
      _setError('Failed to mark all notifications as read: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(
        notificationId,
      );
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notification = _notifications[index];
          _notifications.removeAt(index);

          // Update counts if notification was unread
          if (notification.isUnread) {
            _totalUnreadCount = (_totalUnreadCount - 1)
                .clamp(0, double.infinity)
                .toInt();
            final typeKey = notification.notificationType.value;
            _unreadCounts[typeKey] = ((_unreadCounts[typeKey] ?? 1) - 1)
                .clamp(0, double.infinity)
                .toInt();
            _unreadCountStreamController.add(_totalUnreadCount);
          }
        }
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete notification');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete notification: ${e.toString()}');
      return false;
    }
  }

  /// Mark notification as unread
  Future<bool> markAsUnread(String notificationId) async {
    try {
      final success = await _notificationService.markAsUnread(notificationId);
      if (success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && _notifications[index].isRead) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: false,
            readAt: null,
          );
          // Update counts
          _totalUnreadCount++;
          final typeKey = _notifications[index].notificationType.value;
          _unreadCounts[typeKey] = (_unreadCounts[typeKey] ?? 0) + 1;
          _unreadCountStreamController.add(_totalUnreadCount);
        }
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError('Failed to mark notification as unread');
        return false;
      }
    } catch (e) {
      _setError('Failed to mark notification as unread: ${e.toString()}');
      return false;
    }
  }

  /// Restore a deleted notification
  Future<bool> restoreNotification(models.AppNotification notification) async {
    try {
      // Add notification back to the list
      _notifications.insert(0, notification);
      
      // Update counts if notification was unread
      if (notification.isUnread) {
        _totalUnreadCount++;
        final typeKey = notification.notificationType.value;
        _unreadCounts[typeKey] = (_unreadCounts[typeKey] ?? 0) + 1;
        _unreadCountStreamController.add(_totalUnreadCount);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to restore notification: ${e.toString()}');
      return false;
    }
  }

  /// Schedule arrival notification
  Future<void> scheduleArrivalNotification({
    required String busId,
    required String stopId,
    int? minutesBefore,
  }) async {
    try {
      final success = await _notificationService.scheduleArrivalNotification(
        busId: busId,
        stopId: stopId,
        userId: 'current_user_id', // TODO: Get actual user ID
        estimatedMinutes: minutesBefore ?? 5,
      );
      if (success) {
        _clearError();
      } else {
        _setError('Failed to schedule arrival notification');
      }
    } catch (e) {
      _setError('Failed to schedule arrival notification: ${e.toString()}');
    }
    notifyListeners();
  }

  // ==================== Device Token Management ====================

  /// Load device tokens
  Future<void> loadDeviceTokens() async {
    try {
      final tokenMaps = await _notificationService.getDeviceTokens('current_user_id'); // TODO: Get actual user ID
      _deviceTokens = tokenMaps.map((tokenMap) => models.DeviceToken.fromJson(tokenMap)).toList();
      _clearError();
    } catch (e) {
      _setError('Failed to load device tokens: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Deactivate device token
  Future<void> deactivateDeviceToken(String tokenId) async {
    try {
      final success = await _notificationService.deactivateDeviceToken(
        tokenId,
      );
      if (success) {
        final index = _deviceTokens.indexWhere((t) => t.id == tokenId);
        if (index != -1) {
          _deviceTokens[index] = _deviceTokens[index].copyWith(isActive: false);
        }
        _clearError();
      } else {
        _setError('Failed to deactivate device token');
      }
    } catch (e) {
      _setError('Failed to deactivate device token: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Delete device token
  Future<void> deleteDeviceToken(String tokenId) async {
    try {
      final success = await _notificationService.deleteDeviceToken(tokenId);
      if (success) {
        _deviceTokens.removeWhere((t) => t.id == tokenId);
        if (_currentDeviceToken?.id == tokenId) {
          _currentDeviceToken = null;
        }
        _clearError();
      } else {
        _setError('Failed to delete device token');
      }
    } catch (e) {
      _setError('Failed to delete device token: ${e.toString()}');
    }
    notifyListeners();
  }

  // ==================== Notification Preferences ====================

  /// Load notification preferences
  Future<void> loadNotificationPreferences() async {
    try {
      final preferencesData = await _notificationService.getNotificationPreferences('current_user_id'); // TODO: Get actual user ID
      
      // Convert the Map response to NotificationPreference objects
      // For now, create mock preferences since the service returns Map<String, dynamic>
      _notificationPreferences = [];
      _preferencesByType.clear();
      
      // Create default preferences for each notification type
      for (final type in models.NotificationType.values) {
        final preference = models.NotificationPreference(
          id: 'pref_${type.value}',
          notificationType: type,
          channels: [models.NotificationChannel.push],
          enabled: preferencesData[type.value] ?? true,
          minutesBeforeArrival: 5,
          quietHoursStart: null,
          quietHoursEnd: null,
          favoriteStops: [],
          favoriteLines: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _notificationPreferences.add(preference);
        _preferencesByType[type] = preference;
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to load notification preferences: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Update notification preference
  Future<void> updateNotificationPreference({
    required models.NotificationType type,
    bool? enabled,
    List<models.NotificationChannel>? channels,
    int? minutesBefore,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) async {
    try {
      final request = models.NotificationPreferenceUpdateRequest(
        notificationType: type,
        enabled: enabled,
        channels: channels,
        minutesBeforeArrival: minutesBefore,
        quietHoursStart: quietHoursStart,
        quietHoursEnd: quietHoursEnd,
      );

      final existingPreference = _preferencesByType[type];
      bool success;

      if (existingPreference != null) {
        success = await _notificationService.updateNotificationSettings({
          'user_id': 'current_user_id', // TODO: Get actual user ID
          'notification_type': type.value,
          'enabled': request.enabled ?? true,
        });
      } else {
        success = await _notificationService.updateNotificationSettings({
          'user_id': 'current_user_id', // TODO: Get actual user ID
          'notification_type': type.value,
          'enabled': request.enabled ?? true,
        });
      }

      if (success) {
        // Create a mock preference since service doesn't return one
        final preference = models.NotificationPreference(
          id: existingPreference?.id ?? 'pref_${DateTime.now().millisecondsSinceEpoch}',
          notificationType: type,
          channels: request.channels ?? [models.NotificationChannel.push],
          enabled: request.enabled ?? true,
          minutesBeforeArrival: request.minutesBeforeArrival,
          quietHoursStart: request.quietHoursStart,
          quietHoursEnd: request.quietHoursEnd,
          favoriteStops: [],
          favoriteLines: [],
          createdAt: existingPreference?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Update preferences list
        if (existingPreference != null) {
          final index = _notificationPreferences.indexWhere(
            (p) => p.id == existingPreference.id,
          );
          if (index != -1) {
            _notificationPreferences[index] = preference;
          }
        } else {
          _notificationPreferences.add(preference);
        }

        // Update preferences map
        _preferencesByType[type] = preference;
        _clearError();
      } else {
        _setError('Failed to update notification preference');
      }
    } catch (e) {
      _setError('Failed to update notification preference: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Get preference for notification type
  models.NotificationPreference? getPreferenceForType(models.NotificationType type) {
    return _preferencesByType[type];
  }

  /// Check if notifications are enabled for type
  bool isEnabledForType(models.NotificationType type) {
    final preference = _preferencesByType[type];
    return preference?.enabled ?? true;
  }

  /// Check if channel is enabled for type
  bool isChannelEnabledForType(
    models.NotificationType type,
    models.NotificationChannel channel,
  ) {
    final preference = _preferencesByType[type];
    return preference?.channels.contains(channel) ?? true;
  }

  // ==================== Helper Methods ====================

  /// Get notifications by type
  List<models.AppNotification> getNotificationsByType(models.NotificationType type) {
    return _notifications.where((n) => n.notificationType == type).toList();
  }

  /// Get unread count for type
  int getUnreadCountForType(models.NotificationType type) {
    return _unreadCounts[type.value] ?? 0;
  }

  /// Filter notifications
  List<models.AppNotification> filterNotifications({
    models.NotificationType? type,
    models.NotificationChannel? channel,
    bool? isRead,
    bool? isRecent,
  }) {
    return _notifications.where((notification) {
      if (type != null && notification.notificationType != type) return false;
      if (channel != null && notification.channel != channel) return false;
      if (isRead != null && notification.isRead != isRead) return false;
      if (isRecent != null && notification.isRecent != isRecent) return false;
      return true;
    }).toList();
  }

  // ==================== Legacy compatibility methods ====================

  /// Fetch notifications (legacy method for backward compatibility)
  Future<void> fetchNotifications() async {
    await loadNotifications();
  }

  /// Register device for push notifications (legacy method)
  Future<bool> registerDevice({
    required String token,
    required String deviceType,
  }) async {
    try {
      final request = models.DeviceTokenCreateRequest(
        token: token,
        deviceType: models.DeviceType.fromValue(deviceType),
      );

      final success = await _notificationService.registerDeviceToken(
        request.token,
        userId: 'current_user_id', // TODO: Get actual user ID
        deviceType: request.deviceType.value,
      );
      if (success) {
        // Create a mock device token since the service doesn't return one
        _currentDeviceToken = models.DeviceToken(
          id: 'token_${DateTime.now().millisecondsSinceEpoch}',
          token: request.token,
          deviceType: request.deviceType,
          isActive: true,
          lastUsed: DateTime.now(),
          createdAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to register device: ${e.toString()}');
      return false;
    }
  }

  /// Show local notification (legacy method)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'default',
          'Default Notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // ==================== State Management ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear error (legacy method)
  void clearError() {
    _clearError();
  }

  /// Legacy getter for backward compatibility
  int get unreadCount => _totalUnreadCount;

  /// Convert NotificationData to AppNotification
  models.AppNotification _convertToAppNotification(NotificationData data) {
    return models.AppNotification(
      id: data.id,
      user: models.UserBrief(
        id: data.userId ?? 'unknown',
        email: '',
        fullName: 'User',
      ),
      notificationType: data.type,
      title: data.title,
      message: data.message,
      channel: models.NotificationChannel.push, // Default channel
      isRead: data.isRead,
      readAt: null,
      data: data.payload,
      createdAt: data.timestamp,
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _notificationStreamController.close();
    _unreadCountStreamController.close();
    super.dispose();
  }
}
