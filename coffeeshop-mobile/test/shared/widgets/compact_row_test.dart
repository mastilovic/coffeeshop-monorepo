import 'package:coffeeshop_mobile/shared/widgets/compact_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('CompactRow', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const CompactRow(title: 'Hello World')),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const CompactRow(
          title: 'Title',
          subtitle: 'Subtitle text',
        )),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle text'), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const CompactRow(title: 'Title Only')),
      );

      expect(find.text('Title Only'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const CompactRow(
            title: 'With Leading',
            leading: CircleAvatar(child: Text('A')),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const CompactRow(
            title: 'With Trailing',
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          CompactRow(
            title: 'Tappable',
            onTap: () => wasTapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Tappable'));
      expect(wasTapped, isTrue);
    });

    testWidgets('does not throw when onTap is null and tapped', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const CompactRow(title: 'Not Tappable')),
      );

      await tester.tap(find.text('Not Tappable'));
    });
  });
}
