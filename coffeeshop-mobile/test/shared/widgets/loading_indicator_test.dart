import 'package:coffeeshop_mobile/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('LoadingIndicator', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoadingIndicator()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show message when no message provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoadingIndicator()),
      );

      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoadingIndicator(message: 'Loading shops...')),
      );

      expect(find.text('Loading shops...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const LoadingIndicator(message: 'Loading')),
      );

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
