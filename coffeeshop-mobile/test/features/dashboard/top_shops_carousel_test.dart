import 'package:coffeeshop_mobile/data/models/dashboard_activity_response.dart';
import 'package:coffeeshop_mobile/features/dashboard/widgets/top_shops_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('TopShopsCarousel', () {
    testWidgets('renders compact tiles with rating', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          TopShopsCarousel(
            shops: [
              TopShopItem(
                shopId: '1',
                shopName: 'Central Perk',
                city: 'New York',
                averageRating: 4.5,
                reviewCount: 12,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Top Shops'), findsOneWidget);
      expect(find.text('Central Perk'), findsOneWidget);
      expect(find.text('New York'), findsOneWidget);
      expect(find.text('4.5 (12)'), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('shows No rating yet when no reviews', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const TopShopsCarousel(
            shops: [
              TopShopItem(
                shopId: '1',
                shopName: 'Quiet Cafe',
                city: 'Belgrade',
                averageRating: null,
                reviewCount: 0,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Quiet Cafe'), findsOneWidget);
      expect(find.text('No rating yet'), findsOneWidget);
    });

    testWidgets('renders nothing when shops empty', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const TopShopsCarousel(shops: [])),
      );

      expect(find.text('Top Shops'), findsNothing);
      expect(find.byType(Card), findsNothing);
    });
  });
}
