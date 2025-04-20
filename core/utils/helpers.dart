/// lib/core/utils/helpers.dart

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart'; // For spacing if needed
// Import localization extension if created
// import '../../i18n/app_localizations.dart';

/// A utility class containing miscellaneous helper functions.
class Helpers {
  // Private constructor to prevent instantiation
  Helpers._();

  /// Hides the currently focused keyboard.
  static void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  /// Shows a simple SnackBar message at the bottom of the screen.
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Ensure we have a scaffold messenger context
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) {
      // Handle cases where context might not have ScaffoldMessenger (less common)
      debugPrint('Error: Could not find ScaffoldMessenger to show SnackBar.');
      return;
    }

    scaffoldMessenger.hideCurrentSnackBar(); // Remove existing snackbar first
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).snackBarTheme.backgroundColor,
        behavior: SnackBarBehavior.floating, // Or .fixed
        duration: duration,
        action: SnackBarAction(
           label: 'Dismiss', // TODO: Localize 'Dismiss'
           textColor: isError ? Colors.white : Theme.of(context).colorScheme.primary,
           onPressed: () {
              scaffoldMessenger.hideCurrentSnackBar();
           },
        ),
      ),
    );
  }

  /// Shows a non-dismissible loading indicator dialog.
  /// Remember to call Navigator.pop(context) to dismiss it when loading is complete.
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    // TODO: Localize 'Loading...' message
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: ThemeConstants.spacingMedium),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog.
  /// Returns `true` if the confirm action is pressed, `false` otherwise (or if dismissed).
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm', // TODO: Localize
    String cancelText = 'Cancel', // TODO: Localize
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
            ),
            ElevatedButton(
              child: Text(confirmText),
              style: ElevatedButton.styleFrom(
                 backgroundColor: Theme.of(context).colorScheme.primary, // Or error color if destructive
                 foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true on confirm
              },
            ),
          ],
        );
      },
    );
    // Return false if the dialog was dismissed without pressing a button (result is null)
    return result ?? false;
  }

  // Add other general helper functions as needed, for example:
  // - Launching URLs
  // - Simple platform checks (if not covered by Foundation)
  // - Basic formatters not specific to date/location/string
}
