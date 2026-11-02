import 'package:coffeeshop_mobile/shared/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('EmptyStateView', () {
    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EmptyStateView(message: 'No items found')),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('renders default icon when no icon provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EmptyStateView(message: 'Empty')),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders custom icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const EmptyStateView(
            message: 'No shops yet',
            icon: Icons.store,
          ),
        ),
      );

      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('renders action button when actionLabel and onAction provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          EmptyStateView(
            message: 'No shops yet',
            actionLabel: 'Create Shop',
            onAction: () {},
          ),
        ),
      );

      expect(find.text('Create Shop'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('does not render action button when not provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const EmptyStateView(message: 'Empty')),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('does not render button when only actionLabel provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const EmptyStateView(
            message: 'Empty',
            actionLabel: 'Create',
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('calls onAction when button is tapped', (tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          EmptyStateView(
            message: 'Empty',
            actionLabel: 'Refresh',
            onAction: () => wasTapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Refresh'));
      expect(wasTapped, isTrue);
    });
  });
}
