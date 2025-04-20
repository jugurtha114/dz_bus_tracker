/// lib/core/services/offline_sync_service.dart

import 'dart:async';
import 'dart:convert'; // For JSON encoding/decoding

import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart'; // For BehaviorSubject

import '../constants/api_constants.dart';
import '../exceptions/app_exceptions.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/location_service.dart'; // For LocationUpdateData
import '../services/storage_service.dart';
import '../utils/logger.dart';
import '../typedefs/common_types.dart'; // For JsonMap

/// Enum representing the current status of the offline synchronization process.
enum SyncStatus { idle, syncing, success, failed }

// --- Data Structures for Queued Items ---
// (These internal classes remain the same)
class _QueuedLocationUpdate {
  final String trackingSessionId; final LocationUpdateData locationData; final String uniqueId;
  _QueuedLocationUpdate({ required this.trackingSessionId, required this.locationData, required this.uniqueId, });
  Map<String, dynamic> toJson() => { 'uniqueId': uniqueId, 'trackingSessionId': trackingSessionId, 'locationData': locationData.toJson(), };
  factory _QueuedLocationUpdate.fromJson(Map<String, dynamic> json) {
    return _QueuedLocationUpdate( uniqueId: json['uniqueId'] as String, trackingSessionId: json['trackingSessionId'] as String, locationData: LocationUpdateData( latitude: double.parse(json['locationData']['latitude'] as String), longitude: double.parse(json['locationData']['longitude'] as String), timestamp: DateTime.parse(json['locationData']['timestamp'] as String), accuracy: json['locationData']['accuracy'] as double?, speed: json['locationData']['speed'] as double?, heading: json['locationData']['heading'] as double?, altitude: json['locationData']['altitude'] as double?, ), );
  }
}
class _QueuedLocationBatch {
  final String trackingSessionId; final List<LocationUpdateData> locations; final String batchId;
  _QueuedLocationBatch({ required this.trackingSessionId, required this.locations, required this.batchId, });
  Map<String, dynamic> toJson() => { 'batchId': batchId, 'trackingSessionId': trackingSessionId, 'locations': locations.map((loc) => loc.toJson()).toList(), };
  factory _QueuedLocationBatch.fromJson(Map<String, dynamic> json) { final locationsList = (json['locations'] as List<dynamic>?) ?? []; return _QueuedLocationBatch( batchId: json['batchId'] as String, trackingSessionId: json['trackingSessionId'] as String, locations: locationsList.map((locJson) { final locMap = locJson as Map<String, dynamic>; return LocationUpdateData( latitude: double.parse(locMap['latitude'] as String), longitude: double.parse(locMap['longitude'] as String), timestamp: DateTime.parse(locMap['timestamp'] as String), accuracy: locMap['accuracy'] as double?, speed: locMap['speed'] as double?, heading: locMap['heading'] as double?, altitude: locMap['altitude'] as double?, ); }).toList(), ); }
}


/// Abstract interface for managing offline data queueing and synchronization.
abstract class OfflineSyncService {
  Future<void> initialize();
  Future<void> queueLocationUpdate(String trackingSessionId, LocationUpdateData data);
  Future<void> queueBatchLocationUpdates(String trackingSessionId, List<LocationUpdateData> data);
  Future<void> attemptSync({bool force = false});
  Stream<SyncStatus> get syncStatusStream;
  void dispose();
}


/// Implementation of [OfflineSyncService].
/// Persists queued items using [StorageService] and syncs using [ApiClient].
class OfflineSyncServiceImpl implements OfflineSyncService {
  final StorageService _storageService;
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;

  static const String _singleUpdateQueueKey = 'offline_single_location_queue';
  static const String _batchUpdateQueueKey = 'offline_batch_location_queue';

  List<_QueuedLocationUpdate> _singleUpdateQueue = [];
  List<_QueuedLocationBatch> _batchUpdateQueue = [];

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription; // Corrected type
  final BehaviorSubject<SyncStatus> _syncStatusSubject = BehaviorSubject.seeded(SyncStatus.idle);
  bool _isSyncing = false;

  OfflineSyncServiceImpl({
    required StorageService storageService,
    required ApiClient apiClient,
    required NetworkInfo networkInfo,
  })  : _storageService = storageService,
        _apiClient = apiClient,
        _networkInfo = networkInfo;

  @override
  Stream<SyncStatus> get syncStatusStream => _syncStatusSubject.stream;

  @override
  Future<void> initialize() async {
    Log.i('Initializing OfflineSyncService...');
    await _loadQueuesFromStorage();
    _connectivitySubscription?.cancel();
    // CORRECTED: Listen to the correct stream type from NetworkInfo
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((resultList) {
      // Check if *any* connection exists (simplification)
      bool isConnected = resultList.isNotEmpty && !resultList.contains(ConnectivityResult.none);
      if (isConnected) {
        Log.i('Connectivity restored. Triggering offline sync attempt.');
        attemptSync();
      } else {
        Log.i('Connectivity lost.');
      }
    });
    if (await _networkInfo.isConnected) {
      Log.d('Initial connection detected, attempting sync.');
      attemptSync();
    }
    Log.i('OfflineSyncService initialized with ${_singleUpdateQueue.length} single updates and ${_batchUpdateQueue.length} batches queued.');
  }

  @override
  Future<void> queueLocationUpdate(String trackingSessionId, LocationUpdateData data) async {
    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString() + data.latitude.toString();
    final queuedUpdate = _QueuedLocationUpdate( trackingSessionId: trackingSessionId, locationData: data, uniqueId: uniqueId, );
    _singleUpdateQueue.add(queuedUpdate);
    await _saveSingleUpdateQueueToStorage(); // Save only the relevant queue
    Log.d('Queued single location update: ${queuedUpdate.uniqueId}');
  }

  @override
  Future<void> queueBatchLocationUpdates(String trackingSessionId, List<LocationUpdateData> data) async {
    if (data.isEmpty) return;
    final batchId = DateTime.now().millisecondsSinceEpoch.toString();
    final queuedBatch = _QueuedLocationBatch( trackingSessionId: trackingSessionId, locations: data, batchId: batchId, );
    _batchUpdateQueue.add(queuedBatch);
    await _saveBatchUpdateQueueToStorage(); // Save only the relevant queue
    Log.d('Queued location batch: ${queuedBatch.batchId} with ${data.length} updates.');
  }

  @override
  Future<void> attemptSync({bool force = false}) async {
    if (_isSyncing && !force) { Log.w('Sync already in progress. Skipping.'); return; }
    if (!await _networkInfo.isConnected) { Log.i('AttemptSync called but device is offline.'); return; }
    if (_singleUpdateQueue.isEmpty && _batchUpdateQueue.isEmpty) { Log.d('AttemptSync called but queues are empty.'); return; }

    _isSyncing = true;
    _syncStatusSubject.add(SyncStatus.syncing);
    Log.i('Starting offline data synchronization...');
    bool overallSuccess = true;

    // --- Sync Single Updates ---
    if (_singleUpdateQueue.isNotEmpty) {
      Log.d('Syncing ${_singleUpdateQueue.length} single location updates...');
      List<String> successfullySyncedIds = []; // Store IDs to remove later
      for (final update in _singleUpdateQueue) {
        final payload = { 'session': update.trackingSessionId, ...update.locationData.toJson() };
        try {
          // CORRECTED: Removed useMsgpack parameter. Interceptor handles format.
          await _apiClient.post(ApiConstants.locationUpdates, data: payload);
          successfullySyncedIds.add(update.uniqueId);
          Log.v('Successfully synced single update: ${update.uniqueId}');
        } on NetworkException catch (e) { Log.w('Network error syncing update ${update.uniqueId}. Keeping in queue.', error: e); overallSuccess = false; break; }
        on ServerException catch (e) { Log.e('Server error syncing update ${update.uniqueId}. Removing from queue.', error: e); successfullySyncedIds.add(update.uniqueId); overallSuccess = false; } // Remove on server error
        catch (e, stackTrace) { Log.e('Unexpected error syncing update ${update.uniqueId}. Removing.', error: e, stackTrace: stackTrace); successfullySyncedIds.add(update.uniqueId); overallSuccess = false; } // Remove on other errors
      }
      // Remove synced items from the main list and save
      if (successfullySyncedIds.isNotEmpty) {
        _singleUpdateQueue.removeWhere((item) => successfullySyncedIds.contains(item.uniqueId));
        await _saveSingleUpdateQueueToStorage();
      }
    }

    // --- Sync Batch Updates ---
    if (overallSuccess && _batchUpdateQueue.isNotEmpty) {
      Log.d('Syncing ${_batchUpdateQueue.length} location batches...');
      List<String> successfullySyncedBatchIds = [];
      for (final batch in _batchUpdateQueue) {
        final payload = { 'session_id': batch.trackingSessionId, 'locations': batch.locations.map((loc) => loc.toJson()).toList(), };
        try {
          // CORRECTED: Removed useMsgpack parameter. Interceptor handles format.
          await _apiClient.post(ApiConstants.batchLocationUpdate, data: payload);
          successfullySyncedBatchIds.add(batch.batchId);
          Log.v('Successfully synced batch: ${batch.batchId}');
        } on NetworkException catch (e) { Log.w('Network error syncing batch ${batch.batchId}. Keeping.', error: e); overallSuccess = false; break; }
        on ServerException catch (e) { Log.e('Server error syncing batch ${batch.batchId}. Removing.', error: e); successfullySyncedBatchIds.add(batch.batchId); overallSuccess = false; }
        catch (e, stackTrace) { Log.e('Unexpected error syncing batch ${batch.batchId}. Removing.', error: e, stackTrace: stackTrace); successfullySyncedBatchIds.add(batch.batchId); overallSuccess = false; }
      }
      // Remove synced items from the main list and save
      if (successfullySyncedBatchIds.isNotEmpty) {
        _batchUpdateQueue.removeWhere((item) => successfullySyncedBatchIds.contains(item.batchId));
        await _saveBatchUpdateQueueToStorage();
      }
    }

    // --- Finalize ---
    _isSyncing = false;
    final remainingItems = _singleUpdateQueue.length + _batchUpdateQueue.length;
    if (remainingItems == 0) { Log.i('Offline sync completed successfully. Queues empty.'); _syncStatusSubject.add(SyncStatus.success); }
    else if (!overallSuccess) { Log.w('Offline sync finished with errors. $remainingItems items remaining.'); _syncStatusSubject.add(SyncStatus.failed); }
    else { Log.i('Offline sync finished. $remainingItems items remaining.'); _syncStatusSubject.add(SyncStatus.idle); }
  }

  // --- Storage Helpers ---
  Future<void> _loadQueuesFromStorage() async {
    try {
      final singleJsonString = await _storageService.getData<String>(_singleUpdateQueueKey);
      if (singleJsonString != null && singleJsonString.isNotEmpty) {
        _singleUpdateQueue = (jsonDecode(singleJsonString) as List).map((item) => _QueuedLocationUpdate.fromJson(item as Map<String, dynamic>)).toList();
      } else { _singleUpdateQueue = []; }
      final batchJsonString = await _storageService.getData<String>(_batchUpdateQueueKey);
      if (batchJsonString != null && batchJsonString.isNotEmpty) {
        _batchUpdateQueue = (jsonDecode(batchJsonString) as List).map((item) => _QueuedLocationBatch.fromJson(item as Map<String, dynamic>)).toList();
      } else { _batchUpdateQueue = []; }
    } catch (e, stackTrace) { Log.e('Failed to load offline queues', error: e, stackTrace: stackTrace); _singleUpdateQueue = []; _batchUpdateQueue = []; await _saveQueuesToStorage(); }
  }
  Future<void> _saveQueuesToStorage() async { await _saveSingleUpdateQueueToStorage(); await _saveBatchUpdateQueueToStorage(); }
  Future<void> _saveSingleUpdateQueueToStorage() async { try { await _storageService.saveData(_singleUpdateQueueKey, jsonEncode(_singleUpdateQueue.map((e) => e.toJson()).toList())); } catch (e, s) { Log.e('Failed to save single update queue', error: e, stackTrace: s); } }
  Future<void> _saveBatchUpdateQueueToStorage() async { try { await _storageService.saveData(_batchUpdateQueueKey, jsonEncode(_batchUpdateQueue.map((e) => e.toJson()).toList())); } catch (e, s) { Log.e('Failed to save batch update queue', error: e, stackTrace: s); } }

  @override
  void dispose() {
    Log.d('Disposing OfflineSyncService...');
    _connectivitySubscription?.cancel();
    _syncStatusSubject.close();
  }
}