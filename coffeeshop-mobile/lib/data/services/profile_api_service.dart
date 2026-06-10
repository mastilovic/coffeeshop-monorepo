import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  return ProfileApiService(dioClient: ref.watch(dioClientProvider));
});

class ProfileApiService {
  ProfileApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dioClient.get<Map<String, dynamic>>('/api/v2/profile');
    return response.data!;
  }
}
