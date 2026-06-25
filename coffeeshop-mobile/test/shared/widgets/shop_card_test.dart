import 'package:coffeeshop_mobile/shared/widgets/shop_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ShopCard', () {
    testWidgets('renders shop name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(name: 'Central Perk')),
      );

      expect(find.text('Central Perk'), findsOneWidget);
    });

    testWidgets('renders city when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ShopCard(name: 'Central Perk', city: 'New York'),
        ),
      );

      expect(find.text('New York'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('does not render city when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(name: 'Central Perk')),
      );

      expect(find.byIcon(Icons.location_on), findsNothing);
    });

    testWidgets('renders rating and review count', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ShopCard(
            name: 'Central Perk',
            rating: 4.5,
            reviewCount: 42,
          ),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(42)'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('does not render rating when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(name: 'Central Perk')),
      );

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('renders favourite border when not favourited', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShopCard(name: 'Test Shop', onFavouriteToggle: () {}),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('renders filled favourite when favourited', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShopCard(
            name: 'Test Shop',
            isFavourite: true,
            onFavouriteToggle: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          ShopCard(
            name: 'Central Perk',
            onTap: () => wasTapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Central Perk'));
      expect(wasTapped, isTrue);
    });

    testWidgets('calls onFavouriteToggle when heart tapped', (tester) async {
      bool wasToggled = false;
      await tester.pumpWidget(
        buildTestWidget(
          ShopCard(
            name: 'Central Perk',
            onFavouriteToggle: () => wasToggled = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(wasToggled, isTrue);
    });

    testWidgets('does not show favourite button when not provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(name: 'Test Shop')),
      );

      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('renders store icon placeholder', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(name: 'Test Shop')),
      );

      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('shows management actions when callbacks provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShopCard(
            name: 'Managed Shop',
            onEmployees: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('Employees'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('does not show management actions when not provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const ShopCard(name: 'Customer Shop')),
      );

      expect(find.text('Employees'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('calls onDelete when delete tapped', (tester) async {
      var wasDeleted = false;
      await tester.pumpWidget(
        buildTestWidget(
          ShopCard(
            name: 'Managed Shop',
            onDelete: () => wasDeleted = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(wasDeleted, isTrue);
    });

    testWidgets('renders outlined card when isOwned is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const ShopCard(name: 'My Shop', isOwned: true),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder?;
      expect(shape, isNotNull);
      expect(shape!.side.width, 2);
    });
  });
}
