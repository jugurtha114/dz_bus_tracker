// lib/core/constants/api_constants.dart

class ApiConstants {
  // API status codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusServerError = 500;

  // API headers
  static const String contentTypeKey = 'Content-Type';
  static const String contentTypeJson = 'application/json';
  static const String authorizationKey = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String acceptLanguageKey = 'Accept-Language';

  // Pagination
  static const String pageSizeKey = 'page_size';
  static const String pageKey = 'page';
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  // Filters
  static const String isActiveKey = 'is_active';
  static const String isApprovedKey = 'is_approved';
  static const String driverIdKey = 'driver_id';
  static const String busIdKey = 'bus_id';
  static const String lineIdKey = 'line_id';
  static const String stopIdKey = 'stop_id';
  static const String isTrackingActiveKey = 'is_tracking_active';
  static const String isAvailableKey = 'is_available';
  static const String isCompletedKey = 'is_completed';

  // Response keys
  static const String resultsKey = 'results';
  static const String countKey = 'count';
  static const String nextKey = 'next';
  static const String previousKey = 'previous';
  static const String errorKey = 'error';
  static const String detailKey = 'detail';
  static const String messageKey = 'message';
  static const String nonFieldErrorsKey = 'non_field_errors';

  // Auth response keys
  static const String accessKey = 'access';
  static const String refreshKey = 'refresh';
  static const String tokenKey = 'token';

  // Timeout durations in milliseconds
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;
}