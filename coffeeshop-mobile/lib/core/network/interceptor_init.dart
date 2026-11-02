import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_interceptor.dart';
import '../auth/auth_service.dart';
import '../auth/token_storage.dart';
import 'dio_client.dart';

final authInterceptorInitializer = Provider<void>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final authService = ref.watch(authServiceProvider);

  dioClient.addInterceptor(
    AuthInterceptor(
      dio: dioClient.dio,
      tokenStorage: tokenStorage,
      onLogout: () => authService.logout(),
      getRefreshToken: () => tokenStorage.readRefreshToken(),
      onTokenRefreshed: (String accessToken, String refreshToken) {
        return tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );
      },
    ),
  );
});
