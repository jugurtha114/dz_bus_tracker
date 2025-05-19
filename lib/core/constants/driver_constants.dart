// lib/core/constants/driver_constants.dart

class DriverConstants {
  // Driver status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusSuspended = 'suspended';

  // Validation constants
  static const int minLicenseLength = 8;
  static const int minIdCardLength = 8;
  static const int minYearsOfExperience = 1;
  static const int maxYearsOfExperience = 50;

  // Image capture
  static const double idPhotoQuality = 80;
  static const double licensePhotoQuality = 80;
  static const int maxPhotoSizeKB = 1024; // 1MB

  // Rating
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int defaultRating = 0;
}