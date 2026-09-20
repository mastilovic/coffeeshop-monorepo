import 'package:flutter/material.dart';

String? loyaltyPlanType(Map<String, dynamic>? loyaltyPlan) {
  if (loyaltyPlan == null || loyaltyPlan.isEmpty) return null;
  final type = loyaltyPlan['type'] as String?;
  if (type == null || type.isEmpty) return null;
  return type;
}

bool shopHasLoyaltyProgram(Map<String, dynamic>? loyaltyPlan) =>
    loyaltyPlanType(loyaltyPlan) != null;

bool isPremiumLoyaltyType(String type) {
  switch (type.toUpperCase()) {
    case 'PREMIUM':
    case 'VIP':
      return true;
    default:
      return false;
  }
}

String loyaltyBadgeLabel(String type) {
  return isPremiumLoyaltyType(type) ? 'Premium Loyalty' : 'Loyalty';
}

class LoyaltyBadge extends StatelessWidget {
  const LoyaltyBadge({
    super.key,
    required this.planType,
    this.compact = false,
  });

  final String planType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final premium = isPremiumLoyaltyType(planType);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: premium ? Colors.amber.shade100 : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_giftcard,
            size: compact ? 12 : 14,
            color: premium ? Colors.amber.shade900 : theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            loyaltyBadgeLabel(planType),
            style: theme.textTheme.labelSmall?.copyWith(
              color: premium ? Colors.amber.shade900 : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
