import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(authService: ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required AuthService authService})
      : _authService = authService,
        super(const AuthState()) {
    _authService.authStateChanges.listen((state) {
      this.state = state;
    });
    _authService.tryAutoLogin();
  }

  final AuthService _authService;

  Future<void> loginWithKeycloak() async {
    state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    try {
      await _authService.loginWithKeycloak();
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    try {
      await _authService.loginWithCredentials(email, password);
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    await _authService.register(
      name: name,
      username: username,
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> handleAuthCallback(Uri redirectUri) async {
    // This is handled internally by openid_client Authenticator
  }
}
