// lib/models/driver_application_model.dart

/// Model for driver application data
class DriverApplication {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String idCardNumber;
  final String? idCardPhotoUrl;
  final String driverLicenseNumber;
  final String? driverLicensePhotoUrl;
  final int yearsOfExperience;
  final String status; // pending, approved, rejected
  final DateTime submittedAt;
  final String? feedback;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  /// Get profile image URL (alias for idCardPhotoUrl as a fallback)
  String? get profileImage => idCardPhotoUrl;

  /// Get experience (alias for yearsOfExperience)
  int get experience => yearsOfExperience;

  /// Get license number (alias for driverLicenseNumber)
  String get licenseNumber => driverLicenseNumber;

  /// Get application date (alias for submittedAt)
  DateTime get applicationDate => submittedAt;

  /// Get rejection reason (mock - should be in feedback)
  String get rejectionReason => feedback ?? 'No reason specified';

  /// Get date of birth (mock property)
  DateTime get dateOfBirth => DateTime(1990, 1, 1); // Mock data

  /// Get license type (mock property)
  String get licenseType => 'Category D'; // Commercial vehicle license

  /// Get license issue date (mock property)
  DateTime get licenseIssueDate => DateTime(2020, 1, 1); // Mock data

  /// Get license expiry date (mock property)
  DateTime get licenseExpiryDate => DateTime(2030, 1, 1); // Mock data

  /// Get previous employer (mock property)
  String get previousEmployer => 'Previous Transport Company'; // Mock data

  /// Get references list (mock property)
  List<String> get references => ['Reference 1', 'Reference 2']; // Mock data

  /// Get license image URL (alias for driverLicensePhotoUrl)
  String? get licenseImage => driverLicensePhotoUrl;

  /// Get criminal record check URL (mock property)
  String? get criminalRecordCheck => idCardPhotoUrl; // Mock - use ID card photo as placeholder

  const DriverApplication({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.idCardNumber,
    this.idCardPhotoUrl,
    required this.driverLicenseNumber,
    this.driverLicensePhotoUrl,
    required this.yearsOfExperience,
    this.status = 'pending',
    required this.submittedAt,
    this.feedback,
    this.reviewedAt,
    this.reviewedBy,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get application status color indicator
  String get statusColor {
    switch (status) {
      case 'approved':
        return 'success';
      case 'rejected':
        return 'error';
      case 'pending':
      default:
        return 'warning';
    }
  }

  /// Check if application is pending
  bool get isPending => status == 'pending';

  /// Check if application is approved
  bool get isApproved => status == 'approved';

  /// Check if application is rejected
  bool get isRejected => status == 'rejected';

  /// Create from JSON
  factory DriverApplication.fromJson(Map<String, dynamic> json) {
    return DriverApplication(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      idCardNumber: json['idCardNumber'] ?? '',
      idCardPhotoUrl: json['idCardPhotoUrl'],
      driverLicenseNumber: json['driverLicenseNumber'] ?? '',
      driverLicensePhotoUrl: json['driverLicensePhotoUrl'],
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      status: json['status'] ?? 'pending',
      submittedAt: DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
      feedback: json['feedback'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewedBy: json['reviewedBy'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'idCardNumber': idCardNumber,
      'idCardPhotoUrl': idCardPhotoUrl,
      'driverLicenseNumber': driverLicenseNumber,
      'driverLicensePhotoUrl': driverLicensePhotoUrl,
      'yearsOfExperience': yearsOfExperience,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'feedback': feedback,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
    };
  }

  /// Create a copy with updated fields
  DriverApplication copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? idCardNumber,
    String? idCardPhotoUrl,
    String? driverLicenseNumber,
    String? driverLicensePhotoUrl,
    int? yearsOfExperience,
    String? status,
    DateTime? submittedAt,
    String? feedback,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return DriverApplication(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      idCardPhotoUrl: idCardPhotoUrl ?? this.idCardPhotoUrl,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      driverLicensePhotoUrl: driverLicensePhotoUrl ?? this.driverLicensePhotoUrl,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      feedback: feedback ?? this.feedback,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverApplication &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DriverApplication{id: $id, fullName: $fullName, status: $status}';
  }
}