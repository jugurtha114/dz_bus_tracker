/// lib/data/data_sources/local/cache_local_data_source.dart

import 'dart:convert'; // For jsonEncode/jsonDecode

import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';
import '../../models/line_model.dart';
import '../../models/stop_model.dart';

/// Abstract interface for accessing locally cached application data.
/// Defines methods for caching and retrieving common data like lines and stops
/// to reduce network requests and improve performance.
abstract class CacheLocalDataSource {
  /// Caches a list of bus lines. Overwrites any existing cached lines.
  Future<void> cacheLines(List<LineModel> lines);

  /// Retrieves the cached list of bus lines. Returns null if no lines are cached or cache is invalid.
  Future<List<LineModel>?> getCachedLines();

  /// Caches a list of stops specifically for a given line ID. Overwrites existing cache for that line.
  Future<void> cacheStopsForLine(String lineId, List<StopModel> stops);

  /// Retrieves the cached list of stops for a specific line ID. Returns null if not cached or cache is invalid.
  Future<List<StopModel>?> getCachedStopsForLine(String lineId);

  /// Gets the timestamp when a specific cache key was last updated.
  /// Returns null if the key or its timestamp doesn't exist.
  Future<DateTime?> getLastCacheTime(String cacheKey);

  /// Clears the cache associated with a specific key (and its timestamp).
  Future<void> clearCache(String cacheKey);

  /// Clears the specific cache for all bus lines.
  Future<void> clearAllLinesCache();

  /// Clears the cache for all line-specific stops. Requires iterating or specific key management.
  Future<void> clearAllStopsCache();

  /// Clears all general cache data stored via this source (uses StorageService's non-secure clear).
  Future<void> clearAllGeneralCache();
}

/// Implementation of [CacheLocalDataSource] using the core [StorageService].
/// Stores lists of models as JSON encoded strings in SharedPreferences.
class CacheLocalDataSourceImpl implements CacheLocalDataSource {
  final StorageService _storageService;

  // Define base keys for cached items. Timestamps are stored separately.
  static const String _linesCacheKey = 'cache_lines_list';
  static const String _stopsCachePrefix = 'cache_stops_for_line_'; // e.g., cache_stops_for_line_uuid123
  static const String _timestampSuffix = '_timestamp';

  /// Creates an instance of [CacheLocalDataSourceImpl].
  /// Requires an instance of [StorageService] to interact with storage.
  const CacheLocalDataSourceImpl({required StorageService storageService})
      : _storageService = storageService;

  /// Helper to generate the timestamp key for a given cache key.
  String _getTimestampKey(String baseKey) => '$baseKey$_timestampSuffix';

  /// Helper to generate the cache key for stops of a specific line.
  String _getStopsCacheKey(String lineId) => '$_stopsCachePrefix$lineId';

  @override
  Future<void> cacheLines(List<LineModel> lines) async {
    try {
      final List<Map<String, dynamic>> jsonList = lines.map((line) => line.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await _storageService.saveData<String>(_linesCacheKey, jsonString);
      await _storageService.saveData<String>(
          _getTimestampKey(_linesCacheKey), DateTime.now().toIso8601String());
      Log.d('Cached ${lines.length} lines successfully.');
    } catch (e, stackTrace) {
      Log.e('Failed to cache lines', error: e, stackTrace: stackTrace);
      // Decide if failure should throw or just log
    }
  }

  @override
  Future<List<LineModel>?> getCachedLines() async {
    try {
      final jsonString = await _storageService.getData<String>(_linesCacheKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        final lines = decodedList
            .map((json) => LineModel.fromJson(json as Map<String, dynamic>))
            .toList();
        Log.d('Retrieved ${lines.length} lines from cache.');
        return lines;
      }
      Log.d('No lines found in cache for key: $_linesCacheKey');
      return null;
    } catch (e, stackTrace) {
      Log.e('Failed to get cached lines', error: e, stackTrace: stackTrace);
      // Clear potentially corrupted cache?
      await clearCache(_linesCacheKey);
      return null;
    }
  }

  @override
  Future<void> cacheStopsForLine(String lineId, List<StopModel> stops) async {
    final cacheKey = _getStopsCacheKey(lineId);
    try {
      final List<Map<String, dynamic>> jsonList = stops.map((stop) => stop.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await _storageService.saveData<String>(cacheKey, jsonString);
      await _storageService.saveData<String>(
          _getTimestampKey(cacheKey), DateTime.now().toIso8601String());
      Log.d('Cached ${stops.length} stops for line $lineId successfully.');
    } catch (e, stackTrace) {
      Log.e('Failed to cache stops for line $lineId', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<StopModel>?> getCachedStopsForLine(String lineId) async {
     final cacheKey = _getStopsCacheKey(lineId);
    try {
      final jsonString = await _storageService.getData<String>(cacheKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        final stops = decodedList
            .map((json) => StopModel.fromJson(json as Map<String, dynamic>))
            .toList();
        Log.d('Retrieved ${stops.length} stops from cache for line $lineId.');
        return stops;
      }
       Log.d('No stops found in cache for key: $cacheKey');
      return null;
    } catch (e, stackTrace) {
      Log.e('Failed to get cached stops for line $lineId', error: e, stackTrace: stackTrace);
      await clearCache(cacheKey);
      return null;
    }
  }

  @override
  Future<DateTime?> getLastCacheTime(String cacheKey) async {
     final timestampKey = _getTimestampKey(cacheKey);
     try {
        final timestampString = await _storageService.getData<String>(timestampKey);
        if(timestampString != null && timestampString.isNotEmpty) {
           return DateTime.tryParse(timestampString);
        }
        return null;
     } catch(e, stackTrace) {
        Log.e('Failed to get last cache time for key "$cacheKey"', error: e, stackTrace: stackTrace);
        return null;
     }
  }

  @override
  Future<void> clearCache(String cacheKey) async {
    Log.d('Clearing cache for key: $cacheKey');
    await _storageService.deleteData(cacheKey);
    await _storageService.deleteData(_getTimestampKey(cacheKey));
  }

  @override
  Future<void> clearAllLinesCache() async {
    await clearCache(_linesCacheKey);
     Log.i('Cleared all lines cache.');
  }

  @override
  Future<void> clearAllStopsCache() async {
    // This requires knowing all keys or using a more advanced storage solution
    // that supports prefix deletion. With SharedPreferences, this is difficult.
    // We might need to store a list of all line IDs that have cached stops.
    // For now, this method might be a no-op or rely on clearAllGeneralCache.
     Log.w('clearAllStopsCache is not fully implemented due to SharedPreferences limitations.');
     // Placeholder: Could iterate known keys if feasible, but inefficient.
     // As a fallback, consider calling clearAllGeneralCache, but that's broader.
     // await clearAllGeneralCache(); // Use with caution!
  }

  @override
  Future<void> clearAllGeneralCache() async {
     Log.i('Clearing all non-secure general cache (SharedPreferences).');
    await _storageService.clearNonSecureStorage();
  }
}
