// lib/models/profile_model.dart

/// Profile data model based on API schema
class Profile {
  final String id;
  final String? avatar;
  final String? bio;
  final Language language;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    this.avatar,
    this.bio,
    required this.language,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.smsNotificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      language: Language.fromString(json['language'] as String? ?? 'fr'),
      pushNotificationsEnabled:
          json['push_notifications_enabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['email_notifications_enabled'] as bool? ?? true,
      smsNotificationsEnabled:
          json['sms_notifications_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatar': avatar,
      'bio': bio,
      'language': language.value,
      'push_notifications_enabled': pushNotificationsEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'sms_notifications_enabled': smsNotificationsEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? avatar,
    String? bio,
    Language? language,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
  }) {
    return Profile(
      id: id,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      language: language ?? this.language,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Profile(id: $id, language: $language)';
  }
}

/// Language enumeration based on API schema
enum Language {
  french('fr'),
  arabic('ar'),
  english('en');

  const Language(this.value);
  final String value;

  static Language fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fr':
        return Language.french;
      case 'ar':
        return Language.arabic;
      case 'en':
        return Language.english;
      default:
        return Language.french; // Default fallback
    }
  }

  String get displayName {
    switch (this) {
      case Language.french:
        return 'Français';
      case Language.arabic:
        return 'العربية';
      case Language.english:
        return 'English';
    }
  }

  @override
  String toString() => value;
}

/// Profile creation/update request model
class ProfileRequest {
  final String? avatar;
  final String? bio;
  final Language? language;
  final bool? pushNotificationsEnabled;
  final bool? emailNotificationsEnabled;
  final bool? smsNotificationsEnabled;

  const ProfileRequest({
    this.avatar,
    this.bio,
    this.language,
    this.pushNotificationsEnabled,
    this.emailNotificationsEnabled,
    this.smsNotificationsEnabled,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (avatar != null) json['avatar'] = avatar;
    if (bio != null) json['bio'] = bio;
    if (language != null) json['language'] = language!.value;
    if (pushNotificationsEnabled != null)
      json['push_notifications_enabled'] = pushNotificationsEnabled;
    if (emailNotificationsEnabled != null)
      json['email_notifications_enabled'] = emailNotificationsEnabled;
    if (smsNotificationsEnabled != null)
      json['sms_notifications_enabled'] = smsNotificationsEnabled;
    return json;
  }
}

/// Profile update request for notification preferences
class NotificationPreferencesRequest {
  final bool? pushNotificationsEnabled;
  final bool? emailNotificationsEnabled;
  final bool? smsNotificationsEnabled;

  const NotificationPreferencesRequest({
    this.pushNotificationsEnabled,
    this.emailNotificationsEnabled,
    this.smsNotificationsEnabled,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (pushNotificationsEnabled != null)
      json['push_notifications_enabled'] = pushNotificationsEnabled;
    if (emailNotificationsEnabled != null)
      json['email_notifications_enabled'] = emailNotificationsEnabled;
    if (smsNotificationsEnabled != null)
      json['sms_notifications_enabled'] = smsNotificationsEnabled;
    return json;
  }
}
