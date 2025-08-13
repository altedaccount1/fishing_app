// utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  // Date formats
  static final DateFormat _shortDate = DateFormat('M/d/yyyy');
  static final DateFormat _longDate = DateFormat('MMMM d, yyyy');
  static final DateFormat _shortTime = DateFormat('h:mm a');
  static final DateFormat _longTime = DateFormat('h:mm:ss a');
  static final DateFormat _dateTime = DateFormat('M/d/yyyy h:mm a');
  static final DateFormat _fullDateTime = DateFormat('MMMM d, yyyy h:mm a');

  /// Format date as "3/14/2024"
  static String formatShortDate(DateTime date) {
    return _shortDate.format(date);
  }

  /// Format date as "March 14, 2024"
  static String formatLongDate(DateTime date) {
    return _longDate.format(date);
  }

  /// Format time as "2:30 PM"
  static String formatShortTime(DateTime date) {
    return _shortTime.format(date);
  }

  /// Format time as "2:30:45 PM"
  static String formatLongTime(DateTime date) {
    return _longTime.format(date);
  }

  /// Format date and time as "3/14/2024 2:30 PM"
  static String formatDateTime(DateTime date) {
    return _dateTime.format(date);
  }

  /// Format date and time as "March 14, 2024 2:30 PM"
  static String formatFullDateTime(DateTime date) {
    return _fullDateTime.format(date);
  }

  /// Get relative time like "2 hours ago", "Yesterday", etc.
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${difference.inDays} days ago';
      }
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Get tournament date display (handles upcoming vs past differently)
  static String getTournamentDateDisplay(DateTime date, String status) {
    if (status == 'upcoming') {
      if (isToday(date)) {
        return 'Today at ${formatShortTime(date)}';
      } else if (date.difference(DateTime.now()).inDays == 1) {
        return 'Tomorrow at ${formatShortTime(date)}';
      } else if (date.difference(DateTime.now()).inDays <= 7) {
        return '${DateFormat('EEEE').format(date)} at ${formatShortTime(date)}';
      } else {
        return formatLongDate(date);
      }
    } else {
      return formatShortDate(date);
    }
  }

  /// Format duration for tournament runtime
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
