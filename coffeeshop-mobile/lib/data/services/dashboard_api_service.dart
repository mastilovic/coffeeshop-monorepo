import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final dashboardApiServiceProvider = Provider<DashboardApiService>((ref) {
  return DashboardApiService(dioClient: ref.watch(dioClientProvider));
});

class DashboardApiService {
  DashboardApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<Map<String, dynamic>> getActivity() async {
    final response = await _dioClient.get<Map<String, dynamic>>('/api/v2/dashboard/activity');
    return response.data!;
  }
}
