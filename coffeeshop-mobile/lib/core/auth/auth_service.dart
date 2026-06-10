import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/user_response_dto.dart';
import '../../data/services/auth_api_service.dart';
import '../config/api_config.dart';
import 'token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
  });

  final AuthStatus status;
  final UserResponseDto? user;

  AuthState copyWith({
    AuthStatus? status,
    UserResponseDto? user,
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
  })  : _tokenStorage = tokenStorage,
        _authApiService = authApiService;

  final TokenStorage _tokenStorage;
  final AuthApiService _authApiService;

  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  Stream<AuthState> get authStateChanges => _authStateController.stream;

  Future<Credential> loginWithKeycloak() async {
    final uri = Uri.parse(ApiConfig.keycloakBaseUrl);
    final issuer = await Issuer.discover(uri);
    final client = Client(
      issuer,
      ApiConfig.keycloakClientId,
    );

    final authenticator = Authenticator(
      client,
      scopes: ['openid', 'profile', 'email', 'offline_access'],
      urlLancher: (String url) async {
        final parsedUrl = Uri.parse(url);
        if (await canLaunchUrl(parsedUrl)) {
          await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
        }
      },
    );

    final credential = await authenticator.authorize();

    final response = credential.response;
    if (response != null) {
      await _tokenStorage.saveTokens(
        accessToken: (response['access_token'] as String?) ?? '',
        refreshToken: (response['refresh_token'] as String?) ?? '',
        idToken: (response['id_token'] as String?)?.toString(),
        expiry: DateTime.now().add(
          Duration(seconds: (response['expires_in'] as int?) ?? 3600),
        ),
      );

      await _loadUserProfile();
    }

    return credential;
  }

  Future<void> loginWithCredentials(String email, String password) async {
    try {
      final tokenResponse = await _authApiService.login(email, password);
      await _tokenStorage.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiry: DateTime.now().add(Duration(seconds: tokenResponse.expiresIn)),
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
  }) async {
    await _authApiService.register(
      name: name,
      username: username,
      email: email,
      password: password,
    );
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _authApiService.getProfile();
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
