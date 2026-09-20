import 'package:coffeeshop_mobile/core/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('en_US');
  });

  group('formatEventDateTime', () {
    test('formats valid ISO datetime', () {
      expect(
        formatEventDateTime('2026-09-19T21:00:00.000'),
        'Sep 19, 2026 9:00 PM',
      );
    });

    test('returns raw string when unparseable', () {
      expect(formatEventDateTime('not-a-date'), 'not-a-date');
    });
  });

  group('formatEventShopLabel', () {
    test('returns null for missing or blank shop', () {
      expect(formatEventShopLabel(null), isNull);
      expect(formatEventShopLabel(''), isNull);
      expect(formatEventShopLabel('   '), isNull);
    });

    test('formats shop name only', () {
      expect(formatEventShopLabel('test'), 'at test');
    });

    test('includes city when present', () {
      expect(
        formatEventShopLabel('test', shopCity: 'Belgrade'),
        'at test · Belgrade',
      );
    });
  });

  group('DateTimeExtension', () {
    final testDate = DateTime(2024, 3, 15, 14, 30);

    group('formatDate', () {
      test('formats date correctly', () {
        expect(testDate.formatDate(), 'Mar 15, 2024');
      });
    });

    group('formatDateTime', () {
      test('formats date and time correctly', () {
        expect(testDate.formatDateTime(), 'Mar 15, 2024 2:30 PM');
      });
    });

    group('formatTime', () {
      test('formats time correctly', () {
        expect(testDate.formatTime(), '2:30 PM');
      });
    });

    group('formatRelative', () {
      test('returns "Just now" for less than a minute ago', () {
        final justNow = DateTime.now().subtract(const Duration(seconds: 30));
        expect(justNow.formatRelative(), 'Just now');
      });

      test('returns minutes ago for less than an hour', () {
        final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));
        expect(fiveMinAgo.formatRelative(), '5m ago');
      });

      test('returns hours ago for less than a day', () {
        final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
        expect(twoHoursAgo.formatRelative(), '2h ago');
      });

      test('returns days ago for less than a week', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        expect(threeDaysAgo.formatRelative(), '3d ago');
      });

      test('returns formatted date for more than a week', () {
        final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
        final formatted = tenDaysAgo.formatRelative();
        expect(formatted, isNot(contains('ago')));
        expect(formatted, isNot('Just now'));
      });
    });

    group('formatRelativeAroundNow', () {
      test('returns Today for event on the same calendar day', () {
        final now = DateTime.now();
        final laterToday = DateTime(now.year, now.month, now.day, 23, 59);
        expect(laterToday.formatRelativeAroundNow(), 'Today');
      });

      test('returns Tomorrow for event tomorrow', () {
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 12);
        expect(tomorrow.formatRelativeAroundNow(), 'Tomorrow');
      });

      test('returns In N days for near-future events', () {
        final now = DateTime.now();
        final inThreeDays = DateTime(now.year, now.month, now.day + 3, 12);
        expect(inThreeDays.formatRelativeAroundNow(), 'In 3 days');
      });

      test('returns Yesterday for event yesterday', () {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1, 12);
        expect(yesterday.formatRelativeAroundNow(), 'Yesterday');
      });

      test('returns N days ago for recent past events', () {
        final now = DateTime.now();
        final threeDaysAgo = DateTime(now.year, now.month, now.day - 3, 12);
        expect(threeDaysAgo.formatRelativeAroundNow(), '3 days ago');
      });

      test('returns N days ago for far past without falling back to a date', () {
        final now = DateTime.now();
        final farPast = DateTime(now.year, now.month, now.day - 45, 12);
        expect(farPast.formatRelativeAroundNow(), '45 days ago');
      });
    });
  });

  group('formatEventDateWithRelative', () {
    test('returns null for missing or blank', () {
      expect(formatEventDateWithRelative(null), isNull);
      expect(formatEventDateWithRelative(''), isNull);
    });

    test('returns null for unparseable', () {
      expect(formatEventDateWithRelative('not-a-date'), isNull);
    });

    test('combines absolute date and days-from-today for valid ISO', () {
      final now = DateTime.now();
      final future = DateTime(now.year, now.month, now.day + 2, 15, 30);
      final raw = future.toIso8601String();
      final result = formatEventDateWithRelative(raw);
      expect(result, isNotNull);
      expect(result, contains(future.formatDate()));
      expect(result, contains('In 2 days'));
      expect(result!.split(' · ').length, 2);
    });
  });

  group('formatEventCountdown', () {
    final now = DateTime(2026, 9, 20, 12, 0);

    test('returns null for missing, blank, or unparseable', () {
      expect(formatEventCountdown(null, now: now), isNull);
      expect(formatEventCountdown('', now: now), isNull);
      expect(formatEventCountdown('not-a-date', now: now), isNull);
    });

    test('future days', () {
      final event = now.add(const Duration(days: 5, hours: 2));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        'in 5 days',
      );
    });

    test('future singular day', () {
      final event = now.add(const Duration(days: 1, hours: 1));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        'in 1 day',
      );
    });

    test('future hours when under 24h', () {
      final event = now.add(const Duration(hours: 3, minutes: 30));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        'in 3 hours',
      );
    });

    test('future singular hour', () {
      final event = now.add(const Duration(hours: 1, minutes: 5));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        'in 1 hour',
      );
    });

    test('future minutes when under 1 hour', () {
      final event = now.add(const Duration(minutes: 20));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        'in 20 min',
      );
    });

    test('future singular minute', () {
      final event = now.add(const Duration(minutes: 1));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        'in 1 min',
      );
    });

    test('future under 1 minute returns now', () {
      final event = now.add(const Duration(seconds: 30));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        'now',
      );
    });

    test('past days ago', () {
      final event = now.subtract(const Duration(days: 5, hours: 2));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        '5 days ago',
      );
    });

    test('past singular day ago', () {
      final event = now.subtract(const Duration(days: 1, hours: 1));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        '1 day ago',
      );
    });

    test('past hours ago when under 24h', () {
      final event = now.subtract(const Duration(hours: 3, minutes: 30));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        '3 hours ago',
      );
    });

    test('past singular hour ago', () {
      final event = now.subtract(const Duration(hours: 1, minutes: 5));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        '1 hour ago',
      );
    });

    test('past minutes ago when under 1 hour', () {
      final event = now.subtract(const Duration(minutes: 20));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        '20 min ago',
      );
    });

    test('past under 1 minute returns just now', () {
      final event = now.subtract(const Duration(seconds: 30));
      expect(
        formatEventCountdown(event.toIso8601String(), now: now),
        'just now',
      );
    });
  });

  group('StringExtension.initials', () {
    test('returns single initial for one word', () {
      expect('John'.initials, 'J');
    });

    test('returns two initials for two words', () {
      expect('John Doe'.initials, 'JD');
    });

    test('returns first two initials for multiple words', () {
      expect('John Michael Doe'.initials, 'JM');
    });

    test('throws for empty string', () {
      expect(() => ''.initials, throwsA(isA<RangeError>()));
    });

    test('returns uppercase initials', () {
      expect('john doe'.initials, 'JD');
    });

    test('trim leading/trailing whitespace', () {
      expect('  John Doe  '.initials, 'JD');
    });
  });

  group('StringExtension.capitalize', () {
    test('capitalizes first letter', () {
      expect('hello'.capitalize, 'Hello');
    });

    test('does not modify already capitalized string', () {
      expect('Hello'.capitalize, 'Hello');
    });

    test('returns empty string unchanged', () {
      expect(''.capitalize, '');
    });

    test('only capitalizes first character', () {
      expect('hELLO'.capitalize, 'HELLO');
    });
  });

  group('NumExtension.compact', () {
    test('returns string representation for numbers less than 1000', () {
      expect(5.compact, '5');
      expect(999.compact, '999');
    });

    test('formats thousands with k suffix', () {
      expect(1000.compact, '1.0k');
      expect(1500.compact, '1.5k');
      expect(9999.compact, '10.0k');
    });

    test('formats large numbers correctly', () {
      expect(10000.compact, '10.0k');
      expect(100000.compact, '100.0k');
    });

    test('handles zero', () {
      expect(0.compact, '0');
    });
  });
}
