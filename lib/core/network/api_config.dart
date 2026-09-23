import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: kIsWeb ? 'http://127.0.0.1:3000' : 'http://10.0.2.2:3000',
  );
}
