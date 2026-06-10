import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_list_item_dto.dart';
import '../../data/services/user_api_service.dart';

final userSearchProvider = StateProvider<String>((ref) => '');

final userListProvider = FutureProvider<List<UserListItemDto>>((ref) async {
  final query = ref.watch(userSearchProvider);
  final apiService = ref.watch(userApiServiceProvider);

  final data = await apiService.getAll(
    q: query.isEmpty ? null : query,
  );

  if (data is Map<String, dynamic>) {
    return (data['content'] as List<dynamic>?)
            ?.map((e) => UserListItemDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }
  return [];
});

final deleteUserProvider = FutureProvider.family<void, String>((ref, userId) async {
  final apiService = ref.watch(userApiServiceProvider);
  await apiService.delete(userId);
  ref.invalidate(userListProvider);
});
