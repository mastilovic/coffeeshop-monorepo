import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'web_local_storage_stub.dart'
    if (dart.library.html) 'web_local_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = kIsWeb
            ? null
            : (secureStorage ?? const FlutterSecureStorage());

  final FlutterSecureStorage? _secureStorage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _idTokenKey = 'id_token';
  static const _tokenExpiryKey = 'token_expiry';

  Future<String?> readAccessToken() async {
    if (kIsWeb) {
      return webStorageRead(_accessTokenKey);
    }
    return _secureStorage?.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    if (kIsWeb) {
      return webStorageRead(_refreshTokenKey);
    }
    return _secureStorage?.read(key: _refreshTokenKey);
  }

  Future<String?> readIdToken() async {
    if (kIsWeb) {
      return webStorageRead(_idTokenKey);
    }
    return _secureStorage?.read(key: _idTokenKey);
  }

  Future<DateTime?> readTokenExpiry() async {
    final expiry = kIsWeb
        ? webStorageRead(_tokenExpiryKey)
        : await _secureStorage?.read(key: _tokenExpiryKey);
    if (expiry == null) return null;
    return DateTime.tryParse(expiry);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? idToken,
    required DateTime expiry,
  }) async {
    if (kIsWeb) {
      webStorageWrite(_accessTokenKey, accessToken);
      webStorageWrite(_refreshTokenKey, refreshToken);
      if (idToken != null) {
        webStorageWrite(_idTokenKey, idToken);
      }
      webStorageWrite(_tokenExpiryKey, expiry.toIso8601String());
      return;
    }

    final storage = _secureStorage;
    if (storage == null) return;

    await Future.wait([
      storage.write(key: _accessTokenKey, value: accessToken),
      storage.write(key: _refreshTokenKey, value: refreshToken),
      if (idToken != null) storage.write(key: _idTokenKey, value: idToken),
      storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String()),
    ]);
  }

  Future<void> clearTokens() async {
    if (kIsWeb) {
      webStorageRemove(_accessTokenKey);
      webStorageRemove(_refreshTokenKey);
      webStorageRemove(_idTokenKey);
      webStorageRemove(_tokenExpiryKey);
      return;
    }

    await _secureStorage?.deleteAll();
  }

  Future<bool> hasValidToken() async {
    final accessToken = await readAccessToken();
    final expiry = await readTokenExpiry();
    if (accessToken == null || expiry == null) return false;
    return expiry.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  }
}
