import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

class TokenStorage {
  TokenStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _idTokenKey = 'id_token';
  static const _tokenExpiryKey = 'token_expiry';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> readIdToken() => _storage.read(key: _idTokenKey);

  Future<DateTime?> readTokenExpiry() async {
    final expiry = await _storage.read(key: _tokenExpiryKey);
    if (expiry == null) return null;
    return DateTime.tryParse(expiry);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? idToken,
    required DateTime expiry,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      if (idToken != null)
        _storage.write(key: _idTokenKey, value: idToken),
      _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String()),
    ]);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<bool> hasValidToken() async {
    final accessToken = await readAccessToken();
    final expiry = await readTokenExpiry();
    if (accessToken == null || expiry == null) return false;
    return expiry.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  }
}
