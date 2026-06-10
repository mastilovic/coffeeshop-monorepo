import 'dart:async';

import 'package:coffeeshop_mobile/shared/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfirmDialog', () {
    testWidgets('renders title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Delete Item',
            message: 'Are you sure you want to delete this item?',
          ),
        ),
      );

      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this item?'), findsOneWidget);
    });

    testWidgets('renders default button labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Please Confirm',
            message: 'Proceed?',
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('renders custom button labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Delete',
            message: 'Sure?',
            confirmLabel: 'Yes, Delete',
            cancelLabel: 'No, Keep',
          ),
        ),
      );

      expect(find.text('Yes, Delete'), findsOneWidget);
      expect(find.text('No, Keep'), findsOneWidget);
    });

    testWidgets('cancel button pops with false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Confirm Action',
            message: 'Proceed?',
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsNothing);
    });

    testWidgets('confirm button pops with true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Confirm Action',
            message: 'Proceed?',
          ),
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsNothing);
    });

    testWidgets('renders destructive style when isDestructive is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmDialog(
            title: 'Delete',
            message: 'Sure?',
            isDestructive: true,
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('ConfirmDialog.show', () {
    testWidgets('returns true when confirm is pressed', (tester) async {
      final completer = Completer<bool?>();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await ConfirmDialog.show(
                  context,
                  title: 'Confirm Action',
                  message: 'Proceed?',
                );
                completer.complete(result);
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final result = await completer.future;
      expect(result, isTrue);
    });

    testWidgets('returns false when cancel is pressed', (tester) async {
      final completer = Completer<bool?>();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await ConfirmDialog.show(
                  context,
                  title: 'Confirm Action',
                  message: 'Proceed?',
                );
                completer.complete(result);
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final result = await completer.future;
      expect(result, isFalse);
    });
  });
}
