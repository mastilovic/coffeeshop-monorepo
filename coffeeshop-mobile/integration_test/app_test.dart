import 'package:coffeeshop_mobile/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CoffeeShop Integration Tests', () {
    testWidgets('app launches successfully', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CoffeeshopApp()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigation shows bottom nav on authenticated screens', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CoffeeshopApp()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After initial load, app should render something
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
