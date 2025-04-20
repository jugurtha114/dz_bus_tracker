/// lib/presentation/blocs/app_settings/app_settings_cubit.dart

import 'package:flutter/material.dart'; // For ThemeMode, Locale
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/language.dart'; // Import Language enum
import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';

part 'app_settings_state.dart'; // Define state in separate file

/// Cubit responsible for managing application-level settings.
///
/// Handles loading and saving theme mode and language preferences
/// using the provided [StorageService].
class AppSettingsCubit extends Cubit<AppSettingsState> {
  final StorageService _storageService;

  /// Creates an instance of [AppSettingsCubit].
  ///
  /// Requires a [StorageService] to persist settings.
  /// Immediately loads initial settings upon creation.
  AppSettingsCubit({required StorageService storageService})
      : _storageService = storageService,
  // CORRECTED: Initialize super with required locale using the default
        super(AppSettingsState(locale: Language.fr.locale)) {
    _loadInitialSettings();
  }

  /// Loads the initial theme mode and language from storage.
  Future<void> _loadInitialSettings() async {
    Log.d('AppSettingsCubit: Loading initial settings...');
    try {
      final themeModeString = await _storageService.getThemeMode();
      final languageCode = await _storageService.getLanguagePreference();

      final initialThemeMode = _parseThemeMode(themeModeString);
      // Use Language enum to get Locale, defaulting to French if not found
      final initialLocale = Language.fromString(languageCode).locale;

      Log.i('Loaded settings - Theme: $initialThemeMode, Locale: $initialLocale');
      // Emit the fully loaded state
      emit(state.copyWith(
        themeMode: initialThemeMode,
        locale: initialLocale,
      ));
    } catch (e, stackTrace) {
      Log.e('Failed to load initial app settings', error: e, stackTrace: stackTrace);
      // Emit default state if loading fails
      emit(AppSettingsState.initial()); // Use factory for default state
    }
  }

  /// Updates the application's theme mode and persists the choice.
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    if (themeMode == state.themeMode) return; // No change

    Log.i('Updating theme mode to: $themeMode');
    emit(state.copyWith(themeMode: themeMode));

    try {
      await _storageService.saveThemeMode(_themeModeToString(themeMode));
    } catch (e, stackTrace) {
      Log.e('Failed to save theme mode preference', error: e, stackTrace: stackTrace);
    }
  }

  /// Updates the application's language and persists the choice.
  Future<void> updateLanguage(Language language) async {
    if (language.locale == state.locale) return; // No change

    Log.i('Updating language to: ${language.value}');
    emit(state.copyWith(locale: language.locale));

    try {
      await _storageService.saveLanguagePreference(language.value);
      // Consider if DateUtil localization needs re-init - usually done once at startup
      // await DateUtil.initializeLocalization(language.value);
    } catch (e, stackTrace) {
      Log.e('Failed to save language preference', error: e, stackTrace: stackTrace);
    }
  }

  // --- Private Helper Methods ---

  ThemeMode _parseThemeMode(String? themeModeString) {
    switch (themeModeString?.toLowerCase()) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      case 'system': default: return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: default: return 'system';
    }
  }
}