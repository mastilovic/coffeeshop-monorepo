import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final tableApiServiceProvider = Provider<TableApiService>((ref) {
  return TableApiService(dioClient: ref.watch(dioClientProvider));
});

class TableApiService {
  TableApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<List<dynamic>> getAll() async {
    final response = await _dioClient.get<List<dynamic>>('/api/v2/table');
    return response.data!;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>('/api/v2/table/$id');
    return response.data!;
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/table', data: data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dioClient.put<Map<String, dynamic>>('/api/v2/table/$id', data: data);
  }

  Future<void> delete(String id) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/table/$id');
  }
}
