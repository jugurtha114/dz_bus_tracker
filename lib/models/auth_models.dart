// lib/models/auth_models.dart

/// Authentication token response model
class AuthTokenResponse {
  final String accessToken;
  final String refreshToken;

  const AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
    };
  }
}

/// Login request model
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Token refresh request model
class TokenRefreshRequest {
  final String refreshToken;

  const TokenRefreshRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refresh': refreshToken};
  }
}

/// Token verification request model
class TokenVerifyRequest {
  final String token;

  const TokenVerifyRequest({required this.token});

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}

/// Driver registration request model
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

/// Auth response wrapper for consistent API handling
class AuthResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  const AuthResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  factory AuthResponse.success(T data, {String? message}) {
    return AuthResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory AuthResponse.failure(String message, {Map<String, dynamic>? errors}) {
    return AuthResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }
}

/// Authentication state model
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? refreshToken;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.refreshToken,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? refreshToken,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      error: error,
    );
  }

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, isLoading: $isLoading, hasToken: ${token != null})';
  }
}