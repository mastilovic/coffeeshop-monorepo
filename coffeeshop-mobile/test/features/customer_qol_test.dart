import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/core/auth/user_role.dart';
import 'package:coffeeshop_mobile/core/utils/reservation_event_utils.dart';
import 'package:coffeeshop_mobile/data/models/event_response_dto.dart';
import 'package:coffeeshop_mobile/data/models/shop_response_dto.dart';
import 'package:coffeeshop_mobile/features/events/event_detail_screen.dart';
import 'package:coffeeshop_mobile/features/events/event_providers.dart';
import 'package:coffeeshop_mobile/features/reservations/reservation_list_screen.dart';
import 'package:coffeeshop_mobile/features/reservations/reservation_providers.dart';
import 'package:coffeeshop_mobile/features/shop_details/shop_detail_screen.dart';
import 'package:coffeeshop_mobile/features/shops/shop_providers.dart';
import 'package:coffeeshop_mobile/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

UserPermissions customerPermissions() => const UserPermissions(
      role: UserRole.customer,
    );

UserPermissions ownerPermissions() => const UserPermissions(
      role: UserRole.shop_owner,
      ownedShopIds: ['shop-1'],
    );

EventResponseDto futureEvent({
  String eventId = 'event-1',
  String shopId = 'shop-1',
}) {
  final date = DateTime.now().add(const Duration(days: 7)).toIso8601String();
  return EventResponseDto(
    eventId: eventId,
    eventName: 'Latte Night',
    eventDate: date,
    shopId: shopId,
    shopName: 'Bean Scene',
    description: 'Coffee tasting',
  );
}

ShopResponseDto sampleShop() => ShopResponseDto(
      id: 'shop-1',
      name: 'Bean Scene',
      address: '1 Main St',
      city: 'Seattle',
      events: [
        {
          'eventId': 'event-1',
          'eventName': 'Latte Night',
          'eventDate':
              DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        },
      ],
    );

void main() {
  group('canReserveForDate / openReservationRequest helpers', () {
    test('canReserveForDate is true for future dates', () {
      final future = DateTime.now().add(const Duration(days: 1)).toIso8601String();
      expect(canReserveForDate(future), isTrue);
    });

    test('canReserveForDate is false for past dates', () {
      final past = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
      expect(canReserveForDate(past), isFalse);
    });
  });

  group('EventDetailScreen Reserve CTA', () {
    testWidgets('shows Reserve and navigates with query params', (tester) async {
      final event = futureEvent();
      late GoRouter router;

      router = GoRouter(
        initialLocation: '/events/${event.eventId}',
        routes: [
          GoRoute(
            path: '/events/:id',
            builder: (context, state) =>
                EventDetailScreen(eventId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/reservations',
            builder: (context, state) {
              final params = state.uri.queryParameters;
              return Scaffold(
                body: Text(
                  'Reservations '
                  'shop=${params['shopId']} '
                  'event=${params['eventId']} '
                  'request=${params['request']}',
                ),
              );
            },
          ),
          GoRoute(
            path: '/shops/:id',
            builder: (context, state) => const Scaffold(body: Text('Shop')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPermissionsProvider.overrideWith(
              (ref) async => customerPermissions(),
            ),
            eventDetailProvider(event.eventId).overrideWith(
              (ref) async => event,
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reserve'), findsOneWidget);
      expect(find.text('View Shop'), findsOneWidget);

      await tester.tap(find.text('Reserve'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('shop=${event.shopId}'),
        findsOneWidget,
      );
      expect(
        find.textContaining('event=${event.eventId}'),
        findsOneWidget,
      );
      expect(find.textContaining('request=1'), findsOneWidget);
    });

    testWidgets('hides Reserve for past events', (tester) async {
      final pastEvent = EventResponseDto(
        eventId: 'event-past',
        eventName: 'Old Event',
        eventDate:
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        shopId: 'shop-1',
        shopName: 'Bean Scene',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPermissionsProvider.overrideWith(
              (ref) async => customerPermissions(),
            ),
            eventDetailProvider(pastEvent.eventId).overrideWith(
              (ref) async => pastEvent,
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/events/${pastEvent.eventId}',
              routes: [
                GoRoute(
                  path: '/events/:id',
                  builder: (context, state) => EventDetailScreen(
                    eventId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reserve'), findsNothing);
      expect(find.text('View Shop'), findsOneWidget);
    });
  });

  group('ReservationListScreen form auto-open', () {
    testWidgets('opens request form when openRequest is true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPermissionsProvider.overrideWith(
              (ref) async => customerPermissions(),
            ),
            myReservationRequestsProvider.overrideWith((ref) async => []),
            myReservationsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(openRequest: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request Reservation'), findsOneWidget);
    });

    testWidgets('empty states show Request a reservation CTA', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPermissionsProvider.overrideWith(
              (ref) async => customerPermissions(),
            ),
            myReservationRequestsProvider.overrideWith((ref) async => []),
            myReservationsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: ReservationListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request a reservation'), findsOneWidget);

      await tester.tap(find.text('Request a reservation'));
      await tester.pumpAndSettle();

      expect(find.text('Request Reservation'), findsOneWidget);
    });
  });

  group('AppScaffold role-aware nav', () {
    Widget buildShell({required UserPermissions permissions}) {
      return ProviderScope(
        overrides: [
          userPermissionsProvider.overrideWith((ref) async => permissions),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/dashboard',
            routes: [
              StatefulShellRoute.indexedStack(
                builder: (context, state, navigationShell) {
                  return AppScaffold(navigationShell: navigationShell);
                },
                branches: [
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/dashboard',
                        builder: (_, __) =>
                            const Scaffold(body: Text('Dashboard body')),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/events',
                        builder: (_, __) =>
                            const Scaffold(body: Text('Events body')),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/shops',
                        builder: (_, __) =>
                            const Scaffold(body: Text('Shops body')),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/reservations',
                        builder: (_, __) =>
                            const Scaffold(body: Text('Reservations body')),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: '/profile',
                        builder: (_, __) =>
                            const Scaffold(body: Text('Profile body')),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('customer sees Home Explore Events Reservations Profile',
        (tester) async {
      await tester.pumpWidget(buildShell(permissions: customerPermissions()));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Reservations'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Shops'), findsNothing);

      // Visual order: Home, Explore, Events — tapping Explore opens shops branch.
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      expect(find.text('Shops body'), findsOneWidget);
    });

    testWidgets('owner keeps Dashboard Events Shops labels', (tester) async {
      await tester.pumpWidget(buildShell(permissions: ownerPermissions()));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Shops'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Explore'), findsNothing);
    });
  });

  group('ShopDetailScreen customer tab order', () {
    testWidgets('customer first tab is Menu', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPermissionsProvider.overrideWith(
              (ref) async => customerPermissions(),
            ),
            shopDetailProvider('shop-1').overrideWith(
              (ref) async => sampleShop(),
            ),
          ],
          child: const MaterialApp(
            home: ShopDetailScreen(shopId: 'shop-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tabFinder = find.byType(Tab);
      expect(tabFinder, findsWidgets);

      final tabs = tester.widgetList<Tab>(tabFinder).toList();
      expect(tabs.map((t) => t.text).toList(), [
        'Menu',
        'Events',
        'Community',
        'Reviews',
        'Reservations',
      ]);
    });
  });
}
