/// lib/data/models/user_model.dart
///
/// Model mirrors the backend `User` schema using Freezed + json_serializable.
/// Compatible with Dart ≥3 and Freezed ≥2.4.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/enums/language.dart';   // Language enum
import '../../core/enums/user_type.dart'; // UserType enum

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  /// Empty private ctor ─ enables custom methods without breaking Freezed
  const UserModel._();

  /// Primary factory that delegates to the generated `_UserModel` class.
  /// Keep at least **one** factory or the compiler will complain.
  const factory UserModel({
    /// Unique identifier (UUID). Maps to `id`.
    required String id,

    /// E‑mail address. Maps to `email`.
    required String email,

    /// First name → `first_name` (nullable).
    @JsonKey(name: 'first_name') String? firstName,

    /// Last name → `last_name` (nullable).
    @JsonKey(name: 'last_name') String? lastName,

    /// Phone number → `phone_number` (nullable).
    @JsonKey(name: 'phone_number') String? phoneNumber,

    /// User role → `user_type`. Unknown values fall back to `.unknown`.
    @JsonKey(name: 'user_type', unknownEnumValue: UserType.unknown)
    required UserType userType,

    /// Preferred UI language. Unknown values default to French.
    @JsonKey(unknownEnumValue: Language.fr)
    required Language language,

    /// Account is active → `is_active`.
    @JsonKey(name: 'is_active') required bool isActive,

    /// E‑mail verified flag → `is_email_verified`.
    @JsonKey(name: 'is_email_verified') required bool isEmailVerified,

    /// Phone verified flag → `is_phone_verified`.
    @JsonKey(name: 'is_phone_verified') required bool isPhoneVerified,

    /// Creation timestamp → `date_joined` (read‑only).
    @JsonKey(name: 'date_joined') required DateTime dateJoined,

    /// Last login timestamp → `last_login` (nullable, read‑only).
    @JsonKey(name: 'last_login') DateTime? lastLogin,
  }) = _UserModel;

  /// JSON factory → delegates to the code‑generated helper.
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
