/// lib/core/mixins/validation_mixin.dart

/// A mixin providing common input validation methods.
///
/// Can be mixed into State classes of StatefulWidget forms to easily add validation.
/// Error messages returned should ideally be localization keys.
mixin ValidationMixin {
  /// Validates an email address string.
  ///
  /// Checks if the value is non-empty and matches a basic email pattern.
  /// Returns an error message string if invalid, or null if valid.
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email address is required'; // TODO: Localize key: 'validation_email_required'
    }
    // Basic email regex. Consider a more robust package like `email_validator` for production.
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address'; // TODO: Localize key: 'validation_email_invalid'
    }
    return null; // Valid
  }

  /// Validates a password string.
  ///
  /// Checks if the value is non-empty and meets minimum length criteria.
  /// Returns an error message string if invalid, or null if valid.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required'; // TODO: Localize key: 'validation_password_required'
    }
    // Example: Minimum length requirement
    const minLength = 8;
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long'; // TODO: Localize key: 'validation_password_min_length'
    }
    // Add other complexity checks if needed (e.g., require uppercase, numbers, symbols)
    // if (!value.contains(RegExp(r'[A-Z]'))) return 'Password needs an uppercase letter';
    // if (!value.contains(RegExp(r'[0-9]'))) return 'Password needs a number';
    return null; // Valid
  }

  /// Validates that a confirmation password matches the original password.
  ///
  /// Checks if the [confirmValue] is non-empty and matches the [originalValue].
  /// Returns an error message string if invalid, or null if valid.
  String? validateConfirmPassword(String? confirmValue, String? originalValue) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return 'Please confirm your password'; // TODO: Localize key: 'validation_confirm_password_required'
    }
    if (confirmValue != originalValue) {
      return 'Passwords do not match'; // TODO: Localize key: 'validation_passwords_no_match'
    }
    return null; // Valid
  }

  /// Validates that a required field is not empty.
  ///
  /// Returns an error message string including the [fieldName] if invalid, or null if valid.
  String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      // Example using placeholder: Replace {fieldName} during localization lookup
      return '$fieldName is required'; // TODO: Localize key: 'validation_required_field', pass fieldName as arg
    }
    return null; // Valid
  }

  /// Validates a phone number string (basic non-empty check).
  ///
  /// Specific format validation (e.g., Algerian numbers) might require a dedicated
  /// package or more complex regex and is not included here.
  /// Returns an error message string if invalid, or null if valid.
  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required'; // TODO: Localize key: 'validation_phone_required'
    }
    // Optional: Add basic format checks if needed (e.g., only digits, minimum length)
    // final phoneRegex = RegExp(r'^\+?[0-9]{10,}$'); // Very basic example
    // if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
    //   return 'Please enter a valid phone number'; // TODO: Localize key: 'validation_phone_invalid'
    // }
    return null; // Valid
  }

    /// Validates a vehicle matricule (basic non-empty check).
  /// Specific format validation might be needed based on Algerian standards.
  String? validateMatricule(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Matricule is required'; // TODO: Localize key: 'validation_matricule_required'
    }
    // Add specific format checks if required
    return null; // Valid
  }
}
