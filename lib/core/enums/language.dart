/// lib/core/enums/language.dart

import 'package:flutter/material.dart'; // For Locale object
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // For JsonValue

/// Enum representing the supported languages in the application.
///
/// Matches the `LanguageEnum` defined in the backend API specification.
enum Language {
  /// French Language.
  @JsonValue('fr') // Maps to the API string value
  fr('fr', Locale('fr', 'FR'), 'Français'),

  /// Arabic Language.
  @JsonValue('ar') // Maps to the API string value
  ar('ar', Locale('ar', 'DZ'), 'العربية'), // Assuming Algerian Arabic variant

  /// English Language.
  @JsonValue('en') // Maps to the API string value
  en('en', Locale('en', 'US'), 'English');

  /// The ISO 639-1 language code (e.g., 'fr', 'ar', 'en'). Matches the API value.
  final String value;

  /// The corresponding Flutter [Locale] object for localization configuration.
  final Locale locale;

  /// The native display name for the language.
  final String nativeName;

  /// Constant constructor for the enum.
  const Language(this.value, this.locale, this.nativeName);

  /// Default language used as fallback.
  static const Language defaultLanguage = Language.fr;

  /// Creates a [Language] from its string representation (language code) [value].
  ///
  /// Defaults to [Language.defaultLanguage] if the string doesn't match any known type,
  /// as 'fr' is specified as the default in the requirements.
  static Language fromString(String? value) {
    if (value == null) return defaultLanguage;
    try {
      return Language.values.firstWhere(
        (e) => e.value == value.toLowerCase(), // Case-insensitive comparison
        orElse: () {
          // Log a warning if an unknown value is encountered
          debugPrint('Warning: Unknown Language encountered: "$value". Defaulting to ${defaultLanguage.value}.');
          return defaultLanguage;
        },
      );
    } catch (e) {
      debugPrint('Error parsing Language from string "$value": $e. Defaulting to ${defaultLanguage.value}.');
      return defaultLanguage;
    }
  }

  /// Creates a [Language] enum value from a Flutter [Locale] object.
  /// Compares based on the language code.
  /// Defaults to [Language.defaultLanguage] if no matching language is found.
  static Language fromLocale(Locale locale) {
     try {
        return Language.values.firstWhere(
           (lang) => lang.locale.languageCode == locale.languageCode,
           orElse: () {
             debugPrint('Warning: Locale "${locale.toLanguageTag()}" not directly supported. Defaulting to ${defaultLanguage.value}.');
             return defaultLanguage;
           },
        );
     } catch (e) {
        debugPrint('Error finding Language from Locale "${locale.toLanguageTag()}": $e. Defaulting to ${defaultLanguage.value}.');
        return defaultLanguage;
     }
  }


  /// Returns a list of all supported [Locale] objects.
  static List<Locale> get supportedLocales =>
      Language.values.map((lang) => lang.locale).toList();
}
