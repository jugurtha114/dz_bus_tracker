/// lib/core/services/notification_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For Platform check

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb, @pragma
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // Used in scheduleETANotification
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../exceptions/app_exceptions.dart'; // Import custom exceptions
import '../utils/logger.dart';

/// Data class representing a notification received or interacted with by the user.
class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final Map<String, dynamic>? payload;

  ReceivedNotification({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });

  @override
  String toString() {
    return 'ReceivedNotification(id: $id, title: $title, body: $body, payload: $payload)';
  }
}

/// Top-level function required for Firebase background message handling.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(); // Usually only needed if accessing other Firebase services here
  Log.i("Handling a background message: ${message.messageId}");
}


/// Abstract interface for handling push and local notifications.
abstract class NotificationService {
  Future<void> initialize();
  Future<String?> getFcmToken();
  Stream<ReceivedNotification> get notificationStream;
  Future<void> checkInitialMessage();
  Future<bool> requestPermission();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<void> triggerBackendTokenUpdate(String token);
  Future<String?> scheduleETANotification({
    required String stopId,
    required String stopName,
    required String lineId,
    required String lineName,
    required String busId,
    required String busMatricule,
    required DateTime estimatedArrivalTime,
    required int minutesBefore,
  });
  Future<void> cancelNotification(String notificationId);
  Future<void> cancelAllNotifications();
  void dispose();
}


/// Implementation of [NotificationService] using Firebase Cloud Messaging (FCM)
/// and Flutter Local Notifications.
class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  final BehaviorSubject<ReceivedNotification> _notificationSubject = BehaviorSubject<ReceivedNotification>();

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'dz_bus_tracker_channel_01',
    'DZ Bus Tracker Alerts',
    description: 'Notifications for bus arrivals, delays, and updates.',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
  );

  NotificationServiceImpl({
    required FirebaseMessaging firebaseMessaging,
    required FlutterLocalNotificationsPlugin localNotifications,
  }) : _firebaseMessaging = firebaseMessaging,
        _localNotifications = localNotifications;

  @override
  Stream<ReceivedNotification> get notificationStream => _notificationSubject.stream;

  @override
  Future<void> initialize() async {
    Log.i('Initializing NotificationService...');
    try {
      if (!kIsWeb) {
        tz.initializeTimeZones();
      }
      await requestPermission();
      await _initializeLocalNotifications();

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage, onError: (error, stackTrace) { // CORRECTED: Use named args
        Log.e('Error in onMessage listener', error: error, stackTrace: stackTrace);
      });
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp, onError: (error, stackTrace) { // CORRECTED: Use named args
        Log.e('Error in onMessageOpenedApp listener', error: error, stackTrace: stackTrace);
      });
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      Log.i('NotificationService initialized successfully.');

    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Failed to initialize NotificationService', error: e, stackTrace: stackTrace);
      // CORRECTED: Throw correctly defined exception
      throw NotificationException(message: 'Failed to initialize notifications.', details: e);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // CORRECTED: Removed onDidReceiveLocalNotification parameter as it's for older iOS
      // onDidReceiveLocalNotification: _onDidReceiveOldIOSLocalNotification,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveLocalNotificationResponse,
    );
    Log.d('Local notifications initialized.');
  }


  @override
  Future<bool> requestPermission() async {
    Log.d('Requesting notification permissions...');
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true, announcement: false, badge: true, carPlay: false,
        criticalAlert: false, provisional: false, sound: true,
      );
      Log.i('Notification permission status: ${settings.authorizationStatus}');
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Error requesting notification permission', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<String?> getFcmToken() async {
    try {
      String? apnsToken = kIsWeb ? null : (Platform.isIOS || Platform.isMacOS) ? await _firebaseMessaging.getAPNSToken() : null;
      if (apnsToken != null || !kIsWeb && (Platform.isAndroid || Platform.isLinux || Platform.isWindows)) {
        final token = await _firebaseMessaging.getToken();
        Log.i('FCM Token retrieved: ${token ?? 'null'}');
        return token;
      } else if (kIsWeb) {
        final token = await _firebaseMessaging.getToken();
        Log.i('FCM Token retrieved (Web): ${token ?? 'null'}');
        return token;
      } else {
        Log.w('Could not get APNS token on iOS/MacOS, FCM token might not be available yet.');
        return null;
      }
    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Failed to get FCM token', error: e, stackTrace: stackTrace);
      // CORRECTED: Throw correctly defined exception
      throw NotificationException(message: 'Failed to retrieve FCM token.', details: e);
    }
  }

  @override
  Future<void> triggerBackendTokenUpdate(String token) async {
    Log.d('Triggering backend update for FCM token (placeholder). Token: $token');
    print("TODO: Implement backend call to update FCM token.");
  }

  void _handleForegroundMessage(RemoteMessage message) {
    Log.i('Foreground message received: ${message.messageId}');
    final notification = message.notification;
    if (notification != null) {
      Log.d('Foreground Notification: ${notification.title} / ${notification.body}');
      _showLocalNotification(
        id: notification.hashCode,
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );
    } else { Log.w('Foreground message received without notification object. Data: ${message.data}'); }
    _notificationSubject.add( ReceivedNotification( id: message.hashCode, title: notification?.title, body: notification?.body, payload: message.data, ), );
  }

  void _handleNotificationOpenedApp(RemoteMessage message) {
    Log.i('Notification caused app to open: ${message.messageId}');
    _notificationSubject.add( ReceivedNotification( id: message.hashCode, title: message.notification?.title, body: message.notification?.body, payload: message.data, ), );
  }

  void _onDidReceiveLocalNotificationResponse(NotificationResponse response) {
    Log.i('Local notification tapped. ID: ${response.id}, Payload: ${response.payload}');
    Map<String, dynamic>? payloadMap;
    if (response.payload != null && response.payload!.isNotEmpty) {
      try { payloadMap = jsonDecode(response.payload!) as Map<String, dynamic>; }
      catch (e) { Log.e('Error decoding local notification payload', error: e); } // CORRECTED: Use named args
    }
    _notificationSubject.add( ReceivedNotification( id: response.id ?? 0, payload: payloadMap, ), );
  }

  // Callback for older iOS versions (foreground notification). Not passed to initialize anymore.
  void _onDidReceiveOldIOSLocalNotification(int id, String? title, String? body, String? payload) {
    Log.i('Foreground notification received on older iOS (Handler NOT active). ID: $id');
    // This function remains defined but is not actively used by the current initialize setup.
  }

  Future<void> _showLocalNotification({ required int id, required String title, required String body, String? payload, }) async {
    final androidDetails = AndroidNotificationDetails( _androidChannel.id, _androidChannel.name, channelDescription: _androidChannel.description, importance: _androidChannel.importance, priority: Priority.high, ticker: 'ticker', );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails( presentAlert: true, presentBadge: true, presentSound: true, );
    final NotificationDetails platformChannelSpecifics = NotificationDetails( android: androidDetails, iOS: iosDetails, );
    try {
      await _localNotifications.show( id, title, body, platformChannelSpecifics, payload: payload, );
      Log.d('Local notification shown. ID: $id');
    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Failed to show local notification', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Log.i('App launched from terminated state via notification: ${initialMessage.messageId}');
      _handleNotificationOpenedApp(initialMessage);
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    final sanitizedTopic = _sanitizeTopic(topic);
    try {
      await _firebaseMessaging.subscribeToTopic(sanitizedTopic);
      Log.i('Subscribed to topic: $sanitizedTopic');
    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Failed to subscribe to topic: $sanitizedTopic', error: e, stackTrace: stackTrace);
      throw NotificationException(message: 'Failed to subscribe to topic $sanitizedTopic', details: e);
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    final sanitizedTopic = _sanitizeTopic(topic);
    try {
      await _firebaseMessaging.unsubscribeFromTopic(sanitizedTopic);
      Log.i('Unsubscribed from topic: $sanitizedTopic');
    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Failed to unsubscribe from topic: $sanitizedTopic', error: e, stackTrace: stackTrace);
      throw NotificationException(message: 'Failed to unsubscribe from topic $sanitizedTopic', details: e);
    }
  }

  String _sanitizeTopic(String topic) {
    final sanitized = topic.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');
    if (sanitized != topic) { Log.w('Sanitized topic name from "$topic" to "$sanitized"'); }
    return sanitized;
  }

  @override
  Future<String?> scheduleETANotification({ required String stopId, required String stopName, required String lineId, required String lineName, required String busId, required String busMatricule, required DateTime estimatedArrivalTime, required int minutesBefore, }) async {
    if (kIsWeb) { Log.w('Scheduling local notifications is not supported on Web.'); return null; }
    try {
      final notificationTime = estimatedArrivalTime.subtract(Duration(minutes: minutesBefore));
      final now = DateTime.now();
      if (notificationTime.isBefore(now)) { Log.w('Cannot schedule ETA notification for a time in the past ($notificationTime). ETA: $estimatedArrivalTime'); return null; }
      final notificationId = '${stopId}_${lineId}_${busId}_${estimatedArrivalTime.millisecondsSinceEpoch}'.hashCode;
      final payload = jsonEncode({ 'type': 'eta_arrival', 'stopId': stopId, 'stopName': stopName, 'lineId': lineId, 'lineName': lineName, 'busId': busId, 'busMatricule': busMatricule, 'estimatedArrivalTime': estimatedArrivalTime.toIso8601String(), 'scheduledTime': notificationTime.toIso8601String(), });
      final title = 'Bus Approaching: $lineName'; // TODO: Localize
      final body = 'Bus $busMatricule is expected at $stopName in $minutesBefore minutes (${DateFormat.Hm().format(estimatedArrivalTime)}).'; // TODO: Localize
      final scheduledDateTime = tz.TZDateTime.from(notificationTime, tz.local);
      final androidDetails = AndroidNotificationDetails( _androidChannel.id, _androidChannel.name, channelDescription: _androidChannel.description, importance: _androidChannel.importance, priority: Priority.high, ticker: 'Bus ETA Alert', );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails( presentAlert: true, presentBadge: true, presentSound: true);
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.zonedSchedule(
        notificationId, title, body, scheduledDateTime, details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // CORRECTED: Removed uiLocalNotificationDateInterpretation parameter
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      Log.i('Scheduled ETA notification ID $notificationId for $scheduledDateTime');
      return notificationId.toString();
    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Failed to schedule ETA notification', error: e, stackTrace: stackTrace);
      throw NotificationException(message: 'Could not schedule ETA notification.', details: e);
    }
  }

  @override
  Future<void> cancelNotification(String notificationId) async {
    if (kIsWeb) return;
    try {
      final id = int.tryParse(notificationId);
      if (id != null) { await _localNotifications.cancel(id); Log.i('Cancelled scheduled notification: $id'); }
      else { Log.w('Invalid notification ID format for cancellation: $notificationId'); }
    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Failed to cancel notification $notificationId', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    try {
      await _localNotifications.cancelAll();
      Log.i('Cancelled all scheduled notifications.');
    } catch (e, stackTrace) { // CORRECTED: Use named args
      Log.e('Failed to cancel all notifications', error: e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    Log.d('Disposing NotificationService...');
    _notificationSubject.close();
  }
}