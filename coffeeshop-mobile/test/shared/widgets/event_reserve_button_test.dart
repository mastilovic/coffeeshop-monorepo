import 'package:coffeeshop_mobile/core/utils/reservation_event_utils.dart';
import 'package:coffeeshop_mobile/data/models/reservation_request_response_dto.dart';
import 'package:coffeeshop_mobile/features/reservations/reservation_providers.dart';
import 'package:coffeeshop_mobile/shared/widgets/event_reserve_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('isEventReservable / reservationUnavailableMessage', () {
    test('is reservable with shop and future date', () {
      final future =
          DateTime.now().add(const Duration(days: 1)).toIso8601String();
      expect(isEventReservable(shopId: 'shop-1', eventDate: future), isTrue);
    });

    test('not reservable without shop', () {
      final future =
          DateTime.now().add(const Duration(days: 1)).toIso8601String();
      expect(isEventReservable(shopId: null, eventDate: future), isFalse);
      expect(isEventReservable(shopId: '', eventDate: future), isFalse);
    });

    test('not reservable for past date', () {
      final past =
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
      expect(isEventReservable(shopId: 'shop-1', eventDate: past), isFalse);
    });

    test('not reservable when already reserved', () {
      final future =
          DateTime.now().add(const Duration(days: 1)).toIso8601String();
      expect(
        isEventReservable(
          shopId: 'shop-1',
          eventDate: future,
          alreadyReserved: true,
        ),
        isFalse,
      );
    });

    test('unavailable message prefers already reserved', () {
      expect(
        reservationUnavailableMessage(
          shopId: null,
          alreadyReserved: true,
        ),
        'You already have a reservation for this event.',
      );
    });

    test('unavailable message prefers missing shop over expired', () {
      expect(
        reservationUnavailableMessage(shopId: null, eventDate: null),
        "This event isn't linked to a shop yet.",
      );
      expect(
        reservationUnavailableMessage(shopId: 'shop-1', eventDate: null),
        'Reservations for this event are no longer available.',
      );
    });
  });

  group('userHasReservationForEvent', () {
    test('detects confirmed reservation by eventId', () {
      expect(
        userHasReservationForEvent(
          eventId: 'event-1',
          reservations: [
            {'eventId': 'event-1', 'id': 'r1'},
          ],
        ),
        isTrue,
      );
    });

    test('detects pending request', () {
      expect(
        userHasReservationForEvent(
          eventId: 'event-1',
          requests: [
            const ReservationRequestResponseDto(
              id: 'req-1',
              partySize: 2,
              status: 'PENDING',
              eventId: 'event-1',
            ),
          ],
        ),
        isTrue,
      );
    });

    test('ignores denied request', () {
      expect(
        userHasReservationForEvent(
          eventId: 'event-1',
          requests: [
            const ReservationRequestResponseDto(
              id: 'req-1',
              partySize: 2,
              status: 'DENIED',
              eventId: 'event-1',
            ),
          ],
        ),
        isFalse,
      );
    });
  });

  group('EventReserveButton', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      required Widget home,
      List<Override> overrides = const [],
      GoRouter? router,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myReservationsProvider.overrideWith((ref) async => []),
            myReservationRequestsProvider.overrideWith((ref) async => []),
            ...overrides,
          ],
          child: router != null
              ? MaterialApp.router(routerConfig: router)
              : MaterialApp(home: home),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('navigates to reservation form when reservable', (tester) async {
      final future =
          DateTime.now().add(const Duration(days: 7)).toIso8601String();

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: EventReserveButton(
                eventId: 'event-1',
                shopId: 'shop-1',
                eventDate: future,
              ),
            ),
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
        ],
      );

      await pumpButton(
        tester,
        home: const SizedBox.shrink(),
        router: router,
      );

      await tester.tap(find.text('Reserve'));
      await tester.pumpAndSettle();

      expect(
        find.text('Reservations shop=shop-1 event=event-1 request=1'),
        findsOneWidget,
      );
    });

    testWidgets('shows expired snackbar and does not navigate', (tester) async {
      final past =
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
      var navigatedToReservations = false;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: EventReserveButton(
                eventId: 'event-1',
                shopId: 'shop-1',
                eventDate: past,
              ),
            ),
          ),
          GoRoute(
            path: '/reservations',
            builder: (context, state) {
              navigatedToReservations = true;
              return const Scaffold(body: Text('Reservations'));
            },
          ),
        ],
      );

      await pumpButton(
        tester,
        home: const SizedBox.shrink(),
        router: router,
      );

      await tester.tap(find.text('Reserve'));
      await tester.pumpAndSettle();

      expect(navigatedToReservations, isFalse);
      expect(
        find.text('Reservations for this event are no longer available.'),
        findsOneWidget,
      );
    });

    testWidgets('shows missing-shop snackbar', (tester) async {
      final future =
          DateTime.now().add(const Duration(days: 7)).toIso8601String();

      await pumpButton(
        tester,
        home: Scaffold(
          body: EventReserveButton(
            eventId: 'event-1',
            eventDate: future,
          ),
        ),
      );

      await tester.tap(find.text('Reserve'));
      await tester.pumpAndSettle();

      expect(
        find.text("This event isn't linked to a shop yet."),
        findsOneWidget,
      );
    });

    testWidgets('shows already-reserved snackbar', (tester) async {
      final future =
          DateTime.now().add(const Duration(days: 7)).toIso8601String();
      var navigated = false;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: EventReserveButton(
                eventId: 'event-1',
                shopId: 'shop-1',
                eventDate: future,
              ),
            ),
          ),
          GoRoute(
            path: '/reservations',
            builder: (context, state) {
              navigated = true;
              return const Scaffold(body: Text('Reservations'));
            },
          ),
        ],
      );

      await pumpButton(
        tester,
        home: const SizedBox.shrink(),
        router: router,
        overrides: [
          myReservationsProvider.overrideWith(
            (ref) async => [
              {'eventId': 'event-1', 'id': 'r1'},
            ],
          ),
        ],
      );

      await tester.tap(find.text('Reserve'));
      await tester.pumpAndSettle();

      expect(navigated, isFalse);
      expect(
        find.text('You already have a reservation for this event.'),
        findsOneWidget,
      );
    });
  });
}
