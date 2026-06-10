import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final reservationApiServiceProvider = Provider<ReservationApiService>((ref) {
  return ReservationApiService(dioClient: ref.watch(dioClientProvider));
});

class ReservationApiService {
  ReservationApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<List<dynamic>> getAll({String? shopId}) async {
    final response = await _dioClient.get<List<dynamic>>(
      '/api/v2/reservation',
      queryParameters: {if (shopId != null) 'shopId': shopId},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>('/api/v2/reservation/$id');
    return response.data!;
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/reservation', data: data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dioClient.put<Map<String, dynamic>>('/api/v2/reservation/$id', data: data);
  }

  Future<void> delete(String id) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/reservation/$id');
  }
}
