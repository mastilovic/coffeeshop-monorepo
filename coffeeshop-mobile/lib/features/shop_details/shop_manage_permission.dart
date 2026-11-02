import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/user_role.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/shop_api_service.dart';

/// Used for fetching owned shop data (needed for display, not just IDs).
final ownedShopsProvider = FutureProvider<List<ShopResponseDto>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (auth.status != AuthStatus.authenticated || auth.user == null) {
    return [];
  }
  final role = UserRole.fromString(auth.user!.userType);
  if (role != UserRole.shop_owner && role != UserRole.admin) {
    return [];
  }
  return ref.read(shopApiServiceProvider).getMine();
});
