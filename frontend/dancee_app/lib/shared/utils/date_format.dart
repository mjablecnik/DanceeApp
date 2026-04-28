import '../../i18n/strings.g.dart';

/// Returns a localized abbreviated month name for [month] (1–12).
String _monthAbbrev(int month) {
  switch (month) {
    case 1:
      return t.common.months.jan;
    case 2:
      return t.common.months.feb;
    case 3:
      return t.common.months.mar;
    case 4:
      return t.common.months.apr;
    case 5:
      return t.common.months.may;
    case 6:
      return t.common.months.jun;
    case 7:
      return t.common.months.jul;
    case 8:
      return t.common.months.aug;
    case 9:
      return t.common.months.sep;
    case 10:
      return t.common.months.oct;
    case 11:
      return t.common.months.nov;
    case 12:
      return t.common.months.dec;
    default:
      return '';
  }
}

/// Formats a [DateTime] as "D Mon YYYY" using localized month abbreviations.
/// Example: "5 Jan 2025"
String formatDate(DateTime dt) {
  return '${dt.day} ${_monthAbbrev(dt.month)} ${dt.year}';
}

/// Formats a [DateTime] as "HH:MM" (24-hour).
/// Example: "14:30"
String formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Formats a nullable date string from CMS (ISO 8601) as "D Mon YYYY".
/// Returns [dateStr] as-is if it cannot be parsed, or empty string if null.
String formatDateString(String? dateStr) {
  if (dateStr == null) return '';
  final dt = DateTime.tryParse(dateStr);
  if (dt == null) return dateStr;
  return formatDate(dt);
}

/// Formats an optional date range from two CMS date strings.
/// Returns "D Mon – D Mon YYYY" for multi-day, or "D Mon YYYY" for single date/same dates.
String formatDateRange(String? startDate, String? endDate) {
  if (startDate == null) return '';
  final start = DateTime.tryParse(startDate);
  if (start == null) return startDate;
  final startStr = '${start.day} ${_monthAbbrev(start.month)}';
  if (endDate != null && endDate != startDate) {
    final end = DateTime.tryParse(endDate);
    if (end != null) {
      return '$startStr – ${end.day} ${_monthAbbrev(end.month)} ${end.year}';
    }
  }
  return '$startStr ${start.year}';
}
