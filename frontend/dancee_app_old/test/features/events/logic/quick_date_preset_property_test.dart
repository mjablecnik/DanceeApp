import 'package:dancee_app/features/events/logic/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Feature: event-search-filter, Property 6: Quick date preset computation
//
// For any date representing "now", each quick date preset must produce the
// correct dateFrom and dateTo:
//
// - Today:     from = today 00:00:00, to = today 23:59:59
// - Tomorrow:  from = tomorrow 00:00:00, to = tomorrow 23:59:59
// - This Week: from = today 00:00:00, to = next Sunday 23:59:59
// - Weekend:   from = next Saturday 00:00:00 (or today if already Saturday),
//              to = next Sunday 23:59:59
//
// Validates: Requirements 5.7
// ---------------------------------------------------------------------------

void main() {
  group('Property 6: Quick date preset computation', () {
    // Helper to create a DateTime at midnight
    DateTime midnight(DateTime d) => DateTime(d.year, d.month, d.day);
    // Helper to create a DateTime at end of day
    DateTime endOfDay(DateTime d) =>
        DateTime(d.year, d.month, d.day, 23, 59, 59);

    // -------------------------------------------------------------------------
    // todayPreset
    // -------------------------------------------------------------------------
    group('todayPreset', () {
      test('start is midnight of now', () {
        final now = DateTime(2025, 6, 15, 14, 30);
        final (from, to) = todayPreset(now);
        expect(from, equals(midnight(now)));
      });

      test('end is 23:59:59 of now', () {
        final now = DateTime(2025, 6, 15, 14, 30);
        final (from, to) = todayPreset(now);
        expect(to, equals(endOfDay(now)));
      });

      test('from and to are on the same day', () {
        final now = DateTime(2025, 3, 1, 9, 0);
        final (from, to) = todayPreset(now);
        expect(from.year, equals(to.year));
        expect(from.month, equals(to.month));
        expect(from.day, equals(to.day));
      });

      // Generate a set of representative "now" dates covering each weekday
      for (final nowDate in [
        DateTime(2025, 1, 6),  // Monday
        DateTime(2025, 1, 7),  // Tuesday
        DateTime(2025, 1, 8),  // Wednesday
        DateTime(2025, 1, 9),  // Thursday
        DateTime(2025, 1, 10), // Friday
        DateTime(2025, 1, 11), // Saturday
        DateTime(2025, 1, 12), // Sunday
      ]) {
        test('todayPreset on ${nowDate.weekday == 1 ? "Monday" : nowDate.weekday == 2 ? "Tuesday" : nowDate.weekday == 3 ? "Wednesday" : nowDate.weekday == 4 ? "Thursday" : nowDate.weekday == 5 ? "Friday" : nowDate.weekday == 6 ? "Saturday" : "Sunday"} returns correct range', () {
          final (from, to) = todayPreset(nowDate);
          expect(from, equals(midnight(nowDate)));
          expect(to, equals(endOfDay(nowDate)));
        });
      }

      test('from has zero time component', () {
        final now = DateTime(2025, 12, 31, 23, 59, 59);
        final (from, _) = todayPreset(now);
        expect(from.hour, equals(0));
        expect(from.minute, equals(0));
        expect(from.second, equals(0));
      });

      test('to has time 23:59:59', () {
        final now = DateTime(2025, 12, 31, 0, 0, 0);
        final (_, to) = todayPreset(now);
        expect(to.hour, equals(23));
        expect(to.minute, equals(59));
        expect(to.second, equals(59));
      });
    });

    // -------------------------------------------------------------------------
    // tomorrowPreset
    // -------------------------------------------------------------------------
    group('tomorrowPreset', () {
      test('start is midnight of tomorrow', () {
        final now = DateTime(2025, 6, 15, 14, 30);
        final tomorrow = now.add(const Duration(days: 1));
        final (from, _) = tomorrowPreset(now);
        expect(from, equals(midnight(tomorrow)));
      });

      test('end is 23:59:59 of tomorrow', () {
        final now = DateTime(2025, 6, 15, 14, 30);
        final tomorrow = now.add(const Duration(days: 1));
        final (_, to) = tomorrowPreset(now);
        expect(to, equals(endOfDay(tomorrow)));
      });

      test('from and to are one day after now', () {
        final now = DateTime(2025, 3, 1);
        final (from, to) = tomorrowPreset(now);
        expect(from.day, equals(2));
        expect(to.day, equals(2));
        expect(from.month, equals(3));
        expect(to.month, equals(3));
      });

      test('handles month boundary correctly (March 31 → April 1)', () {
        final now = DateTime(2025, 3, 31);
        final (from, to) = tomorrowPreset(now);
        expect(from.month, equals(4));
        expect(from.day, equals(1));
        expect(to.month, equals(4));
        expect(to.day, equals(1));
      });

      test('handles year boundary correctly (Dec 31 → Jan 1)', () {
        final now = DateTime(2025, 12, 31);
        final (from, to) = tomorrowPreset(now);
        expect(from.year, equals(2026));
        expect(from.month, equals(1));
        expect(from.day, equals(1));
        expect(to.year, equals(2026));
      });

      test('from has zero time component', () {
        final now = DateTime(2025, 6, 15, 14, 30);
        final (from, _) = tomorrowPreset(now);
        expect(from.hour, equals(0));
        expect(from.minute, equals(0));
        expect(from.second, equals(0));
      });

      test('to has time 23:59:59', () {
        final now = DateTime(2025, 6, 15, 14, 30);
        final (_, to) = tomorrowPreset(now);
        expect(to.hour, equals(23));
        expect(to.minute, equals(59));
        expect(to.second, equals(59));
      });
    });

    // -------------------------------------------------------------------------
    // thisWeekPreset
    // -------------------------------------------------------------------------
    group('thisWeekPreset', () {
      test('start is midnight of today', () {
        final now = DateTime(2025, 6, 11, 10, 0); // Wednesday
        final (from, _) = thisWeekPreset(now);
        expect(from, equals(midnight(now)));
      });

      test('end is Sunday 23:59:59 from a Monday', () {
        // 2025-01-06 is a Monday
        final now = DateTime(2025, 1, 6);
        final (_, to) = thisWeekPreset(now);
        // Sunday should be 2025-01-12
        expect(to, equals(DateTime(2025, 1, 12, 23, 59, 59)));
      });

      test('end is Sunday 23:59:59 from a Wednesday', () {
        // 2025-01-08 is a Wednesday
        final now = DateTime(2025, 1, 8);
        final (_, to) = thisWeekPreset(now);
        // Sunday should be 2025-01-12
        expect(to, equals(DateTime(2025, 1, 12, 23, 59, 59)));
      });

      test('end is Sunday 23:59:59 from a Saturday', () {
        // 2025-01-11 is a Saturday
        final now = DateTime(2025, 1, 11);
        final (_, to) = thisWeekPreset(now);
        // Sunday should be 2025-01-12
        expect(to, equals(DateTime(2025, 1, 12, 23, 59, 59)));
      });

      test('end is same day when today is Sunday', () {
        // 2025-01-12 is a Sunday
        final now = DateTime(2025, 1, 12);
        final (from, to) = thisWeekPreset(now);
        expect(from.day, equals(to.day));
        expect(to, equals(DateTime(2025, 1, 12, 23, 59, 59)));
      });

      test('from has zero time component', () {
        final now = DateTime(2025, 6, 11, 14, 30, 45);
        final (from, _) = thisWeekPreset(now);
        expect(from.hour, equals(0));
        expect(from.minute, equals(0));
        expect(from.second, equals(0));
      });

      test('to has time 23:59:59', () {
        final now = DateTime(2025, 6, 11, 14, 30, 45);
        final (_, to) = thisWeekPreset(now);
        expect(to.hour, equals(23));
        expect(to.minute, equals(59));
        expect(to.second, equals(59));
      });

      // For any now, to.weekday must be 7 (Sunday)
      for (final nowDate in [
        DateTime(2025, 1, 6),  // Monday
        DateTime(2025, 1, 7),  // Tuesday
        DateTime(2025, 1, 8),  // Wednesday
        DateTime(2025, 1, 9),  // Thursday
        DateTime(2025, 1, 10), // Friday
        DateTime(2025, 1, 11), // Saturday
        DateTime(2025, 1, 12), // Sunday
      ]) {
        test('to is always a Sunday (weekday=7) — input weekday=${nowDate.weekday}', () {
          final (_, to) = thisWeekPreset(nowDate);
          expect(to.weekday, equals(DateTime.sunday),
              reason: 'This Week preset must always end on a Sunday');
        });
      }

      // from must always be <= to
      test('from is always <= to', () {
        final testDates = [
          DateTime(2025, 1, 6),
          DateTime(2025, 1, 10),
          DateTime(2025, 1, 12),
          DateTime(2025, 6, 15),
          DateTime(2025, 12, 28),
        ];
        for (final now in testDates) {
          final (from, to) = thisWeekPreset(now);
          expect(from.isBefore(to) || from.isAtSameMomentAs(to), isTrue,
              reason: 'from must be <= to for $now');
        }
      });
    });

    // -------------------------------------------------------------------------
    // weekendPreset
    // -------------------------------------------------------------------------
    group('weekendPreset', () {
      test('from is Saturday 00:00:00 when today is Monday', () {
        // 2025-01-06 is a Monday; next Saturday is 2025-01-11
        final now = DateTime(2025, 1, 6);
        final (from, _) = weekendPreset(now);
        expect(from, equals(DateTime(2025, 1, 11)));
        expect(from.weekday, equals(DateTime.saturday));
      });

      test('to is Sunday 23:59:59 when today is Monday', () {
        // 2025-01-06 is a Monday; next Sunday is 2025-01-12
        final now = DateTime(2025, 1, 6);
        final (_, to) = weekendPreset(now);
        expect(to, equals(DateTime(2025, 1, 12, 23, 59, 59)));
        expect(to.weekday, equals(DateTime.sunday));
      });

      test('from is today when today is Saturday', () {
        // 2025-01-11 is a Saturday
        final now = DateTime(2025, 1, 11);
        final (from, _) = weekendPreset(now);
        expect(from, equals(DateTime(2025, 1, 11)));
        expect(from.weekday, equals(DateTime.saturday));
      });

      test('to is next Sunday when today is Saturday', () {
        // 2025-01-11 is a Saturday; next Sunday is 2025-01-12
        final now = DateTime(2025, 1, 11);
        final (_, to) = weekendPreset(now);
        expect(to, equals(DateTime(2025, 1, 12, 23, 59, 59)));
      });

      test('from is current Saturday when today is Sunday', () {
        // 2025-01-12 is a Sunday; current Saturday is 2025-01-11
        final now = DateTime(2025, 1, 12);
        final (from, _) = weekendPreset(now);
        expect(from, equals(DateTime(2025, 1, 11)));
        expect(from.weekday, equals(DateTime.saturday));
      });

      test('to is today (Sunday) when today is Sunday', () {
        // 2025-01-12 is a Sunday; end of today is 2025-01-12 23:59:59
        final now = DateTime(2025, 1, 12);
        final (_, to) = weekendPreset(now);
        expect(to, equals(DateTime(2025, 1, 12, 23, 59, 59)));
      });

      test('from is Saturday 00:00:00 when today is Friday', () {
        // 2025-01-10 is a Friday; next Saturday is 2025-01-11
        final now = DateTime(2025, 1, 10);
        final (from, _) = weekendPreset(now);
        expect(from, equals(DateTime(2025, 1, 11)));
        expect(from.weekday, equals(DateTime.saturday));
      });

      test('from has zero time component', () {
        final now = DateTime(2025, 1, 6, 14, 30, 45); // Monday
        final (from, _) = weekendPreset(now);
        expect(from.hour, equals(0));
        expect(from.minute, equals(0));
        expect(from.second, equals(0));
      });

      test('to has time 23:59:59', () {
        final now = DateTime(2025, 1, 6, 14, 30, 45); // Monday
        final (_, to) = weekendPreset(now);
        expect(to.hour, equals(23));
        expect(to.minute, equals(59));
        expect(to.second, equals(59));
      });

      // For any now, from.weekday must be 6 (Saturday) and to.weekday must be 7 (Sunday)
      for (final nowDate in [
        DateTime(2025, 1, 6),  // Monday
        DateTime(2025, 1, 7),  // Tuesday
        DateTime(2025, 1, 8),  // Wednesday
        DateTime(2025, 1, 9),  // Thursday
        DateTime(2025, 1, 10), // Friday
        DateTime(2025, 1, 11), // Saturday
        DateTime(2025, 1, 12), // Sunday
      ]) {
        test('from is always Saturday and to is always Sunday — input weekday=${nowDate.weekday}', () {
          final (from, to) = weekendPreset(nowDate);
          expect(from.weekday, equals(DateTime.saturday),
              reason: 'Weekend preset from must always be a Saturday');
          expect(to.weekday, equals(DateTime.sunday),
              reason: 'Weekend preset to must always be a Sunday');
        });
      }

      // from must always be < to (Saturday is always before Sunday)
      test('from is always before to', () {
        final testDates = [
          DateTime(2025, 1, 6),
          DateTime(2025, 1, 11),
          DateTime(2025, 1, 12),
          DateTime(2025, 6, 15),
          DateTime(2025, 12, 28),
        ];
        for (final now in testDates) {
          final (from, to) = weekendPreset(now);
          expect(from.isBefore(to), isTrue,
              reason: 'from must be before to for $now');
        }
      });

      // Saturday and Sunday should be exactly 1 day apart
      test('from and to are exactly 1 day apart', () {
        final testDates = [
          DateTime(2025, 1, 6),
          DateTime(2025, 1, 11),
          DateTime(2025, 6, 15),
        ];
        for (final now in testDates) {
          final (from, to) = weekendPreset(now);
          final fromMidnight = DateTime(from.year, from.month, from.day);
          final toMidnight = DateTime(to.year, to.month, to.day);
          final diff = toMidnight.difference(fromMidnight).inDays;
          expect(diff, equals(1),
              reason: 'Saturday and Sunday must be exactly 1 day apart for $now');
        }
      });
    });

    // -------------------------------------------------------------------------
    // Cross-preset ordering property:
    // today <= tomorrow <= this week end (all from <= to)
    // -------------------------------------------------------------------------
    group('preset ordering invariants', () {
      test('today from <= tomorrow from <= this week to', () {
        final now = DateTime(2025, 6, 11); // Wednesday
        final (todayFrom, todayTo) = todayPreset(now);
        final (tomorrowFrom, tomorrowTo) = tomorrowPreset(now);
        final (weekFrom, weekTo) = thisWeekPreset(now);

        expect(todayFrom.isBefore(tomorrowFrom) || todayFrom.isAtSameMomentAs(tomorrowFrom), isTrue);
        expect(tomorrowTo.isBefore(weekTo) || tomorrowTo.isAtSameMomentAs(weekTo), isTrue);
      });

      test('todayPreset range is within thisWeekPreset range', () {
        final now = DateTime(2025, 1, 8); // Wednesday
        final (todayFrom, todayTo) = todayPreset(now);
        final (weekFrom, weekTo) = thisWeekPreset(now);

        expect(
          todayFrom.isAfter(weekFrom) || todayFrom.isAtSameMomentAs(weekFrom),
          isTrue,
          reason: 'today start must be within this week range',
        );
        expect(
          todayTo.isBefore(weekTo) || todayTo.isAtSameMomentAs(weekTo),
          isTrue,
          reason: 'today end must be within this week range',
        );
      });
    });
  });
}
