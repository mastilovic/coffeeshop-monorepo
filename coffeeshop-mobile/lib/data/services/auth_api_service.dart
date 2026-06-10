import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/token_response.dart';
import '../models/user_response_dto.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(dioClient: ref.watch(dioClientProvider));
});

class AuthApiService {
  AuthApiService({required DioClient dioClient}) : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<TokenResponse> login(String email, String password) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/api/v2/auth/login',
      data: LoginRequest(email: email, password: password).toJson(),
    );
    return TokenResponse.fromJson(response.data!);
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    await _dioClient.post<Map<String, dynamic>>(
      '/api/v2/auth/register',
      data: RegisterRequest(
        name: name,
        username: username,
        email: email,
        password: password,
      ).toJson(),
    );
  }

  Future<TokenResponse> refresh(String refreshToken) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/api/v2/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return TokenResponse.fromJson(response.data!);
  }

  Future<UserResponseDto> getProfile() async {
    final response =
        await _dioClient.get<Map<String, dynamic>>('/api/v2/profile');
    return UserResponseDto.fromJson(response.data!);
  }
}
