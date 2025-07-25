// lib/models/api_response_models.dart

/// Generic API response wrapper for consistent error handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.success({T? data, String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    String? message,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'An error occurred',
      errors: errors,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, hasData: ${data != null})';
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  const PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final resultsJson = json['results'] as List<dynamic>? ?? [];
    final results = resultsJson
        .cast<Map<String, dynamic>>()
        .map((item) => fromJsonT(item))
        .toList();

    return PaginatedResponse<T>(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }

  bool get hasNextPage => next != null;
  bool get hasPreviousPage => previous != null;
  bool get isEmpty => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;
  int get totalPages => (count / results.length).ceil();

  @override
  String toString() {
    return 'PaginatedResponse(count: $count, results: ${results.length})';
  }
}

/// Query parameters for filtering and sorting
class QueryParameters {
  final Map<String, dynamic> _params = {};

  QueryParameters();

  /// Add parameter if value is not null
  QueryParameters addParam(String key, dynamic value) {
    if (value != null) {
      _params[key] = value;
    }
    return this;
  }

  /// Add boolean parameter
  QueryParameters addBool(String key, bool? value) {
    if (value != null) {
      _params[key] = value;
    }
    return this;
  }

  /// Add string parameter
  QueryParameters addString(String key, String? value) {
    if (value != null && value.isNotEmpty) {
      _params[key] = value;
    }
    return this;
  }

  /// Add integer parameter
  QueryParameters addInt(String key, int? value) {
    if (value != null) {
      _params[key] = value;
    }
    return this;
  }

  /// Add list parameter
  QueryParameters addList(String key, List<dynamic>? value) {
    if (value != null && value.isNotEmpty) {
      _params[key] = value;
    }
    return this;
  }

  /// Add pagination parameters
  QueryParameters addPagination({int? page, int? pageSize}) {
    if (page != null) _params['page'] = page;
    if (pageSize != null) _params['page_size'] = pageSize;
    return this;
  }

  /// Add ordering parameter
  QueryParameters addOrdering(List<String>? orderBy) {
    if (orderBy != null && orderBy.isNotEmpty) {
      _params['order_by'] = orderBy;
    }
    return this;
  }

  /// Get the parameters map
  Map<String, dynamic> toMap() => Map.from(_params);

  /// Check if parameters are empty
  bool get isEmpty => _params.isEmpty;
  bool get isNotEmpty => _params.isNotEmpty;

  @override
  String toString() => _params.toString();
}

/// Bus query parameters
class BusQueryParameters extends QueryParameters {
  BusQueryParameters({
    String? driverId,
    bool? isActive,
    bool? isAirConditioned,
    bool? isApproved,
    String? licensePlate,
    String? manufacturer,
    String? model,
    int? maxCapacity,
    int? minCapacity,
    int? maxYear,
    int? minYear,
    String? status,
    int? year,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addString('driver_id', driverId);
    addBool('is_active', isActive);
    addBool('is_air_conditioned', isAirConditioned);
    addBool('is_approved', isApproved);
    addString('license_plate', licensePlate);
    addString('manufacturer', manufacturer);
    addString('model', model);
    addInt('max_capacity', maxCapacity);
    addInt('min_capacity', minCapacity);
    addInt('max_year', maxYear);
    addInt('min_year', minYear);
    addString('status', status);
    addInt('year', year);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Driver query parameters
class DriverQueryParameters extends QueryParameters {
  DriverQueryParameters({
    bool? isActive,
    bool? isAvailable,
    double? maxRating,
    double? minRating,
    int? minExperience,
    String? status,
    String? userId,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addBool('is_active', isActive);
    addBool('is_available', isAvailable);
    addParam('max_rating', maxRating);
    addParam('min_rating', minRating);
    addInt('min_experience', minExperience);
    addString('status', status);
    addString('user_id', userId);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Bus location query parameters
class BusLocationQueryParameters extends QueryParameters {
  BusLocationQueryParameters({
    String? busId,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool? isTrackingActive,
    int? maxPassengerCount,
    int? minPassengerCount,
    double? maxSpeed,
    double? minSpeed,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addString('bus_id', busId);
    addString('created_after', createdAfter?.toIso8601String());
    addString('created_before', createdBefore?.toIso8601String());
    addBool('is_tracking_active', isTrackingActive);
    addInt('max_passenger_count', maxPassengerCount);
    addInt('min_passenger_count', minPassengerCount);
    addParam('max_speed', maxSpeed);
    addParam('min_speed', minSpeed);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Driver rating query parameters  
class DriverRatingQueryParameters extends QueryParameters {
  DriverRatingQueryParameters({
    DateTime? createdAfter,
    DateTime? createdBefore,
    String? driverId,
    int? maxRating,
    int? minRating,
    String? userId,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addString('created_after', createdAfter?.toIso8601String());
    addString('created_before', createdBefore?.toIso8601String());
    addString('driver_id', driverId);
    addInt('max_rating', maxRating);
    addInt('min_rating', minRating);
    addString('user_id', userId);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Line query parameters
class LineQueryParameters extends QueryParameters {
  LineQueryParameters({
    String? code,
    bool? isActive,
    int? maxFrequency,
    int? minFrequency,
    String? name,
    String? stopId,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addString('code', code);
    addBool('is_active', isActive);
    addInt('max_frequency', maxFrequency);
    addInt('min_frequency', minFrequency);
    addString('name', name);
    addString('stop_id', stopId);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Schedule query parameters
class ScheduleQueryParameters extends QueryParameters {
  ScheduleQueryParameters({
    int? dayOfWeek,
    bool? isActive,
    String? lineId,
    int? maxFrequency,
    int? minFrequency,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addInt('day_of_week', dayOfWeek);
    addBool('is_active', isActive);
    addString('line_id', lineId);
    addInt('max_frequency', maxFrequency);
    addInt('min_frequency', minFrequency);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Anomaly query parameters
class AnomalyQueryParameters extends QueryParameters {
  AnomalyQueryParameters({
    String? busId,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool? resolved,
    DateTime? resolvedAfter,
    DateTime? resolvedBefore,
    String? severity,
    String? tripId,
    String? type,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addString('bus_id', busId);
    addString('created_after', createdAfter?.toIso8601String());
    addString('created_before', createdBefore?.toIso8601String());
    addBool('resolved', resolved);
    addString('resolved_after', resolvedAfter?.toIso8601String());
    addString('resolved_before', resolvedBefore?.toIso8601String());
    addString('severity', severity);
    addString('trip_id', tripId);
    addString('type', type);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}


/// Location update query parameters
class LocationUpdateQueryParameters extends QueryParameters {
  LocationUpdateQueryParameters({
    String? busId,
    DateTime? createdAfter,
    DateTime? createdBefore,
    String? lineId,
    double? maxSpeed,
    double? minSpeed,
    String? nearestStopId,
    String? tripId,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addString('bus_id', busId);
    addString('created_after', createdAfter?.toIso8601String());
    addString('created_before', createdBefore?.toIso8601String());
    addString('line_id', lineId);
    addParam('max_speed', maxSpeed);
    addParam('min_speed', minSpeed);
    addString('nearest_stop_id', nearestStopId);
    addString('trip_id', tripId);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Bus line assignment query parameters
class BusLineQueryParameters extends QueryParameters {
  BusLineQueryParameters({
    String? busId,
    bool? isActive,
    String? lineId,
    String? trackingStatus,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addString('bus_id', busId);
    addBool('is_active', isActive);
    addString('line_id', lineId);
    addString('tracking_status', trackingStatus);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Achievement query parameters
class AchievementQueryParameters extends QueryParameters {
  AchievementQueryParameters({
    List<String>? achievementType,
    int? maxPoints,
    int? minPoints,
    List<String>? rarity,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addList('achievement_type', achievementType);
    addInt('max_points', maxPoints);
    addInt('min_points', minPoints);
    addList('rarity', rarity);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Challenge query parameters
class ChallengeQueryParameters extends QueryParameters {
  ChallengeQueryParameters({
    List<String>? challengeType,
    DateTime? endsBefore,
    bool? isCompleted,
    int? minReward,
    DateTime? startsAfter,
    String? targetLine,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addList('challenge_type', challengeType);
    addString('ends_before', endsBefore?.toIso8601String());
    addBool('is_completed', isCompleted);
    addInt('min_reward', minReward);
    addString('starts_after', startsAfter?.toIso8601String());
    addString('target_line', targetLine);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Reward query parameters
class RewardQueryParameters extends QueryParameters {
  RewardQueryParameters({
    int? maxCost,
    int? minCost,
    String? partner,
    String? partnerName,
    List<String>? rewardType,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addInt('max_cost', maxCost);
    addInt('min_cost', minCost);
    addString('partner', partner);
    addString('partner_name', partnerName);
    addList('reward_type', rewardType);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Point transaction query parameters
class PointTransactionQueryParameters extends QueryParameters {
  PointTransactionQueryParameters({
    List<String>? transactionType,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int? minPoints,
    int? maxPoints,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addList('transaction_type', transactionType);
    addString('created_after', createdAfter?.toIso8601String());
    addString('created_before', createdBefore?.toIso8601String());
    addInt('min_points', minPoints);
    addInt('max_points', maxPoints);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Notification query parameters
class NotificationQueryParameters extends QueryParameters {
  NotificationQueryParameters({
    List<String>? notificationType,
    List<String>? channel,
    bool? isRead,
    DateTime? createdAfter,
    DateTime? createdBefore,
    DateTime? readAfter,
    DateTime? readBefore,
    String? userId,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addList('notification_type', notificationType);
    addList('channel', channel);
    addBool('is_read', isRead);
    addString('created_after', createdAfter?.toIso8601String());
    addString('created_before', createdBefore?.toIso8601String());
    addString('read_after', readAfter?.toIso8601String());
    addString('read_before', readBefore?.toIso8601String());
    addString('user_id', userId);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Device token query parameters
class DeviceTokenQueryParameters extends QueryParameters {
  DeviceTokenQueryParameters({
    List<String>? deviceType,
    bool? isActive,
    DateTime? createdAfter,
    DateTime? createdBefore,
    DateTime? lastUsedAfter,
    DateTime? lastUsedBefore,
    String? userId,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addList('device_type', deviceType);
    addBool('is_active', isActive);
    addString('created_after', createdAfter?.toIso8601String());
    addString('created_before', createdBefore?.toIso8601String());
    addString('last_used_after', lastUsedAfter?.toIso8601String());
    addString('last_used_before', lastUsedBefore?.toIso8601String());
    addString('user_id', userId);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Notification preference query parameters
class NotificationPreferenceQueryParameters extends QueryParameters {
  NotificationPreferenceQueryParameters({
    List<String>? notificationType,
    List<String>? channels,
    bool? enabled,
    String? userId,
    List<String>? orderBy,
    int? page,
    int? pageSize,
  }) {
    addList('notification_type', notificationType);
    addList('channels', channels);
    addBool('enabled', enabled);
    addString('user_id', userId);
    addOrdering(orderBy);
    addPagination(page: page, pageSize: pageSize);
  }
}

/// Error details for API responses
class ApiError {
  final String message;
  final int? code;
  final Map<String, List<String>>? fieldErrors;

  const ApiError({
    required this.message,
    this.code,
    this.fieldErrors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    // Handle different error response formats
    String message = 'An error occurred';
    Map<String, List<String>>? fieldErrors;

    if (json.containsKey('detail')) {
      message = json['detail'].toString();
    } else if (json.containsKey('message')) {
      message = json['message'].toString();
    } else if (json.containsKey('error')) {
      message = json['error'].toString();
    }

    // Handle field-specific errors
    if (json.containsKey('non_field_errors')) {
      final nonFieldErrors = json['non_field_errors'] as List<dynamic>?;
      if (nonFieldErrors != null && nonFieldErrors.isNotEmpty) {
        message = nonFieldErrors.first.toString();
      }
    }

    // Extract field errors
    final Map<String, List<String>> extractedFieldErrors = {};
    json.forEach((key, value) {
      if (key != 'detail' && key != 'message' && key != 'error' && key != 'non_field_errors') {
        if (value is List) {
          extractedFieldErrors[key] = value.map((e) => e.toString()).toList();
        } else {
          extractedFieldErrors[key] = [value.toString()];
        }
      }
    });

    if (extractedFieldErrors.isNotEmpty) {
      fieldErrors = extractedFieldErrors;
    }

    return ApiError(
      message: message,
      fieldErrors: fieldErrors,
    );
  }

  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;

  @override
  String toString() {
    return 'ApiError(message: $message, hasFieldErrors: $hasFieldErrors)';
  }
}