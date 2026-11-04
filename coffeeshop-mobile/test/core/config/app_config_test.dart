import 'package:coffeeshop_mobile/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig brand', () {
    test('appName is the full product name', () {
      expect(AppConfig.appName, 'Find: Cafes & Events');
    });

    test('appShortName is the short product name', () {
      expect(AppConfig.appShortName, 'Find');
    });
  });
}
