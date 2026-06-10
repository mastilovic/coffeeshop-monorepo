import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final loyaltyPlanApiServiceProvider = Provider<LoyaltyPlanApiService>((ref) {
  return LoyaltyPlanApiService(dioClient: ref.watch(dioClientProvider));
});

class LoyaltyPlanApiService {
  LoyaltyPlanApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<List<dynamic>> getAll() async {
    final response = await _dioClient.get<List<dynamic>>('/api/v2/loyalty-plan');
    return response.data!;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>('/api/v2/loyalty-plan/$id');
    return response.data!;
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/loyalty-plan', data: data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dioClient.put<Map<String, dynamic>>('/api/v2/loyalty-plan/$id', data: data);
  }

  Future<void> delete(String id) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/loyalty-plan/$id');
  }
}
