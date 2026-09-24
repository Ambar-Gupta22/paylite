import 'package:flutter_test/flutter_test.dart';
import 'package:paylite/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateVpa', () {
      test('returns error for empty VPA', () {
        expect(Validators.validateVpa(''), 'UPI ID is required');
      });

      test('returns error for VPA without @', () {
        expect(
          Validators.validateVpa('priyasharma'),
          'Invalid UPI ID format (must contain @)',
        );
      });

      test('returns null for valid VPA', () {
        expect(Validators.validateVpa('priya@paylite'), isNull);
      });
    });

    group('validateAmount', () {
      test('returns error for 0', () {
        expect(Validators.validateAmount('0'), 'Amount must be greater than 0');
      });

      test('returns error for negative amount', () {
        expect(
          Validators.validateAmount('-100'),
          'Amount must be greater than 0',
        );
      });

      test('returns error for amount > 10000000 paise (1 lakh)', () {
        expect(
          Validators.validateAmount('100001'),
          'Maximum payment limit is ₹1,00,000',
        );
      });

      test('returns null for valid amount', () {
        expect(Validators.validateAmount('500'), isNull);
        expect(
          Validators.validateAmount('100000'),
          isNull,
        ); // Max limit is allowed
      });
    });

    group('validatePin', () {
      test('returns error for empty PIN', () {
        expect(Validators.validatePin(''), 'PIN is required');
      });

      test('returns error for short PIN', () {
        expect(Validators.validatePin('123'), 'PIN must be exactly 4 digits');
      });

      test('returns error for long PIN', () {
        expect(Validators.validatePin('12345'), 'PIN must be exactly 4 digits');
      });

      test('returns null for valid 4-digit PIN', () {
        expect(Validators.validatePin('1234'), isNull);
        expect(Validators.validatePin('0000'), isNull);
      });
    });

    group('validateCustomerId', () {
      test('returns error for empty ID', () {
        expect(Validators.validateCustomerId(''), 'Customer ID is required');
      });

      test('returns error for non-alphanumeric ID', () {
        expect(
          Validators.validateCustomerId('cust-001!'),
          'Customer ID must be alphanumeric',
        );
      });

      test('returns null for valid ID', () {
        expect(Validators.validateCustomerId('customer001'), isNull);
        expect(Validators.validateCustomerId('User123'), isNull);
      });
    });
  });
}
