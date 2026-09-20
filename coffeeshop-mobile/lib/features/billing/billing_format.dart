import 'package:intl/intl.dart';

import '../../data/models/subscription_dto.dart';

String formatCents(int cents) {
  return NumberFormat.simpleCurrency(name: 'USD').format(cents / 100);
}

const tierOrder = ['STARTER', 'GROWTH', 'PRO'];

int tierSortIndex(String tier) {
  final index = tierOrder.indexOf(tier);
  return index >= 0 ? index : tierOrder.length;
}

String planLabel({
  required String? planMode,
  required String? planTier,
  required List<CatalogTierDto> tiers,
}) {
  if (planMode == 'CUSTOM') return 'Custom Plan';
  if (planTier == null) return 'Preset Plan';
  for (final tier in tiers) {
    if (tier.tier == planTier) return tier.displayName;
  }
  return planTier;
}
