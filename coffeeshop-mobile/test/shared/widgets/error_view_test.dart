import 'package:coffeeshop_mobile/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ErrorView', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ErrorView(message: 'Something went wrong')),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders error icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ErrorView(message: 'Error')),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ErrorView(
            message: 'Network error',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('does not render retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ErrorView(message: 'Error')),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          ErrorView(
            message: 'Error',
            onRetry: () => wasTapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(wasTapped, isTrue);
    });
  });
}
