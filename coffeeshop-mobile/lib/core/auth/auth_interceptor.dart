import 'package:dio/dio.dart';

import '../auth/token_storage.dart';
import '../config/api_config.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required Future<void> Function() onLogout,
    required Future<String?> Function() getRefreshToken,
    required Future<void> Function(String accessToken, String refreshToken)
        onTokenRefreshed,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _onLogout = onLogout,
        _getRefreshToken = getRefreshToken,
        _onTokenRefreshed = onTokenRefreshed;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final Future<void> Function() _onLogout;
  final Future<String?> Function() _getRefreshToken;
  final Future<void> Function(String accessToken, String refreshToken)
      _onTokenRefreshed;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicPath(options.path)) {
      return handler.next(options);
    }

    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        _isPublicPath(err.requestOptions.path)) {
      return handler.next(err);
    }

    if (_isTokenRefreshPath(err.requestOptions.path)) {
      await _onLogout();
      return handler.next(err);
    }

    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        await _onLogout();
        return handler.next(err);
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '${ApiConfig.baseUrl}/api/v2/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final accessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String;

        await _onTokenRefreshed(accessToken, newRefreshToken);

        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $accessToken';

        final retryResponse = await _dio.fetch<dynamic>(retryOptions);
        return handler.resolve(retryResponse);
      }
    } catch (_) {
      await _onLogout();
    }

    handler.next(err);
  }

  bool _isPublicPath(String path) {
    const publicPaths = [
      '/api/v2/auth/login',
      '/api/v2/auth/register',
      '/api/v2/auth/refresh',
    ];
    return publicPaths.any((p) => path.contains(p));
  }

  bool _isTokenRefreshPath(String path) {
    return path.contains('/api/v2/auth/refresh');
  }
}
