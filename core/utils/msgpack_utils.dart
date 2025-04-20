/// lib/core/utils/msgpack_utils.dart

import 'dart:typed_data';
// Import the message_pack_dart library
// Note: Check the actual import path after adding the dependency
import 'package:message_pack_dart/message_pack_dart.dart' as msgpack;
import 'logger.dart';
import '../exceptions/app_exceptions.dart'; // For DataParsingException

/// Utility functions for serializing and deserializing Dart objects
/// using the `message_pack_dart` package.
class MsgpackUtils {
  MsgpackUtils._(); // Prevents instantiation

  /// Serializes (packs) a Dart object into a MessagePack byte list (Uint8List).
  /// Handles basic types, Lists, and Maps supported by the library.
  /// Throws [DataParsingException] if serialization fails.
  static Uint8List packObject(dynamic value) {
    try {
      // Use the library's static encode/serialize method
      // Adjust method name if the library uses something else (e.g., serialize)
      return msgpack.serialize(value);
    } catch (e, stackTrace) {
      Log.e('MsgpackUtils: Failed to serialize object', error:e, stackTrace:stackTrace);
      throw DataParsingException(
        message: 'Failed to serialize data to MessagePack.',
        details: e.toString(),
      );
    }
  }

  /// Deserializes (unpacks) MessagePack bytes (Uint8List) into a Dart object.
  /// Returns the deserialized object (e.g., Map, List, String, int).
  /// Throws [DataParsingException] if deserialization fails.
  static dynamic unpackObject(Uint8List bytes) {
    if (bytes.isEmpty) {
      Log.w('MsgpackUtils: Attempted to unpack empty byte list.');
      return null; // Or handle as needed, maybe throw?
    }
    try {
      // Use the library's static decode/deserialize method
      // Adjust method name if the library uses something else (e.g., decode)
      return msgpack.deserialize(bytes);
    } catch (e, stackTrace) {
      Log.e('MsgpackUtils: Failed to deserialize MessagePack bytes', error: e, stackTrace:  stackTrace);
      throw DataParsingException(
        message: 'Failed to deserialize MessagePack data.',
        details: e.toString(),
      );
    }
  }
}