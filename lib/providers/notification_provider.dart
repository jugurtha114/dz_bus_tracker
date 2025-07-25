// lib/providers/notification_provider.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_model.dart';
import '../models/api_response_models.dart';
import '../services/notification_service.dart';
import '../core/exceptions/app_exceptions.dart';

/// Comprehensive notification provider with Firebase Cloud Messaging support
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // State variables
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  bool _permissionGranted = false;
  String? _fcmToken;

  // Notifications data
  List<AppNotification> _notifications = [];
  Map<String, int> _unreadCounts = {};
  int _totalUnreadCount = 0;

  // Device tokens data
  List<DeviceToken> _deviceTokens = [];
  DeviceToken? _currentDeviceToken;

  // Notification preferences data
  List<NotificationPreference> _notificationPreferences = [];
  Map<NotificationType, NotificationPreference> _preferencesByType = {};

  // Pagination and filtering
  int _currentPage = 1;
  bool _hasMorePages = false;
  NotificationQueryParameters? _currentQuery;

  // Stream controllers for real-time updates
  final StreamController<AppNotification> _notificationStreamController = 
      StreamController<AppNotification>.broadcast();
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

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => n.isUnread).toList();
  List<AppNotification> get recentNotifications => 
      _notifications.where((n) => n.isRecent).toList();

  Map<String, int> get unreadCounts => Map.unmodifiable(_unreadCounts);
  int get totalUnreadCount => _totalUnreadCount;

  List<DeviceToken> get deviceTokens => List.unmodifiable(_deviceTokens);
  DeviceToken? get currentDeviceToken => _currentDeviceToken;

  List<NotificationPreference> get notificationPreferences => 
      List.unmodifiable(_notificationPreferences);
  Map<NotificationType, NotificationPreference> get preferencesByType => 
      Map.unmodifiable(_preferencesByType);

  bool get hasMorePages => _hasMorePages;
  int get currentPage => _currentPage;

  // Streams
  Stream<AppNotification> get notificationStream => _notificationStreamController.stream;
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
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

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

    _permissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                       settings.authorizationStatus == AuthorizationStatus.provisional;

    // Request local notification permissions for iOS
    if (Platform.isIOS) {
      final localPermission = await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      
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
      DeviceType deviceType;
      if (Platform.isIOS) {
        deviceType = DeviceType.ios;
      } else if (Platform.isAndroid) {
        deviceType = DeviceType.android;
      } else {
        deviceType = DeviceType.web;
      }

      final request = DeviceTokenCreateRequest(
        token: _fcmToken!,
        deviceType: deviceType,
      );

      final response = await _notificationService.registerDeviceToken(request);
      if (response.isSuccess) {
        _currentDeviceToken = response.data;
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
      final data = FCMNotificationData.fromStringMap(
        message.data.cast<String, String>(),
      );

      // Create local notification object
      final notification = AppNotification(
        id: data.notificationId,
        user: UserBrief(
          id: message.data['user_id'] ?? '',
          email: message.data['user_email'] ?? '',
          fullName: message.data['user_name'] ?? '',
        ),
        notificationType: data.type,
        title: message.notification?.title ?? '',
        message: message.notification?.body ?? '',
        channel: NotificationChannel.push,
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
    final notificationType = NotificationType.fromValue(
      message.data['type'] ?? 'system',
    );
    
    String channelId = 'default';
    NotificationDetails notificationDetails;

    if (notificationType.isTransport) {
      channelId = 'transport';
    } else if ([
      NotificationType.busCancelled,
      NotificationType.busDelayed,
      NotificationType.driverRejected,
    ].contains(notificationType)) {
      channelId = 'high_priority';
    }

    notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId == 'high_priority' ? 'High Priority Notifications' : 
        channelId == 'transport' ? 'Transport Notifications' : 'Default Notifications',
        importance: channelId == 'high_priority' ? Importance.high : Importance.defaultImportance,
        priority: channelId == 'high_priority' ? Priority.high : Priority.defaultPriority,
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

      final params = queryParams ?? _currentQuery ?? NotificationQueryParameters(
        orderBy: ['-created_at'],
        pageSize: 20,
        page: _currentPage,
      );

      final response = await _notificationService.getNotifications(queryParams: params);

      if (response.isSuccess && response.data != null) {
        if (resetPagination) {
          _notifications = response.data!.results;
        } else {
          _notifications.addAll(response.data!.results);
        }
        
        _hasMorePages = response.data!.hasNextPage;
        _clearError();
      } else {
        _setError(response.message);
      }
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
      final response = await _notificationService.getUnreadCount();
      if (response.isSuccess && response.data != null) {
        _totalUnreadCount = response.data!['count'] ?? 0;
        
        // Update type counts if available
        if (response.data!.containsKey('type_counts')) {
          _unreadCounts = Map<String, int>.from(response.data!['type_counts']);
        }
        
        _unreadCountStreamController.add(_totalUnreadCount);
        _clearError();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to load unread count: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _notificationService.markAsRead(notificationId);
      if (response.isSuccess && response.data != null) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && _notifications[index].isUnread) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          
          // Update counts
          _totalUnreadCount = (_totalUnreadCount - 1).clamp(0, double.infinity).toInt();
          final typeKey = _notifications[index].notificationType.value;
          _unreadCounts[typeKey] = ((_unreadCounts[typeKey] ?? 1) - 1).clamp(0, double.infinity).toInt();
          
          _unreadCountStreamController.add(_totalUnreadCount);
        }
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
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
      final response = await _notificationService.markAllAsRead();
      if (response.isSuccess) {
        // Update local state
        _notifications = _notifications.map((n) => n.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        )).toList();
        
        _totalUnreadCount = 0;
        _unreadCounts.clear();
        _unreadCountStreamController.add(0);
        _clearError();
        return true;
      } else {
        _setError(response.message);
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
      final response = await _notificationService.deleteNotification(notificationId);
      if (response.isSuccess) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notification = _notifications[index];
          _notifications.removeAt(index);
          
          // Update counts if notification was unread
          if (notification.isUnread) {
            _totalUnreadCount = (_totalUnreadCount - 1).clamp(0, double.infinity).toInt();
            final typeKey = notification.notificationType.value;
            _unreadCounts[typeKey] = ((_unreadCounts[typeKey] ?? 1) - 1).clamp(0, double.infinity).toInt();
            _unreadCountStreamController.add(_totalUnreadCount);
          }
        }
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete notification: ${e.toString()}');
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
      final request = BusArrivalNotificationRequest(
        busId: busId,
        stopId: stopId,
        minutesBefore: minutesBefore,
      );

      final response = await _notificationService.scheduleArrivalNotification(request);
      if (response.isSuccess && response.data != null) {
        // Add to notifications list
        _notifications.insert(0, response.data!);
        _clearError();
      } else {
        _setError(response.message);
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
      final response = await _notificationService.getDeviceTokens();
      if (response.isSuccess && response.data != null) {
        _deviceTokens = response.data!.results;
        _clearError();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to load device tokens: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Deactivate device token
  Future<void> deactivateDeviceToken(String tokenId) async {
    try {
      final response = await _notificationService.deactivateDeviceToken(tokenId);
      if (response.isSuccess && response.data != null) {
        final index = _deviceTokens.indexWhere((t) => t.id == tokenId);
        if (index != -1) {
          _deviceTokens[index] = response.data!;
        }
        _clearError();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to deactivate device token: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Delete device token
  Future<void> deleteDeviceToken(String tokenId) async {
    try {
      final response = await _notificationService.deleteDeviceToken(tokenId);
      if (response.isSuccess) {
        _deviceTokens.removeWhere((t) => t.id == tokenId);
        if (_currentDeviceToken?.id == tokenId) {
          _currentDeviceToken = null;
        }
        _clearError();
      } else {
        _setError(response.message);
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
      final response = await _notificationService.getNotificationPreferences();
      if (response.isSuccess && response.data != null) {
        _notificationPreferences = response.data!.results;
        
        // Build preferences map by type
        _preferencesByType.clear();
        for (final preference in _notificationPreferences) {
          _preferencesByType[preference.notificationType] = preference;
        }
        
        _clearError();
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to load notification preferences: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Update notification preference
  Future<void> updateNotificationPreference({
    required NotificationType type,
    bool? enabled,
    List<NotificationChannel>? channels,
    int? minutesBefore,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) async {
    try {
      final request = NotificationPreferenceUpdateRequest(
        notificationType: type,
        enabled: enabled,
        channels: channels,
        minutesBeforeArrival: minutesBefore,
        quietHoursStart: quietHoursStart,
        quietHoursEnd: quietHoursEnd,
      );

      final existingPreference = _preferencesByType[type];
      ApiResponse<NotificationPreference> response;

      if (existingPreference != null) {
        response = await _notificationService.updateNotificationPreference(
          existingPreference.id,
          request,
        );
      } else {
        response = await _notificationService.createNotificationPreference(request);
      }

      if (response.isSuccess && response.data != null) {
        final preference = response.data!;
        
        // Update preferences list
        if (existingPreference != null) {
          final index = _notificationPreferences.indexWhere((p) => p.id == existingPreference.id);
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
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to update notification preference: ${e.toString()}');
    }
    notifyListeners();
  }

  /// Get preference for notification type
  NotificationPreference? getPreferenceForType(NotificationType type) {
    return _preferencesByType[type];
  }

  /// Check if notifications are enabled for type
  bool isEnabledForType(NotificationType type) {
    final preference = _preferencesByType[type];
    return preference?.enabled ?? true;
  }

  /// Check if channel is enabled for type
  bool isChannelEnabledForType(NotificationType type, NotificationChannel channel) {
    final preference = _preferencesByType[type];
    return preference?.channels.contains(channel) ?? true;
  }

  // ==================== Helper Methods ====================

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.notificationType == type).toList();
  }

  /// Get unread count for type
  int getUnreadCountForType(NotificationType type) {
    return _unreadCounts[type.value] ?? 0;
  }

  /// Filter notifications
  List<AppNotification> filterNotifications({
    NotificationType? type,
    NotificationChannel? channel,
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
      final request = DeviceTokenCreateRequest(
        token: token,
        deviceType: DeviceType.fromValue(deviceType),
      );

      final response = await _notificationService.registerDeviceToken(request);
      if (response.isSuccess) {
        _currentDeviceToken = response.data;
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

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _notificationStreamController.close();
    _unreadCountStreamController.close();
    super.dispose();
  }
}