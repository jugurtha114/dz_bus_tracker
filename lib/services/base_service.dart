// lib/services/base_service.dart

import '../core/network/api_client.dart';

abstract class BaseService {
  static final ApiClient _apiClient = ApiClient();
  
  ApiClient get apiClient => _apiClient;
}