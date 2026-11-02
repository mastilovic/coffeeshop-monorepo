import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/event_response_dto.dart';

final eventApiServiceProvider = Provider<EventApiService>((ref) {
  return EventApiService(dioClient: ref.watch(dioClientProvider));
});

class EventApiService {
  EventApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<dynamic> getAll({String? shopId, String? q, String? dateFrom, String? dateTo, int page = 0, int size = 20}) async {
    final response = await _dioClient.get<dynamic>(
      '/api/v2/event',
      queryParameters: {
        if (shopId != null) 'shopId': shopId,
        if (q != null) 'q': q,
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
        'page': page,
        'size': size,
      },
    );
    return response.data;
  }

  Future<EventResponseDto> getById(String eventId) async {
    final response = await _dioClient.get<Map<String, dynamic>>('/api/v2/event/$eventId');
    return EventResponseDto.fromJson(response.data!);
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/event', data: data);
  }

  Future<void> update(String eventId, Map<String, dynamic> data) async {
    await _dioClient.put<Map<String, dynamic>>('/api/v2/event/$eventId', data: data);
  }

  Future<void> delete(String eventId) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/event/$eventId');
  }
}
