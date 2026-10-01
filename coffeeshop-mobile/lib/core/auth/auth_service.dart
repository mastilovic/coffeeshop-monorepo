import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile_response_dto.dart';
import '../../data/services/auth_api_service.dart';
import 'token_storage.dart';
import 'user_role.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({this.status = AuthStatus.unknown, this.user});

  final AuthStatus status;
  final UserProfileResponseDto? user;

  UserRole? get role {
    if (user == null) return null;
    return UserRole.fromString(user!.userType);
  }

  AuthState copyWith({
    AuthStatus? status,
    UserProfileResponseDto? user,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    tokenStorage: ref.watch(tokenStorageProvider),
    authApiService: ref.watch(authApiServiceProvider),
  );
});

class AuthService {
  AuthService({
    required TokenStorage tokenStorage,
    required AuthApiService authApiService,
  }) : _tokenStorage = tokenStorage,
       _authApiService = authApiService;

  final TokenStorage _tokenStorage;
  final AuthApiService _authApiService;

  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  Stream<AuthState> get authStateChanges => _authStateController.stream;

  Future<void> login(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    try {
      final tokenResponse = await _authApiService.login(email, password);
      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiry: DateTime.now().add(Duration(seconds: tokenResponse.expiresIn)),
        persist: rememberMe,
      );
      await _loadUserProfile();
    } catch (e) {
      _updateState(const AuthState(status: AuthStatus.unauthenticated));
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
    await _authApiService.register(
      name: name,
      username: username,
      email: email,
      password: password,
      role: role,
    );

    final tokenResponse = await _authApiService.login(email, password);
    await _tokenStorage.saveTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
      expiry: DateTime.now().add(Duration(seconds: tokenResponse.expiresIn)),
      persist: true,
    );
    await _loadUserProfile();
  }

  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authApiService.getProfile();
      final user = profile.copyWith(
        userType: UserRole.fromString(profile.userType).name,
      );
      _updateState(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      _updateState(const AuthState(status: AuthStatus.unauthenticated));
      rethrow;
    }
  }

  Future<void> tryAutoLogin() async {
    final hasToken = await _tokenStorage.hasValidToken();
    if (hasToken) {
      try {
        await _loadUserProfile();
      } catch (_) {
        await _tryRefreshToken();
      }
    } else {
      await _tryRefreshToken();
    }
  }

  Future<void> _tryRefreshToken() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      _updateState(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    try {
      final tokenResponse = await _authApiService.refresh(refreshToken);
      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiry: DateTime.now().add(Duration(seconds: tokenResponse.expiresIn)),
      );
      await _loadUserProfile();
    } catch (_) {
      await logout();
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    _updateState(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _updateState(AuthState state) {
    _authStateController.add(state);
  }
}
