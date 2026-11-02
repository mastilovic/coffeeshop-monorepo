import 'package:coffeeshop_mobile/core/auth/auth_notifier.dart';
import 'package:coffeeshop_mobile/core/auth/auth_service.dart';
import 'package:coffeeshop_mobile/data/models/subscription_dto.dart';
import 'package:coffeeshop_mobile/data/models/user_profile_response_dto.dart';
import 'package:coffeeshop_mobile/data/services/subscription_api_service.dart';
import 'package:coffeeshop_mobile/features/billing/custom_plan_builder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionApiService extends Mock
    implements SubscriptionApiService {}

QuoteBreakdownDto quoteFor(int featuresMonthlyCents) {
  return QuoteBreakdownDto(
    featuresMonthlyCents: featuresMonthlyCents,
    monthlyTotalCents: featuresMonthlyCents,
    annualTotalCents: featuresMonthlyCents * 12,
    lineItems: featuresMonthlyCents > 0
        ? <QuoteLineItemDto>[
            QuoteLineItemDto(
              key: 'feature',
              label: 'Feature',
              amountCents: featuresMonthlyCents,
            ),
          ]
        : const <QuoteLineItemDto>[],
  );
}

final mockCatalog = CatalogResponseDto(
  tiers: const [
    CatalogTierDto(
      tier: 'GROWTH',
      displayName: 'Growth',
      basePriceMonthlyCents: 2900,
      extraShopPriceCents: 1500,
      annualMonthsCharged: 12,
      isActive: true,
      includedFeatures: [],
    ),
  ],
  features: const [
    FeatureCatalogItemDto(
      featureKey: 'reservation_manage',
      displayName: 'Reservation management',
      monthlyPriceCents: 800,
      isSelectableCustom: true,
      sortOrder: 10,
      isActive: true,
    ),
    FeatureCatalogItemDto(
      featureKey: 'event_create',
      displayName: 'Events',
      monthlyPriceCents: 1000,
      isSelectableCustom: true,
      sortOrder: 20,
      isActive: true,
    ),
    FeatureCatalogItemDto(
      featureKey: 'analytics',
      displayName: 'Analytics',
      monthlyPriceCents: 1500,
      isSelectableCustom: false,
      sortOrder: 90,
      isActive: true,
    ),
  ],
);

const mockMe = SubscriptionMeResponseDto(
  planMode: 'PRESET',
  planTier: 'STARTER',
  status: 'active',
  billingInterval: 'monthly',
  shopsIncluded: 1,
  shopsUsed: 1,
  lockedMonthlyAmountCents: 0,
);

UserProfileResponseDto testUser({SubscriptionSummaryDto? subscription}) {
  return UserProfileResponseDto(
    id: 'user-1',
    name: 'Owner',
    username: 'owner',
    email: 'owner@example.com',
    userType: 'shop_owner',
    subscription: subscription ??
        const SubscriptionSummaryDto(
          planMode: 'PRESET',
          planTier: 'STARTER',
          status: 'active',
          shopsIncluded: 1,
          shopsUsed: 1,
          monthlyAmountCents: 0,
        ),
  );
}

class FakeAuthService implements AuthService {
  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<void> tryAutoLogin() async {}

  @override
  Future<void> refreshProfile() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class TestAuthNotifier extends AuthNotifier {
  TestAuthNotifier(AuthState initialState)
      : super(authService: FakeAuthService()) {
    state = initialState;
  }
}

void main() {
  late MockSubscriptionApiService mockService;
  late List<QuoteRequestDto> quoteRequests;

  setUp(() {
    mockService = MockSubscriptionApiService();
    quoteRequests = [];
    registerFallbackValue(
      const QuoteRequestDto(
        planMode: 'CUSTOM',
        shopCount: 1,
        billingInterval: 'monthly',
      ),
    );
    registerFallbackValue(
      const UpdatePlanRequestDto(
        planMode: 'CUSTOM',
        billingInterval: 'monthly',
      ),
    );

    when(() => mockService.getCatalog()).thenAnswer((_) async => mockCatalog);
    when(() => mockService.getMe()).thenAnswer((_) async => mockMe);
    when(() => mockService.quote(any())).thenAnswer((invocation) async {
      final request = invocation.positionalArguments.first as QuoteRequestDto;
      quoteRequests.add(request);
      final featureTotal = request.features.fold<int>(
        0,
        (sum, key) => sum + switch (key) {
          'reservation_manage' => 800,
          'event_create' => 1000,
          _ => 0,
        },
      );
      return quoteFor(featureTotal);
    });
    when(() => mockService.changePlan(any())).thenAnswer(
      (_) async => const SubscriptionMeResponseDto(
        planMode: 'CUSTOM',
        status: 'active',
        features: ['reservation_manage'],
        shopsIncluded: 1,
        shopsUsed: 1,
        lockedMonthlyAmountCents: 800,
      ),
    );
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        subscriptionApiServiceProvider.overrideWithValue(mockService),
        authNotifierProvider.overrideWith(
          (ref) => TestAuthNotifier(
            AuthState(
              status: AuthStatus.authenticated,
              user: testUser(),
            ),
          ),
        ),
      ],
      child: const MaterialApp(
        home: CustomPlanBuilderScreen(),
      ),
    );
  }

  Future<void> waitForCatalog(WidgetTester tester) async {
    await tester.pump();
    await tester.pumpAndSettle();
  }

  group('CustomPlanBuilderScreen', () {
    testWidgets('renders only selectable custom features', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await waitForCatalog(tester);

      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(find.text('Reservation management'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('requests quote on load and when features change',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await waitForCatalog(tester);

      quoteRequests.clear();
      await tester.tap(find.byKey(const Key('feature-reservation_manage')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(quoteRequests, isNotEmpty);
      final lastRequest = quoteRequests.last;
      expect(lastRequest.planMode, 'CUSTOM');
      expect(lastRequest.features, ['reservation_manage']);
      expect(lastRequest.shopCount, 1);
      expect(lastRequest.billingInterval, 'monthly');
    });

    testWidgets('updates quote when shop count changes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await waitForCatalog(tester);

      quoteRequests.clear();
      await tester.enterText(find.byKey(const Key('shop-count')), '3');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(quoteRequests.last.shopCount, 3);
    });

    testWidgets('updates quote when annual toggle changes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await waitForCatalog(tester);

      quoteRequests.clear();
      await tester.tap(find.byKey(const Key('annual-toggle')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(quoteRequests.last.billingInterval, 'annual');
      expect(find.byKey(const Key('quote-total')), findsOneWidget);
    });

    testWidgets('displays quote total from service response', (tester) async {
      when(() => mockService.quote(any())).thenAnswer((_) async => quoteFor(1800));

      await tester.pumpWidget(buildTestWidget());
      await waitForCatalog(tester);

      expect(find.byKey(const Key('quote-total')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('quote-total'))).data,
        '\$18.00',
      );
    });

    testWidgets('applies custom plan via subscription service', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await waitForCatalog(tester);

      await tester.tap(find.byKey(const Key('feature-reservation_manage')));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('apply-plan')));
      await tester.pump();
      await tester.pumpAndSettle();

      final captured = verify(() => mockService.changePlan(captureAny()))
          .captured
          .single as UpdatePlanRequestDto;
      expect(captured.planMode, 'CUSTOM');
      expect(captured.features, ['reservation_manage']);
      expect(captured.billingInterval, 'monthly');
      expect(find.byKey(const Key('apply-success')), findsOneWidget);
    });

    testWidgets('shows error when quote request fails', (tester) async {
      when(() => mockService.quote(any())).thenThrow(Exception('quote failed'));

      await tester.pumpWidget(buildTestWidget());
      await waitForCatalog(tester);

      expect(find.text('Unable to load quote.'), findsOneWidget);
    });
  });
}
