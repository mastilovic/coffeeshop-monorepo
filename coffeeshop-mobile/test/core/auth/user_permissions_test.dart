import 'package:coffeeshop_mobile/core/auth/user_permissions.dart';
import 'package:coffeeshop_mobile/core/auth/user_role.dart';
import 'package:coffeeshop_mobile/data/models/user_profile_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserPermissions.canUseFeature', () {
    const starterEntitlements = {
      'reservation_manage': false,
      'event_create': false,
      'employee_assign': false,
      'community_post': false,
      'loyalty_basic': false,
      'loyalty_premium': false,
      'review_moderate': false,
      'dashboard_notifications': false,
      'analytics': false,
      'unlimited_tables': false,
      'unlimited_menus': false,
    };

    const growthEntitlements = {
      'reservation_manage': true,
      'event_create': true,
      'employee_assign': true,
      'community_post': true,
      'loyalty_basic': true,
      'loyalty_premium': false,
      'review_moderate': true,
      'dashboard_notifications': true,
      'analytics': false,
      'unlimited_tables': true,
      'unlimited_menus': true,
    };

    const proEntitlements = {
      'reservation_manage': true,
      'event_create': true,
      'employee_assign': true,
      'community_post': true,
      'loyalty_basic': true,
      'loyalty_premium': true,
      'review_moderate': true,
      'dashboard_notifications': true,
      'analytics': true,
      'unlimited_tables': true,
      'unlimited_menus': true,
    };

    const customEntitlements = {
      'reservation_manage': true,
      'event_create': false,
      'employee_assign': false,
      'community_post': false,
      'loyalty_basic': false,
      'loyalty_premium': false,
      'review_moderate': false,
      'dashboard_notifications': false,
      'analytics': true,
      'unlimited_tables': false,
      'unlimited_menus': false,
    };

    test('admin bypasses all feature checks', () {
      const permissions = UserPermissions(
        role: UserRole.admin,
        entitlements: starterEntitlements,
      );

      for (final feature in SubscriptionFeature.values) {
        expect(
          permissions.canUseFeature(feature),
          isTrue,
          reason: 'admin should bypass ${feature.key}',
        );
      }
    });

    test('starter owner has only base features disabled', () {
      const permissions = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: starterEntitlements,
      );

      expect(
        permissions.canUseFeature(SubscriptionFeature.reservationManage),
        isFalse,
      );
      expect(permissions.canUseFeature(SubscriptionFeature.eventCreate), isFalse);
      expect(permissions.canUseFeature(SubscriptionFeature.analytics), isFalse);
      expect(
        permissions.canUseFeature(SubscriptionFeature.unlimitedTables),
        isFalse,
      );
    });

    test('growth owner has growth tier features', () {
      const permissions = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: growthEntitlements,
      );

      expect(
        permissions.canUseFeature(SubscriptionFeature.reservationManage),
        isTrue,
      );
      expect(permissions.canUseFeature(SubscriptionFeature.eventCreate), isTrue);
      expect(
        permissions.canUseFeature(SubscriptionFeature.loyaltyPremium),
        isFalse,
      );
      expect(permissions.canUseFeature(SubscriptionFeature.analytics), isFalse);
      expect(
        permissions.canUseFeature(SubscriptionFeature.unlimitedMenus),
        isTrue,
      );
    });

    test('pro owner has all features enabled', () {
      const permissions = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: proEntitlements,
      );

      for (final feature in SubscriptionFeature.values) {
        expect(
          permissions.canUseFeature(feature),
          isTrue,
          reason: 'pro should include ${feature.key}',
        );
      }
    });

    test('custom owner only has selected features', () {
      const permissions = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: customEntitlements,
      );

      expect(
        permissions.canUseFeature(SubscriptionFeature.reservationManage),
        isTrue,
      );
      expect(permissions.canUseFeature(SubscriptionFeature.analytics), isTrue);
      expect(permissions.canUseFeature(SubscriptionFeature.eventCreate), isFalse);
      expect(
        permissions.canUseFeature(SubscriptionFeature.loyaltyBasic),
        isFalse,
      );
    });

    test('missing entitlement key defaults to false', () {
      const permissions = UserPermissions(role: UserRole.shop_owner);

      expect(
        permissions.canUseFeature(SubscriptionFeature.reservationManage),
        isFalse,
      );
    });

    test('availableLoyaltyTypes respects entitlements', () {
      const growth = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: growthEntitlements,
      );
      const pro = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: proEntitlements,
      );
      const starter = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: starterEntitlements,
      );

      expect(growth.availableLoyaltyTypes, ['BASIC']);
      expect(pro.availableLoyaltyTypes, ['BASIC', 'PREMIUM', 'VIP']);
      expect(starter.availableLoyaltyTypes, isEmpty);
      expect(growth.showLoyaltyPremiumUpgrade, isTrue);
      expect(pro.showLoyaltyPremiumUpgrade, isFalse);
    });

    test('canCreateLoyaltyType gates by plan type', () {
      const growth = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: growthEntitlements,
      );
      const pro = UserPermissions(
        role: UserRole.shop_owner,
        entitlements: proEntitlements,
      );

      expect(growth.canCreateLoyaltyType('BASIC'), isTrue);
      expect(growth.canCreateLoyaltyType('PREMIUM'), isFalse);
      expect(pro.canCreateLoyaltyType('VIP'), isTrue);
    });

    test('customer without entitlements cannot use gated features', () {
      const permissions = UserPermissions(role: UserRole.customer);

      expect(
        permissions.canUseFeature(SubscriptionFeature.eventCreate),
        isFalse,
      );
    });
  });

  group('UserPermissions.getLimit', () {
    test('returns limit usage when present', () {
      const permissions = UserPermissions(
        role: UserRole.shop_owner,
        limits: {
          'tables': LimitUsageDto(used: 5, max: 15),
          'events': LimitUsageDto(used: 2, max: 5),
        },
      );

      expect(permissions.getLimit('tables'), const LimitUsageDto(used: 5, max: 15));
      expect(permissions.getLimit('events'), const LimitUsageDto(used: 2, max: 5));
      expect(permissions.getLimit('shops'), isNull);
    });
  });
}
