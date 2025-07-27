// lib/models/notification_model.dart

import 'package:flutter/material.dart';

/// Device types for push notifications
enum DeviceType {
  ios('ios', 'iOS'),
  android('android', 'Android'),
  web('web', 'Web');

  const DeviceType(this.value, this.displayName);
  final String value;
  final String displayName;

  static DeviceType fromValue(String value) {
    return DeviceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DeviceType.android,
    );
  }
}

/// Notification types with comprehensive coverage
enum NotificationType {
  driverApproved(
    'driver_approved',
    'Driver Approved',
    Icons.check_circle,
    Colors.green,
  ),
  driverRejected(
    'driver_rejected',
    'Driver Rejected',
    Icons.cancel,
    Colors.red,
  ),
  busArriving(
    'bus_arriving',
    'Bus Arriving',
    Icons.directions_bus,
    Colors.blue,
  ),
  busDelayed('bus_delayed', 'Bus Delayed', Icons.schedule, Colors.orange),
  busCancelled('bus_cancelled', 'Bus Cancelled', Icons.cancel, Colors.red),
  system('system', 'System', Icons.info, Colors.grey),
  arrival('arrival', 'Bus Arrival', Icons.location_on, Colors.green),
  routeChange('route_change', 'Route Change', Icons.route, Colors.orange),
  seatAvailability(
    'seat_availability',
    'Seat Availability',
    Icons.event_seat,
    Colors.blue,
  ),
  tripStart('trip_start', 'Trip Started', Icons.play_arrow, Colors.green),
  tripEnd('trip_end', 'Trip Ended', Icons.stop, Colors.red),
  achievement('achievement', 'Achievement Unlocked', Icons.star, Colors.amber),
  reward('reward', 'Reward Earned', Icons.card_giftcard, Colors.purple),
  tripUpdate('trip_update', 'Trip Update', Icons.update, Colors.blue);

  const NotificationType(this.value, this.displayName, this.icon, this.color);
  final String value;
  final String displayName;
  final IconData icon;
  final Color color;

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }

  bool get isTransport => [
    NotificationType.busArriving,
    NotificationType.busDelayed,
    NotificationType.busCancelled,
    NotificationType.arrival,
    NotificationType.routeChange,
    NotificationType.seatAvailability,
  ].contains(this);

  bool get isTrip => [
    NotificationType.tripStart,
    NotificationType.tripEnd,
    NotificationType.tripUpdate,
  ].contains(this);

  bool get isGamification =>
      [NotificationType.achievement, NotificationType.reward].contains(this);

  bool get isAdmin => [
    NotificationType.driverApproved,
    NotificationType.driverRejected,
    NotificationType.system,
  ].contains(this);

  bool get isImportant => [
    NotificationType.driverApproved,
    NotificationType.driverRejected,
    NotificationType.busArriving,
    NotificationType.busDelayed,
    NotificationType.busCancelled,
    NotificationType.system,
  ].contains(this);
}

/// Notification channels
enum NotificationChannel {
  push('push', 'Push Notification', Icons.notifications),
  sms('sms', 'SMS', Icons.sms),
  email('email', 'Email', Icons.email),
  inApp('in_app', 'In-App', Icons.app_registration);

  const NotificationChannel(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final IconData icon;

  static NotificationChannel fromValue(String value) {
    return NotificationChannel.values.firstWhere(
      (channel) => channel.value == value,
      orElse: () => NotificationChannel.push,
    );
  }
}

/// User type enum for notifications
enum UserType {
  admin('admin', 'Admin'),
  driver('driver', 'Driver'),
  passenger('passenger', 'Passenger');

  const UserType(this.value, this.displayName);
  final String value;
  final String displayName;

  static UserType fromValue(String value) {
    return UserType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => UserType.passenger,
    );
  }
}

/// Device token model for push notifications
class DeviceToken {
  final String id;
  final String token;
  final DeviceType deviceType;
  final bool isActive;
  final DateTime lastUsed;
  final DateTime createdAt;

  const DeviceToken({
    required this.id,
    required this.token,
    required this.deviceType,
    required this.isActive,
    required this.lastUsed,
    required this.createdAt,
  });

  factory DeviceToken.fromJson(Map<String, dynamic> json) {
    return DeviceToken(
      id: json['id'] as String,
      token: json['token'] as String,
      deviceType: DeviceType.fromValue(json['device_type'] as String),
      isActive: json['is_active'] as bool? ?? true,
      lastUsed: DateTime.parse(json['last_used'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'device_type': deviceType.value,
      'is_active': isActive,
      'last_used': lastUsed.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  String get formattedLastUsed =>
      '${lastUsed.day}/${lastUsed.month}/${lastUsed.year}';
  String get formattedCreatedAt =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';

  bool get isRecent => DateTime.now().difference(lastUsed).inDays < 7;
  String get statusText => isActive ? 'Active' : 'Inactive';
  Color get statusColor => isActive ? Colors.green : Colors.grey;

  DeviceToken copyWith({
    String? id,
    String? token,
    DeviceType? deviceType,
    bool? isActive,
    DateTime? lastUsed,
    DateTime? createdAt,
  }) {
    return DeviceToken(
      id: id ?? this.id,
      token: token ?? this.token,
      deviceType: deviceType ?? this.deviceType,
      isActive: isActive ?? this.isActive,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// User brief model for notifications
class UserBrief {
  final String id;
  final String email;
  final String fullName;
  final UserType? userType;

  const UserBrief({
    required this.id,
    required this.email,
    required this.fullName,
    this.userType,
  });

  factory UserBrief.fromJson(Map<String, dynamic> json) {
    return UserBrief(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      userType: json['user_type'] != null
          ? UserType.fromValue(json['user_type'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'user_type': userType?.value,
    };
  }
}

/// Notification model
class AppNotification {
  final String id;
  final UserBrief user;
  final NotificationType notificationType;
  final String title;
  final String message;
  final NotificationChannel channel;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.user,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.channel,
    required this.isRead,
    this.readAt,
    this.data,
    required this.createdAt,
  });

  /// Convenience getter for type
  String get type => notificationType.value;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      user: UserBrief.fromJson(json['user'] as Map<String, dynamic>),
      notificationType: NotificationType.fromValue(
        json['notification_type'] as String,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      channel: NotificationChannel.fromValue(json['channel'] as String),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'notification_type': notificationType.value,
      'title': title,
      'message': message,
      'channel': channel.value,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  IconData get typeIcon => notificationType.icon;
  Color get typeColor => notificationType.color;
  String get typeDisplayName => notificationType.displayName;

  String get channelDisplayName => channel.displayName;
  IconData get channelIcon => channel.icon;

  String get formattedCreatedAt =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedTime =>
      '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  String get formattedDateTime => '$formattedCreatedAt $formattedTime';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formattedCreatedAt;
    }
  }

  bool get isUnread => !isRead;
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;
  bool get hasData => data != null && data!.isNotEmpty;

  String get priority {
    switch (notificationType) {
      case NotificationType.busCancelled:
      case NotificationType.busDelayed:
      case NotificationType.driverRejected:
        return 'High';
      case NotificationType.busArriving:
      case NotificationType.arrival:
      case NotificationType.routeChange:
      case NotificationType.driverApproved:
        return 'Medium';
      default:
        return 'Low';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  AppNotification copyWith({
    String? id,
    UserBrief? user,
    NotificationType? notificationType,
    String? title,
    String? message,
    NotificationChannel? channel,
    bool? isRead,
    DateTime? readAt,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      user: user ?? this.user,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      channel: channel ?? this.channel,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Stop brief model
class StopBrief {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const StopBrief({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory StopBrief.fromJson(Map<String, dynamic> json) {
    return StopBrief(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
  }
}

/// Line brief model
class LineBrief {
  final String id;
  final String name;
  final String code;
  final bool isActive;

  const LineBrief({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  factory LineBrief.fromJson(Map<String, dynamic> json) {
    return LineBrief(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'is_active': isActive};
  }
}

/// Notification preference model
class NotificationPreference {
  final String id;
  final NotificationType notificationType;
  final List<NotificationChannel> channels;
  final bool enabled;
  final int? minutesBeforeArrival;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;
  final List<StopBrief> favoriteStops;
  final List<LineBrief> favoriteLines;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationPreference({
    required this.id,
    required this.notificationType,
    required this.channels,
    required this.enabled,
    this.minutesBeforeArrival,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.favoriteStops,
    required this.favoriteLines,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: json['id'] as String,
      notificationType: NotificationType.fromValue(
        json['notification_type'] as String,
      ),
      channels:
          (json['channels'] as List<dynamic>?)
              ?.map(
                (channel) => NotificationChannel.fromValue(channel as String),
              )
              .toList() ??
          [],
      enabled: json['enabled'] as bool? ?? true,
      minutesBeforeArrival: json['minutes_before_arrival'] as int?,
      quietHoursStart: json['quiet_hours_start'] != null
          ? _parseTimeOfDay(json['quiet_hours_start'] as String)
          : null,
      quietHoursEnd: json['quiet_hours_end'] != null
          ? _parseTimeOfDay(json['quiet_hours_end'] as String)
          : null,
      favoriteStops:
          (json['favorite_stops'] as List<dynamic>?)
              ?.map((stop) => StopBrief.fromJson(stop as Map<String, dynamic>))
              .toList() ??
          [],
      favoriteLines:
          (json['favorite_lines'] as List<dynamic>?)
              ?.map((line) => LineBrief.fromJson(line as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType.value,
      'channels': channels.map((channel) => channel.value).toList(),
      'enabled': enabled,
      'minutes_before_arrival': minutesBeforeArrival,
      'quiet_hours_start': quietHoursStart != null
          ? '${quietHoursStart!.hour.toString().padLeft(2, '0')}:${quietHoursStart!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'quiet_hours_end': quietHoursEnd != null
          ? '${quietHoursEnd!.hour.toString().padLeft(2, '0')}:${quietHoursEnd!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'favorite_stops': favoriteStops.map((stop) => stop.toJson()).toList(),
      'favorite_lines': favoriteLines.map((line) => line.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Helper getters
  String get channelsDisplayText =>
      channels.map((c) => c.displayName).join(', ');

  bool get hasPushNotification => channels.contains(NotificationChannel.push);
  bool get hasSmsNotification => channels.contains(NotificationChannel.sms);
  bool get hasEmailNotification => channels.contains(NotificationChannel.email);
  bool get hasInAppNotification => channels.contains(NotificationChannel.inApp);

  bool get hasQuietHours => quietHoursStart != null && quietHoursEnd != null;
  String get quietHoursText => hasQuietHours
      ? '${_formatTimeOfDay(quietHoursStart!)} - ${_formatTimeOfDay(quietHoursEnd!)}'
      : 'None';

  String get arrivalNotificationText => minutesBeforeArrival != null
      ? '$minutesBeforeArrival minutes before'
      : 'Default';

  bool get hasFavorites => favoriteStops.isNotEmpty || favoriteLines.isNotEmpty;
  String get favoritesText =>
      '${favoriteStops.length} stops, ${favoriteLines.length} lines';

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  NotificationPreference copyWith({
    String? id,
    NotificationType? notificationType,
    List<NotificationChannel>? channels,
    bool? enabled,
    int? minutesBeforeArrival,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    List<StopBrief>? favoriteStops,
    List<LineBrief>? favoriteLines,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      channels: channels ?? this.channels,
      enabled: enabled ?? this.enabled,
      minutesBeforeArrival: minutesBeforeArrival ?? this.minutesBeforeArrival,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      favoriteStops: favoriteStops ?? this.favoriteStops,
      favoriteLines: favoriteLines ?? this.favoriteLines,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Request models for API operations

class DeviceTokenCreateRequest {
  final String token;
  final DeviceType deviceType;

  const DeviceTokenCreateRequest({
    required this.token,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {'token': token, 'device_type': deviceType.value};
  }
}

class DeviceTokenUpdateRequest {
  final String? token;
  final DeviceType? deviceType;
  final bool? isActive;

  const DeviceTokenUpdateRequest({this.token, this.deviceType, this.isActive});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (token != null) json['token'] = token;
    if (deviceType != null) json['device_type'] = deviceType!.value;
    if (isActive != null) json['is_active'] = isActive;
    return json;
  }
}

class NotificationCreateRequest {
  final NotificationType notificationType;
  final String title;
  final String message;
  final NotificationChannel channel;
  final Map<String, dynamic>? data;

  const NotificationCreateRequest({
    required this.notificationType,
    required this.title,
    required this.message,
    required this.channel,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'notification_type': notificationType.value,
      'title': title,
      'message': message,
      'channel': channel.value,
      if (data != null) 'data': data,
    };
  }
}

class NotificationPreferenceUpdateRequest {
  final NotificationType? notificationType;
  final List<NotificationChannel>? channels;
  final bool? enabled;
  final int? minutesBeforeArrival;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  const NotificationPreferenceUpdateRequest({
    this.notificationType,
    this.channels,
    this.enabled,
    this.minutesBeforeArrival,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (notificationType != null)
      json['notification_type'] = notificationType!.value;
    if (channels != null)
      json['channels'] = channels!.map((c) => c.value).toList();
    if (enabled != null) json['enabled'] = enabled;
    if (minutesBeforeArrival != null)
      json['minutes_before_arrival'] = minutesBeforeArrival;
    if (quietHoursStart != null) {
      json['quiet_hours_start'] =
          '${quietHoursStart!.hour.toString().padLeft(2, '0')}:${quietHoursStart!.minute.toString().padLeft(2, '0')}:00';
    }
    if (quietHoursEnd != null) {
      json['quiet_hours_end'] =
          '${quietHoursEnd!.hour.toString().padLeft(2, '0')}:${quietHoursEnd!.minute.toString().padLeft(2, '0')}:00';
    }
    return json;
  }
}

class BusArrivalNotificationRequest {
  final String busId;
  final String stopId;
  final int? minutesBefore;

  const BusArrivalNotificationRequest({
    required this.busId,
    required this.stopId,
    this.minutesBefore,
  });

  Map<String, dynamic> toJson() {
    return {
      'bus_id': busId,
      'stop_id': stopId,
      if (minutesBefore != null) 'minutes_before': minutesBefore,
    };
  }
}

/// Firebase Cloud Messaging data models

class FCMMessage {
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, String>? data;
  final String? clickAction;
  final String? sound;
  final String? tag;
  final String? color;
  final String? icon;

  const FCMMessage({
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    this.clickAction,
    this.sound,
    this.tag,
    this.color,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'notification': {
        'title': title,
        'body': body,
        if (imageUrl != null) 'image': imageUrl,
        if (clickAction != null) 'click_action': clickAction,
        if (sound != null) 'sound': sound,
        if (tag != null) 'tag': tag,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
      },
      if (data != null) 'data': data,
    };
  }
}

class FCMNotificationData {
  final String notificationId;
  final NotificationType type;
  final String? busId;
  final String? stopId;
  final String? lineId;
  final String? tripId;
  final String? route;
  final Map<String, dynamic>? extra;

  const FCMNotificationData({
    required this.notificationId,
    required this.type,
    this.busId,
    this.stopId,
    this.lineId,
    this.tripId,
    this.route,
    this.extra,
  });

  Map<String, String> toStringMap() {
    final map = <String, String>{
      'notification_id': notificationId,
      'type': type.value,
    };

    if (busId != null) map['bus_id'] = busId!;
    if (stopId != null) map['stop_id'] = stopId!;
    if (lineId != null) map['line_id'] = lineId!;
    if (tripId != null) map['trip_id'] = tripId!;
    if (route != null) map['route'] = route!;

    if (extra != null) {
      extra!.forEach((key, value) {
        map[key] = value.toString();
      });
    }

    return map;
  }

  factory FCMNotificationData.fromStringMap(Map<String, String> map) {
    return FCMNotificationData(
      notificationId: map['notification_id'] ?? '',
      type: NotificationType.fromValue(map['type'] ?? 'system'),
      busId: map['bus_id'],
      stopId: map['stop_id'],
      lineId: map['line_id'],
      tripId: map['trip_id'],
      route: map['route'],
      extra: Map<String, dynamic>.fromEntries(
        map.entries
            .where(
              (entry) => ![
                'notification_id',
                'type',
                'bus_id',
                'stop_id',
                'line_id',
                'trip_id',
                'route',
              ].contains(entry.key),
            )
            .map((entry) => MapEntry(entry.key, entry.value)),
      ),
    );
  }
}
