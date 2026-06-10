import 'package:coffeeshop_mobile/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test - renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CoffeeshopApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
