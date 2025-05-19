// lib/core/network/interceptors.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../utils/storage_utils.dart';

class InterceptedRequest {
  final Uri uri;
  final Map<String, String> headers;
  final dynamic body;

  InterceptedRequest(this.uri, this.headers, this.body);
}

abstract class Interceptor {
  Future<InterceptedRequest> onRequest(InterceptedRequest request);
  Future<http.Response> onResponse(http.Response response);
  Future<dynamic> onError(dynamic error);
}

class AuthInterceptor implements Interceptor {
  @override
  Future<InterceptedRequest> onRequest(InterceptedRequest request) async {
    final token = await StorageUtils.getFromStorage<String>(AppConstants.tokenKey);

    if (token != null && token.isNotEmpty) {
      final headers = Map<String, String>.from(request.headers);
      headers[ApiConstants.authorizationKey] = '${ApiConstants.bearerPrefix}$token';

      return InterceptedRequest(request.uri, headers, request.body);
    }

    return request;
  }

  @override
  Future<http.Response> onResponse(http.Response response) async {
    return response;
  }

  @override
  Future<dynamic> onError(dynamic error) async {
    return error;
  }
}

class LoggingInterceptor implements Interceptor {
  @override
  Future<InterceptedRequest> onRequest(InterceptedRequest request) async {
    if (kDebugMode) {
      debugPrint('REQUEST[${request.uri.path}] => URL: ${request.uri}');
      debugPrint('REQUEST[${request.uri.path}] => HEADERS: ${request.headers}');

      if (request.body != null) {
        debugPrint('REQUEST[${request.uri.path}] => BODY: ${_formatBody(request.body)}');
      }
    }

    return request;
  }

  @override
  Future<http.Response> onResponse(http.Response response) async {
    if (kDebugMode) {
      debugPrint('RESPONSE[${response.statusCode}] => URL: ${response.request?.url}');
      debugPrint('RESPONSE[${response.statusCode}] => HEADERS: ${response.headers}');

      if (response.body.isNotEmpty) {
        debugPrint('RESPONSE[${response.statusCode}] => BODY: ${_truncateResponse(response.body)}');
      }
    }

    return response;
  }

  @override
  Future<dynamic> onError(dynamic error) async {
    if (kDebugMode) {
      debugPrint('ERROR => $error');
    }

    return error;
  }

  String _formatBody(dynamic body) {
    if (body == null) return 'null';

    if (body is String) {
      try {
        final jsonObj = json.decode(body);
        return const JsonEncoder.withIndent('  ').convert(jsonObj);
      } catch (e) {
        return body;
      }
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(body);
    } catch (e) {
      return body.toString();
    }
  }

  String _truncateResponse(String body) {
    const maxLength = 1000;

    try {
      final jsonObj = json.decode(body);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonObj);

      if (prettyJson.length <= maxLength) {
        return prettyJson;
      }

      return '${prettyJson.substring(0, maxLength)}... (truncated)';
    } catch (e) {
      if (body.length <= maxLength) {
        return body;
      }

      return '${body.substring(0, maxLength)}... (truncated)';
    }
  }
}

class LanguageInterceptor implements Interceptor {
  @override
  Future<InterceptedRequest> onRequest(InterceptedRequest request) async {
    final language = await StorageUtils.getFromStorage<String>(AppConstants.languageKey) ?? AppConstants.defaultLanguage;

    final headers = Map<String, String>.from(request.headers);
    headers[ApiConstants.acceptLanguageKey] = language;

    return InterceptedRequest(request.uri, headers, request.body);
  }

  @override
  Future<http.Response> onResponse(http.Response response) async {
    return response;
  }

  @override
  Future<dynamic> onError(dynamic error) async {
    return error;
  }
}