// lib/models/user_model.dart

import 'profile_model.dart';

/// User data model based on API schema
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final UserType userType;
  final bool isActive;
  final DateTime dateJoined;
  final Profile? profile;
  
  // Additional properties for UI consistency
  final String? profileImageUrl;
  final double? rating;
  final int? totalTrips;
  final int? totalDistanceDriven;
  final int? yearsExperience;
  final DateTime? createdAt;
  
  // Admin management properties
  final DateTime? lastLoginAt;
  final double? totalSpent;
  final String? favoriteRoute;
  
  // Driver-specific properties
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? assignedBusPlate;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.userType,
    required this.isActive,
    required this.dateJoined,
    this.profile,
    this.profileImageUrl,
    this.rating,
    this.totalTrips,
    this.totalDistanceDriven,
    this.yearsExperience,
    this.createdAt,
    this.lastLoginAt,
    this.totalSpent,
    this.favoriteRoute,
    this.licenseNumber,
    this.licenseExpiry,
    this.assignedBusPlate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      userType: UserType.fromString(json['user_type'] as String),
      isActive: json['is_active'] as bool? ?? true,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'user_type': userType.value,
      'is_active': isActive,
      'date_joined': dateJoined.toIso8601String(),
      'profile': profile?.toJson(),
    };
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserType? userType,
    bool? isActive,
    Profile? profile,
  }) {
    return User(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      dateJoined: dateJoined,
      profile: profile ?? this.profile,
    );
  }

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    if (first.isEmpty && last.isEmpty) return email;
    return '$first $last'.trim();
  }

  // Convenience getter for name (alias for fullName)
  String? get name => fullName.isNotEmpty ? fullName : null;

  // Convenience getter for profile image
  String? get profileImage => profileImageUrl;
  
  // Convenience getter for role based on userType
  String get role => userType.value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, userType: $userType)';
  }
}

/// User type enumeration based on API schema
enum UserType {
  admin('admin'),
  driver('driver'),
  passenger('passenger');

  const UserType(this.value);
  final String value;

  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserType.admin;
      case 'driver':
        return UserType.driver;
      case 'passenger':
        return UserType.passenger;
      default:
        throw ArgumentError('Invalid user type: $value');
    }
  }

  @override
  String toString() => value;
}

/// User creation request model
class UserCreateRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final UserType userType;

  const UserCreateRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.userType,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'user_type': userType.value,
    };
  }
}

/// User update request model
class UserUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  const UserUpdateRequest({this.firstName, this.lastName, this.phoneNumber});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (firstName != null) json['first_name'] = firstName;
    if (lastName != null) json['last_name'] = lastName;
    if (phoneNumber != null) json['phone_number'] = phoneNumber;
    return json;
  }
}

/// Password change request model
class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}

/// Password reset request model
class PasswordResetRequest {
  final String email;

  const PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

/// Password reset confirmation model
class PasswordResetConfirmRequest {
  final String uid;
  final String token;
  final String newPassword;
  final String confirmPassword;

  const PasswordResetConfirmRequest({
    required this.uid,
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'token': token,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}
