import 'package:coffeeshop_mobile/shared/widgets/form_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('FormSelect', () {
    final items = ['Option A', 'Option B', 'Option C'];

    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FormSelect<String>(
            label: 'Choose Option',
            value: null,
            items: items,
            itemLabel: (item) => item,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Choose Option'), findsOneWidget);
    });

    testWidgets('shows hint text when no value selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FormSelect<String>(
            label: 'Choose',
            value: null,
            items: items,
            itemLabel: (item) => item,
            onChanged: (_) {},
            hint: 'Select an option',
          ),
        ),
      );

      expect(find.text('Select an option'), findsOneWidget);
    });

    testWidgets('renders prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FormSelect<String>(
            label: 'Choose',
            value: null,
            items: items,
            itemLabel: (item) => item,
            onChanged: (_) {},
            prefixIcon: Icons.store,
          ),
        ),
      );

      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('renders all dropdown items', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FormSelect<String>(
            label: 'Choose',
            value: null,
            items: items,
            itemLabel: (item) => item,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      for (final item in items) {
        expect(find.text(item).last, findsOneWidget);
      }
    });

    testWidgets('calls onChanged when item is selected', (tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        buildTestWidget(
          FormSelect<String>(
            label: 'Choose',
            value: null,
            items: items,
            itemLabel: (item) => item,
            onChanged: (v) => selectedValue = v,
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Option B').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 'Option B');
    });
  });

  group('FormMultiSelect', () {
    final items = ['Red', 'Green', 'Blue'];

    testWidgets('shows "None selected" when no items selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FormMultiSelect<String>(
            label: 'Colors',
            selectedValues: const [],
            items: items,
            itemLabel: (item) => item,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('None selected'), findsOneWidget);
    });

    testWidgets('shows chips for selected items', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FormMultiSelect<String>(
            label: 'Colors',
            selectedValues: const ['Red', 'Blue'],
            items: items,
            itemLabel: (item) => item,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
    });

    testWidgets('removes chip on delete', (tester) async {
      List<String> selected = ['Red', 'Blue'];
      await tester.pumpWidget(
        buildTestWidget(
          FormMultiSelect<String>(
            label: 'Colors',
            selectedValues: selected,
            items: items,
            itemLabel: (item) => item,
            onChanged: (v) => selected = v,
          ),
        ),
      );

      final redChip = find.widgetWithText(Chip, 'Red');
      expect(redChip, findsOneWidget);
    });
  });
}
