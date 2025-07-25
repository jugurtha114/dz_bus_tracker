// lib/services/driver_performance_service.dart

import 'dart:async';
//import '../core/api/api_client.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';

class DriverPerformanceService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getPerformanceData({String period = 'week'}) async {
    try {
      final response = await _apiClient.get(
        '/driver/performance',
        queryParameters: {'period': period},
      );
      
      return response;
    } catch (e) {
      // Return mock data for now
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockPerformanceData(period);
    }
  }

  Future<Map<String, dynamic>> getDrivingBehaviorData({String period = 'week'}) async {
    try {
      final response = await _apiClient.get(
        '/driver/performance/driving-behavior',
        queryParameters: {'period': period},
      );
      
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockDrivingBehaviorData();
    }
  }

  Future<Map<String, dynamic>> getFuelEfficiencyData({String period = 'week'}) async {
    try {
      final response = await _apiClient.get(
        '/driver/performance/fuel-efficiency',
        queryParameters: {'period': period},
      );
      
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockFuelEfficiencyData();
    }
  }

  Future<Map<String, dynamic>> getSafetyScoreData({String period = 'week'}) async {
    try {
      final response = await _apiClient.get(
        '/driver/performance/safety-score',
        queryParameters: {'period': period},
      );
      
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockSafetyScoreData();
    }
  }

  Future<List<Map<String, dynamic>>> getPerformanceTrends({String period = 'month'}) async {
    try {
      final response = await _apiClient.get(
        '/driver/performance/trends',
        queryParameters: {'period': period},
      );
      
      return List<Map<String, dynamic>>.from(response['trends']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _getMockTrendsData();
    }
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final response = await _apiClient.get('/driver/performance/achievements');
      return List<Map<String, dynamic>>.from(response['achievements']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _getMockAchievements();
    }
  }

  Future<List<Map<String, dynamic>>> getImprovementSuggestions() async {
    try {
      final response = await _apiClient.get('/driver/performance/suggestions');
      return List<Map<String, dynamic>>.from(response['suggestions']);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _getMockSuggestions();
    }
  }

  Future<Map<String, dynamic>> getSpeedAnalysis({String period = 'week'}) async {
    try {
      final response = await _apiClient.get(
        '/driver/performance/speed-analysis',
        queryParameters: {'period': period},
      );
      
      return response;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockSpeedAnalysis();
    }
  }

  Future<bool> submitFeedback(String feedback, {int? rating}) async {
    try {
      final response = await _apiClient.post('/driver/performance/feedback', body: {
        'feedback': feedback,
        'rating': rating});
      
      return response != null;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true; // Simulate success
    }
  }

  // Mock data methods
  Map<String, dynamic> _getMockPerformanceData(String period) {
    return {
      'overall_score': 85,
      'previous_score': 82,
      'period': period,
      'metrics': {
        'total_distance': 245,
        'fuel_efficiency': 12,
        'on_time_rate': 92,
        'safety_score': 95,
      },
      'driving_behavior': {
        'harsh_braking': 3,
        'rapid_acceleration': 2,
        'smooth_turns': 95,
        'idle_time': 12,
      },
      'efficiency': {
        'avg_speed': 45,
        'route_completion': 98,
        'maintenance_score': 87,
        'eco_score': 82,
      },
      'safety': {
        'speed_compliance': 95,
        'traffic_rules': 98,
        'defensive_driving': 87,
        'vehicle_handling': 92,
        'recent_events': [
          {
            'title': 'Speed Warning',
            'description': 'Exceeded speed limit by 5 km/h on Highway 1',
            'severity': 'low',
            'timestamp': '2024-07-23T14:30:00Z',
          },
          {
            'title': 'Hard Braking',
            'description': 'Hard braking event detected at City Center intersection',
            'severity': 'medium',
            'timestamp': '2024-07-22T09:15:00Z',
          },
        ],
      },
      'achievements': [
        {
          'title': 'Eco Driver',
          'description': 'Achieved excellent fuel efficiency for 7 consecutive days',
          'earned_at': '2024-07-22T00:00:00Z',
          'badge_type': 'eco',
        },
        {
          'title': 'Safety Champion',
          'description': 'No safety incidents for 30 days',
          'earned_at': '2024-07-20T00:00:00Z',
          'badge_type': 'safety',
        },
      ],
      'suggestions': [
        {'text': 'Try to maintain consistent speed to improve fuel efficiency'},
        {'text': 'Consider reducing idle time during passenger stops'},
        {'text': 'Practice smoother acceleration for better passenger comfort'},
      ],
    };
  }

  Map<String, dynamic> _getMockDrivingBehaviorData() {
    return {
      'harsh_braking_events': 8,
      'rapid_acceleration_events': 5,
      'smooth_driving_score': 87,
      'idle_time_minutes': 45,
      'speed_violations': 2,
      'daily_scores': [
        {'date': '2024-07-18', 'score': 85},
        {'date': '2024-07-19', 'score': 88},
        {'date': '2024-07-20', 'score': 82},
        {'date': '2024-07-21', 'score': 90},
        {'date': '2024-07-22', 'score': 87},
        {'date': '2024-07-23', 'score': 89},
        {'date': '2024-07-24', 'score': 91},
      ],
    };
  }

  Map<String, dynamic> _getMockFuelEfficiencyData() {
    return {
      'current_efficiency': 12,
      'target_efficiency': 11,
      'improvement_percentage': 8,
      'weekly_data': [
        {'week': 'Week 1', 'efficiency': 13},
        {'week': 'Week 2', 'efficiency': 12},
        {'week': 'Week 3', 'efficiency': 12},
        {'week': 'Week 4', 'efficiency': 12},
      ],
      'factors': {
        'driving_style': 0,
        'route_conditions': 0,
        'vehicle_maintenance': 0,
      },
    };
  }

  Map<String, dynamic> _getMockSafetyScoreData() {
    return {
      'overall_safety_score': 95,
      'components': {
        'speed_compliance': 95,
        'traffic_rules': 98,
        'defensive_driving': 87,
        'vehicle_handling': 92,
      },
      'incidents_last_30_days': 1,
      'safety_trend': 'improving',
      'comparison_to_fleet_average': 8,
    };
  }

  List<Map<String, dynamic>> _getMockTrendsData() {
    return [
      {'date': '2024-07-01', 'score': 80, 'fuel_efficiency': 13, 'safety_score': 92},
      {'date': '2024-07-08', 'score': 82, 'fuel_efficiency': 12, 'safety_score': 94},
      {'date': '2024-07-15', 'score': 78, 'fuel_efficiency': 13, 'safety_score': 89},
      {'date': '2024-07-22', 'score': 85, 'fuel_efficiency': 12, 'safety_score': 95},
    ];
  }

  List<Map<String, dynamic>> _getMockAchievements() {
    return [
      {
        'title': 'Fuel Efficiency Master',
        'description': 'Maintained fuel efficiency below 12 L/100km for 2 weeks',
        'earned_at': '2024-07-22T00:00:00Z',
        'badge_type': 'efficiency',
        'points': 100,
      },
      {
        'title': 'Safety First',
        'description': 'Zero safety incidents for 45 consecutive days',
        'earned_at': '2024-07-20T00:00:00Z',
        'badge_type': 'safety',
        'points': 150,
      },
      {
        'title': 'Route Expert',
        'description': 'Completed 100 trips with 98% on-time performance',
        'earned_at': '2024-07-18T00:00:00Z',
        'badge_type': 'performance',
        'points': 200,
      },
    ];
  }

  List<Map<String, dynamic>> _getMockSuggestions() {
    return [
      {
        'text': 'Try to maintain a steady speed between 40-50 km/h for optimal fuel efficiency',
        'category': 'fuel_efficiency',
        'priority': 'high',
      },
      {
        'text': 'Consider using engine braking on downhill sections to reduce wear on brake pads',
        'category': 'vehicle_maintenance',
        'priority': 'medium',
      },
      {
        'text': 'Plan your route to avoid peak traffic hours when possible',
        'category': 'route_optimization',
        'priority': 'medium',
      },
      {
        'text': 'Use air conditioning efficiently - consider opening windows at lower speeds',
        'category': 'fuel_efficiency',
        'priority': 'low',
      },
    ];
  }

  Map<String, dynamic> _getMockSpeedAnalysis() {
    return {
      'average_speed': 42,
      'max_speed': 68,
      'speed_violations': 2,
      'time_in_speed_ranges': {
        '0-30': 0,
        '30-50': 0,
        '50-70': 0,
        '70+': 0,
      },
      'hourly_speed_data': [
        {'hour': 6, 'avg_speed': 35},
        {'hour': 7, 'avg_speed': 28},
        {'hour': 8, 'avg_speed': 32},
        {'hour': 9, 'avg_speed': 45},
        {'hour': 10, 'avg_speed': 48},
        {'hour': 11, 'avg_speed': 46},
        {'hour': 12, 'avg_speed': 42},
        {'hour': 13, 'avg_speed': 44},
        {'hour': 14, 'avg_speed': 38},
        {'hour': 15, 'avg_speed': 35},
        {'hour': 16, 'avg_speed': 30},
        {'hour': 17, 'avg_speed': 25},
        {'hour': 18, 'avg_speed': 33},
      ],
    };
  }
}