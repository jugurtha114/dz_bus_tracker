/// lib/core/services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Abstract interface for local data storage.
/// Provides methods for secure storage (e.g., tokens) and general preferences/cache.
abstract class StorageService {
  // --- Authentication Tokens (using Secure Storage) ---

  /// Saves the user's authentication token securely.
  Future<void> saveUserToken(String token);

  /// Retrieves the user's authentication token from secure storage.
  /// Returns null if no token is found.
  Future<String?> getUserToken();

  /// Deletes the user's authentication token from secure storage.
  Future<void> deleteUserToken();

  /// Saves the user's refresh token securely.
  Future<void> saveRefreshToken(String token);

  /// Retrieves the user's refresh token from secure storage.
  /// Returns null if no token is found.
  Future<String?> getRefreshToken();

  /// Deletes the user's refresh token from secure storage.
  Future<void> deleteRefreshToken();

  // --- User Preferences (using Shared Preferences) ---

  /// Saves the user's preferred language code (e.g., 'fr', 'ar', 'en').
  Future<bool> saveLanguagePreference(String languageCode);

  /// Retrieves the user's preferred language code. Returns null if not set.
  Future<String?> getLanguagePreference();

  /// Saves the user's preferred theme mode ('light', 'dark', or 'system').
  Future<bool> saveThemeMode(String themeMode);

  /// Retrieves the user's preferred theme mode. Returns null if not set.
  Future<String?> getThemeMode();

  // --- Generic Key-Value Storage (using Shared Preferences for simple data) ---
  // Suitable for simple caching or flags. For complex objects, consider Hive/Drift.

  /// Saves data associated with a [key]. Supports String, bool, int, double, List<String>.
  Future<bool> saveData<T>(String key, T value);

  /// Retrieves data associated with a [key]. Specify the expected type [T].
  /// Returns null if the key doesn't exist or type doesn't match.
  Future<T?> getData<T>(String key);

  /// Deletes data associated with a [key].
  Future<bool> deleteData(String key);

  /// Checks if a key exists in storage.
  Future<bool> containsKey(String key);

  /// Clears all data from SharedPreferences (use with caution).
  /// Does NOT clear secure storage (tokens).
  Future<bool> clearNonSecureStorage();
}

/// Implementation of [StorageService] using [SharedPreferences] for general
/// preferences/cache and [FlutterSecureStorage] for sensitive data like tokens.
class StorageServiceImpl implements StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  // Define keys used for storage to avoid typos.
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';

  StorageServiceImpl({
    required SharedPreferences prefs,
    required FlutterSecureStorage secureStorage,
  })  : _prefs = prefs,
        _secureStorage = secureStorage;

  // --- Token Management Implementation ---

  @override
  Future<void> saveUserToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
      Log.d('Auth token saved securely.');
    } catch (e, stackTrace) {
      Log.e('Failed to save auth token', error: e, stackTrace: stackTrace);
      // Depending on requirements, might rethrow or handle differently
    }
  }

  @override
  Future<String?> getUserToken() async {
    try {
      final token = await _secureStorage.read(key: _authTokenKey);
      // Log.v('Auth token retrieved: ${token != null ? "found" : "not found"}');
      return token;
    } catch (e, stackTrace) {
      Log.e('Failed to read auth token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<void> deleteUserToken() async {
    try {
      await _secureStorage.delete(key: _authTokenKey);
      Log.d('Auth token deleted.');
    } catch (e, stackTrace) {
      Log.e('Failed to delete auth token', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
       Log.d('Refresh token saved securely.');
    } catch (e, stackTrace) {
      Log.e('Failed to save refresh token', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
       // Log.v('Refresh token retrieved: ${token != null ? "found" : "not found"}');
      return token;
    } catch (e, stackTrace) {
      Log.e('Failed to read refresh token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<void> deleteRefreshToken() async {
    try {
      await _secureStorage.delete(key: _refreshTokenKey);
      Log.d('Refresh token deleted.');
    } catch (e, stackTrace) {
      Log.e('Failed to delete refresh token', error: e, stackTrace: stackTrace);
    }
  }

  // --- Preference Management Implementation ---

  @override
  Future<bool> saveLanguagePreference(String languageCode) async {
    try {
      final success = await _prefs.setString(_languageCodeKey, languageCode);
      Log.d('Language preference saved: $languageCode ($success)');
      return success;
    } catch (e, stackTrace) {
      Log.e('Failed to save language preference', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<String?> getLanguagePreference() async {
    try {
      final lang = _prefs.getString(_languageCodeKey);
      // Log.v('Language preference retrieved: $lang');
      return lang;
    } catch (e, stackTrace) {
      Log.e('Failed to read language preference', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> saveThemeMode(String themeMode) async {
    try {
      final success = await _prefs.setString(_themeModeKey, themeMode);
       Log.d('Theme mode saved: $themeMode ($success)');
      return success;
    } catch (e, stackTrace) {
      Log.e('Failed to save theme mode', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<String?> getThemeMode() async {
    try {
      final theme = _prefs.getString(_themeModeKey);
      // Log.v('Theme mode retrieved: $theme');
      return theme;
    } catch (e, stackTrace) {
      Log.e('Failed to read theme mode', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // --- Generic Key-Value Implementation ---

  @override
  Future<bool> saveData<T>(String key, T value) async {
    try {
      bool success = false;
      if (value is String) {
        success = await _prefs.setString(key, value);
      } else if (value is bool) {
        success = await _prefs.setBool(key, value);
      } else if (value is int) {
        success = await _prefs.setInt(key, value);
      } else if (value is double) {
        success = await _prefs.setDouble(key, value);
      } else if (value is List<String>) {
        success = await _prefs.setStringList(key, value);
      } else {
        Log.e('Unsupported type for saveData: ${value.runtimeType}');
        throw ArgumentError('Unsupported type for saveData: ${value.runtimeType}');
      }
       Log.d('Data saved for key "$key" ($success)');
      return success;
    } catch (e, stackTrace) {
      Log.e('Failed to save data for key "$key"', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<T?> getData<T>(String key) async {
    try {
      final dynamic value = _prefs.get(key);
      if (value is T) {
        // Log.v('Data retrieved for key "$key"');
        return value;
      } else if (value != null) {
         // Log if type mismatch occurs
         Log.w('Type mismatch for key "$key". Expected $T but found ${value.runtimeType}.');
      } else {
         // Log.v('No data found for key "$key"');
      }
      return null;
    } catch (e, stackTrace) {
       Log.e('Failed to get data for key "$key"', error: e, stackTrace: stackTrace);
       return null;
    }
  }

  @override
  Future<bool> deleteData(String key) async {
    try {
      final success = await _prefs.remove(key);
      Log.d('Data deleted for key "$key" ($success)');
      return success;
    } catch (e, stackTrace) {
      Log.e('Failed to delete data for key "$key"', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
     try {
      return _prefs.containsKey(key);
    } catch (e, stackTrace) {
      Log.e('Failed to check key "$key"', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> clearNonSecureStorage() async {
    try {
      // Be careful with this! It clears ALL shared preferences.
      // Consider iterating and removing specific keys if more granular control is needed.
      final success = await _prefs.clear();
      Log.i('Cleared all non-secure storage (SharedPreferences). Success: $success');
      return success;
    } catch (e, stackTrace) {
      Log.e('Failed to clear non-secure storage', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
