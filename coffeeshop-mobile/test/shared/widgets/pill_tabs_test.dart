import 'package:coffeeshop_mobile/shared/widgets/pill_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('PillTabs', () {
    final tabs = ['All', 'Today', 'This Week', 'This Month'];

    testWidgets('renders all tab labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PillTabs(
            tabs: tabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
          ),
        ),
      );

      for (final tab in tabs) {
        expect(find.text(tab), findsOneWidget);
      }
    });

    testWidgets('marks first tab as selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PillTabs(
            tabs: tabs,
            selectedIndex: 0,
            onTabSelected: (_) {},
          ),
        ),
      );

      final firstChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'All'),
      );
      expect(firstChip.selected, isTrue);
    });

    testWidgets('marks correct tab as selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PillTabs(
            tabs: tabs,
            selectedIndex: 2,
            onTabSelected: (_) {},
          ),
        ),
      );

      final selectedChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'This Week'),
      );
      expect(selectedChip.selected, isTrue);
    });

    testWidgets('calls onTabSelected when tab is tapped', (tester) async {
      int? selectedIndex;
      await tester.pumpWidget(
        buildTestWidget(
          PillTabs(
            tabs: tabs,
            selectedIndex: 0,
            onTabSelected: (i) => selectedIndex = i,
          ),
        ),
      );

      await tester.tap(find.text('This Month'));
      expect(selectedIndex, 3);
    });

    testWidgets('calls onTabSelected with correct index', (tester) async {
      int? selectedIndex;
      await tester.pumpWidget(
        buildTestWidget(
          PillTabs(
            tabs: const ['A', 'B', 'C'],
            selectedIndex: 0,
            onTabSelected: (i) => selectedIndex = i,
          ),
        ),
      );

      await tester.tap(find.text('B'));
      expect(selectedIndex, 1);
    });

    testWidgets('handles single tab', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PillTabs(
            tabs: const ['Only'],
            selectedIndex: 0,
            onTabSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Only'), findsOneWidget);
    });
  });
}
