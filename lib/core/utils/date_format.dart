import 'package:intl/intl.dart';

class AppDateFormat {
  static final _displayFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _relativeDayFormat = DateFormat('hh:mm a');
  static final _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  /// Parses an ISO 8601 UTC string (from backend) into a local DateTime
  static DateTime parseUtc(String isoString) {
    return _isoFormat.parse(isoString, true).toLocal();
  }

  /// Formats a DateTime for display. If it's today, shows "Today, 10:30 AM".
  /// Otherwise "24 Oct 2023, 10:30 AM"
  static String format(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today, ${_relativeDayFormat.format(date)}';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_relativeDayFormat.format(date)}';
    } else {
      return _displayFormat.format(date);
    }
  }
}
