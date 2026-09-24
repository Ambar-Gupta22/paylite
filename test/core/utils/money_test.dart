import 'package:flutter_test/flutter_test.dart';
import 'package:paylite/core/utils/money.dart';

void main() {
  group('MoneyFormatter', () {
    test('formats whole rupees correctly without decimals', () {
      expect(MoneyFormatter.formatPaise(10000), '₹100'); // 100 INR
      expect(MoneyFormatter.formatPaise(100000), '₹1,000'); // 1000 INR
      expect(MoneyFormatter.formatPaise(1500000), '₹15,000'); // 15,000 INR
      expect(MoneyFormatter.formatPaise(10000000), '₹1,00,000'); // 1,00,000 INR
    });

    test('formats fractional rupees correctly with 2 decimals', () {
      expect(MoneyFormatter.formatPaise(10050), '₹100.50'); // 100.50 INR
      expect(MoneyFormatter.formatPaise(99), '₹0.99'); // 0.99 INR
    });
  });
}
