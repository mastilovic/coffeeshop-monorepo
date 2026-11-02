import 'package:coffeeshop_mobile/shared/widgets/loyalty_badge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('loyaltyBadgeLabel', () {
    test('returns Loyalty for BASIC', () {
      expect(loyaltyBadgeLabel('BASIC'), 'Loyalty');
      expect(loyaltyBadgeLabel('basic'), 'Loyalty');
    });

    test('returns Premium Loyalty for PREMIUM and VIP', () {
      expect(loyaltyBadgeLabel('PREMIUM'), 'Premium Loyalty');
      expect(loyaltyBadgeLabel('VIP'), 'Premium Loyalty');
      expect(loyaltyBadgeLabel('vip'), 'Premium Loyalty');
    });
  });

  group('shopHasLoyaltyProgram', () {
    test('returns false for null or empty plan', () {
      expect(shopHasLoyaltyProgram(null), isFalse);
      expect(shopHasLoyaltyProgram({}), isFalse);
      expect(shopHasLoyaltyProgram({'name': 'Rewards'}), isFalse);
    });

    test('returns true when plan has type', () {
      expect(
        shopHasLoyaltyProgram({'type': 'BASIC', 'name': 'Rewards'}),
        isTrue,
      );
    });
  });
}
