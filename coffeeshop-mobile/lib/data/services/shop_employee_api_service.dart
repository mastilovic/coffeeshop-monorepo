import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final shopEmployeeApiServiceProvider = Provider<ShopEmployeeApiService>((ref) {
  return ShopEmployeeApiService(dioClient: ref.watch(dioClientProvider));
});

class ShopEmployeeApiService {
  ShopEmployeeApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<List<dynamic>> getEmployees(String shopId) async {
    final response = await _dioClient.get<List<dynamic>>('/api/v2/shop/$shopId/employees');
    return response.data!;
  }

  Future<void> assign(Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/shop-employees', data: data);
  }

  Future<void> remove(Map<String, dynamic> data) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/shop-employees', data: data);
  }

  Future<List<dynamic>> getMyEmployeeShops() async {
    final response = await _dioClient.get<List<dynamic>>('/api/v2/shop-employees/me');
    return response.data!;
  }
}
