// lib/models/driver_model.dart

import 'package:flutter/material.dart';

/// Driver status enumeration based on API schema
enum DriverStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  suspended('suspended');

  const DriverStatus(this.value);
  final String value;

  static DriverStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return DriverStatus.pending;
      case 'approved':
        return DriverStatus.approved;
      case 'rejected':
        return DriverStatus.rejected;
      case 'suspended':
        return DriverStatus.suspended;
      default:
        throw ArgumentError('Invalid driver status: $value');
    }
  }

  bool get isApproved => this == DriverStatus.approved;
  bool get isPending => this == DriverStatus.pending;
  bool get isRejected => this == DriverStatus.rejected;
  bool get isSuspended => this == DriverStatus.suspended;

  @override
  String toString() => value;
}

/// Rating enumeration for driver ratings
enum Rating {
  one(1),
  two(2),
  three(3),
  four(4),
  five(5);

  const Rating(this.value);
  final int value;

  static Rating fromInt(int value) {
    switch (value) {
      case 1:
        return Rating.one;
      case 2:
        return Rating.two;
      case 3:
        return Rating.three;
      case 4:
        return Rating.four;
      case 5:
        return Rating.five;
      default:
        throw ArgumentError('Invalid rating: $value');
    }
  }

  @override
  String toString() => value.toString();
}

/// Driver data model based on API schema
class Driver {
  final String id;
  final String user;
  final Map<String, dynamic>? userDetails;
  final String fullName;
  final String phoneNumber;
  final String idCardNumber;
  final String idCardPhoto;
  final String driverLicenseNumber;
  final String driverLicensePhoto;
  final DriverStatus status;
  final DateTime statusChangedAt;
  final String? rejectionReason;
  final int yearsOfExperience;
  final bool isActive;
  final bool isAvailable;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Driver({
    required this.id,
    required this.user,
    this.userDetails,
    required this.fullName,
    required this.phoneNumber,
    required this.idCardNumber,
    required this.idCardPhoto,
    required this.driverLicenseNumber,
    required this.driverLicensePhoto,
    required this.status,
    required this.statusChangedAt,
    this.rejectionReason,
    required this.yearsOfExperience,
    required this.isActive,
    required this.isAvailable,
    required this.rating,
    required this.totalRatings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      user: json['user'] as String,
      userDetails: json['user_details'] as Map<String, dynamic>?,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      idCardNumber: json['id_card_number'] as String,
      idCardPhoto: json['id_card_photo'] as String,
      driverLicenseNumber: json['driver_license_number'] as String,
      driverLicensePhoto: json['driver_license_photo'] as String,
      status: DriverStatus.fromString(json['status'] as String),
      statusChangedAt: DateTime.parse(json['status_changed_at'] as String),
      rejectionReason: json['rejection_reason'] as String?,
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isAvailable: json['is_available'] as bool? ?? false,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 0.0 : 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'user_details': userDetails,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'id_card_number': idCardNumber,
      'id_card_photo': idCardPhoto,
      'driver_license_number': driverLicenseNumber,
      'driver_license_photo': driverLicensePhoto,
      'status': status.value,
      'status_changed_at': statusChangedAt.toIso8601String(),
      'rejection_reason': rejectionReason,
      'years_of_experience': yearsOfExperience,
      'is_active': isActive,
      'is_available': isAvailable,
      'rating': rating.toString(),
      'total_ratings': totalRatings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Driver copyWith({
    String? user,
    Map<String, dynamic>? userDetails,
    String? fullName,
    String? phoneNumber,
    String? idCardNumber,
    String? idCardPhoto,
    String? driverLicenseNumber,
    String? driverLicensePhoto,
    DriverStatus? status,
    DateTime? statusChangedAt,
    String? rejectionReason,
    int? yearsOfExperience,
    bool? isActive,
    bool? isAvailable,
    double? rating,
    int? totalRatings,
  }) {
    return Driver(
      id: id,
      user: user ?? this.user,
      userDetails: userDetails ?? this.userDetails,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      idCardPhoto: idCardPhoto ?? this.idCardPhoto,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      driverLicensePhoto: driverLicensePhoto ?? this.driverLicensePhoto,
      status: status ?? this.status,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Get the user's email from user details
  String get userEmail {
    if (userDetails != null && userDetails!.containsKey('email')) {
      return userDetails!['email'] as String;
    }
    return '';
  }

  /// Get rounded rating for display
  int get roundedRating => rating.round();

  /// Get experience level description
  String get experienceLevel {
    if (yearsOfExperience < 1) return 'New Driver';
    if (yearsOfExperience < 3) return 'Beginner';
    if (yearsOfExperience < 5) return 'Experienced';
    if (yearsOfExperience < 10) return 'Professional';
    return 'Expert';
  }

  /// Check if driver can be activated
  bool get canBeActivated => status.isApproved && !isActive;

  /// Check if driver is operational
  bool get isOperational => isActive && status.isApproved && isAvailable;

  /// Get driver initials from full name
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'D';
  }

  /// Get license number (alias for driverLicenseNumber)
  String get licenseNumber => driverLicenseNumber;

  /// Get status color for UI
  Color get statusColor {
    switch (status) {
      case DriverStatus.approved:
        return const Color(0xFF4CAF50); // Green
      case DriverStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case DriverStatus.rejected:
        return const Color(0xFFF44336); // Red
      case DriverStatus.suspended:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Driver && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Driver(id: $id, fullName: $fullName, status: $status, rating: $rating)';
  }
}

/// Driver creation request model
class DriverCreateRequest {
  final String user;
  final String phoneNumber;
  final String idCardNumber;
  final String idCardPhoto;
  final String driverLicenseNumber;
  final String driverLicensePhoto;
  final int yearsOfExperience;

  const DriverCreateRequest({
    required this.user,
    required this.phoneNumber,
    required this.idCardNumber,
    required this.idCardPhoto,
    required this.driverLicenseNumber,
    required this.driverLicensePhoto,
    required this.yearsOfExperience,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'phone_number': phoneNumber,
      'id_card_number': idCardNumber,
      'id_card_photo': idCardPhoto,
      'driver_license_number': driverLicenseNumber,
      'driver_license_photo': driverLicensePhoto,
      'years_of_experience': yearsOfExperience,
    };
  }
}

/// Driver update request model
class DriverUpdateRequest {
  final String? phoneNumber;
  final int? yearsOfExperience;
  final bool? isActive;
  final bool? isAvailable;

  const DriverUpdateRequest({
    this.phoneNumber,
    this.yearsOfExperience,
    this.isActive,
    this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (phoneNumber != null) json['phone_number'] = phoneNumber;
    if (yearsOfExperience != null) json['years_of_experience'] = yearsOfExperience;
    if (isActive != null) json['is_active'] = isActive;
    if (isAvailable != null) json['is_available'] = isAvailable;
    
    return json;
  }
}

/// Driver approval request model
class DriverApprovalRequest {
  final bool approve;
  final String? rejectionReason;

  const DriverApprovalRequest({
    required this.approve,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'approve': approve};
    if (rejectionReason != null) json['rejection_reason'] = rejectionReason;
    return json;
  }
}

/// Driver availability request model
class DriverAvailabilityRequest {
  final bool isAvailable;

  const DriverAvailabilityRequest({required this.isAvailable});

  Map<String, dynamic> toJson() {
    return {'is_available': isAvailable};
  }
}

/// Driver rating model
class DriverRating {
  final String id;
  final String driver;
  final String? user;
  final String userName;
  final Rating rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DriverRating({
    required this.id,
    required this.driver,
    this.user,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverRating.fromJson(Map<String, dynamic> json) {
    return DriverRating(
      id: json['id'] as String,
      driver: json['driver'] as String,
      user: json['user'] as String?,
      userName: json['user_name'] as String,
      rating: Rating.fromInt(json['rating'] as int),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver,
      'user': user,
      'user_name': userName,
      'rating': rating.value,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get driver name (alias for userName)
  String get driverName => userName;

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'DriverRating(id: $id, driver: $driver, rating: $rating)';
  }
}

/// Driver rating create request model
class DriverRatingCreateRequest {
  final Rating rating;
  final String? comment;

  const DriverRatingCreateRequest({
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'rating': rating.value};
    if (comment != null) json['comment'] = comment;
    return json;
  }
}

/// Driver registration request model (for initial registration)
class DriverRegistrationRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String idCardNumber;
  final dynamic idCardPhoto;
  final String driverLicenseNumber;
  final dynamic driverLicensePhoto;
  final int yearsOfExperience;

  const DriverRegistrationRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.idCardNumber,
    required this.idCardPhoto,
    required this.driverLicenseNumber,
    required this.driverLicensePhoto,
    required this.yearsOfExperience,
  });

  Map<String, String> toFormFields() {
    return {
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'id_card_number': idCardNumber,
      'driver_license_number': driverLicenseNumber,
      'years_of_experience': yearsOfExperience.toString(),
    };
  }

  Map<String, dynamic> getFiles() {
    return {
      'id_card_photo': idCardPhoto,
      'driver_license_photo': driverLicensePhoto,
    };
  }
}

/// Driver rating query parameters for filtering ratings
class DriverRatingQueryParameters {
  final String? driverId;
  final Rating? minRating;
  final Rating? maxRating;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final int? limit;
  final int? offset;

  const DriverRatingQueryParameters({
    this.driverId,
    this.minRating,
    this.maxRating,
    this.createdAfter,
    this.createdBefore,
    this.limit,
    this.offset,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (driverId != null) params['driver'] = driverId;
    if (minRating != null) params['rating__gte'] = minRating!.value;
    if (maxRating != null) params['rating__lte'] = maxRating!.value;
    if (createdAfter != null) params['created_at__gte'] = createdAfter!.toIso8601String();
    if (createdBefore != null) params['created_at__lte'] = createdBefore!.toIso8601String();
    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;
    
    return params;
  }

  Map<String, dynamic> toMap() => toQueryParams();
}