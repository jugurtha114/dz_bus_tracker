// lib/services/payment_service.dart

import 'dart:async';
import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/exceptions/app_exceptions.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  Future<double> getWalletBalance() async {
    try {
      final response = await _apiClient.get('/payment/wallet/balance');
      return (response['balance'] as num).toDouble();
    } catch (e) {
      // Return mock data for now
      await Future.delayed(const Duration(milliseconds: 500));
      return 2450;
    }
  }

  Future<bool> topUpWallet(double amount) async {
    try {
      final response = await _apiClient.post(
        '/payment/wallet/topup',
        body: {'amount': amount},
      );
      return response != null;
    } catch (e) {
      // Simulate success for now
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }
  }

  Future<bool> processPayment({
    required String method,
    required double amount,
    Map<String, dynamic>? tripDetails,
    Map<String, String>? cardDetails,
  }) async {
    try {
      final data = {
        'method': method,
        'amount': amount,
        'trip_details': tripDetails,
        if (cardDetails != null) 'card_details': cardDetails,
      };

      final response = await _apiClient.post('/payment/process', body: data);
      return response != null;
    } catch (e) {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      // Simulate success rate of 90%
      return DateTime.now().millisecond % 10 != 0;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        '/payment/history',
        queryParameters: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['payments']);
    } catch (e) {
      // Return mock data
      await Future.delayed(const Duration(milliseconds: 800));
      return _mockPaymentHistory;
    }
  }

  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get('/payment/methods');
      return response;
    } catch (e) {
      // Return mock data
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'wallet': {'enabled': true, 'balance': 2450},
        'card': {
          'enabled': true,
          'supported_types': ['visa', 'mastercard', 'cib'],
        },
        'mobile': {
          'enabled': true,
          'providers': ['cib_mobile', 'baridi_mob', 'mobilis_money'],
        },
        'cash': {'enabled': true},
      };
    }
  }

  Future<String> generatePaymentQR({
    required double amount,
    required String method,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.post(
        '/payment/qr/generate',
        body: {'amount': amount, 'method': method, 'metadata': metadata},
      );

      return response['qr_code'];
    } catch (e) {
      // Generate mock QR code
      await Future.delayed(const Duration(milliseconds: 500));
      return 'PAYMENT_QR_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<bool> refundPayment(String paymentId, {String? reason}) async {
    try {
      final response = await _apiClient.post(
        '/payment/$paymentId/refund',
        body: {'reason': reason},
      );

      return response != null;
    } catch (e) {
      // Simulate refund processing
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }
  }

  Future<Map<String, dynamic>> getPaymentStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '/payment/stats',
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      // Return mock stats
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'total_spent': 1280,
        'total_transactions': 42,
        'average_trip_cost': 145,
        'payment_methods': {'wallet': 0, 'card': 0, 'cash': 0, 'mobile': 0},
        'monthly_spending': [
          {'month': 'Jan', 'amount': 420},
          {'month': 'Feb', 'amount': 380},
          {'month': 'Mar', 'amount': 480},
        ],
      };
    }
  }

  static final List<Map<String, dynamic>> _mockPaymentHistory = [
    {
      'id': 'pay_001',
      'amount': 150,
      'method': 'wallet',
      'status': 'completed',
      'created_at': '2024-07-24T08:30:00Z',
      'trip_details': {
        'line': 'Line 1 - City Center - Airport',
        'from': 'City Center Plaza',
        'to': 'Airport Terminal 1',
      },
    },
    {
      'id': 'pay_002',
      'amount': 120,
      'method': 'card',
      'status': 'completed',
      'created_at': '2024-07-23T14:20:00Z',
      'trip_details': {
        'line': 'Line 2 - University - Shopping Mall',
        'from': 'University Main Gate',
        'to': 'Shopping Mall Central',
      },
    },
    {
      'id': 'pay_003',
      'amount': 130,
      'method': 'mobile',
      'status': 'completed',
      'created_at': '2024-07-22T11:10:00Z',
      'trip_details': {
        'line': 'Line 5 - Hospital - Train Station',
        'from': 'Central Hospital',
        'to': 'Train Station Plaza',
      },
    },
    {
      'id': 'pay_004',
      'amount': 200,
      'method': 'wallet',
      'status': 'refunded',
      'created_at': '2024-07-21T16:45:00Z',
      'refund_reason': 'Trip cancelled due to bus breakdown',
      'trip_details': {
        'line': 'Line 4 - Beach - Downtown',
        'from': 'Beach Promenade',
        'to': 'Downtown Plaza',
      },
    },
    {
      'id': 'pay_005',
      'amount': 165,
      'method': 'cash',
      'status': 'completed',
      'created_at': '2024-07-20T09:25:00Z',
      'trip_details': {
        'line': 'Line 3 - Residential - Business District',
        'from': 'Residential Area A',
        'to': 'Business District Center',
      },
    },
  ];
}
