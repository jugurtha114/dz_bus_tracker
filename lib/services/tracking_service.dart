// lib/services/tracking_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../config/api_config.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/api_response_models.dart';
import '../models/tracking_model.dart' as tracking;
import '../models/bus_model.dart';
import '../models/line_model.dart';

/// Tracking service with real-time WebSocket support
class TrackingService {
  final String _baseUrl;
  final ApiClient _apiClient = ApiClient();
  WebSocketChannel? _channel;
  final StreamController<tracking.TrackingEvent> _eventController = StreamController.broadcast();
  final StreamController<List<Bus>> _busLocationController = StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _tripUpdateController = StreamController.broadcast();
  
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  
  TrackingService() : _baseUrl = ApiConfig.wsBaseUrl;

  /// Stream of real-time tracking events
  Stream<tracking.TrackingEvent> get trackingEvents => _eventController.stream;
  
  /// Stream of real-time bus location updates
  Stream<List<Bus>> get busLocationUpdates => _busLocationController.stream;
  
  /// Stream of real-time trip updates
  Stream<Map<String, dynamic>> get tripUpdates => _tripUpdateController.stream;
  
  /// Check if WebSocket is connected
  bool get isConnected => _isConnected;

  /// Connect to real-time tracking WebSocket
  Future<void> connect() async {
    try {
      if (_isConnected) {
        return;
      }

      final wsUrl = Uri.parse('$_baseUrl/tracking/ws/');
      _channel = IOWebSocketChannel.connect(wsUrl);
      
      _isConnected = true;
      _reconnectAttempts = 0;
      
      // Listen to WebSocket messages
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketClosed,
      );
      
      // Start heartbeat
      _startHeartbeat();
      
      // Send initial connection message
      _sendMessage({
        'type': 'connect',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      _isConnected = false;
      throw NetworkException('Failed to connect to tracking service: ${e.toString()}');
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    
    await _channel?.sink.close();
    _channel = null;
  }

  /// Subscribe to bus location updates
  void subscribeToBusUpdates(List<String> busIds) {
    if (!_isConnected) return;
    
    _sendMessage({
      'type': 'subscribe_buses',
      'bus_ids': busIds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Subscribe to line tracking updates
  void subscribeToLineUpdates(List<String> lineIds) {
    if (!_isConnected) return;
    
    _sendMessage({
      'type': 'subscribe_lines',
      'line_ids': lineIds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Subscribe to driver trip updates
  void subscribeToDriverUpdates(String driverId) {
    if (!_isConnected) return;
    
    _sendMessage({
      'type': 'subscribe_driver',
      'driver_id': driverId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send location update for a bus
  void sendLocationUpdate({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    int? passengerCount,
  }) {
    if (!_isConnected) return;
    
    _sendMessage({
      'type': 'location_update',
      'bus_id': busId,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'heading': heading,
        'passenger_count': passengerCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  /// Send trip status update
  void sendTripUpdate({
    required String tripId,
    required String status,
    String? currentStopId,
    String? nextStopId,
    int? passengerCount,
    Map<String, dynamic>? additionalData,
  }) {
    if (!_isConnected) return;
    
    _sendMessage({
      'type': 'trip_update',
      'trip_id': tripId,
      'status': status,
      'current_stop_id': currentStopId,
      'next_stop_id': nextStopId,
      'passenger_count': passengerCount,
      'additional_data': additionalData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send anomaly report
  void reportAnomaly({
    required String busId,
    required String type,
    required String severity,
    required String description,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) return;
    
    _sendMessage({
      'type': 'anomaly_report',
      'bus_id': busId,
      'anomaly_type': type,
      'severity': severity,
      'description': description,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Request arrival estimate
  void requestArrivalEstimate({
    required String busId,
    required String stopId,
  }) {
    if (!_isConnected) return;
    
    _sendMessage({
      'type': 'arrival_estimate_request',
      'bus_id': busId,
      'stop_id': stopId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final messageType = data['type'] as String?;
      
      switch (messageType) {
        case 'bus_location_update':
          _handleBusLocationUpdate(data);
          break;
        case 'trip_update':
          _handleTripUpdate(data);
          break;
        case 'anomaly_detected':
          _handleAnomalyDetected(data);
          break;
        case 'arrival_estimate':
          _handleArrivalEstimate(data);
          break;
        case 'driver_status_update':
          _handleDriverStatusUpdate(data);
          break;
        case 'line_status_update':
          _handleLineStatusUpdate(data);
          break;
        case 'heartbeat_response':
          // Heartbeat acknowledged
          break;
        case 'error':
          _handleServerError(data);
          break;
        default:
          // Unknown message type, emit generic tracking event
          _eventController.add(tracking.TrackingEvent.fromJson(data));
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _handleBusLocationUpdate(Map<String, dynamic> data) {
    try {
      final buses = (data['buses'] as List<dynamic>?)
          ?.map((busData) => Bus.fromJson(busData as Map<String, dynamic>))
          .toList() ?? [];
      
      _busLocationController.add(buses);
      
      // Also emit as tracking event
      _eventController.add(tracking.TrackingEvent(
        type: tracking.TrackingEventType.busLocationUpdate,
        busId: data['bus_id'] as String?,
        data: data,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('Error handling bus location update: $e');
    }
  }

  void _handleTripUpdate(Map<String, dynamic> data) {
    _tripUpdateController.add(data);
    
    _eventController.add(tracking.TrackingEvent(
      type: tracking.TrackingEventType.tripUpdate,
      tripId: data['trip_id'] as String?,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void _handleAnomalyDetected(Map<String, dynamic> data) {
    _eventController.add(tracking.TrackingEvent(
      type: tracking.TrackingEventType.anomalyDetected,
      busId: data['bus_id'] as String?,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void _handleArrivalEstimate(Map<String, dynamic> data) {
    _eventController.add(tracking.TrackingEvent(
      type: tracking.TrackingEventType.arrivalEstimate,
      busId: data['bus_id'] as String?,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void _handleDriverStatusUpdate(Map<String, dynamic> data) {
    _eventController.add(tracking.TrackingEvent(
      type: tracking.TrackingEventType.driverStatusUpdate,
      driverId: data['driver_id'] as String?,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void _handleLineStatusUpdate(Map<String, dynamic> data) {
    _eventController.add(tracking.TrackingEvent(
      type: tracking.TrackingEventType.lineStatusUpdate,
      lineId: data['line_id'] as String?,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void _handleServerError(Map<String, dynamic> data) {
    _eventController.add(tracking.TrackingEvent(
      type: tracking.TrackingEventType.error,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  void _handleWebSocketError(error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _eventController.add(tracking.TrackingEvent(
      type: tracking.TrackingEventType.connectionError,
      data: {'error': error.toString()},
      timestamp: DateTime.now(),
    ));
    
    _attemptReconnect();
  }

  void _handleWebSocketClosed() {
    print('WebSocket connection closed');
    _isConnected = false;
    _heartbeatTimer?.cancel();
    
    _eventController.add(tracking.TrackingEvent(
      type: tracking.TrackingEventType.connectionClosed,
      data: {},
      timestamp: DateTime.now(),
    ));
    
    _attemptReconnect();
  }

  void _sendMessage(Map<String, dynamic> message) {
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending WebSocket message: $e');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        _sendMessage({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: 2 * _reconnectAttempts);
    
    _reconnectTimer = Timer(delay, () async {
      try {
        await connect();
        print('Reconnected successfully');
      } catch (e) {
        print('Reconnection attempt failed: $e');
        _attemptReconnect();
      }
    });
  }

  // ================== HTTP API Methods ==================

  /// Get trips with query parameters
  Future<ApiResponse<PaginatedResponse<tracking.Trip>>> getTrips({
    dynamic queryParams,
  }) async {
    try {
      Map<String, dynamic> params;
      if (queryParams is QueryParameters) {
        params = queryParams.toMap();
      } else if (queryParams != null && queryParams.toMap != null) {
        params = queryParams.toMap();
      } else {
        params = <String, dynamic>{};
      }
      
      final response = await _apiClient.get('/tracking/trips', queryParameters: params);
      final paginatedResponse = PaginatedResponse<tracking.Trip>.fromJson(
        response,
        (json) => tracking.Trip.fromJson(json),
      );
      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get trip by ID
  Future<ApiResponse<tracking.Trip>> getTripById(String tripId) async {
    try {
      final response = await _apiClient.get('/tracking/trips/$tripId');
      final trip = tracking.Trip.fromJson(response);
      return ApiResponse.success(data: trip);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Create new trip
  Future<ApiResponse<tracking.Trip>> createTrip({
    required String driverId,
    required String busId,
    required String lineId,
    required String originStopId,
    required String destinationStopId,
    DateTime? scheduledDeparture,
  }) async {
    try {
      final data = {
        'driver_id': driverId,
        'bus_id': busId,
        'line_id': lineId,
        'origin_stop_id': originStopId,
        'destination_stop_id': destinationStopId,
        'scheduled_departure': scheduledDeparture?.toIso8601String(),
      };

      final response = await _apiClient.post('/tracking/trips', body: data);
      final trip = tracking.Trip.fromJson(response);
      return ApiResponse.success(data: trip);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// End trip
  Future<ApiResponse<tracking.Trip>> endTrip(String tripId, {String? reason}) async {
    try {
      final data = {'status': 'completed', 'end_reason': reason};
      final response = await _apiClient.patch('/tracking/trips/$tripId', body: data);
      final trip = tracking.Trip.fromJson(response);
      return ApiResponse.success(data: trip);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Update passenger count
  Future<ApiResponse<Map<String, dynamic>>> updatePassengerCount(String tripId, int count) async {
    try {
      final data = {'passenger_count': count};
      final response = await _apiClient.patch('/tracking/trips/$tripId/passenger-count', body: data);
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Estimate arrival time
  Future<ApiResponse<Map<String, dynamic>>> estimateArrival(String busId, String stopId) async {
    try {
      final response = await _apiClient.get('/tracking/estimate-arrival', queryParameters: {
        'bus_id': busId,
        'stop_id': stopId,
      });
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get anomalies
  Future<ApiResponse<List<Map<String, dynamic>>>> getAnomalies({
    String? busId,
    String? status,
    String? severity,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (busId != null) queryParams['bus_id'] = busId;
      if (status != null) queryParams['status'] = status;
      if (severity != null) queryParams['severity'] = severity;

      final response = await _apiClient.get('/tracking/anomalies', queryParameters: queryParams);
      return ApiResponse.success(data: List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get unresolved anomalies
  Future<ApiResponse<List<Map<String, dynamic>>>> getUnresolvedAnomalies() async {
    try {
      final response = await _apiClient.get('/tracking/anomalies', queryParameters: {'status': 'unresolved'});
      return ApiResponse.success(data: List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get anomaly by ID
  Future<ApiResponse<Map<String, dynamic>>> getAnomalyById(String anomalyId) async {
    try {
      final response = await _apiClient.get('/tracking/anomalies/$anomalyId');
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Create anomaly
  Future<ApiResponse<Map<String, dynamic>>> createAnomaly({
    required String busId,
    required String type,
    required String severity,
    required String description,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = {
        'bus_id': busId,
        'type': type,
        'severity': severity,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'metadata': metadata,
      };

      final response = await _apiClient.post('/tracking/anomalies', body: data);
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Resolve anomaly
  Future<ApiResponse<Map<String, dynamic>>> resolveAnomaly(String anomalyId, {String? resolution}) async {
    try {
      final data = {'status': 'resolved', 'resolution': resolution};
      final response = await _apiClient.patch('/tracking/anomalies/$anomalyId', body: data);
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get trip statistics
  Future<ApiResponse<Map<String, dynamic>>> getTripStatistics({
    String? driverId,
    String? busId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (driverId != null) queryParams['driver_id'] = driverId;
      if (busId != null) queryParams['bus_id'] = busId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get('/tracking/statistics', queryParameters: queryParams);
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get location updates
  Future<ApiResponse<List<Map<String, dynamic>>>> getLocationUpdates({
    String? busId,
    String? tripId,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (busId != null) queryParams['bus_id'] = busId;
      if (tripId != null) queryParams['trip_id'] = tripId;
      if (startTime != null) queryParams['start_time'] = startTime.toIso8601String();
      if (endTime != null) queryParams['end_time'] = endTime.toIso8601String();

      final response = await _apiClient.get('/tracking/location-updates', queryParameters: queryParams);
      return ApiResponse.success(data: List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Create location update
  Future<ApiResponse<Map<String, dynamic>>> createLocationUpdate({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
    String? tripId,
  }) async {
    try {
      final data = {
        'bus_id': busId,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'heading': heading,
        'accuracy': accuracy,
        'trip_id': tripId,
      };

      final response = await _apiClient.post('/tracking/location-updates', body: data);
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get current bus location
  Future<ApiResponse<Map<String, dynamic>>> getCurrentBusLocation(String busId) async {
    try {
      final response = await _apiClient.get('/tracking/buses/$busId/location');
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get bus lines
  Future<ApiResponse<List<Line>>> getBusLines({bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _apiClient.get('/tracking/lines', queryParameters: queryParams);
      final lines = (response as List).map((json) => Line.fromJson(json)).toList();
      return ApiResponse.success(data: lines);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Create bus line
  Future<ApiResponse<Line>> createBusLine(Map<String, dynamic> lineData) async {
    try {
      final response = await _apiClient.post('/tracking/lines', body: lineData);
      final line = Line.fromJson(response);
      return ApiResponse.success(data: line);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Start tracking for a bus
  Future<ApiResponse<Map<String, dynamic>>> startTracking(String busId, {String? tripId}) async {
    try {
      final data = {'action': 'start', 'trip_id': tripId};
      final response = await _apiClient.post('/tracking/buses/$busId/tracking', body: data);
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Stop tracking for a bus
  Future<ApiResponse<Map<String, dynamic>>> stopTracking(String busId) async {
    try {
      final data = {'action': 'stop'};
      final response = await _apiClient.post('/tracking/buses/$busId/tracking', body: data);
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get active buses
  Future<ApiResponse<List<Bus>>> getActiveBuses() async {
    try {
      final response = await _apiClient.get('/tracking/buses/active');
      final buses = (response as List).map((json) => Bus.fromJson(json)).toList();
      return ApiResponse.success(data: buses);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Start bus tracking (alias for startTracking)
  Future<ApiResponse<Map<String, dynamic>>> startBusTracking(String busId) async {
    return startTracking(busId);
  }

  /// Stop bus tracking (alias for stopTracking)
  Future<ApiResponse<Map<String, dynamic>>> stopBusTracking(String busId) async {
    return stopTracking(busId);
  }

  /// Get bus route
  Future<ApiResponse<Map<String, dynamic>>> getBusRoute(String busId) async {
    try {
      final response = await _apiClient.get('/tracking/buses/$busId/route');
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get route arrivals
  Future<ApiResponse<List<Map<String, dynamic>>>> getRouteArrivals(String lineId) async {
    try {
      final response = await _apiClient.get('/tracking/lines/$lineId/arrivals');
      return ApiResponse.success(data: List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Track me (for passengers)
  Future<ApiResponse<Map<String, dynamic>>> trackMe(String userId, double latitude, double longitude) async {
    try {
      final data = {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await _apiClient.post('/tracking/passengers/location', body: data);
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get route visualization data
  Future<ApiResponse<Map<String, dynamic>>> getRouteVisualization(String lineId) async {
    try {
      final response = await _apiClient.get('/tracking/lines/$lineId/visualization');
      return ApiResponse.success(data: response);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get active trip for bus
  Future<ApiResponse<tracking.Trip?>> getActiveTripForBus(String busId) async {
    try {
      final response = await _apiClient.get('/tracking/buses/$busId/active-trip');
      if (response != null) {
        final trip = tracking.Trip.fromJson(response);
        return ApiResponse.success(data: trip);
      }
      return ApiResponse.success(data: null);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get recent anomalies for bus
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecentAnomaliesForBus(String busId, {int limit = 10}) async {
    try {
      final response = await _apiClient.get('/tracking/buses/$busId/anomalies', queryParameters: {
        'limit': limit,
        'recent': true,
      });
      return ApiResponse.success(data: List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Dispose resources
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _eventController.close();
    _busLocationController.close();
    _tripUpdateController.close();
    disconnect();
  }
}

