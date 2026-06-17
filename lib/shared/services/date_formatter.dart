import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final _monthDay = DateFormat('MM月dd日');
  static final _full = DateFormat('yyyy年MM月dd日');

  static String monthDay(DateTime date) => _monthDay.format(date);

  static String full(DateTime date) => _full.format(date);

  static String fullWithToday(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final label = full(date);
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    return isToday ? '$label（今天）' : label;
  }

  static String monthYear(DateTime date) => DateFormat('yyyy年M月').format(date);
}
