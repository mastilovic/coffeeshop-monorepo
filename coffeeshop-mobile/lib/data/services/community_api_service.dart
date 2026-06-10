import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final communityApiServiceProvider = Provider<CommunityApiService>((ref) {
  return CommunityApiService(dioClient: ref.watch(dioClientProvider));
});

class CommunityApiService {
  CommunityApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<Map<String, dynamic>> getPosts(String shopId, {int page = 0, int size = 20}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v2/shop/$shopId/community/posts',
      queryParameters: {'page': page, 'size': size},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getMembers(String shopId, {String? q, int page = 0, int size = 20}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v2/shop/$shopId/community/members',
      queryParameters: {'q': q, 'page': page, 'size': size},
    );
    return response.data!;
  }

  Future<void> createAnnouncement(String shopId, Map<String, dynamic> data) async {
    await _dioClient.post<Map<String, dynamic>>('/api/v2/shop/$shopId/community/announcements', data: data);
  }

  Future<void> deletePost(String shopId, String postId) async {
    await _dioClient.delete<Map<String, dynamic>>('/api/v2/shop/$shopId/community/posts/$postId');
  }
}
