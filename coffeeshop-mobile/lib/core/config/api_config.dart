import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:18080';
    }
    // Default matches Docker compose: backend exposed on host port 18080.
    // Override with --dart-define=API_BASE_URL=... for other setups.
    return 'http://localhost:18080';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
