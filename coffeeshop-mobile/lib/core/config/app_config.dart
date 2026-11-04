class AppConfig {
  AppConfig._();

  static bool _initialized = false;

  static const String appName = 'na bleji';
  static const String packageName = 'com.coffeeshop.mobile';

  static void initialize() {
    if (_initialized) return;
    _initialized = true;
  }
}
