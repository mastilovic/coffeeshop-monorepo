import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/user_permissions.dart';
import '../../data/services/shop_api_service.dart';

/// Used for fetching owned shop data (needed for display, not just IDs).
final ownedShopsProvider = FutureProvider((ref) async {
  return ref.watch(shopApiServiceProvider).getMine();
});

/// Synchronous check for shop list cards.
bool canManageShopInList(WidgetRef ref, String shopId) {
  final permissions = ref.watch(userPermissionsProvider).valueOrNull;
  return permissions?.canManageShop(shopId) ?? false;
}
