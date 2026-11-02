import 'package:coffeeshop_mobile/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test - renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CoffeeshopApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
