import 'package:coffeeshop_mobile/core/auth/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenStorage remember me', () {
    late MemoryTokenKeyStore store;
    late TokenStorage storage;
    final expiry = DateTime.now().add(const Duration(hours: 1));

    setUp(() {
      store = MemoryTokenKeyStore();
      storage = TokenStorage(store: store);
    });

    test(
      'remember on writes the refresh token and a new instance restores it',
      () async {
        await storage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiry: expiry,
          persist: true,
        );

        expect(store.values[TokenStorage.refreshTokenKey], 'refresh');
        expect(await storage.readRefreshToken(), 'refresh');
        expect(await storage.hasValidToken(), isTrue);

        final restarted = TokenStorage(store: store);
        expect(await restarted.readRefreshToken(), 'refresh');
        expect(await restarted.hasValidToken(), isTrue);
      },
    );

    test(
      'remember off keeps tokens in memory and clears stored ones',
      () async {
        await storage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiry: expiry,
          persist: true,
        );

        await storage.saveTokens(
          accessToken: 'access-session',
          refreshToken: 'refresh-session',
          expiry: expiry,
          persist: false,
        );

        expect(store.values.containsKey(TokenStorage.refreshTokenKey), isFalse);
        expect(await storage.readRefreshToken(), 'refresh-session');
        expect(await storage.hasValidToken(), isTrue);

        await storage.saveTokens(
          accessToken: 'access-refreshed',
          refreshToken: 'refresh-refreshed',
          expiry: expiry,
        );

        expect(store.values.containsKey(TokenStorage.refreshTokenKey), isFalse);
        expect(await storage.readRefreshToken(), 'refresh-refreshed');

        final restarted = TokenStorage(store: store);
        expect(await restarted.readRefreshToken(), isNull);
        expect(await restarted.hasValidToken(), isFalse);
      },
    );
  });
}
