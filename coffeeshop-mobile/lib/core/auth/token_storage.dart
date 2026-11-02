import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'web_local_storage_stub.dart'
    if (dart.library.html) 'web_local_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// Key-value store used for persisted auth tokens.
abstract class TokenKeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// In-memory stand-in for secure storage, used by tests.
class MemoryTokenKeyStore implements TokenKeyStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<void> clear() async {
    values.clear();
  }
}

class _SecureTokenKeyStore implements TokenKeyStore {
  _SecureTokenKeyStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}

class _WebTokenKeyStore implements TokenKeyStore {
  @override
  Future<String?> read(String key) async => webStorageRead(key);

  @override
  Future<void> write(String key, String value) async {
    webStorageWrite(key, value);
  }

  @override
  Future<void> delete(String key) async {
    webStorageRemove(key);
  }

  @override
  Future<void> clear() async {
    for (final key in TokenStorage.tokenKeys) {
      webStorageRemove(key);
    }
  }
}

class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage, TokenKeyStore? store})
    : _store =
          store ??
          (kIsWeb
              ? _WebTokenKeyStore()
              : _SecureTokenKeyStore(
                  secureStorage ?? const FlutterSecureStorage(),
                ));

  final TokenKeyStore _store;

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const idTokenKey = 'id_token';
  static const tokenExpiryKey = 'token_expiry';

  static const tokenKeys = [
    accessTokenKey,
    refreshTokenKey,
    idTokenKey,
    tokenExpiryKey,
  ];

  /// When false, tokens live only in this process and are not written to disk.
  bool _persist = true;

  String? _sessionAccess;
  String? _sessionRefresh;
  String? _sessionId;
  DateTime? _sessionExpiry;

  Future<String?> readAccessToken() async {
    if (!_persist) return _sessionAccess;
    return _store.read(accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    if (!_persist) return _sessionRefresh;
    return _store.read(refreshTokenKey);
  }

  Future<String?> readIdToken() async {
    if (!_persist) return _sessionId;
    return _store.read(idTokenKey);
  }

  Future<DateTime?> readTokenExpiry() async {
    if (!_persist) return _sessionExpiry;
    final expiry = await _store.read(tokenExpiryKey);
    if (expiry == null) return null;
    return DateTime.tryParse(expiry);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? idToken,
    required DateTime expiry,
    bool? persist,
  }) async {
    if (persist != null) {
      _persist = persist;
    }

    if (!_persist) {
      await _deletePersistedTokens();
      _sessionAccess = accessToken;
      _sessionRefresh = refreshToken;
      if (idToken != null) {
        _sessionId = idToken;
      }
      _sessionExpiry = expiry;
      return;
    }

    _clearSession();
    await _store.write(accessTokenKey, accessToken);
    await _store.write(refreshTokenKey, refreshToken);
    if (idToken != null) {
      await _store.write(idTokenKey, idToken);
    }
    await _store.write(tokenExpiryKey, expiry.toIso8601String());
  }

  Future<void> clearTokens() async {
    _persist = true;
    _clearSession();
    await _store.clear();
  }

  Future<bool> hasValidToken() async {
    final accessToken = await readAccessToken();
    final expiry = await readTokenExpiry();
    if (accessToken == null || expiry == null) return false;
    return expiry.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  }

  Future<void> _deletePersistedTokens() async {
    for (final key in tokenKeys) {
      await _store.delete(key);
    }
  }

  void _clearSession() {
    _sessionAccess = null;
    _sessionRefresh = null;
    _sessionId = null;
    _sessionExpiry = null;
  }
}
