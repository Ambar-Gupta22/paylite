import 'qr_payload.dart';

class QrParser {
  /// Parses a UPI QR string and normalizes it.
  /// Format: upi://pay?pa=<vpa>&pn=<name>&am=<amount>
  /// Returns null if the format is invalid.
  static QrPayload? parse(String rawQr) {
    if (!rawQr.startsWith('upi://pay?')) {
      return null;
    }

    try {
      // Uri.parse can handle upi:// scheme
      final uri = Uri.parse(rawQr);
      final params = uri.queryParameters;
      
      final pa = params['pa'];
      if (pa == null || pa.isEmpty) {
        return null;
      }
      
      final vpa = pa.trim().toLowerCase();
      final name = params['pn'];
      
      int? amountPaise;
      if (params.containsKey('am')) {
        final double? am = double.tryParse(params['am']!);
        if (am != null && am > 0) {
          amountPaise = (am * 100).round();
        }
      }

      return QrPayload(
        vpa: vpa,
        name: name,
        amountPaise: amountPaise,
      );
    } catch (_) {
      return null;
    }
  }
}
