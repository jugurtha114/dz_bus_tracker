// lib/core/utils/date_utils.dart

import 'package:intl/intl.dart';

class DzDateUtils {
  // Format date for display
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }

  // Format time for display
  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    final formatter = DateFormat(format);
    return formatter.format(time);
  }

  // Format date and time for display
  static String formatDateTime(DateTime dateTime, {String format = 'yyyy-MM-dd HH:mm'}) {
    final formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  // Get relative time (e.g., "2 minutes ago")
  static String timeAgo(DateTime dateTime, {String locale = 'en'}) {
    return getTimeAgo(dateTime, locale: locale);
  }

  // Get relative time (e.g., "2 minutes ago")
  static String getTimeAgo(DateTime dateTime, {String locale = 'en'}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${_getYearText(locale, (difference.inDays / 365).floor())} ago';
    }
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${_getMonthText(locale, (difference.inDays / 30).floor())} ago';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} ${_getDayText(locale, difference.inDays)} ago';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} ${_getHourText(locale, difference.inHours)} ago';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${_getMinuteText(locale, difference.inMinutes)} ago';
    }
    return _getJustNowText(locale);
  }

  // Helper methods for time ago text
  static String _getYearText(String locale, int count) {
    switch (locale) {
      case 'fr':
        return count > 1 ? 'ans' : 'an';
      case 'ar':
        return count > 1 ? 'سنوات' : 'سنة';
      default:
        return count > 1 ? 'years' : 'year';
    }
  }

  static String _getMonthText(String locale, int count) {
    switch (locale) {
      case 'fr':
        return count > 1 ? 'mois' : 'mois';
      case 'ar':
        return count > 1 ? 'أشهر' : 'شهر';
      default:
        return count > 1 ? 'months' : 'month';
    }
  }

  static String _getDayText(String locale, int count) {
    switch (locale) {
      case 'fr':
        return count > 1 ? 'jours' : 'jour';
      case 'ar':
        return count > 1 ? 'أيام' : 'يوم';
      default:
        return count > 1 ? 'days' : 'day';
    }
  }

  static String _getHourText(String locale, int count) {
    switch (locale) {
      case 'fr':
        return count > 1 ? 'heures' : 'heure';
      case 'ar':
        return count > 1 ? 'ساعات' : 'ساعة';
      default:
        return count > 1 ? 'hours' : 'hour';
    }
  }

  static String _getMinuteText(String locale, int count) {
    switch (locale) {
      case 'fr':
        return count > 1 ? 'minutes' : 'minute';
      case 'ar':
        return count > 1 ? 'دقائق' : 'دقيقة';
      default:
        return count > 1 ? 'minutes' : 'minute';
    }
  }

  static String _getJustNowText(String locale) {
    switch (locale) {
      case 'fr':
        return 'à l\'instant';
      case 'ar':
        return 'الآن';
      default:
        return 'just now';
    }
  }

  // Calculate time difference in minutes
  static int getMinutesDifference(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  // Format day of week
  static String getDayOfWeek(int dayOfWeek, {String locale = 'en'}) {
    final days = {
      'en': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      'fr': ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'],
      'ar': ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'],
    };

    return days[locale]?[dayOfWeek - 1] ?? days['en']![dayOfWeek - 1];
  }

  // Get short day of week
  static String getShortDayOfWeek(int dayOfWeek, {String locale = 'en'}) {
    final days = {
      'en': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'fr': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
      'ar': ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'],
    };

    return days[locale]?[dayOfWeek - 1] ?? days['en']![dayOfWeek - 1];
  }

  // Get month name
  static String getMonthName(int month, {String locale = 'en'}) {
    final months = {
      'en': [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ],
      'fr': [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ],
      'ar': [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ],
    };

    return months[locale]?[month - 1] ?? months['en']![month - 1];
  }
}