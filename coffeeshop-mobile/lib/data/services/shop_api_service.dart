import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/shop_response_dto.dart';

final shopApiServiceProvider = Provider<ShopApiService>((ref) {
  return ShopApiService(dioClient: ref.watch(dioClientProvider));
});

class ShopApiService {
  ShopApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<Map<String, dynamic>> getShops({
    String? q,
    String? city,
    int page = 0,
    int size = 25,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v2/shop',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (city != null && city.isNotEmpty) 'city': city,
        'page': page,
        'size': size,
      },
    );
    return response.data!;
  }

  Future<List<ShopResponseDto>> getMine() async {
    final response = await _dioClient.get<List<dynamic>>('/api/v2/shop/mine');
    return response.data!.map((e) => ShopResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>('/api/v2/shop/$id');
    return response.data!;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dioClient.post<Map<String, dynamic>>('/api/v2/shop', data: data);
    return response.data!;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _dioClient.put<Map<String, dynamic>>('/api/v2/shop/$id', data: data);
  }

  Future<void> delete(String id) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/shop/$id');
  }

  Future<void> addFavourite(String shopId) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/shop/$shopId/favourite');
  }

  Future<void> removeFavourite(String shopId) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/shop/$shopId/favourite');
  }

  Future<List<Map<String, dynamic>>> getMenus(String shopId) async {
    final response = await _dioClient.get<List<dynamic>>('/api/v2/shop/$shopId/menus');
    return response.data!.cast<Map<String, dynamic>>();
  }

  Future<void> createMenu(String shopId, Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/shop/$shopId/menus', data: data);
  }
}
