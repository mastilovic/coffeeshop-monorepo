import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/shop_response_dto.dart';
import '../../data/services/reference_api_service.dart';
import '../../data/services/shop_api_service.dart';

class ShopListParams {
  const ShopListParams({
    this.query = '',
    this.city,
    this.page = 0,
  });

  final String query;
  final String? city;
  final int page;

  static const pageSize = 20;

  ShopListParams copyWith({
    String? query,
    String? city,
    bool clearCity = false,
    int? page,
  }) {
    return ShopListParams(
      query: query ?? this.query,
      city: clearCity ? null : city ?? this.city,
      page: page ?? this.page,
    );
  }
}

class ShopListResult {
  const ShopListResult({
    required this.shops,
    required this.totalPages,
    required this.totalElements,
  });

  final List<ShopResponseDto> shops;
  final int totalPages;
  final int totalElements;
}

final shopListParamsProvider = StateProvider<ShopListParams>((ref) {
  return const ShopListParams();
});

final shopListProvider = FutureProvider<ShopListResult>((ref) async {
  final params = ref.watch(shopListParamsProvider);
  final apiService = ref.watch(shopApiServiceProvider);

  final data = await apiService.getShops(
    q: params.query.isEmpty ? null : params.query,
    page: params.page,
  );

  final content = (data['content'] as List<dynamic>?)
          ?.map((e) => ShopResponseDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];

  return ShopListResult(
    shops: content,
    totalPages: (data['total_pages'] as int?) ?? 0,
    totalElements: (data['total_elements'] as int?) ?? 0,
  );
});

final shopDetailProvider = FutureProvider.family<ShopResponseDto, String>((ref, id) async {
  final apiService = ref.watch(shopApiServiceProvider);
  final data = await apiService.getById(id);
  return ShopResponseDto.fromJson(data);
});

final citiesProvider = FutureProvider<List<String>>((ref) async {
  final apiService = ref.watch(referenceApiServiceProvider);
  return apiService.getCities();
});
