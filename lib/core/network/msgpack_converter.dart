/// lib/core/network/msgpack_converter.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
// Use the correct messagepack utility
import '../utils/msgpack_utils.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';
import '../exceptions/app_exceptions.dart';

/// A Dio [BackgroundTransformer] that handles deserializing MessagePack responses.
///
/// Uses [MsgpackUtils.unpackObject] to decode the byte stream if the response
/// is identified as MessagePack via its Content-Type header. Otherwise, it falls
/// back to Dio's default JSON transformer.
class MsgpackConverter extends BackgroundTransformer {
  MsgpackConverter() : super();

  @override
  Future<String> transformRequest(RequestOptions options) async {
    // Request serialization is handled by ApiInterceptor using MsgpackUtils.packObject
    // This method primarily handles default JSON encoding as fallback.
    final dynamic data = options.data;
    if (data != null && data is! String && data is! Stream && data is! FormData && data is! Uint8List) {
      try {
        return super.transformRequest(options);
      } catch (e, stackTrace) {
        // CORRECTED: Reverted logging to use named arguments as requested
        Log.e('MsgpackConverter: Error during default JSON request transformation', error: e, stackTrace: stackTrace);
        throw DataParsingException(message: 'Failed to encode request data to JSON.', details: e);
      }
    }
    return ''; // Let Dio handle other types or empty string for binary
  }

  @override
  Future<dynamic> transformResponse(RequestOptions options, ResponseBody responseBody) async {
    final responseType = options.responseType;
    final String? contentType = responseBody.headers[Headers.contentTypeHeader]?.first?.toLowerCase();
    final bool isMsgpackResponse = contentType?.contains(ApiConstants.msgpackContentType) ?? false;

    if (isMsgpackResponse && responseType == ResponseType.bytes) {
      Log.d('MsgpackConverter: Received Msgpack response for: ${options.uri}');
      try {
        // CORRECTED: Consume Stream<Uint8List> into a single Uint8List
        final Completer<Uint8List> bytesCompleter = Completer<Uint8List>();
        final BytesBuilder bytesBuilder = BytesBuilder(copy: false);
        StreamSubscription<Uint8List>? subscription;

        subscription = responseBody.stream.listen(
              (chunk) => bytesBuilder.add(chunk),
          onError: (error, stackTrace) {
            // CORRECTED: Reverted logging to use named arguments
            Log.e('MsgpackConverter: Error reading response stream', error: error, stackTrace: stackTrace);
            if (!bytesCompleter.isCompleted) {
              subscription?.cancel(); // Cancel if error occurs
              bytesCompleter.completeError(error, stackTrace);
            }
          },
          onDone: () {
            if (!bytesCompleter.isCompleted) {
              bytesCompleter.complete(bytesBuilder.takeBytes());
            }
          },
          cancelOnError: true, // Automatically cancel on error
        );

        // Await the completion of the stream reading
        final Uint8List bytes = await bytesCompleter.future;

        if (bytes.isEmpty) {
          Log.w('MsgpackConverter: Received empty Msgpack response body for: ${options.uri}');
          return null;
        }

        // Deserialize bytes using the utility function
        final dynamic deserializedData = MsgpackUtils.unpackObject(bytes);
        Log.v('MsgpackConverter: Msgpack deserialized data: $deserializedData');
        return deserializedData;

      } on DataParsingException {
        rethrow; // Re-throw specific parsing exceptions from the util
      } catch (e, stackTrace) {
        // CORRECTED: Reverted logging to use named arguments
        Log.e('MsgpackConverter: Error processing Msgpack response for ${options.uri}', error: e, stackTrace: stackTrace);
        throw DataParsingException(
          message: 'Failed to process MessagePack response bytes.',
          code: 'msgpack_process_error',
          details: e.toString(),
        );
      }
    } else {
      // Fallback to default JSON transformer.
      Log.d('MsgpackConverter: Falling back to default JSON transformer for: ${options.uri} (Content-Type: $contentType, ResponseType: $responseType)');
      return super.transformResponse(options, responseBody);
    }
  }
}