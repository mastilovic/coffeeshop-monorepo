import 'package:coffeeshop_mobile/features/events/event_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('eventApiDate', () {
    test('formats as yyyy-MM-dd', () {
      expect(eventApiDate(DateTime(2026, 9, 19)), '2026-09-19');
      expect(eventApiDate(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });

  group('eventFilterDateRange', () {
    test('all has no date bounds', () {
      final range = eventFilterDateRange(EventTimeFilter.all);
      expect(range.dateFrom, isNull);
      expect(range.dateTo, isNull);
    });

    test('today uses same yyyy-MM-dd for from and to', () {
      final range = eventFilterDateRange(EventTimeFilter.today);
      final expected = eventApiDate(DateTime.now());
      expect(range.dateFrom, expected);
      expect(range.dateTo, expected);
      expect(range.dateFrom, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('thisWeek spans Monday through Sunday as yyyy-MM-dd', () {
      final range = eventFilterDateRange(EventTimeFilter.thisWeek);
      final from = DateTime.parse(range.dateFrom!);
      final to = DateTime.parse(range.dateTo!);
      expect(from.weekday, DateTime.monday);
      expect(to.weekday, DateTime.sunday);
      expect(to.difference(from).inDays, 6);
      expect(range.dateFrom, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(range.dateTo, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('thisMonth starts on day 1 as yyyy-MM-dd', () {
      final range = eventFilterDateRange(EventTimeFilter.thisMonth);
      final from = DateTime.parse(range.dateFrom!);
      expect(from.day, 1);
      expect(range.dateFrom, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(range.dateTo, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });
  });
}
