// lib/helpers/error_handler.dart

import 'package:flutter/material.dart';
import '../core/exceptions/app_exceptions.dart';

/// Error type enumeration for categorizing different types of errors
enum ErrorType {
  unknown,
  network,
  server,
  validation,
  authentication,
  permission,
  notFound,
  timeout,
  general,
}

class ErrorHandler {
  // Handle error and return appropriate message
  static String handleError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is LocationException) {
      return error.message;
    } else if (error is CacheException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return error?.toString() ?? 'An unknown error occurred';
    }
  }

  // Alias for handleError for backward compatibility
  static String getErrorMessage(dynamic error) {
    return handleError(error);
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onPressed != null) {
                onPressed();
              }
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
      ),
    );
  }

  // Log error
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    // In a real app, you would log this to a service like Firebase Crashlytics
    debugPrint('ERROR: ${error.toString()}');
    if (stackTrace != null) {
      debugPrint('STACK TRACE: ${stackTrace.toString()}');
    }
  }

  // Parse field errors from ValidationException
  static Map<String, String> parseFieldErrors(ValidationException error) {
    final fieldErrors = <String, String>{};

    error.fieldErrors.forEach((key, errors) {
      if (errors.isNotEmpty) {
        fieldErrors[key] = errors.first;
      }
    });

    return fieldErrors;
  }
}
