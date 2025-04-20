/// lib/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

import '../../core/enums/language.dart';
import '../../core/enums/user_type.dart';

/// Represents the core User entity within the application domain.
///
/// This class is independent of data layer models or presentation layer widgets.
/// It defines the essential properties of a user based on the API specification.
class UserEntity extends Equatable {
  /// Unique identifier for the user (UUID).
  final String id;

  /// User's email address. Required.
  final String email;

  /// User's first name. Optional.
  final String? firstName;

  /// User's last name. Optional.
  final String? lastName;

  /// User's phone number. Optional.
  final String? phoneNumber;

  /// The type of user (Admin, Driver, Passenger). Required.
  final UserType userType;

  /// User's preferred language setting. Required.
  final Language language;

  /// Flag indicating if the user account is active. Read-only from API model.
  final bool isActive;

  /// Flag indicating if the user's email address has been verified. Read-only from API model.
  final bool isEmailVerified;

  /// Flag indicating if the user's phone number has been verified. Read-only from API model.
  final bool isPhoneVerified;

  /// Timestamp when the user account was created. Read-only from API model.
  final DateTime dateJoined;

  /// Timestamp of the user's last login. Optional and read-only from API model.
  final DateTime? lastLogin;

  // Note: Profile picture URL and notification preferences could be added here
  // if considered fundamental domain information, or managed separately via a
  // UserProfileEntity if they have more complex logic/structure. For now, keeping it lean.
  // final String? profilePictureUrl;

  /// Creates a [UserEntity] instance.
  const UserEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.userType,
    required this.language,
    required this.isActive,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.dateJoined,
    this.lastLogin,
    // this.profilePictureUrl,
  });

  /// Returns the user's full name, concatenating first and last names.
  /// Returns an empty string if both are null or empty.
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  /// Helper getter to check if the user is an administrator.
  bool get isAdmin => userType == UserType.admin;

  /// Helper getter to check if the user is a driver.
  bool get isDriver => userType == UserType.driver;

  /// Helper getter to check if the user is a passenger.
  bool get isPassenger => userType == UserType.passenger;

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        userType,
        language,
        isActive,
        isEmailVerified,
        isPhoneVerified,
        dateJoined,
        lastLogin,
        // profilePictureUrl,
      ];

  /// Creates an empty UserEntity, useful for default states or placeholders.
  static UserEntity empty() => UserEntity(
        id: '',
        email: '',
        userType: UserType.unknown,
        language: Language.fr, // Default language
        isActive: false,
        isEmailVerified: false,
        isPhoneVerified: false,
        dateJoined: DateTime(0), // Placeholder date
      );
}

