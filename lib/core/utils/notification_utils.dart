// lib/core/utils/notification_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtils {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // Initialize notifications
  static Future<bool> setupNotifications() async {
    if (_isInitialized) {
      return true;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    _isInitialized = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    ) ?? false;

    return _isInitialized;
  }

  // Show a local notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    if (!_isInitialized) {
      await setupNotifications();
    }

    notificationDetails ??= _defaultNotificationDetails();

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show a scheduled notification
  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    if (!_isInitialized) {
      await setupNotifications();
    }

    notificationDetails ??= _defaultNotificationDetails();

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate.isUtc
          ? scheduledDate
          : scheduledDate.subtract(scheduledDate.timeZoneOffset),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel a notification
  static Future<void> cancelNotification(int id) async {
    if (!_isInitialized) {
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      return;
    }

    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Default notification details
  static NotificationDetails _defaultNotificationDetails() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'dz_bus_tracker_channel',
      'DZ Bus Tracker Notifications',
      channelDescription: 'Notifications from DZ Bus Tracker app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  // Handle notification selection
  static void _onSelectNotification(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
      // Handle notification tap
    }
  }

  // Handle iOS notification when app is in foreground
  static void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    debugPrint('Notification received: id=$id, title=$title, body=$body, payload=$payload');
    // Handle notification when app is in foreground
  }
}