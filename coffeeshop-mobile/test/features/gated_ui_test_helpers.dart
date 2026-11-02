import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/core/auth/user_role.dart';
import 'package:coffeeshop_mobile/data/models/user_profile_response_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

FilledButton filledButtonWithLabel(WidgetTester tester, String label) {
  return tester.widget<FilledButton>(
    find.ancestor(
      of: find.text(label),
      matching: find.bySubtype<FilledButton>(),
    ),
  );
}

UserPermissions starterOwnerPermissions() => const UserPermissions(
      role: UserRole.shop_owner,
      ownedShopIds: ['shop-1'],
    );

UserPermissions growthOwnerPermissions() => const UserPermissions(
      role: UserRole.shop_owner,
      ownedShopIds: ['shop-1'],
      entitlements: {'employee_assign': true},
    );

UserPermissions proOwnerPermissions() => const UserPermissions(
      role: UserRole.shop_owner,
      ownedShopIds: ['shop-1'],
      entitlements: {
        'reservation_manage': true,
        'event_create': true,
        'employee_assign': true,
        'community_post': true,
        'loyalty_basic': true,
        'loyalty_premium': true,
        'review_moderate': true,
        'dashboard_notifications': true,
        'analytics': true,
        'unlimited_tables': true,
        'unlimited_menus': true,
      },
    );

UserPermissions starterOwnerAtTableCapPermissions() => const UserPermissions(
      role: UserRole.shop_owner,
      ownedShopIds: ['shop-1'],
      limits: {
        'tables': LimitUsageDto(used: 1, max: 1),
      },
    );

Widget buildGatedHarness({
  required UserPermissions permissions,
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      userPermissionsProvider.overrideWith((ref) async => permissions),
      ...overrides,
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: child),
          ),
          GoRoute(
            path: '/profile/billing',
            builder: (context, state) => const Scaffold(
              body: Text('Billing page'),
            ),
          ),
        ],
      ),
    ),
  );
}
