import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/core/auth/user_role.dart';
import 'package:coffeeshop_mobile/features/shop_details/tabs/loyalty_tab.dart';
import 'package:coffeeshop_mobile/shared/widgets/upgrade_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gated_ui_test_helpers.dart';

UserPermissions growthOwnerWithLoyaltyBasic() => const UserPermissions(
      role: UserRole.shop_owner,
      ownedShopIds: ['shop-1'],
      entitlements: {'loyalty_basic': true},
    );

UserPermissions proOwnerWithLoyalty() => const UserPermissions(
      role: UserRole.shop_owner,
      ownedShopIds: ['shop-1'],
      entitlements: {'loyalty_basic': true, 'loyalty_premium': true},
    );

void main() {
  group('LoyaltyTab gated UI', () {
    testWidgets('shows upgrade prompt without loyalty entitlement', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: starterOwnerPermissions(),
          child: const LoyaltyTab(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enable loyalty program'), findsOneWidget);
      final button = filledButtonWithLabel(tester, 'Enable loyalty program');
      expect(button.onPressed, isNull);
      expect(find.text(upgradeToGrowthLabel), findsOneWidget);
    });

    testWidgets('enables BASIC loyalty for growth owners', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: growthOwnerWithLoyaltyBasic(),
          child: const LoyaltyTab(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      final button = filledButtonWithLabel(tester, 'Enable loyalty program');
      expect(button.onPressed, isNotNull);
      expect(find.text('Upgrade to Pro for Premium and VIP loyalty tiers.'), findsOneWidget);
    });

    testWidgets('shows existing plan with badge', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: growthOwnerWithLoyaltyBasic(),
          child: const LoyaltyTab(
            shopId: 'shop-1',
            loyaltyPlan: {
              'id': 'plan-1',
              'name': 'Basic Rewards',
              'description': 'Earn points on every visit',
              'type': 'BASIC',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Basic Rewards'), findsOneWidget);
      expect(find.text('Loyalty'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('shows premium upgrade banner for growth owners in form', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: growthOwnerWithLoyaltyBasic(),
          child: const LoyaltyTab(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable loyalty program'));
      await tester.pumpAndSettle();

      expect(find.text('Plan type'), findsOneWidget);
      expect(find.text('BASIC'), findsWidgets);
      expect(find.text('PREMIUM'), findsNothing);
      expect(find.text('VIP'), findsNothing);
    });

    testWidgets('allows PREMIUM and VIP types for pro owners', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: proOwnerWithLoyalty(),
          child: const LoyaltyTab(shopId: 'shop-1'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable loyalty program'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Plan type'));
      await tester.pumpAndSettle();

      expect(find.text('BASIC').last, findsOneWidget);
      expect(find.text('PREMIUM'), findsOneWidget);
      expect(find.text('VIP'), findsOneWidget);
      expect(
        find.text('Upgrade to Pro for Premium and VIP loyalty tiers.'),
        findsNothing,
      );
    });
  });
}
