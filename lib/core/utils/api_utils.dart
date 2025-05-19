// lib/core/utils/api_utils.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../exceptions/app_exceptions.dart';

class ApiUtils {
  // Handle API errors and convert them to custom exceptions
  static AppException handleApiError(dynamic error, {String? defaultMessage}) {
    if (error is ApiException) {
      return error;
    }

    if (error is Map<String, dynamic>) {
      // Try to extract error messages from the response
      if (error.containsKey(ApiConstants.detailKey)) {
        return ApiException(error[ApiConstants.detailKey].toString());
      }

      if (error.containsKey(ApiConstants.messageKey)) {
        return ApiException(error[ApiConstants.messageKey].toString());
      }

      if (error.containsKey(ApiConstants.nonFieldErrorsKey)) {
        final errors = error[ApiConstants.nonFieldErrorsKey];
        if (errors is List) {
          return ApiException(errors.join('. '));
        }
        return ApiException(errors.toString());
      }

      // Check for validation errors
      final fieldErrors = <String, List<String>>{};
      bool hasFieldErrors = false;

      error.forEach((key, value) {
        if (key != ApiConstants.errorKey && key != ApiConstants.detailKey && key != ApiConstants.messageKey) {
          hasFieldErrors = true;
          if (value is List) {
            fieldErrors[key] = List<String>.from(value.map((e) => e.toString()));
          } else {
            fieldErrors[key] = [value.toString()];
          }
        }
      });

      if (hasFieldErrors) {
        return ValidationException(
          defaultMessage ?? 'Validation error',
          fieldErrors: fieldErrors,
          data: error,
        );
      }

      // If we can't extract a specific error, return a generic message
      return ApiException(defaultMessage ?? 'An error occurred while processing your request.');
    }

    // Handle network or unexpected errors
    return ApiException(defaultMessage ?? 'An unexpected error occurred. Please try again.');
  }

  // Parse API response
  static T parseResponse<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) parser) {
    try {
      return parser(json);
    } catch (e) {
      debugPrint('Error parsing response: $e');
      throw ApiException('Failed to parse server response: ${e.toString()}');
    }
  }

  // Parse list from API response
  static List<T> parseResponseList<T>(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) parser,
      {String resultsKey = ApiConstants.resultsKey}
      ) {
    try {
      if (json.containsKey(resultsKey) && json[resultsKey] is List) {
        return (json[resultsKey] as List)
            .map((item) => parser(item as Map<String, dynamic>))
            .toList();
      }

      if (json is List) {
        return (json as List)
            .map((item) => parser(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error parsing response list: $e');
      throw ApiException('Failed to parse server response: ${e.toString()}');
    }
  }

  // Format query parameters for API requests
  static Map<String, String> formatQueryParameters(Map<String, dynamic> params) {
    final formattedParams = <String, String>{};

    params.forEach((key, value) {
      if (value != null) {
        if (value is bool) {
          formattedParams[key] = value.toString();
        } else if (value is int || value is double) {
          formattedParams[key] = value.toString();
        } else if (value is String) {
          formattedParams[key] = value;
        } else if (value is List) {
          // Convert list to comma-separated string
          formattedParams[key] = value.join(',');
        } else {
          formattedParams[key] = value.toString();
        }
      }
    });

    return formattedParams;
  }

  // Convert string to proper JSON format
  static dynamic parseJson(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      throw ApiException('Failed to parse JSON: ${e.toString()}');
    }
  }

  // Format date for API requests
  static String formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }
}