import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final userApiServiceProvider = Provider<UserApiService>((ref) {
  return UserApiService(dioClient: ref.watch(dioClientProvider));
});

class UserApiService {
  UserApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<dynamic> getAll({String? q, int page = 0, int size = 20}) async {
    final response = await _dioClient.get<dynamic>(
      '/api/v2/user',
      queryParameters: {'q': q, 'page': page, 'size': size},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>('/api/v2/user/$id');
    return response.data!;
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/user', data: data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dioClient.put<Map<String, dynamic>>('/api/v2/user/$id', data: data);
  }

  Future<void> delete(String id) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/user/$id');
  }
}
