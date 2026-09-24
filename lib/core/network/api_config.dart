import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }
}
