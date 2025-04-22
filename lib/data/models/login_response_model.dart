/// lib/data/models/login_response_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart'; // Import UserModel

part 'login_response_model.freezed.dart';
part 'login_response_model.g.dart';

/// Data Transfer Object (DTO) representing the successful response from the login endpoint.
/// Contains the access and refresh JWT tokens, and potentially user details.
/// Mirrors the backend API's `TokenRefresh` schema plus optional user data.
@freezed
class LoginResponseModel with _$LoginResponseModel {
  const factory LoginResponseModel({
    /// The JWT access token used for authenticating subsequent requests. Matches API 'access'. Required.
    required String access,

    /// The JWT refresh token used to obtain new access tokens when the current one expires. Matches API 'refresh'. Required.
    required String refresh,

    /// Optional: User details returned directly upon login by some backends.
    UserModel? user,

  }) = _LoginResponseModel;

  /// Creates a LoginResponseModel instance from a JSON map.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
}