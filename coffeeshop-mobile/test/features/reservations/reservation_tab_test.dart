import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/features/reservations/reservation_list_screen.dart';
import 'package:coffeeshop_mobile/features/reservations/reservation_providers.dart';
import 'package:coffeeshop_mobile/features/shop_details/shop_manage_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../gated_ui_test_helpers.dart';

void main() {
  Future<void> pumpOwnerReservations(
    WidgetTester tester, {
    required String location,
  }) async {
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/reservations',
          builder: (context, state) => ReservationListScreen(
            initialTab: state.uri.queryParameters['tab'],
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPermissionsProvider.overrideWith((ref) async => starterOwnerPermissions()),
          myReservationRequestsProvider.overrideWith((ref) async => []),
          myReservationsProvider.overrideWith((ref) async => []),
          ownedShopsProvider.overrideWith((ref) async => []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shop owner on /reservations?tab=manage sees Manage Shops', (tester) async {
    await pumpOwnerReservations(tester, location: '/reservations?tab=manage');

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, 2);
    expect(find.text('No shops to manage.'), findsOneWidget);
  });

  testWidgets('shop owner on /reservations still sees My Requests', (tester) async {
    await pumpOwnerReservations(tester, location: '/reservations');

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, 0);
    expect(find.text('No reservation requests.'), findsOneWidget);
  });

  testWidgets('an open reservations screen follows a later tab=manage query', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPermissionsProvider.overrideWith((ref) async => starterOwnerPermissions()),
          myReservationRequestsProvider.overrideWith((ref) async => []),
          myReservationsProvider.overrideWith((ref) async => []),
          ownedShopsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: ReservationListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPermissionsProvider.overrideWith((ref) async => starterOwnerPermissions()),
          myReservationRequestsProvider.overrideWith((ref) async => []),
          myReservationsProvider.overrideWith((ref) async => []),
          ownedShopsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: ReservationListScreen(initialTab: 'manage')),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 2);
    expect(find.text('No shops to manage.'), findsOneWidget);
  });
}
