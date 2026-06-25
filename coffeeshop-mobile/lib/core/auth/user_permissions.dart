import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/shop_api_service.dart';
import '../../data/services/shop_employee_api_service.dart';
import 'auth_notifier.dart';
import 'user_role.dart';

class UserPermissions {
  const UserPermissions({
    this.role = UserRole.customer,
    this.ownedShopIds = const [],
    this.employeeShopIds = const [],
  });

  final UserRole role;
  final List<String> ownedShopIds;
  final List<String> employeeShopIds;

  static const empty = UserPermissions();

  bool get isAdmin => role == UserRole.admin;
  bool get isShopOwner =>
      role == UserRole.shop_owner || role == UserRole.admin;
  bool get canCreateShop => isShopOwner;
  bool get canCreateEvent => isShopOwner;

  bool canManageShop(String shopId) =>
      isAdmin || ownedShopIds.contains(shopId);

  bool canManageContent(String shopId) =>
      isAdmin ||
      ownedShopIds.contains(shopId) ||
      employeeShopIds.contains(shopId);
}

/// Provides the current user's permissions, resolving owned and employee
/// shop IDs from the API.
final userPermissionsProvider = FutureProvider<UserPermissions>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  final user = auth.user;
  if (user == null) return UserPermissions.empty;

  final role = UserRole.fromString(user.userType);

  if (role == UserRole.admin) {
    return UserPermissions(role: role);
  }

  if (role == UserRole.customer) {
    return UserPermissions(role: role);
  }

  // shop_owner: resolve owned and employee shops
  final ownedShops = await ref.watch(shopApiServiceProvider).getMine();
  final employeeShops =
      await ref.watch(shopEmployeeApiServiceProvider).getMyEmployeeShops();

  return UserPermissions(
    role: role,
    ownedShopIds: ownedShops.map((s) => s.id).toList(),
    employeeShopIds: employeeShops
        .map((s) => s is Map<String, dynamic> ? s['id'] as String? : null)
        .whereType<String>()
        .toList(),
  );
});

/// Synchronous check for shop list cards.
/// Requires [ownedShopsProvider] (or equivalent) to be watched first.
bool canManageShopInList(WidgetRef ref, String shopId) {
  final permissions = ref.watch(userPermissionsProvider).valueOrNull;
  if (permissions == null) return false;
  return permissions.canManageShop(shopId);
}
