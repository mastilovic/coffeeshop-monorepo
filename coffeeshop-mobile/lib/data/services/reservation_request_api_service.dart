import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/reservation_request_response_dto.dart';

final reservationRequestApiServiceProvider = Provider<ReservationRequestApiService>((ref) {
  return ReservationRequestApiService(dioClient: ref.watch(dioClientProvider));
});

class ReservationRequestApiService {
  ReservationRequestApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<List<ReservationRequestResponseDto>> getAll({String? shopId}) async {
    final response = await _dioClient.get<List<dynamic>>(
      '/api/v2/reservation-request',
      queryParameters: {if (shopId != null) 'shopId': shopId},
    );
    return response.data!.map((e) => ReservationRequestResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/reservation-request', data: data);
  }

  Future<void> accept(String id, {String? tableId}) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/reservation-request/$id/accept', data: {'table_id': tableId});
  }

  Future<void> deny(String id) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/reservation-request/$id/deny');
  }
}
