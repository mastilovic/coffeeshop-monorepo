import 'package:coffeeshop_mobile/shared/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('StarRating', () {
    testWidgets('renders correct number of stars', (tester) async {
      await tester.pumpWidget(buildTestWidget(const StarRating(rating: 3.0)));

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('renders all filled stars for max rating', (tester) async {
      await tester.pumpWidget(buildTestWidget(const StarRating(rating: 5.0)));

      expect(find.byIcon(Icons.star), findsNWidgets(5));
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('renders all empty stars for zero rating', (tester) async {
      await tester.pumpWidget(buildTestWidget(const StarRating(rating: 0.0)));

      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    });

    testWidgets('renders half star for .5 rating', (tester) async {
      await tester.pumpWidget(buildTestWidget(const StarRating(rating: 2.5)));

      expect(find.byIcon(Icons.star), findsNWidgets(2));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('renders half star for rating between .5 ranges', (tester) async {
      await tester.pumpWidget(buildTestWidget(const StarRating(rating: 3.7)));

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('calls onRatingChanged callback when tapped', (tester) async {
      int? tappedRating;
      await tester.pumpWidget(
        buildTestWidget(
          StarRating(
            rating: 0.0,
            onRatingChanged: (r) => tappedRating = r,
          ),
        ),
      );

      final firstStar = find.byIcon(Icons.star_border).first;
      await tester.tap(firstStar);
      expect(tappedRating, 1);
    });

    testWidgets('calls onRatingChanged with correct star value', (tester) async {
      int? tappedRating;
      await tester.pumpWidget(
        buildTestWidget(
          StarRating(
            rating: 0.0,
            onRatingChanged: (r) => tappedRating = r,
          ),
        ),
      );

      final thirdStar = find.byIcon(Icons.star_border).at(2);
      await tester.tap(thirdStar);
      expect(tappedRating, 3);
    });

    testWidgets('does not call callback when not provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const StarRating(rating: 3.0)),
      );

      final star = find.byIcon(Icons.star).first;
      await tester.tap(star);
    });

    testWidgets('uses custom maxRating', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const StarRating(rating: 7.0, maxRating: 10)),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(7));
      expect(find.byIcon(Icons.star_border), findsNWidgets(3));
    });

    testWidgets('uses custom color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const StarRating(rating: 5.0, color: Colors.amber),
        ),
      );

      final star = tester.widget<Icon>(find.byIcon(Icons.star).first);
      expect(star.color, Colors.amber);
    });
  });
}
