// lib/helpers/permission_helper.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/exceptions/app_exceptions.dart';
import 'dialog_helper.dart';

class PermissionHelper {
  // Request location permission
  static Future<bool> requestLocation(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show dialog to open settings
      final shouldOpenSettings = await DialogHelper.showConfirmDialog(
        context,
        title: 'Location Permission Required',
        message:
            'Location permission is required for this feature. Please enable it in app settings.',
        confirmText: 'Open Settings',
        cancelText: 'Cancel',
      );

      if (shouldOpenSettings) {
        await Geolocator.openAppSettings();
        return await Geolocator.checkPermission() != LocationPermission.denied;
      }

      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Request notification permission
  static Future<bool> requestNotification(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      final shouldOpenSettings = await DialogHelper.showConfirmDialog(
        context,
        title: 'Notification Permission Required',
        message:
            'Notification permission is required for this feature. Please enable it in app settings.',
        confirmText: 'Open Settings',
        cancelText: 'Cancel',
      );

      if (shouldOpenSettings) {
        await openAppSettings();
        return await Permission.notification.status.isGranted;
      }

      return false;
    }

    return status.isGranted;
  }

  // Request camera permission
  static Future<bool> requestCamera(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      final shouldOpenSettings = await DialogHelper.showConfirmDialog(
        context,
        title: 'Camera Permission Required',
        message:
            'Camera permission is required for this feature. Please enable it in app settings.',
        confirmText: 'Open Settings',
        cancelText: 'Cancel',
      );

      if (shouldOpenSettings) {
        await openAppSettings();
        return await Permission.camera.status.isGranted;
      }

      return false;
    }

    return status.isGranted;
  }

  // Request storage permission
  static Future<bool> requestStorage(BuildContext context) async {
    final status = await Permission.storage.status;

    if (status.isDenied) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      final shouldOpenSettings = await DialogHelper.showConfirmDialog(
        context,
        title: 'Storage Permission Required',
        message:
            'Storage permission is required for this feature. Please enable it in app settings.',
        confirmText: 'Open Settings',
        cancelText: 'Cancel',
      );

      if (shouldOpenSettings) {
        await openAppSettings();
        return await Permission.storage.status.isGranted;
      }

      return false;
    }

    return status.isGranted;
  }

  // Check permission status
  static Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  // Handle permission exception
  static void handlePermissionException(
    BuildContext context,
    LocationException exception,
  ) {
    if (exception.message.contains('Location permission is denied')) {
      DialogHelper.showConfirmDialog(
        context,
        title: 'Location Permission Required',
        message: 'Please enable location permission to use this feature.',
        confirmText: 'Open Settings',
        cancelText: 'Cancel',
      ).then((shouldOpenSettings) {
        if (shouldOpenSettings) {
          Geolocator.openAppSettings();
        }
      });
    } else if (exception.message.contains('Location services are disabled')) {
      DialogHelper.showConfirmDialog(
        context,
        title: 'Location Services Disabled',
        message: 'Please enable location services to use this feature.',
        confirmText: 'Open Settings',
        cancelText: 'Cancel',
      ).then((shouldOpenSettings) {
        if (shouldOpenSettings) {
          Geolocator.openLocationSettings();
        }
      });
    } else {
      DialogHelper.showInfoDialog(
        context,
        title: 'Location Error',
        message: exception.message,
      );
    }
  }
}
