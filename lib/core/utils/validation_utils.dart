// lib/core/utils/validation_utils.dart

class ValidationUtils {
  // Validate email
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  // Get email validation message
  static String? validateEmail(String? email, {String? errorMessage}) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    if (!isValidEmail(email)) {
      return errorMessage ?? 'Please enter a valid email address';
    }

    return null;
  }

  // Validate phone number (international format)
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return false;
    }

    // Basic international phone validation (starts with + followed by digits)
    final phoneRegExp = RegExp(r'^\+?\d{10,15}$');
    return phoneRegExp.hasMatch(phone);
  }

  // Get phone validation message
  static String? validatePhone(String? phone, {String? errorMessage}) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }

    if (!isValidPhone(phone)) {
      return errorMessage ?? 'Please enter a valid phone number';
    }

    return null;
  }

  // Validate password
  static bool isValidPassword(String? password, {int minLength = 8}) {
    if (password == null || password.isEmpty) {
      return false;
    }

    if (password.length < minLength) {
      return false;
    }

    return true;
  }

  // Get password validation message
  static String? validatePassword(
    String? password, {
    int minLength = 8,
    String? errorMessage,
  }) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (!isValidPassword(password, minLength: minLength)) {
      return errorMessage ??
          'Password must be at least $minLength characters long';
    }

    return null;
  }

  // Validate confirm password
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Validate required field
  static String? validateRequired(
    String? value, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? '${fieldName ?? 'This field'} is required';
    }

    return null;
  }

  // Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (value.length < minLength) {
      return errorMessage ??
          '${fieldName ?? 'This field'} must be at least $minLength characters long';
    }

    return null;
  }

  // Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Not required
    }

    if (value.length > maxLength) {
      return errorMessage ??
          '${fieldName ?? 'This field'} must be at most $maxLength characters long';
    }

    return null;
  }

  // Validate numeric value
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    return double.tryParse(value) != null;
  }

  // Get numeric validation message
  static String? validateNumeric(
    String? value, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (!isNumeric(value)) {
      return errorMessage ?? '${fieldName ?? 'This field'} must be a number';
    }

    return null;
  }

  // Validate integer value
  static bool isInteger(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    return int.tryParse(value) != null;
  }

  // Get integer validation message
  static String? validateInteger(
    String? value, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (!isInteger(value)) {
      return errorMessage ?? '${fieldName ?? 'This field'} must be an integer';
    }

    return null;
  }

  // Validate value range
  static String? validateRange(
    String? value, {
    String? fieldName,
    double? min,
    double? max,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final numericValue = double.tryParse(value);
    if (numericValue == null) {
      return '${fieldName ?? 'This field'} must be a number';
    }

    if (min != null && numericValue < min) {
      return errorMessage ??
          '${fieldName ?? 'This field'} must be at least $min';
    }

    if (max != null && numericValue > max) {
      return errorMessage ??
          '${fieldName ?? 'This field'} must be at most $max';
    }

    return null;
  }
}
