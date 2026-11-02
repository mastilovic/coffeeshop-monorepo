import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_profile_response_dto.dart';
import '../../data/services/shop_api_service.dart';
import '../../data/services/shop_employee_api_service.dart';
import 'auth_notifier.dart';
import 'user_role.dart';

enum SubscriptionFeature {
  reservationManage('reservation_manage'),
  eventCreate('event_create'),
  employeeAssign('employee_assign'),
  communityPost('community_post'),
  loyaltyBasic('loyalty_basic'),
  loyaltyPremium('loyalty_premium'),
  reviewModerate('review_moderate'),
  dashboardNotifications('dashboard_notifications'),
  analytics('analytics'),
  unlimitedTables('unlimited_tables'),
  unlimitedMenus('unlimited_menus');

  const SubscriptionFeature(this.key);

  final String key;
}

class UserPermissions {
  const UserPermissions({
    this.role = UserRole.customer,
    this.ownedShopIds = const [],
    this.employeeShopIds = const [],
    this.entitlements = const {},
    this.limits = const {},
  });

  final UserRole role;
  final List<String> ownedShopIds;
  final List<String> employeeShopIds;
  final Map<String, bool> entitlements;
  final Map<String, LimitUsageDto> limits;

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

  bool canUseFeature(SubscriptionFeature feature) {
    if (isAdmin) return true;
    return entitlements[feature.key] ?? false;
  }

  LimitUsageDto? getLimit(String limitKey) => limits[limitKey];

  bool get canManageReservations =>
      canUseFeature(SubscriptionFeature.reservationManage);

  bool get canAssignEmployees =>
      canUseFeature(SubscriptionFeature.employeeAssign);

  bool get canPostCommunity =>
      canUseFeature(SubscriptionFeature.communityPost);

  bool get showLoyaltyTab =>
      isShopOwner &&
      (canUseFeature(SubscriptionFeature.loyaltyBasic) ||
          canUseFeature(SubscriptionFeature.loyaltyPremium));

  List<String> get availableLoyaltyTypes {
    if (isAdmin) return const ['BASIC', 'PREMIUM', 'VIP'];
    final types = <String>[];
    if (canUseFeature(SubscriptionFeature.loyaltyBasic)) {
      types.add('BASIC');
    }
    if (canUseFeature(SubscriptionFeature.loyaltyPremium)) {
      types.addAll(const ['PREMIUM', 'VIP']);
    }
    return types;
  }

  bool canCreateLoyaltyType(String type) {
    if (isAdmin) return true;
    switch (type.toUpperCase()) {
      case 'BASIC':
        return canUseFeature(SubscriptionFeature.loyaltyBasic);
      case 'PREMIUM':
      case 'VIP':
        return canUseFeature(SubscriptionFeature.loyaltyPremium);
      default:
        return false;
    }
  }

  bool get showLoyaltyPremiumUpgrade =>
      canUseFeature(SubscriptionFeature.loyaltyBasic) &&
      !canUseFeature(SubscriptionFeature.loyaltyPremium);

  bool get canCreateEventWithSubscription {
    if (!canCreateEvent) return false;
    if (!canUseFeature(SubscriptionFeature.eventCreate)) return false;
    final eventsLimit = getLimit('events');
    if (eventsLimit != null &&
        eventsLimit.max >= 0 &&
        eventsLimit.used >= eventsLimit.max) {
      return false;
    }
    return true;
  }

  bool get showEventCreateUpgrade =>
      canCreateEvent && !canUseFeature(SubscriptionFeature.eventCreate);

  bool get showEmployeeAssignUpgrade =>
      isShopOwner && !canUseFeature(SubscriptionFeature.employeeAssign);

  String? get tablesQuotaLabel {
    final limit = getLimit('tables');
    if (limit == null || limit.max < 0) return null;
    return '${limit.used} / ${limit.max} tables';
  }

  bool get canAddTable {
    if (canUseFeature(SubscriptionFeature.unlimitedTables)) return true;
    final limit = getLimit('tables');
    if (limit == null || limit.max < 0) return true;
    return limit.used < limit.max;
  }

  bool get showTablesUpgrade =>
      !canAddTable && !canUseFeature(SubscriptionFeature.unlimitedTables);

  String? get menusQuotaLabel {
    final limit = getLimit('menus');
    if (limit == null || limit.max < 0) return null;
    return '${limit.used} / ${limit.max} menus';
  }

  bool get canCreateMenu {
    if (canUseFeature(SubscriptionFeature.unlimitedMenus)) return true;
    final limit = getLimit('menus');
    if (limit == null || limit.max < 0) return true;
    return limit.used < limit.max;
  }

  bool get showMenusUpgrade =>
      !canCreateMenu && !canUseFeature(SubscriptionFeature.unlimitedMenus);

  bool get showCommunityUpgrade =>
      !canUseFeature(SubscriptionFeature.communityPost);

  String? get eventsQuotaLabel {
    final limit = getLimit('events');
    if (limit == null) return null;
    if (limit.max < 0) {
      return '${limit.used} / Unlimited events this month';
    }
    return '${limit.used} / ${limit.max} events this month';
  }
}

/// Provides the current user's permissions, resolving owned and employee
/// shop IDs from the API.
final userPermissionsProvider = FutureProvider<UserPermissions>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  final user = auth.user;
  if (user == null) return UserPermissions.empty;

  final role = UserRole.fromString(user.userType);
  final entitlements = user.entitlements;
  final limits = user.limits;

  if (role == UserRole.admin) {
    return UserPermissions(
      role: role,
      entitlements: entitlements,
      limits: limits,
    );
  }

  if (role == UserRole.customer) {
    return UserPermissions(
      role: role,
      entitlements: entitlements,
      limits: limits,
    );
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
    entitlements: entitlements,
    limits: limits,
  );
});

/// Synchronous check for shop list cards.
/// Requires [ownedShopsProvider] (or equivalent) to be watched first.
bool canManageShopInList(WidgetRef ref, String shopId) {
  final permissions = ref.watch(userPermissionsProvider).valueOrNull;
  if (permissions == null) return false;
  return permissions.canManageShop(shopId);
}
