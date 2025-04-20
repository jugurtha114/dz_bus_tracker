/// lib/core/utils/date_utils.dart

import 'package:flutter/material.dart'; // For Locale access if needed
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // For initializing locales
import 'package:timeago/timeago.dart' as timeago; // Use prefix to avoid conflicts

import '../utils/logger.dart'; // For logging errors

/// Utility class for common date and time operations like formatting and parsing.
class DateUtil {
  // Private constructor to prevent instantiation
  DateUtil._();

  static bool _intlInitialized = false;
  static bool _timeagoInitialized = false;

  /// Initializes localization data for both `intl` and `timeago` packages.
  /// Should be called once during app startup (e.g., in main.dart).
  static Future<void> initializeLocalization() async {
    if (!_intlInitialized) {
      try {
        // Load locale data for date formatting (consider loading only needed locales)
        await initializeDateFormatting();
        _intlInitialized = true;
        Log.d('Intl localization data initialized.');
      } catch (e, stackTrace) {
         Log.e('Failed to initialize Intl locale data', error: e, stackTrace: stackTrace);
         // Continue without intl initialization? Or throw?
      }
    }
    if (!_timeagoInitialized) {
       try {
        // Setup locales for the 'timeago' package
        // TODO: Add more locales as needed (e.g., Arabic)
        timeago.setLocaleMessages('fr', timeago.FrMessages());
        timeago.setLocaleMessages('en', timeago.EnMessages());
        // timeago.setLocaleMessages('ar', timeago.ArMessages()); // Add when available or create custom
        _timeagoInitialized = true;
        Log.d('Timeago localization data initialized.');
       } catch (e, stackTrace) {
          Log.e('Failed to initialize Timeago locale data', error: e, stackTrace: stackTrace);
       }
    }
  }

  /// Formats a [DateTime] object into a string based on the provided [format] and [locale].
  ///
  /// Common formats:
  /// - 'HH:mm' (e.g., 14:30)
  /// - 'dd/MM/yyyy' (e.g., 16/04/2025)
  /// - 'd MMM yyyy' (e.g., 16 Apr 2025)
  /// - 'EEEE, d MMMM yyyy' (e.g., Wednesday, 16 April 2025)
  /// - 'HH:mm, dd MMM' (e.g., 14:30, 16 Apr)
  ///
  /// Returns a placeholder ('-') if [dateTime] is null.
  /// Ensure [initializeLocalization] has been called for custom locales.
  static String formatDateTime(
    DateTime? dateTime, {
    String format = 'HH:mm, dd MMM yyyy', // Default format
    String? locale, // Uses Intl default locale if null
  }) {
    if (dateTime == null) return '-';
    if (!_intlInitialized) {
       Log.w('Intl not initialized, formatting may use default locale/patterns.');
       // Attempt initialization just in case it wasn't called
       // initializeLocalization(); // This might cause issues if called repeatedly
    }
    try {
      return DateFormat(format, locale).format(dateTime);
    } catch (e, stackTrace) {
      Log.e('Error formatting date', error: e, stackTrace: stackTrace);
      // Fallback to ISO string on error
      return dateTime.toIso8601String();
    }
  }

  /// Calculates and formats the relative time difference between [dateTime] and now.
  ///
  /// Examples: "5 minutes ago", "in 2 hours", "yesterday".
  /// Returns a placeholder ('-') if [dateTime] is null.
  /// Uses the `timeago` package for relative formatting.
  /// Ensure [initializeLocalization] has been called for correct language output.
  static String timeAgoOrUntil(DateTime? dateTime, {String? locale}) {
    if (dateTime == null) return '-';
     if (!_timeagoInitialized) {
       Log.w('Timeago not initialized, formatting may use default locale.');
    }
    try {
       // Use timeago.format, providing the current locale if available
       return timeago.format(dateTime, locale: locale);
    } catch (e, stackTrace) {
       Log.e('Error formatting time ago', error: e, stackTrace: stackTrace);
       // Fallback to simple date format on error
       return formatDateTime(dateTime, format: 'dd/MM/yyyy', locale: locale);
    }
  }

  /// Parses an ISO 8601 formatted string into a [DateTime] object.
  ///
  /// Returns null if the string is null or cannot be parsed.
  static DateTime? parseIsoDateTime(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString).toLocal(); // Convert to local timezone
    } catch (e) {
      Log.w('Failed to parse ISO date time string: $dateString', error: e);
      return null;
    }
  }

  /// Checks if two DateTime objects represent the same calendar day.
  /// Ignores the time component. Returns false if either date is null.
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Formats a Duration into a human-readable string (e.g., "1h 30m", "45s").
  static String formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s'; // TODO: Localize 's'
    } else if (duration.inMinutes < 60) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return seconds == 0 ? '${minutes}m' : '${minutes}m ${seconds}s'; // TODO: Localize 'm', 's'
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m'; // TODO: Localize 'h', 'm'
    }
  }

   /// Calculates the number of minutes remaining until a future [dateTime].
   /// Returns null if the date is null or in the past.
   static int? minutesUntil(DateTime? dateTime) {
      if (dateTime == null) return null;
      final now = DateTime.now();
      if (dateTime.isBefore(now)) return null;
      return dateTime.difference(now).inMinutes;
   }
}
