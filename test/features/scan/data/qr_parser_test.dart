import 'package:flutter_test/flutter_test.dart';
import 'package:paylite/features/scan/data/qr_parser.dart';

void main() {
  group('QrParser', () {
    test('parses valid UPI QR with amount', () {
      final payload = QrParser.parse(
        'upi://pay?pa=priya@paylite&pn=Priya%20Sharma&am=100.50',
      );

      expect(payload, isNotNull);
      expect(payload!.vpa, 'priya@paylite');
      expect(payload.name, 'Priya Sharma');
      expect(payload.amountPaise, 10050);
    });

    test('parses valid UPI QR without amount', () {
      final payload = QrParser.parse('upi://pay?pa=ramesh@paylite&pn=Ramesh');

      expect(payload, isNotNull);
      expect(payload!.vpa, 'ramesh@paylite');
      expect(payload.name, 'Ramesh');
      expect(payload.amountPaise, isNull);
    });

    test('trims whitespace and lowercases VPA', () {
      final payload = QrParser.parse('upi://pay?pa= PRIYA@PAYLITE  &pn=Priya');

      expect(payload, isNotNull);
      expect(payload!.vpa, 'priya@paylite');
    });

    test('returns null for non-UPI format', () {
      final payload = QrParser.parse('https://example.com/pay');
      expect(payload, isNull);
    });

    test('returns null if pa (VPA) is missing', () {
      final payload = QrParser.parse('upi://pay?pn=Priya&am=100');
      expect(payload, isNull);
    });

    test('handles invalid amount gracefully', () {
      final payload = QrParser.parse('upi://pay?pa=priya@paylite&am=invalid');

      expect(payload, isNotNull);
      expect(payload!.vpa, 'priya@paylite');
      expect(payload.amountPaise, isNull); // Ignores invalid amount
    });
  });
}
