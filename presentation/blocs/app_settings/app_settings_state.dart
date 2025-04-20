/// lib/presentation/blocs/app_settings/app_settings_state.dart

part of 'app_settings_cubit.dart'; // Link to the cubit file

/// Represents the state for application-level settings like theme and language.
///
/// Uses [Equatable] for easy state comparison in BLoC/Cubit.
class AppSettingsState extends Equatable {
  /// The currently selected theme mode (light, dark, or system default).
  final ThemeMode themeMode;

  /// The currently selected locale for application language.
  final Locale locale;

  /// Creates an [AppSettingsState] instance.
  /// Requires a locale and defaults themeMode to system.
  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    required this.locale, // CORRECTED: Locale is now required
  });

  /// Creates a copy of the current state with updated values.
  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale, // Use provided locale or keep existing
    );
  }

  /// Determines if the current effective theme is dark.
  /// NOTE: UI layer should check platform brightness for system theme mode.
  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return false; // Simplification for state comparison
    }
    return themeMode == ThemeMode.dark;
  }

  @override
  List<Object> get props => [themeMode, locale];

  @override
  String toString() => 'AppSettingsState(themeMode: $themeMode, locale: $locale)';

  /// Convenience factory for the initial state with default values.
  /// Used by the Cubit.
  factory AppSettingsState.initial() => AppSettingsState(
    themeMode: ThemeMode.system,
    locale: Language.fr.locale, // Default locale set here
  );
}