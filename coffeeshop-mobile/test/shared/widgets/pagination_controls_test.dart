import 'package:coffeeshop_mobile/shared/widgets/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('PaginationControls', () {
    testWidgets('renders nothing when totalPages is 1 or less', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PaginationControls(
            currentPage: 0,
            totalPages: 1,
            onPageChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('renders page indicator and navigation buttons', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PaginationControls(
            currentPage: 0,
            totalPages: 5,
            onPageChanged: (_) {},
          ),
        ),
      );

      expect(find.text('1 / 5'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('disables left button on first page', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PaginationControls(
            currentPage: 0,
            totalPages: 5,
            onPageChanged: (_) {},
          ),
        ),
      );

      final leftButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(leftButton.onPressed, isNull);
    });

    testWidgets('disables right button on last page', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PaginationControls(
            currentPage: 4,
            totalPages: 5,
            onPageChanged: (_) {},
          ),
        ),
      );

      final rightButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(rightButton.onPressed, isNull);
    });

    testWidgets('calls onPageChanged when right arrow tapped', (tester) async {
      int? newPage;
      await tester.pumpWidget(
        buildTestWidget(
          PaginationControls(
            currentPage: 0,
            totalPages: 3,
            onPageChanged: (p) => newPage = p,
          ),
        ),
      );

      final rightButton = find.widgetWithIcon(IconButton, Icons.chevron_right);
      await tester.tap(rightButton);
      expect(newPage, 1);
    });

    testWidgets('calls onPageChanged when left arrow tapped', (tester) async {
      int? newPage;
      await tester.pumpWidget(
        buildTestWidget(
          PaginationControls(
            currentPage: 2,
            totalPages: 3,
            onPageChanged: (p) => newPage = p,
          ),
        ),
      );

      final leftButton = find.widgetWithIcon(IconButton, Icons.chevron_left);
      await tester.tap(leftButton);
      expect(newPage, 1);
    });

    testWidgets('displays correct page number for 0-indexed page', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PaginationControls(
            currentPage: 3,
            totalPages: 10,
            onPageChanged: (_) {},
          ),
        ),
      );

      expect(find.text('4 / 10'), findsOneWidget);
    });
  });
}
