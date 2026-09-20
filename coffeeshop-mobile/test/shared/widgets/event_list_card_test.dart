import 'package:coffeeshop_mobile/core/utils/extensions.dart';
import 'package:coffeeshop_mobile/features/reservations/reservation_providers.dart';
import 'package:coffeeshop_mobile/shared/widgets/event_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _wrapCard(Widget card) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: card),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) => const Scaffold(body: Text('detail')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      myReservationsProvider.overrideWith((ref) async => []),
      myReservationRequestsProvider.overrideWith((ref) async => []),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUpAll(() {
    initializeDateFormatting('en_US');
  });

  testWidgets('shows event name, formatted date, shop label, and countdown',
      (tester) async {
    final eventDate = DateTime.now().add(const Duration(days: 5, hours: 2));
    final countdown = formatEventCountdown(eventDate.toIso8601String())!;

    await tester.pumpWidget(
      _wrapCard(
        EventListCard(
          eventId: 'event-1',
          eventName: 'dj avram',
          eventDate: eventDate.toIso8601String(),
          shopId: 'shop-1',
          shopName: 'test',
          shopCity: 'Belgrade',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('dj avram'), findsOneWidget);
    expect(find.text(eventDate.formatDateTime()), findsOneWidget);
    expect(find.text('at test · Belgrade'), findsOneWidget);
    expect(find.text(countdown), findsOneWidget);
    expect(find.text('Reserve'), findsOneWidget);
  });

  testWidgets('hides countdown when event date is unparseable', (tester) async {
    await tester.pumpWidget(
      _wrapCard(
        const EventListCard(
          eventId: 'event-1',
          eventName: 'dj avram',
          eventDate: 'not-a-date',
          shopId: 'shop-1',
          shopName: 'test',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('dj avram'), findsOneWidget);
    expect(find.text('not-a-date'), findsOneWidget);
    expect(find.textContaining('in '), findsNothing);
    expect(find.textContaining(' ago'), findsNothing);
    expect(find.text('now'), findsNothing);
    expect(find.text('just now'), findsNothing);
  });
}
