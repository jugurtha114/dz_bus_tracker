/// lib/core/utils/logger.dart

import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:logger/logger.dart';

/// A utility class for centralized application logging.
/// Uses the `logger` package for formatted and level-controlled output.
///
/// Usage:
/// ```dart
/// Log.d('This is a debug message');
/// Log.i('Information message');
/// Log.w('Warning message');
/// Log.e('Error message', error: exception, stackTrace: stack);
/// Log.v('Verbose message');
/// ```
class Log {
  // Private constructor to prevent instantiation
  Log._();

  // Configure the logger instance
  static final Logger _logger = Logger(
    // Define the printer for log message format
    printer: PrettyPrinter(
      methodCount: 1, // Number of method calls to be displayed in stacktrace (0 = none)
      errorMethodCount: 8, // Number of method calls if stacktrace is provided for error
      lineLength: 100, // Width of the log print
      colors: true, // Use colors for different log levels
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Include timestamp in log output
      // Optional: Customize level colors
      // levelColors: {
      //   Level.verbose: AnsiColor.fg(AnsiColor.grey(0.5)),
      //   // ... other levels
      // },
      // Optional: Customize level emojis
      // levelEmojis: {
      //   Level.verbose: '🔬',
      //   // ... other levels
      // },
    ),
    // Define the filter to control which logs are shown based on build mode
    filter: kDebugMode
        ? DevelopmentFilter() // Shows all logs (verbose and up) in debug mode
        : ProductionFilter(), // Shows only warning and error in release mode
    // Optional: Define output handler (defaults to ConsoleOutput)
    // output: ConsoleOutput(),
  );

  /// Logs a verbose message (Level.verbose/trace). Least important.
  /// Use for detailed tracing. Only shown in debug mode by default.
  static void v(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace); // 't' is trace/verbose in logger package
  }

  /// Logs a debug message (Level.debug).
  /// Use for debugging information during development. Only shown in debug mode by default.
  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an informational message (Level.info).
  /// Use for general app flow information. Only shown in debug mode by default.
  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message (Level.warning).
  /// Use for potential issues that don't stop execution. Shown in debug and release mode by default.
  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message (Level.error).
  /// Use for errors that have occurred, potentially recoverable. Shown in debug and release mode.
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal error message (Level.fatal/wtf).
  /// Use for critical errors that should not happen. Shown in debug and release mode.
  static void fatal(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace); // 'f' is fatal in logger package
  }
}
