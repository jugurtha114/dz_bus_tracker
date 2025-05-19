// lib/core/constants/error_constants.dart

class ErrorConstants {
  // Network errors
  static const String connectionError = 'Cannot connect to the server. Please check your internet connection.';
  static const String timeoutError = 'The connection has timed out. Please try again.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred. Please try again.';

  // Authentication errors
  static const String invalidCredentials = 'Invalid email or password.';
  static const String unauthorized = 'You are not authorized to perform this action.';
  static const String sessionExpired = 'Your session has expired. Please log in again.';

  // Validation errors
  static const String requiredField = 'This field is required.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String passwordTooShort = 'Password must be at least 8 characters long.';

  // Permission errors
  static const String locationPermissionDenied = 'Location permission is required to use this feature.';
  static const String cameraPermissionDenied = 'Camera permission is required to use this feature.';
  static const String storagePermissionDenied = 'Storage permission is required to use this feature.';

  // Bus and driver errors
  static const String busNotFound = 'Bus not found.';
  static const String driverNotFound = 'Driver not found.';
  static const String lineNotFound = 'Line not found.';
  static const String stopNotFound = 'Stop not found.';
  static const String busNotApproved = 'This bus has not been approved yet.';
  static const String driverNotApproved = 'This driver has not been approved yet.';

  // Tracking errors
  static const String trackingAlreadyActive = 'Tracking is already active for this bus.';
  static const String trackingNotActive = 'Tracking is not active for this bus.';
  static const String locationNotAvailable = 'Location is not available.';
}