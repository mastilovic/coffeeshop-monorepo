import 'package:coffeeshop_mobile/core/auth/auth_notifier.dart';
import 'package:coffeeshop_mobile/core/auth/auth_service.dart';
import 'package:coffeeshop_mobile/core/config/app_config.dart';
import 'package:coffeeshop_mobile/data/models/user_profile_response_dto.dart';
import 'package:coffeeshop_mobile/data/services/reservation_api_service.dart';
import 'package:coffeeshop_mobile/data/services/review_api_service.dart';
import 'package:coffeeshop_mobile/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

class MockReservationApiService extends Mock implements ReservationApiService {}

class MockReviewApiService extends Mock implements ReviewApiService {}

void main() {
  late MockReservationApiService reservationApi;
  late MockReviewApiService reviewApi;
  late List<Uri> launched;

  setUp(() {
    reservationApi = MockReservationApiService();
    reviewApi = MockReviewApiService();
    launched = <Uri>[];
    when(() => reservationApi.getAll()).thenAnswer((_) async => <dynamic>[]);
    when(() => reviewApi.getAll()).thenAnswer((_) async => <dynamic>[]);
  });

  testWidgets('Privacy Policy opens the hosted AppConfig URL', (tester) async {
    const user = UserProfileResponseDto(
      id: 'user-1',
      name: 'Ada',
      username: 'ada',
      email: 'ada@example.com',
      userType: 'customer',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            (ref) => TestAuthNotifier(
              const AuthState(
                status: AuthStatus.authenticated,
                user: user,
              ),
            ),
          ),
          reservationApiServiceProvider.overrideWithValue(reservationApi),
          reviewApiServiceProvider.overrideWithValue(reviewApi),
        ],
        child: MaterialApp(
          home: ProfileScreen(
            openUrl: (uri) async {
              launched.add(uri);
              return true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(launched, [Uri.parse(AppConfig.privacyPolicyUrl)]);
  });
}
