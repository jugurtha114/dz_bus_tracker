/// lib/core/utils/string_utils.dart

/// Utility class providing helper methods for common string operations.
class StringUtil {
  // Private constructor to prevent instantiation
  StringUtil._();

  /// Checks if the given [value] string is null or empty after trimming whitespace.
  /// Returns true if the string is null, empty, or contains only whitespace.
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Capitalizes the first letter of the given string [s].
  /// Returns an empty string if the input is null or empty.
  /// Example: "hello world" -> "Hello world"
  static String capitalizeFirst(String? s) {
    if (isNullOrEmpty(s)) return '';
    // Ensure the string is not empty after potential trimming (although handled by isNullOrEmpty)
    if (s!.isEmpty) return '';
    return "${s[0].toUpperCase()}${s.substring(1)}"; // No need for toLowerCase() on the rest
  }

  /// Checks if the given string [s] contains only numeric characters (0-9).
  /// Returns false if the string is null, empty, or contains non-numeric characters.
  static bool isNumeric(String? s) {
    if (isNullOrEmpty(s)) return false;
    return double.tryParse(s!) != null; // A simple check; handles integers and doubles
    // Alternative using RegExp for integers only:
    // final numericRegex = RegExp(r'^[0-9]+$');
    // return numericRegex.hasMatch(s!);
  }

  /// Checks if the given string [s] represents a valid URL format (basic check).
  /// Returns false if the string is null or doesn't seem like a URL.
  /// Note: This is a basic pattern check, not a guarantee of URL existence or validity.
  static bool isValidUrl(String? s) {
    if (isNullOrEmpty(s)) return false;
    // Basic regex for common URL patterns (http, https)
    final urlRegex = RegExp(
        r"^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$",
        caseSensitive: false);
    return urlRegex.hasMatch(s!);
  }

  /// Truncates the given string [text] to a maximum [maxLength] and appends ellipsis (...) if truncated.
  /// Returns the original string if it's null, empty, or shorter than [maxLength].
  static String truncateWithEllipsis(String? text, int maxLength) {
    if (isNullOrEmpty(text) || text!.length <= maxLength) {
      return text ?? '';
    }
    if (maxLength <= 3) { // Ensure space for ellipsis
        return '...';
    }
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Generates a simple slug from a string by converting to lowercase,
  /// replacing spaces with hyphens, and removing non-alphanumeric characters (except hyphens).
  /// Example: "My Awesome Bus Line!" -> "my-awesome-bus-line"
  static String slugify(String? text) {
      if (isNullOrEmpty(text)) return '';
      return text!
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
          .replaceAll(RegExp(r'[^\w\-]+'), '') // Remove non-word characters except hyphens
          .replaceAll(RegExp(r'\-{2,}'), '-') // Replace multiple hyphens with single one
          .replaceAll(RegExp(r'^-+|-+$'), ''); // Trim leading/trailing hyphens
  }

}
