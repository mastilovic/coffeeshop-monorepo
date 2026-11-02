import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/core/network/dio_client.dart';
import 'package:coffeeshop_mobile/data/services/shop_api_service.dart';
import 'package:coffeeshop_mobile/features/shop_details/shop_manage_permission.dart';
import 'package:coffeeshop_mobile/features/shops/shop_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../gated_ui_test_helpers.dart';

class _RecordingShopApi extends ShopApiService {
  _RecordingShopApi() : super(dioClient: DioClient());

  final recentReviewQueries = <int?>[];

  @override
  Future<Map<String, dynamic>> getShops({
    String? q,
    String? city,
    int page = 0,
    int size = 25,
    int? recentReviews,
  }) async {
    recentReviewQueries.add(recentReviews);
    return {
      'content': [
        {
          'id': 'plain',
          'name': 'Plain Shop',
          'address': '1',
          'city': 'Beograd',
          'reviewCount': 0,
          'recentReviewCount': 0,
          'memberCount': 0,
        },
        {
          'id': 'rated',
          'name': 'Rated Shop',
          'address': '2',
          'city': 'Beograd',
          'averageRating': 4.5,
          'reviewCount': 2,
          'recentReviewCount': 2,
          'memberCount': 1,
        },
      ],
      'totalPages': 1,
      'totalElements': 2,
    };
  }
}

void main() {
  testWidgets('recent reviews route requests the query, badges shops, and clears on dismiss', (tester) async {
    final api = _RecordingShopApi();
    final router = GoRouter(
      initialLocation: '/shops?recentReviews=30',
      routes: [
        GoRoute(
          path: '/shops',
          builder: (context, state) {
            final recentReviews = int.tryParse(state.uri.queryParameters['recentReviews'] ?? '');
            return ShopListScreen(recentReviews: recentReviews == 30 ? 30 : null);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shopApiServiceProvider.overrideWithValue(api),
          userPermissionsProvider.overrideWith((ref) async => starterOwnerPermissions()),
          ownedShopsProvider.overrideWith((ref) async => []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.recentReviewQueries, contains(30));
    expect(find.text('New reviews · 30 days'), findsOneWidget);
    expect(find.text('2 new'), findsOneWidget);
    expect(find.text('No rating yet'), findsOneWidget);
    expect(find.text('Rated Shop'), findsOneWidget);
    expect(find.text('Plain Shop'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Rated Shop')).dy,
      lessThan(tester.getTopLeft(find.text('Plain Shop')).dy),
    );

    tester.widget<InputChip>(find.byType(InputChip)).onDeleted!();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.queryParameters.containsKey('recentReviews'), isFalse);
    expect(api.recentReviewQueries, contains(null));
    expect(find.text('New reviews · 30 days'), findsNothing);
    expect(find.text('2 new'), findsNothing);
  });
}
