// lib/localization/localization_provider.dart

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/storage_utils.dart';

class LocalizationProvider with ChangeNotifier {
  Locale _locale;

  LocalizationProvider({Locale? locale})
    : _locale = locale ?? Locale(AppConstants.defaultLanguage);

  Locale get locale => _locale;

  // Initialize the locale from storage
  Future<void> initialize() async {
    final savedLanguage = await StorageUtils.getFromStorage<String>(
      AppConstants.languageKey,
    );

    if (savedLanguage != null &&
        AppConstants.supportedLanguages.contains(savedLanguage)) {
      _locale = Locale(savedLanguage);
    } else {
      _locale = Locale(AppConstants.defaultLanguage);
    }

    notifyListeners();
  }

  // Change the app language
  Future<void> changeLocale(String languageCode) async {
    if (AppConstants.supportedLanguages.contains(languageCode) &&
        languageCode != _locale.languageCode) {
      _locale = Locale(languageCode);

      await StorageUtils.saveToStorage(AppConstants.languageKey, languageCode);

      notifyListeners();
    }
  }

  // Get language name
  String getLanguageName(String languageCode) {
    return AppConstants.languageNames[languageCode] ??
        languageCode.toUpperCase();
  }

  // Get current language name
  String get currentLanguageName => getLanguageName(_locale.languageCode);

  // Check if the language is RTL
  bool isRtl(String languageCode) {
    return languageCode == 'ar';
  }

  // Is current language RTL
  bool get isCurrentRtl => isRtl(_locale.languageCode);
}
