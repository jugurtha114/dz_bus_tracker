/// lib/core/network/api_interceptor.dart

import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
// We still need the import even if not actively packing, for potential errors
import '../utils/msgpack_utils.dart';
import '../constants/api_constants.dart';
import '../exceptions/app_exceptions.dart';
import '../network/network_info.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';


class ApiInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;
  final StorageService _storageService;

  ApiInterceptor(
      this._networkInfo,
      this._storageService,
      );

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    Log.d('--> ${options.method} ${options.uri}');
    Log.v('Headers: ${options.headers}');
    if (options.data != null && options.data is! FormData) {
      Log.v('Data: ${options.data}');
    }

    // 1. Add Auth Token (Logic remains the same)
    final bool isAuthPath = options.path.contains(ApiConstants.login) ||
        options.path.contains(ApiConstants.register) ||
        options.path.contains(ApiConstants.refreshToken);
    if (!isAuthPath) {
      final String? token = await _storageService.getUserToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.authorizationHeader] = 'Bearer $token';
        Log.v('Authorization header added.');
      } else {
        Log.w('Auth token is null or empty for non-auth path: ${options.path}');
      }
    }

    // 2. Dynamic Content-Type & Serialization
    // --------------------------------------------------------------------
    // TEMPORARY FIX FOR TESTING: Force JSON by setting preferMsgpack=false
    // TODO: Remove this line and uncomment original logic to re-enable Msgpack
    bool preferMsgpack = false;
    Log.w("[TESTING] MessagePack is temporarily disabled. Forcing JSON.");
    // --------------------------------------------------------------------

    // <<< ORIGINAL LOGIC TO UNCOMMENT LATER >>>
    // bool preferMsgpack = false;
    // final bool isLocationUpdate = options.path.contains(ApiConstants.locationUpdates) ||
    //                               options.path.contains(ApiConstants.batchLocationUpdate);
    // if (isLocationUpdate) {
    //   preferMsgpack = true; // Always use msgpack for location data efficiency
    // } else {
    //   // Prefer based on network type (example logic)
    //   preferMsgpack = !(await _networkInfo.isPotentiallyLowBandwidth);
    // }
    // <<< END ORIGINAL LOGIC >>>


    if (preferMsgpack) {
      // --- This block will be skipped due to the temporary fix above ---
      options.headers[ApiConstants.acceptHeader] = ApiConstants.msgpackContentType;
      options.responseType = ResponseType.bytes;
      if (options.data != null && options.data is! FormData && options.data is! Stream && options.data is! Uint8List) {
        try {
          options.data = MsgpackUtils.packObject(options.data); // Use packing util
          options.headers[ApiConstants.contentTypeHeader] = ApiConstants.msgpackContentType;
          Log.v('Request body serialized to Msgpack.');
        } on DataParsingException catch(e, stackTrace) {
          Log.e('Msgpack request serialization failed', error: e, stackTrace: stackTrace);
          options.headers[ApiConstants.contentTypeHeader] = ApiConstants.jsonContentType;
          options.responseType = ResponseType.json;
          Log.w('Falling back to JSON due to Msgpack request serialization error.');
        } catch (e, stackTrace) {
          Log.e('Unexpected error during Msgpack request serialization', error: e, stackTrace: stackTrace);
          options.headers[ApiConstants.contentTypeHeader] = ApiConstants.jsonContentType;
          options.responseType = ResponseType.json;
          Log.w('Falling back to JSON due to unexpected Msgpack request serialization error.');
        }
      } else if (options.data is FormData || options.data is Stream || options.data is Uint8List) {
        options.headers.remove(ApiConstants.contentTypeHeader); // Let Dio handle
      }
      // --- End of skipped block ---
    } else {
      // --- This block will now ALWAYS execute ---
      Log.d('Using JSON content type for request.');
      options.headers[ApiConstants.acceptHeader] = ApiConstants.jsonContentType;
      options.responseType = ResponseType.json; // Expect JSON response
      if (options.data != null && options.data is! FormData && options.data is! Stream && options.data is! Uint8List) {
        // Ensure Content-Type is set if data is present and not handled by Dio (like Map/List)
        options.headers[ApiConstants.contentTypeHeader] = ApiConstants.jsonContentType;
      } else if (options.data is FormData || options.data is Stream || options.data is Uint8List) {
        // Let Dio set Content-Type for these specific types
        options.headers.remove(ApiConstants.contentTypeHeader);
      }
      // --- End of JSON block ---
    }

    handler.next(options);
  }

  // onResponse and onError methods remain the same as the last correct version
  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    Log.d('<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
    Log.v('Response Headers: ${response.headers}');
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    Log.e('<-- ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.method} ${err.requestOptions.uri}', error: err.error, stackTrace: err.stackTrace);
    Log.e('DioError Type: ${err.type}');
    if (err.response?.data != null) { Log.e('DioError Response Data: ${err.response!.data}'); }
    // Optional token refresh logic placeholder...
    handler.next(err);
  }
}



// /// lib/core/network/api_interceptor.dart
//
// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import '../constants/api_constants.dart';
// import '../exceptions/app_exceptions.dart';
// import '../network/network_info.dart';
// import '../services/storage_service.dart';
// import '../utils/logger.dart';
// import '../utils/msgpack_utils.dart';
// // Import AppConfig if needed for specific logic based on environment
// // import '../../config/app_config.dart';
//
// /// A Dio interceptor to handle common API request tasks:
// /// - Adding Authentication Tokens.
// /// - Dynamically setting Content-Type/Accept headers for Msgpack/JSON.
// /// - Serializing request data to Msgpack when needed.
// /// - Basic logging.
// /// - Placeholder for token refresh logic on 401 errors.
// class ApiInterceptor extends Interceptor {
//   final NetworkInfo _networkInfo;
//   final StorageService _storageService;
//   // Inject Dio instance ONLY if needed for token refresh logic INSIDE the interceptor
//   // final Dio _dio;
//
//   ApiInterceptor(
//     this._networkInfo,
//     this._storageService,
//     /* this._dio */
//   );
//
//   @override
//   Future<void> onRequest(
//       RequestOptions options, RequestInterceptorHandler handler) async {
//     Log.d('--> ${options.method} ${options.uri}');
//     Log.v('Headers: ${options.headers}');
//     if (options.data != null && options.data is! FormData) {
//       Log.v('Data: ${options.data}');
//     }
//
//     // 1. Add Auth Token
//     final bool isAuthPath = options.path.contains(ApiConstants.login) ||
//         options.path.contains(ApiConstants.register) ||
//         options.path.contains(ApiConstants.refreshToken);
//     if (!isAuthPath) {
//       final String? token = await _storageService.getUserToken();
//       if (token != null && token.isNotEmpty) {
//         options.headers[ApiConstants.authorizationHeader] = 'Bearer $token';
//         Log.v('Authorization header added.');
//       } else {
//         Log.w('Auth token is null or empty for non-auth path: ${options.path}');
//       }
//     }
//
//     // 2. Dynamic Content-Type & Serialization
//     bool preferMsgpack = false;
//     final bool isLocationUpdate = options.path.contains(ApiConstants.locationUpdates) ||
//         options.path.contains(ApiConstants.batchLocationUpdate);
//
//     if (isLocationUpdate) {
//       preferMsgpack = true;
//     } else {
//       preferMsgpack = !(await _networkInfo.isPotentiallyLowBandwidth);
//     }
//
//     if (preferMsgpack) {
//       options.headers[ApiConstants.acceptHeader] = ApiConstants.msgpackContentType;
//       options.responseType = ResponseType.bytes;
//
//       if (options.data != null && options.data is! FormData && options.data is! Stream && options.data is! Uint8List) {
//         try {
//           // CORRECTED: Use MsgpackUtils.packObject helper
//           options.data = MsgpackUtils.packObject(options.data);
//           options.headers[ApiConstants.contentTypeHeader] = ApiConstants.msgpackContentType;
//           Log.v('Request body serialized to Msgpack.');
//         } on DataParsingException catch(e, stackTrace) { // Catch specific packing error
//           // CORRECTED: Use positional arguments for Log.e
//           Log.e('Msgpack request serialization failed for ${options.path}', error: e, stackTrace: stackTrace);
//           options.headers[ApiConstants.contentTypeHeader] = ApiConstants.jsonContentType;
//           options.responseType = ResponseType.json;
//           // Revert data back to original Map/List for JSON transformer if needed
//           // options.data = originalData; // Requires storing originalData before try block
//           Log.w('Falling back to JSON due to Msgpack request serialization error.');
//         } catch (e, stackTrace) { // Catch unexpected errors during packing
//           Log.e('Unexpected error during Msgpack request serialization for ${options.path}', error: e, stackTrace: stackTrace);
//           options.headers[ApiConstants.contentTypeHeader] = ApiConstants.jsonContentType;
//           options.responseType = ResponseType.json;
//           Log.w('Falling back to JSON due to unexpected Msgpack request serialization error.');
//         }
//       } else if (options.method != 'GET' && options.method != 'DELETE' && options.data == null) {
//         // No content-type needed for empty body
//       } else if (options.data is FormData || options.data is Stream || options.data is Uint8List) {
//         options.headers.remove(ApiConstants.contentTypeHeader); // Let Dio handle
//       }
//     } else {
//       // Prefer JSON
//       options.headers[ApiConstants.acceptHeader] = ApiConstants.jsonContentType;
//       options.responseType = ResponseType.json;
//       if (options.data != null && options.data is! FormData && options.data is! Stream && options.data is! Uint8List) {
//         options.headers[ApiConstants.contentTypeHeader] = ApiConstants.jsonContentType;
//       } else if (options.data is FormData || options.data is Stream || options.data is Uint8List) {
//         options.headers.remove(ApiConstants.contentTypeHeader); // Let Dio handle
//       }
//     }
//
//     handler.next(options);
//   }
//
//   @override
//   Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
//     Log.d('<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
//     Log.v('Response Headers: ${response.headers}');
//     // Log.v('Response Data: ${response.data}'); // Usually handled by MsgpackConverter or JSON default
//
//     // Response deserialization is handled by MsgpackConverter or default Dio transformer
//     // based on the response Content-Type and options.responseType set in onRequest.
//
//     // Pass the response along
//     handler.next(response);
//   }
//
//   @override
//   Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
//     Log.e('<-- ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.method} ${err.requestOptions.uri}', error: err.error, stackTrace: err.stackTrace);
//     Log.e('DioError Type: ${err.type}');
//      if (err.response?.data != null) {
//         Log.e('DioError Response Data: ${err.response!.data}');
//      }
//
//     // --- Optional: Token Refresh Logic ---
//     // if (err.response?.statusCode == 401) {
//     //   Log.i('Received 401 Unauthorized for ${err.requestOptions.path}. Attempting token refresh.');
//     //   // Avoid retry loop if refresh token itself failed or it's not a token error
//     //   if (err.requestOptions.path == ApiConstants.refreshToken) {
//     //     Log.e('Refresh token request failed. Cannot refresh.');
//     //     // Clear tokens and trigger logout state?
//     //     // await _storageService.deleteUserToken();
//     //     // await _storageService.deleteRefreshToken();
//     //     return handler.next(err); // Propagate the original error
//     //   }
//     //
//     //   try {
//     //     // 1. Get refresh token
//     //     final refreshToken = await _storageService.getRefreshToken();
//     //     if (refreshToken == null || refreshToken.isEmpty) {
//     //       Log.e('No refresh token found. Cannot refresh.');
//     //       return handler.next(err);
//     //     }
//     //
//     //     // 2. Request new token (Requires a separate Dio instance or careful handling)
//     //     // IMPORTANT: Use a Dio instance *without* this interceptor for the refresh call!
//     //     // Or use the injected _dio instance with a flag to skip interception.
//     //     Log.d('Requesting new token using refresh token.');
//     //     // Example: Assuming a method exists in AuthService or directly using ApiClient
//     //     // final refreshResponse = await sl<AuthService>().refreshToken(refreshToken);
//     //     // Or direct call (use separate Dio instance):
//     //     // final dioRefresh = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
//     //     // final refreshResponse = await dioRefresh.post(
//     //     //    ApiConstants.refreshToken, data: {'refresh': refreshToken}
//     //     // );
//     //     // if (refreshResponse.statusCode == 200) {
//     //     //    final newAccessToken = refreshResponse.data['access'];
//     //     //    final newRefreshToken = refreshResponse.data['refresh']; // Check if backend rotates refresh tokens
//     //     //    await _storageService.saveUserToken(newAccessToken);
//     //     //    if (newRefreshToken != null) {
//     //     //        await _storageService.saveRefreshToken(newRefreshToken);
//     //     //    }
//     //     //    Log.i('Token refreshed successfully. Retrying original request.');
//     //     //
//     //     //    // 3. Clone original request with new token and retry
//     //     //    final originalRequest = err.requestOptions;
//     //     //    originalRequest.headers[ApiConstants.authorizationHeader] = 'Bearer $newAccessToken';
//     //     //
//     //     //    // Use dio.fetch to retry the request. Pass the original RequestOptions.
//     //     //    final retryResponse = await _dio.fetch(originalRequest);
//     //     //    return handler.resolve(retryResponse); // Resolve with the new response
//     //     // } else {
//     //     //    Log.e('Token refresh API call failed with status: ${refreshResponse.statusCode}');
//     //     // }
//     //
//     //   } catch (refreshError) {
//     //     Log.e('Exception during token refresh', error: refreshError);
//     //     // Clear tokens if refresh fails definitively?
//     //     // await _storageService.deleteUserToken();
//     //     // await _storageService.deleteRefreshToken();
//     //   }
//     // }
//     // --- End Token Refresh Logic ---
//
//     // --- Optional: Offline Queueing Logic ---
//     // Based on your example ApiClient, queueing could happen here for network errors
//     // if (!await _networkInfo.isConnected && _isNetworkError(err)) {
//     //    Log.i('Network error and offline. Queueing request: ${err.requestOptions.path}');
//     //    // TODO: Implement request queueing logic (e.g., save to local storage)
//     //    // Potentially resolve the handler with a custom response/error indicating it's queued?
//     //    // Or just reject with the original error after queuing?
//     //    // Example:
//     //    // await sl<OfflineQueueService>().queueRequest(err.requestOptions);
//     //    // return handler.reject(err); // Or resolve with custom indicator
//     // }
//     // --- End Offline Queueing Logic ---
//
//
//     // If not handled by token refresh or offline logic, pass the error along
//     handler.next(err);
//   }
//
//   // Helper to check if a DioException represents a network connectivity issue
//   // bool _isNetworkError(DioException error) {
//   //   return error.type == DioExceptionType.connectionTimeout ||
//   //       error.type == DioExceptionType.receiveTimeout ||
//   //       error.type == DioExceptionType.sendTimeout ||
//   //       error.type == DioExceptionType.connectionError ||
//   //       error.type == DioExceptionType.unknown; // Unknown can sometimes be network related
//   // }
// }
