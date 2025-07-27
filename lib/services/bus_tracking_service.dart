// lib/services/bus_tracking_service.dart

import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/network/api_client.dart';
import '../core/exceptions/app_exceptions.dart';

class BusTrackingService {
  final ApiClient _apiClient = ApiClient();
  Timer? _trackingTimer;
  final Map<String, StreamController<Map<String, dynamic>>> _trackingStreams =
      {};

  Future<Map<String, dynamic>> getBusInfo(String busId) async {
    try {
      final response = await _apiClient.get('/buses/$busId');
      return response;
    } catch (e) {
      // Return mock data for now
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockBusInfo(busId);
    }
  }

  Future<Map<String, dynamic>> getBusLocation(String busId) async {
    try {
      final response = await _apiClient.get('/buses/$busId/location');
      return response;
    } catch (e) {
      // Return mock location data
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockBusLocation(busId);
    }
  }

  Future<Map<String, dynamic>> getRouteInfo(String lineId) async {
    try {
      final response = await _apiClient.get('/lines/$lineId/route');
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _getMockRouteInfo(lineId);
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyBuses(
    double latitude,
    double longitude, {
    double radiusKm = 5,
  }) async {
    try {
      final response = await _apiClient.get(
        '/buses/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusKm,
        },
      );

      return List<Map<String, dynamic>>.from(response['buses']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockNearbyBuses(latitude, longitude);
    }
  }

  Stream<Map<String, dynamic>> trackBusRealTime(String busId) {
    if (!_trackingStreams.containsKey(busId)) {
      _trackingStreams[busId] =
          StreamController<Map<String, dynamic>>.broadcast();
      _startRealTimeTracking(busId);
    }

    return _trackingStreams[busId]!.stream;
  }

  void _startRealTimeTracking(String busId) {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final locationData = await getBusLocation(busId);
        _trackingStreams[busId]?.add(locationData);
      } catch (e) {
        _trackingStreams[busId]?.addError(e);
      }
    });
  }

  void stopTracking(String busId) {
    if (_trackingStreams.containsKey(busId)) {
      _trackingStreams[busId]?.close();
      _trackingStreams.remove(busId);
    }
  }

  Future<Map<String, dynamic>> getETAToStop(String busId, String stopId) async {
    try {
      final response = await _apiClient.get('/buses/$busId/eta/$stopId');
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _getMockETA(busId, stopId);
    }
  }

  Future<List<Map<String, dynamic>>> getBusRoute(String busId) async {
    try {
      final response = await _apiClient.get('/buses/$busId/route');
      return List<Map<String, dynamic>>.from(response['route_points']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockRoutePoints();
    }
  }

  Future<Map<String, dynamic>> getBusSchedule(String busId) async {
    try {
      final response = await _apiClient.get('/buses/$busId/schedule');
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _getMockBusSchedule(busId);
    }
  }

  Future<bool> subscribeToNotifications(
    String busId,
    String notificationType, {
    Map<String, dynamic>? options,
  }) async {
    try {
      final response = await _apiClient.post(
        '/buses/$busId/notifications',
        body: {'type': notificationType, 'options': options},
      );

      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true; // Simulate success
    }
  }

  Future<List<Map<String, dynamic>>> getBusHistory(
    String busId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '/buses/$busId/history',
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['history']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockBusHistory(busId);
    }
  }

  // Utility methods
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadiusKm = 6371;

    final double lat1Rad = point1.latitude * pi / 180;
    final double lat2Rad = point2.latitude * pi / 180;
    final double deltaLatRad = (point2.latitude - point1.latitude) * pi / 180;
    final double deltaLonRad = (point2.longitude - point1.longitude) * pi / 180;

    final double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLonRad / 2) *
            sin(deltaLonRad / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  int calculateETAMinutes(
    LatLng busLocation,
    LatLng destination, {
    double averageSpeedKmh = 30,
  }) {
    final distance = calculateDistance(busLocation, destination);
    return (distance / averageSpeedKmh * 60).round();
  }

  void dispose() {
    _trackingTimer?.cancel();
    for (final controller in _trackingStreams.values) {
      controller.close();
    }
    _trackingStreams.clear();
  }

  // Mock data methods
  Map<String, dynamic> _getMockBusInfo(String busId) {
    return {
      'id': busId,
      'license_plate': 'DZ-${busId.padLeft(3, '0')}-AB',
      'model': 'Mercedes Citaro',
      'capacity': 40,
      'current_passengers': 18,
      'driver': {'name': 'Ahmed Ben Ali', 'rating': 4},
      'line': {
        'id': 'line_1',
        'name': 'Line 1 - City Center - Airport',
        'code': 'L001',
      },
      'features': ['AC', 'WiFi', 'USB Charging'],
      'accessibility': {
        'wheelchair_accessible': true,
        'audio_announcements': true,
      },
    };
  }

  Map<String, dynamic> _getMockBusLocation(String busId) {
    // Simulate movement around Algiers
    final random = Random();
    final baseLatitude = 36 + (random.nextDouble() - 0) * 0;
    final baseLongitude = 3 + (random.nextDouble() - 0) * 0;

    return {
      'bus_id': busId,
      'latitude': baseLatitude,
      'longitude': baseLongitude,
      'heading': random.nextInt(360),
      'speed': 25 + random.nextInt(20), // 25-45 km/h
      'status': ['active', 'at_stop', 'in_transit'][random.nextInt(3)],
      'passenger_count': 15 + random.nextInt(25),
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _getMockRouteInfo(String lineId) {
    return {
      'line_id': lineId,
      'name': 'Line 1 - City Center - Airport',
      'color': '#2196F3',
      'stops': [
        {
          'id': 'stop_1',
          'name': 'City Center Plaza',
          'latitude': 36,
          'longitude': 3,
          'order': 1,
        },
        {
          'id': 'stop_2',
          'name': 'University Gate',
          'latitude': 36,
          'longitude': 3,
          'order': 2,
        },
        {
          'id': 'stop_3',
          'name': 'Shopping Mall',
          'latitude': 36,
          'longitude': 3,
          'order': 3,
        },
        {
          'id': 'stop_4',
          'name': 'Business District',
          'latitude': 36,
          'longitude': 3,
          'order': 4,
        },
        {
          'id': 'stop_5',
          'name': 'Airport Terminal 1',
          'latitude': 36,
          'longitude': 3,
          'order': 5,
        },
      ],
      'route_polyline': _generateMockPolyline(),
    };
  }

  List<Map<String, dynamic>> _getMockNearbyBuses(
    double latitude,
    double longitude,
  ) {
    final random = Random();
    final buses = <Map<String, dynamic>>[];

    for (int i = 1; i <= 5; i++) {
      buses.add({
        'id': 'bus_$i',
        'license_plate': 'DZ-${i.toString().padLeft(3, '0')}-AB',
        'line_name': 'Line $i',
        'latitude': latitude + (random.nextDouble() - 0) * 0,
        'longitude': longitude + (random.nextDouble() - 0) * 0,
        'distance_km': random.nextDouble() * 3,
        'eta_minutes': 5 + random.nextInt(20),
        'passenger_count': random.nextInt(40),
        'capacity': 40,
        'status': ['active', 'at_stop', 'delayed'][random.nextInt(3)],
      });
    }

    return buses;
  }

  Map<String, dynamic> _getMockETA(String busId, String stopId) {
    final random = Random();
    final etaMinutes = 5 + random.nextInt(15);

    return {
      'bus_id': busId,
      'stop_id': stopId,
      'eta_minutes': etaMinutes,
      'eta_time': DateTime.now()
          .add(Duration(minutes: etaMinutes))
          .toIso8601String(),
      'confidence': 0 + random.nextDouble() * 0,
      'stops_remaining': 2 + random.nextInt(4),
      'distance_km': random.nextDouble() * 3,
    };
  }

  List<Map<String, dynamic>> _getMockRoutePoints() {
    return [
      {'latitude': 36, 'longitude': 3, 'order': 1},
      {'latitude': 36, 'longitude': 3, 'order': 2},
      {'latitude': 36, 'longitude': 3, 'order': 3},
      {'latitude': 36, 'longitude': 3, 'order': 4},
      {'latitude': 36, 'longitude': 3, 'order': 5},
      {'latitude': 36, 'longitude': 3, 'order': 6},
      {'latitude': 36, 'longitude': 3, 'order': 7},
      {'latitude': 36, 'longitude': 3, 'order': 8},
      {'latitude': 36, 'longitude': 3, 'order': 9},
      {'latitude': 36, 'longitude': 3, 'order': 10},
    ];
  }

  Map<String, dynamic> _getMockBusSchedule(String busId) {
    return {
      'bus_id': busId,
      'daily_schedule': [
        {
          'departure_time': '06:00',
          'arrival_time': '07:30',
          'trip_id': 'trip_1',
        },
        {
          'departure_time': '08:00',
          'arrival_time': '09:30',
          'trip_id': 'trip_2',
        },
        {
          'departure_time': '10:00',
          'arrival_time': '11:30',
          'trip_id': 'trip_3',
        },
        {
          'departure_time': '12:00',
          'arrival_time': '13:30',
          'trip_id': 'trip_4',
        },
        {
          'departure_time': '14:00',
          'arrival_time': '15:30',
          'trip_id': 'trip_5',
        },
        {
          'departure_time': '16:00',
          'arrival_time': '17:30',
          'trip_id': 'trip_6',
        },
        {
          'departure_time': '18:00',
          'arrival_time': '19:30',
          'trip_id': 'trip_7',
        },
      ],
      'frequency_minutes': 120,
      'operating_hours': {'start': '06:00', 'end': '20:00'},
    };
  }

  List<Map<String, dynamic>> _getMockBusHistory(String busId) {
    final random = Random();
    final history = <Map<String, dynamic>>[];

    for (int i = 0; i < 20; i++) {
      final timestamp = DateTime.now().subtract(Duration(minutes: i * 15));
      history.add({
        'timestamp': timestamp.toIso8601String(),
        'latitude': 36 + (random.nextDouble() - 0) * 0,
        'longitude': 3 + (random.nextDouble() - 0) * 0,
        'speed': 20 + random.nextInt(30),
        'passenger_count': 10 + random.nextInt(30),
        'status': ['active', 'at_stop', 'in_transit'][random.nextInt(3)],
      });
    }

    return history;
  }

  String _generateMockPolyline() {
    // This would normally be an encoded polyline string
    return 'mock_polyline_data_for_route';
  }
}
