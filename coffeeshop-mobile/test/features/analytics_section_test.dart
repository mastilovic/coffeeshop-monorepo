import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/data/models/dashboard_analytics_response.dart';
import 'package:coffeeshop_mobile/features/dashboard/widgets/analytics_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gated_ui_test_helpers.dart';

const _analyticsResponse = DashboardAnalyticsResponse(
  aggregate: DashboardAnalyticsAggregate(
    shopCount: 1,
    reservationCount: 4,
    pendingReservationRequestCount: 1,
    eventCount: 2,
    reviewCount: 5,
    averageRating: 4.2,
    communityPostCount: 3,
    memberCount: 10,
    employeeCount: 2,
    tableCount: 6,
    menuCount: 2,
  ),
  shops: [
    DashboardShopAnalytics(
      shopId: 'shop-1',
      shopName: 'Bean There',
      city: 'Zagreb',
      reservationCount: 4,
      pendingReservationRequestCount: 1,
      eventCount: 2,
      reviewCount: 5,
      averageRating: 4.2,
      communityPostCount: 3,
      memberCount: 10,
      employeeCount: 2,
      tableCount: 6,
      menuCount: 2,
    ),
  ],
);

void main() {
  group('AnalyticsSection gated UI', () {
    testWidgets('shows upgrade CTA for Starter/Growth owners', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: growthOwnerPermissions(),
          child: const AnalyticsSection(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('analytics-upgrade')), findsOneWidget);
      expect(find.text(upgradeToProLabel), findsOneWidget);
      expect(find.byKey(const Key('analytics-aggregate')), findsNothing);
    });

    testWidgets('loads analytics for Pro owners', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: proOwnerPermissions(),
          overrides: [
            dashboardAnalyticsProvider.overrideWith((ref) async => _analyticsResponse),
          ],
          child: const AnalyticsSection(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('analytics-upgrade')), findsNothing);
      expect(find.byKey(const Key('analytics-aggregate')), findsOneWidget);
      expect(find.text('Bean There'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
    });

    testWidgets('hides analytics section for customers', (tester) async {
      await tester.pumpWidget(
        buildGatedHarness(
          permissions: const UserPermissions(),
          child: const AnalyticsSection(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pro Analytics'), findsNothing);
    });
  });
}
