class ApiConfig {
  ApiConfig._();

  static String get baseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080',
      );

  static String get keycloakBaseUrl => const String.fromEnvironment(
        'KEYCLOAK_BASE_URL',
        defaultValue: 'http://localhost:8081',
      );

  static String get keycloakRealm => const String.fromEnvironment(
        'KEYCLOAK_REALM',
        defaultValue: 'coffeeshop',
      );

  static String get keycloakClientId => const String.fromEnvironment(
        'KEYCLOAK_CLIENT_ID',
        defaultValue: 'coffeeshop-mobile',
      );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
