import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/subscription_dto.dart';

final subscriptionApiServiceProvider = Provider<SubscriptionApiService>((ref) {
  return SubscriptionApiService(dioClient: ref.watch(dioClientProvider));
});

class SubscriptionApiService {
  SubscriptionApiService({required DioClient dioClient}) : _dioClient = dioClient;

  final DioClient _dioClient;
  static const _base = '/api/v2/subscription';

  Future<CatalogResponseDto> getCatalog() async {
    final response =
        await _dioClient.get<Map<String, dynamic>>('$_base/catalog');
    return CatalogResponseDto.fromJson(response.data!);
  }

  Future<QuoteBreakdownDto> quote(QuoteRequestDto request) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '$_base/quote',
      data: request.toJson(),
    );
    return QuoteBreakdownDto.fromJson(response.data!);
  }

  Future<SubscriptionMeResponseDto> getMe() async {
    final response = await _dioClient.get<Map<String, dynamic>>('$_base/me');
    return SubscriptionMeResponseDto.fromJson(response.data!);
  }

  Future<SubscriptionMeResponseDto> changePlan(UpdatePlanRequestDto request) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      '$_base/plan',
      data: request.toJson(),
    );
    return SubscriptionMeResponseDto.fromJson(response.data!);
  }
}
