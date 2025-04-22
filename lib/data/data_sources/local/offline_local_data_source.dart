/// lib/data/data_sources/local/offline_local_data_source.dart

import 'dart:convert'; // For jsonEncode/jsonDecode

import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/typedefs/common_types.dart'; // For JsonMap

/// Abstract interface for storing and retrieving offline request queues locally.
/// Defines methods for managing queues of single location updates and batches.
abstract class OfflineLocalDataSource {
  /// Saves the entire queue of single location updates.
  /// Overwrites the existing queue.
  /// Expects a list of maps, where each map is a JSON representation of a queued update.
  Future<void> saveSingleUpdateQueue(List<JsonMap> queue);

  /// Retrieves the stored queue of single location updates.
  /// Returns an empty list if no queue exists or if an error occurs during loading/parsing.
  Future<List<JsonMap>> getSingleUpdateQueue();

  /// Saves the entire queue of batched location updates.
  /// Overwrites the existing queue.
  /// Expects a list of maps, where each map is a JSON representation of a queued batch.
  Future<void> saveBatchUpdateQueue(List<JsonMap> queue);

  /// Retrieves the stored queue of batched location updates.
  /// Returns an empty list if no queue exists or if an error occurs during loading/parsing.
  Future<List<JsonMap>> getBatchUpdateQueue();

  /// Clears the queue of single location updates from storage.
  Future<void> clearSingleUpdateQueue();

  /// Clears the queue of batched location updates from storage.
  Future<void> clearBatchUpdateQueue();
}

/// Implementation of [OfflineLocalDataSource] using the core [StorageService].
/// Stores queues as JSON encoded strings in SharedPreferences (or equivalent).
class OfflineLocalDataSourceImpl implements OfflineLocalDataSource {
  final StorageService _storageService;

  // Define keys used for storing the queues. Match keys used in OfflineSyncService.
  // These could alternatively be defined in a shared constants file.
  static const String _singleUpdateQueueKey = 'offline_single_location_queue';
  static const String _batchUpdateQueueKey = 'offline_batch_location_queue';

  /// Creates an instance of [OfflineLocalDataSourceImpl].
  /// Requires an instance of [StorageService] to interact with storage.
  const OfflineLocalDataSourceImpl({required StorageService storageService})
      : _storageService = storageService;

  @override
  Future<void> saveSingleUpdateQueue(List<JsonMap> queue) async {
    try {
      final String jsonString = jsonEncode(queue);
      await _storageService.saveData<String>(_singleUpdateQueueKey, jsonString);
      Log.d('Saved single update queue (${queue.length} items).');
    } catch (e, stackTrace) {
      Log.e('Failed to save single update queue', error: e, stackTrace: stackTrace);
      // Optionally rethrow or handle as needed
    }
  }

  @override
  Future<List<JsonMap>> getSingleUpdateQueue() async {
    try {
      final jsonString = await _storageService.getData<String>(_singleUpdateQueueKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        // Ensure type safety
        final queue = decodedList
            .whereType<Map<String, dynamic>>() // Filter out non-map items
            .toList();
        Log.d('Retrieved single update queue (${queue.length} items).');
        return queue;
      }
      return []; // Return empty list if key not found or string is empty
    } catch (e, stackTrace) {
      Log.e('Failed to get or parse single update queue', error: e, stackTrace: stackTrace);
      // Clear potentially corrupted data on parse error
      await clearSingleUpdateQueue();
      return []; // Return empty list on error
    }
  }

  @override
  Future<void> saveBatchUpdateQueue(List<JsonMap> queue) async {
     try {
      final String jsonString = jsonEncode(queue);
      await _storageService.saveData<String>(_batchUpdateQueueKey, jsonString);
      Log.d('Saved batch update queue (${queue.length} items).');
    } catch (e, stackTrace) {
      Log.e('Failed to save batch update queue', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<JsonMap>> getBatchUpdateQueue() async {
     try {
      final jsonString = await _storageService.getData<String>(_batchUpdateQueueKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        final queue = decodedList
            .whereType<Map<String, dynamic>>()
            .toList();
        Log.d('Retrieved batch update queue (${queue.length} items).');
        return queue;
      }
      return [];
    } catch (e, stackTrace) {
      Log.e('Failed to get or parse batch update queue', error: e, stackTrace: stackTrace);
      await clearBatchUpdateQueue();
      return [];
    }
  }

  @override
  Future<void> clearSingleUpdateQueue() async {
    Log.d('Clearing single update queue.');
    await _storageService.deleteData(_singleUpdateQueueKey);
  }

  @override
  Future<void> clearBatchUpdateQueue() async {
    Log.d('Clearing batch update queue.');
    await _storageService.deleteData(_batchUpdateQueueKey);
  }
}
