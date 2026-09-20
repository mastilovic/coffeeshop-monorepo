import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/features/shop_details/tabs/community_tab.dart';
import 'package:coffeeshop_mobile/features/shop_details/tabs/employees_tab.dart';
import 'package:coffeeshop_mobile/features/shop_details/tabs/tables_tab.dart';
import 'package:coffeeshop_mobile/shared/widgets/upgrade_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'gated_ui_test_helpers.dart';

void main() {
  group('UpgradePromptBanner', () {
    testWidgets('navigates to billing when upgrade tapped', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: UpgradePromptBanner(),
            ),
          ),
          GoRoute(
            path: billingRoute,
            builder: (context, state) => const Scaffold(
              body: Text('Billing page'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );

      expect(find.text(upgradeToGrowthLabel), findsOneWidget);
      await tester.tap(find.text(upgradeToGrowthLabel));
      await tester.pumpAndSettle();

      expect(find.text('Billing page'), findsOneWidget);
    });
  });

  group('EmployeesTab gated UI', () {
    testWidgets('disables Add Employee without employee_assign', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: starterOwnerPermissions(),
          overrides: [
            shopEmployeesProvider('shop-1').overrideWith((ref) async => []),
            assignableUsersProvider.overrideWith((ref) async => []),
          ],
          child: const EmployeesTab(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      final button = filledButtonWithLabel(tester, 'Add Employee');
      expect(button.onPressed, isNull);
      expect(find.text(upgradeToGrowthLabel), findsOneWidget);
    });

    testWidgets('enables Add Employee with employee_assign', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: growthOwnerPermissions(),
          overrides: [
            shopEmployeesProvider('shop-1').overrideWith((ref) async => []),
            assignableUsersProvider.overrideWith((ref) async => []),
          ],
          child: const EmployeesTab(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      final button = filledButtonWithLabel(tester, 'Add Employee');
      expect(button.onPressed, isNotNull);
      expect(find.text(upgradeToGrowthLabel), findsNothing);
    });
  });

  group('CommunityTab gated UI', () {
    testWidgets('disables Post without community_post', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: starterOwnerPermissions(),
          overrides: [
            communityPostsProvider('shop-1').overrideWith(
              (ref) async => {'content': []},
            ),
          ],
          child: const CommunityTab(shopId: 'shop-1', canManage: true),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Post'));
      expect(button.onPressed, isNull);
      expect(find.text(upgradeToGrowthLabel), findsOneWidget);
    });
  });

  group('TablesTab gated UI', () {
    testWidgets('disables Add Table when table cap reached', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: starterOwnerAtTableCapPermissions(),
          child: TablesTab(
            shopId: 'shop-1',
            tables: const [
              {'id': 't1', 'number': 1, 'capacity': 4},
            ],
            canManage: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = filledButtonWithLabel(tester, 'Add Table');
      expect(button.onPressed, isNull);
      expect(find.text('1 / 1 tables'), findsOneWidget);
      expect(find.text(upgradeToGrowthLabel), findsOneWidget);
    });
  });
}
