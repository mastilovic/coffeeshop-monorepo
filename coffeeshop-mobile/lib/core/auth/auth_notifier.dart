import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
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

  Future<void> login(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    try {
      await _authService.login(email, password, rememberMe: rememberMe);
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
    required String role,
  }) async {
    await _authService.register(
      name: name,
      username: username,
      email: email,
      password: password,
      role: role,
    );
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> refreshProfile() async {
    await _authService.refreshProfile();
  }
}
