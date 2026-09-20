import 'package:coffeeshop_mobile/core/utils/extensions.dart';
import 'package:coffeeshop_mobile/data/models/shop_response_dto.dart';
import 'package:coffeeshop_mobile/features/reservations/reservation_providers.dart';
import 'package:coffeeshop_mobile/features/shop_details/tabs/overview_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

ShopResponseDto buildShop({
  String? phoneNumber = '555-0100',
  String? email = 'cafe@example.com',
  Map<String, dynamic>? currentMenu,
  List<Map<String, dynamic>>? events,
  List<Map<String, dynamic>>? reviews,
  bool favouriteByCurrentUser = false,
}) {
  return ShopResponseDto(
    id: 'shop-1',
    name: 'Test Cafe',
    address: '1 Main St',
    city: 'Berlin',
    phoneNumber: phoneNumber,
    email: email,
    averageRating: 4.5,
    reviewCount: 2,
    memberCount: 12,
    favouriteByCurrentUser: favouriteByCurrentUser,
    loyaltyPlan: {
      'id': 'plan-1',
      'name': 'Basic Rewards',
      'type': 'BASIC',
    },
    currentMenu: currentMenu,
    events: events,
    reviews: reviews,
  );
}

Widget wrapOverview(Widget child) {
  return ProviderScope(
    overrides: [
      myReservationsProvider.overrideWith((ref) async => []),
      myReservationRequestsProvider.overrideWith((ref) async => []),
    ],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUpAll(() {
    initializeDateFormatting('en_US');
  });

  group('overview helpers', () {
    test('menuPreviewItems returns up to three items', () {
      final items = menuPreviewItems({
        'items': [
          {'id': '1', 'name': 'Latte'},
          {'id': '2', 'name': 'Mocha'},
          {'id': '3', 'name': 'Tea'},
          {'id': '4', 'name': 'Cake'},
        ],
      });
      expect(items, hasLength(3));
      expect(items.first['name'], 'Latte');
    });

    test('upcomingEventsPreview filters past events and sorts', () {
      final now = DateTime(2026, 6, 15, 12);
      final events = upcomingEventsPreview(
        [
          {
            'eventId': 'past',
            'eventName': 'Past',
            'eventDate': '2026-06-01T10:00:00',
          },
          {
            'eventId': 'later',
            'eventName': 'Later',
            'eventDate': '2026-07-01T10:00:00',
          },
          {
            'eventId': 'soon',
            'eventName': 'Soon',
            'eventDate': '2026-06-20T10:00:00',
          },
        ],
        now: now,
      );
      expect(events.map((e) => e.eventId), ['soon', 'later']);
    });

    test('reviewsPreview returns newest first limited to two', () {
      final reviews = reviewsPreview([
        {
          'id': 'old',
          'rating': 3,
          'description': 'Ok',
          'reviewDate': '2026-01-01',
        },
        {
          'id': 'new',
          'rating': 5,
          'description': 'Great',
          'reviewDate': '2026-06-01',
        },
        {
          'id': 'mid',
          'rating': 4,
          'description': 'Good',
          'reviewDate': '2026-03-01',
        },
      ]);
      expect(reviews.map((r) => r['id']), ['new', 'mid']);
    });
  });

  group('OverviewTab', () {
    testWidgets('shows identity, contact, stats and empty previews', (tester) async {
      await tester.pumpWidget(
        wrapOverview(
          OverviewTab(
            shop: buildShop(),
            canManageShop: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Cafe'), findsOneWidget);
      expect(find.text('Berlin · 1 Main St'), findsOneWidget);
      expect(find.text('555-0100'), findsOneWidget);
      expect(find.text('cafe@example.com'), findsOneWidget);
      expect(find.text('4.5 (2)'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('No menu yet.'), findsOneWidget);
      expect(find.text('No upcoming events.'), findsOneWidget);
      expect(find.text('No reviews yet.'), findsOneWidget);
      expect(find.text('Join community'), findsOneWidget);
      expect(find.text('Loyalty'), findsOneWidget);
    });

    testWidgets('hides join for managers', (tester) async {
      await tester.pumpWidget(
        wrapOverview(
          OverviewTab(
            shop: buildShop(),
            canManageShop: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Join community'), findsNothing);
      expect(find.text('Leave community'), findsNothing);
    });

    testWidgets('See all callbacks fire', (tester) async {
      var sawMenu = false;
      var sawEvents = false;
      var sawReviews = false;

      final eventDate = DateTime.now().add(const Duration(days: 5, hours: 2));
      final countdown = formatEventCountdown(eventDate.toIso8601String())!;

      await tester.pumpWidget(
        wrapOverview(
          OverviewTab(
            shop: buildShop(
              currentMenu: {
                'items': [
                  {
                    'id': '1',
                    'name': 'Espresso',
                    'price': 3,
                    'priceCurrency': 'EUR',
                  },
                ],
              },
              events: [
                {
                  'eventId': 'e1',
                  'eventName': 'Latte Art Night',
                  'eventDate': eventDate.toIso8601String(),
                },
              ],
              reviews: [
                {
                  'id': 'r1',
                  'rating': 5,
                  'description': 'Amazing',
                  'reviewDate': '2026-06-01',
                  'user': {'name': 'Alex', 'username': 'alex'},
                },
              ],
            ),
            canManageShop: false,
            onSeeMenu: () => sawMenu = true,
            onSeeEvents: () => sawEvents = true,
            onSeeReviews: () => sawReviews = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Latte Art Night'), findsOneWidget);
      expect(find.text(countdown), findsOneWidget);
      expect(find.text('Reserve'), findsOneWidget);
      expect(find.text('Amazing'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Espresso'), 200);
      expect(find.text('Espresso'), findsOneWidget);

      // Order: Events → Reviews → Menu
      await tester.tap(find.text('See all').at(0));
      expect(sawEvents, isTrue);
      await tester.tap(find.text('See all').at(1));
      expect(sawReviews, isTrue);
      await tester.ensureVisible(find.text('See all').at(2));
      await tester.tap(find.text('See all').at(2));
      expect(sawMenu, isTrue);
    });

    testWidgets('shows leave community when already favourited', (tester) async {
      await tester.pumpWidget(
        wrapOverview(
          OverviewTab(
            shop: buildShop(favouriteByCurrentUser: true),
            canManageShop: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Leave community'), findsOneWidget);

      await tester.tap(find.text('Leave community'));
      await tester.pumpAndSettle();

      expect(find.text('Leave community'), findsWidgets);
      expect(
        find.text("Are you sure you want to leave Test Cafe's community?"),
        findsOneWidget,
      );
      expect(find.text('Leave'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
