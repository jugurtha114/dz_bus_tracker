// lib/providers/localization_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/utils/storage_utils.dart';

/// Provider for managing app localization and language settings
class LocalizationProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // French (default)
    Locale('ar', 'DZ'), // Arabic (Algeria)
    Locale('en', 'US'), // English
  ];

  // Default locale
  static const Locale defaultLocale = Locale('fr', 'FR');

  Locale _currentLocale = defaultLocale;
  bool _isLoading = false;

  // Getters
  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;
  String get currentLanguageCode => _currentLocale.languageCode;
  bool get isRTL => _currentLocale.languageCode == 'ar';
  String get currentLanguageName => getLanguageDisplayName(_currentLocale.languageCode);

  /// Initialize the localization provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedLanguage = await StorageUtils.getString(_languageKey);
      if (savedLanguage != null) {
        _setLocaleFromCode(savedLanguage);
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set locale directly
  Future<void> setLocale(Locale locale) async {
    await setLanguage(locale.languageCode);
  }

  /// Change the app language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;

    _isLoading = true;
    notifyListeners();

    try {
      _setLocaleFromCode(languageCode);
      await StorageUtils.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set locale from language code
  void _setLocaleFromCode(String languageCode) {
    switch (languageCode) {
      case 'fr':
        _currentLocale = const Locale('fr', 'FR');
        break;
      case 'ar':
        _currentLocale = const Locale('ar', 'DZ');
        break;
      case 'en':
        _currentLocale = const Locale('en', 'US');
        break;
      default:
        _currentLocale = defaultLocale;
    }
  }

  /// Get language display name
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }

  /// Get all available languages
  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'fr', 'name': 'Français', 'nativeName': 'Français'},
      {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    ];
  }

  /// Check if a locale is supported
  bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode);
  }

  /// Reset to default language
  Future<void> resetToDefault() async {
    await setLanguage(defaultLocale.languageCode);
  }
}