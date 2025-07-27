// lib/core/utils/storage_utils.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/app_exceptions.dart';

class StorageUtils {
  static SharedPreferences? _prefs;

  // Initialize shared preferences
  static Future<SharedPreferences> get _instance async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs!;
  }

  // Save data to local storage
  static Future<bool> saveToStorage(String key, dynamic value) async {
    final prefs = await _instance;

    if (value is String) {
      return await prefs.setString(key, value);
    } else if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await prefs.setStringList(key, value);
    } else {
      // Convert to JSON string for complex objects
      try {
        final jsonString = json.encode(value);
        return await prefs.setString(key, jsonString);
      } catch (e) {
        throw CacheException('Failed to save data: ${e.toString()}');
      }
    }
  }

  // Get data from local storage
  static Future<T?> getFromStorage<T>(String key) async {
    final prefs = await _instance;

    if (!prefs.containsKey(key)) {
      return null;
    }

    final value = prefs.get(key);

    if (T == String) {
      return value as T;
    } else if (T == int) {
      return value as T;
    } else if (T == double) {
      return value as T;
    } else if (T == bool) {
      return value as T;
    } else if (value is List) {
      return value as T;
    } else if (value is String) {
      // Try to decode JSON string for complex objects
      try {
        final decodedValue = json.decode(value);
        return decodedValue as T;
      } catch (e) {
        // If not a valid JSON, return as is
        return value as T;
      }
    }

    return value as T;
  }

  // Get complex object from local storage
  static Future<Map<String, dynamic>?> getJsonFromStorage(String key) async {
    final jsonString = await getFromStorage<String>(key);
    if (jsonString == null) {
      return null;
    }

    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Failed to parse JSON: ${e.toString()}');
    }
  }

  // Get list from local storage
  static Future<List<T>?> getListFromStorage<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final jsonString = await getFromStorage<String>(key);
    if (jsonString == null) {
      return null;
    }

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to parse JSON list: ${e.toString()}');
    }
  }

  // Remove data from local storage
  static Future<bool> removeFromStorage(String key) async {
    final prefs = await _instance;
    return await prefs.remove(key);
  }

  // Clear all data from local storage
  static Future<bool> clearStorage() async {
    final prefs = await _instance;
    return await prefs.clear();
  }

  // Check if key exists in local storage
  static Future<bool> containsKey(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key);
  }

  // Get all keys from local storage
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _instance;
    return prefs.getKeys();
  }

  /// Get string value from storage
  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  /// Set string value in storage
  static Future<bool> setString(String key, String value) async {
    final prefs = await _instance;
    return await prefs.setString(key, value);
  }

  /// Get int value from storage
  static Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }

  /// Set int value in storage
  static Future<bool> setInt(String key, int value) async {
    final prefs = await _instance;
    return await prefs.setInt(key, value);
  }

  /// Get bool value from storage
  static Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  /// Set bool value in storage
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return await prefs.setBool(key, value);
  }
}
