// lib/helpers/validation_helper.dart

/// Helper class for form validation throughout the app
class ValidationHelper {
  // Private constructor to prevent instantiation
  ValidationHelper._();

  /// Email validation regex pattern
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone number validation regex pattern (Algerian format)
  static final RegExp _phoneRegExp = RegExp(
    r'^(0|\+213)[5-7][0-9]{8}$',
  );

  /// Password validation regex pattern
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!_emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!_passwordRegExp.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number and special character';
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validate phone number (Algerian format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and dashes for validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!_phoneRegExp.hasMatch(cleanPhone)) {
      return 'Please enter a valid Algerian phone number';
    }
    
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate name (first name, last name)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    
    if (value.trim().length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    
    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$").hasMatch(value.trim())) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validate numeric input
  static String? validateNumeric(String? value, String fieldName, {int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final number = int.tryParse(value.trim());
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName must be at most $max';
    }
    
    return null;
  }

  /// Validate ID card number (Algerian format)
  static String? validateIdCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ID card number is required';
    }
    
    // Algerian ID card format: 12 digits
    if (!RegExp(r'^\d{12}$').hasMatch(value.trim())) {
      return 'ID card number must be 12 digits';
    }
    
    return null;
  }

  /// Validate driver license number
  static String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Driver license number is required';
    }
    
    if (value.trim().length < 5) {
      return 'Driver license number must be at least 5 characters';
    }
    
    return null;
  }

  /// Validate bus registration number
  static String? validateBusRegistration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bus registration number is required';
    }
    
    // Algerian license plate format (simplified)
    if (value.trim().length < 6) {
      return 'Registration number must be at least 6 characters';
    }
    
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }
    
    try {
      final uri = Uri.parse(value.trim());
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return 'Please enter a valid URL';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validate GPS coordinates
  static String? validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Latitude is required';
    }
    
    final latitude = double.tryParse(value.trim());
    if (latitude == null) {
      return 'Latitude must be a valid number';
    }
    
    if (latitude < -90 || latitude > 90) {
      return 'Latitude must be between -90 and 90';
    }
    
    return null;
  }

  static String? validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Longitude is required';
    }
    
    final longitude = double.tryParse(value.trim());
    if (longitude == null) {
      return 'Longitude must be a valid number';
    }
    
    if (longitude < -180 || longitude > 180) {
      return 'Longitude must be between -180 and 180';
    }
    
    return null;
  }

  /// Validate text length
  static String? validateLength(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }
    
    final length = value.trim().length;
    
    if (minLength != null && length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    if (maxLength != null && length > maxLength) {
      return '$fieldName must be at most $maxLength characters long';
    }
    
    return null;
  }

  /// Validate age
  static String? validateAge(String? value, {int minAge = 18, int maxAge = 80}) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Age must be a valid number';
    }
    
    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }
    
    if (age > maxAge) {
      return 'Age must be less than $maxAge years';
    }
    
    return null;
  }

  /// Validate experience years
  static String? validateExperience(String? value, {int maxYears = 50}) {
    if (value == null || value.trim().isEmpty) {
      return 'Years of experience is required';
    }
    
    final years = int.tryParse(value.trim());
    if (years == null) {
      return 'Experience must be a valid number';
    }
    
    if (years < 0) {
      return 'Experience cannot be negative';
    }
    
    if (years > maxYears) {
      return 'Experience must be less than $maxYears years';
    }
    
    return null;
  }

  /// Clean phone number for storage
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s-()]'), '');
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    final clean = cleanPhoneNumber(phone);
    if (clean.startsWith('+213')) {
      return '+213 ${clean.substring(4, 7)} ${clean.substring(7, 9)} ${clean.substring(9, 11)} ${clean.substring(11)}';
    } else if (clean.startsWith('0')) {
      return '${clean.substring(0, 4)} ${clean.substring(4, 6)} ${clean.substring(6, 8)} ${clean.substring(8)}';
    }
    return phone;
  }

  /// Check if email format is valid (without error message)
  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  /// Check if phone format is valid (without error message)
  static bool isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    return _phoneRegExp.hasMatch(cleanPhone);
  }

  /// Check if password meets requirements (without error message)
  static bool isValidPassword(String password) {
    return password.length >= 8 && _passwordRegExp.hasMatch(password);
  }
}