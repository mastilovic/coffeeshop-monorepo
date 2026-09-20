import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/data/models/reservation_request_response_dto.dart';
import 'package:coffeeshop_mobile/features/shop_details/tabs/reservations_tab.dart';
import 'package:coffeeshop_mobile/shared/widgets/upgrade_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gated_ui_test_helpers.dart';

void main() {
  group('Reservation accept/deny gated UI', () {
    testWidgets('disables Accept and Deny without reservation_manage', (tester) async {
      const request = ReservationRequestResponseDto(
        id: 'req-1',
        partySize: 2,
        status: 'PENDING',
      );
      const tables = [
        {'id': 'table-1', 'number': 1, 'capacity': 4},
      ];

      await tester.pumpWidget(
        buildGatedHarness(
          permissions: starterOwnerPermissions(),
          overrides: [
            shopReservationRequestsProvider('shop-1').overrideWith(
              (ref) async => [request],
            ),
            shopReservationsProvider('shop-1').overrideWith((ref) async => []),
          ],
          child: const ReservationsTab(
            shopId: 'shop-1',
            tables: tables,
            canManage: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final accept = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Accept'),
      );
      final deny = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Deny'),
      );

      expect(accept.onPressed, isNull);
      expect(deny.onPressed, isNull);
      expect(find.text(upgradeToGrowthLabel), findsOneWidget);
    });
  });
}
