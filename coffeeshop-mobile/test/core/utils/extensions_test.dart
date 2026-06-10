import 'package:coffeeshop_mobile/core/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('en_US');
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
