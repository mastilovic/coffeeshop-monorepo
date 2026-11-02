import 'package:coffeeshop_mobile/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('returns null for valid email', () {
      expect(Validators.email('test@example.com'), isNull);
    });

    test('returns null for valid email with subdomain', () {
      expect(Validators.email('user@mail.example.co.uk'), isNull);
    });

    test('returns null for email with plus sign', () {
      expect(Validators.email('user+tag@example.com'), isNull);
    });

    test('returns error when value is null', () {
      expect(Validators.email(null), 'Email is required');
    });

    test('returns error when value is empty', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('returns error when value is whitespace only', () {
      expect(Validators.email('   '), 'Email is required');
    });

    test('returns error for invalid email without @', () {
      expect(Validators.email('notanemail'), 'Please enter a valid email address');
    });

    test('returns error for email without domain', () {
      expect(Validators.email('test@'), 'Please enter a valid email address');
    });

    test('returns error for email without tld', () {
      expect(Validators.email('test@example'), 'Please enter a valid email address');
    });

    test('trims whitespace before validation', () {
      expect(Validators.email('  test@example.com  '), isNull);
    });
  });

  group('Validators.password', () {
    test('returns null for valid password', () {
      expect(Validators.password('password123'), isNull);
    });

    test('returns null for password exactly 6 characters', () {
      expect(Validators.password('123456'), isNull);
    });

    test('returns error when value is null', () {
      expect(Validators.password(null), 'Password is required');
    });

    test('returns error when value is empty', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('returns error when password is too short', () {
      expect(Validators.password('12345'), 'Password must be at least 6 characters');
    });
  });

  group('Validators.required', () {
    test('returns null for non-empty value', () {
      expect(Validators.required('hello'), isNull);
    });

    test('returns error when value is null', () {
      expect(Validators.required(null), 'This field is required');
    });

    test('returns error when value is empty', () {
      expect(Validators.required(''), 'This field is required');
    });

    test('returns error when value is whitespace only', () {
      expect(Validators.required('   '), 'This field is required');
    });

    test('uses custom field name in error message', () {
      expect(Validators.required(null, 'Email'), 'Email is required');
    });
  });

  group('Validators.username', () {
    test('returns null for valid username', () {
      expect(Validators.username('john_doe'), isNull);
    });

    test('returns null for username exactly 3 characters', () {
      expect(Validators.username('abc'), isNull);
    });

    test('returns error when value is null', () {
      expect(Validators.username(null), 'Username is required');
    });

    test('returns error when value is empty', () {
      expect(Validators.username(''), 'Username is required');
    });

    test('returns error when username is too short', () {
      expect(Validators.username('ab'), 'Username must be at least 3 characters');
    });

    test('trims whitespace before validation', () {
      expect(Validators.username('  abc  '), isNull);
    });

    test('trims whitespace and detects too short', () {
      expect(Validators.username('  a  '), 'Username must be at least 3 characters');
    });
  });

  group('Validators.positiveInt', () {
    test('returns null for valid positive integer', () {
      expect(Validators.positiveInt('5'), isNull);
    });

    test('returns null for large positive integer', () {
      expect(Validators.positiveInt('999'), isNull);
    });

    test('returns error when value is null', () {
      expect(Validators.positiveInt(null), 'This field is required');
    });

    test('returns error when value is empty', () {
      expect(Validators.positiveInt(''), 'This field is required');
    });

    test('returns error when value is zero', () {
      expect(Validators.positiveInt('0'), 'This field must be a positive number');
    });

    test('returns error when value is negative', () {
      expect(Validators.positiveInt('-1'), 'This field must be a positive number');
    });

    test('returns error when value is not a number', () {
      expect(Validators.positiveInt('abc'), 'This field must be a positive number');
    });

    test('uses custom field name in error message', () {
      expect(Validators.positiveInt(null, 'Party size'), 'Party size is required');
    });

    test('uses custom field name for non-positive error', () {
      expect(Validators.positiveInt('0', 'Party size'), 'Party size must be a positive number');
    });
  });
}
