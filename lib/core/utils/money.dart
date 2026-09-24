import 'package:intl/intl.dart';

class MoneyFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits:
        0, // Since we only display integers for UPI usually, or up to 2.
  );

  /// Converts paise (integer) to formatted Rupee string.
  /// Example: 100000 -> ₹1,000
  static String formatPaise(int paise) {
    final double rupees = paise / 100.0;

    // If it's a whole number of rupees, don't show decimals
    if (paise % 100 == 0) {
      _currencyFormat.minimumFractionDigits = 0;
      _currencyFormat.maximumFractionDigits = 0;
    } else {
      _currencyFormat.minimumFractionDigits = 2;
      _currencyFormat.maximumFractionDigits = 2;
    }

    return _currencyFormat.format(rupees);
  }
}
