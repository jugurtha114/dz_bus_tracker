// lib/helpers/dialog_helper.dart (continued)

import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class DialogHelper {
  // Show confirmation dialog
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
        bool barrierDismissible = true,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Show information dialog
  static Future<void> showInfoDialog(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'OK',
      }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Show loading dialog
  static Future<void> showLoadingDialog(
      BuildContext context, {
        String message = 'Loading...',
      }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  // Show success dialog
  static Future<void> showSuccessDialog(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'OK',
      }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 8, height: 40),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Show custom dialog with glassy effect
  static Future<T?> showGlassyDialog<T>(
      BuildContext context, {
        required Widget child,
        bool barrierDismissible = true,
        Color barrierColor = Colors.black54,
      }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: AppTheme.glassContainer(
          child: child,
          borderRadius: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Show bottom sheet
  static Future<T?> showAppBottomSheet<T>(
      BuildContext context, {
        required Widget child,
        bool isScrollControlled = true,
        bool isDismissible = true,
        bool enableDrag = true,
        Color? backgroundColor,
      }) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
        
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }

  // Show glassy bottom sheet
  static Future<T?> showGlassyBottomSheet<T>(
      BuildContext context, {
        required Widget child,
        bool isScrollControlled = true,
        bool isDismissible = true,
        bool enableDrag = true,
      }) async {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
        
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AppTheme.glassContainer(
                    child: child,
                    borderRadius: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}