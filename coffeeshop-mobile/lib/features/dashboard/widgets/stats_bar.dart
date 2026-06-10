import 'package:flutter/material.dart';

import '../../../core/utils/extensions.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({
    super.key,
    required this.shopCount,
    required this.reviewCount,
    required this.averageRating,
    required this.eventCount,
    required this.memberCount,
  });

  final int shopCount;
  final int reviewCount;
  final double? averageRating;
  final int eventCount;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.store,
            label: 'Shops',
            value: shopCount.compact,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _StatCard(
            icon: Icons.star,
            label: 'Rating',
            value: averageRating?.toStringAsFixed(1) ?? '--',
            color: Colors.amber,
          ),
          const SizedBox(width: 8),
          _StatCard(
            icon: Icons.reviews,
            label: 'Reviews',
            value: reviewCount.compact,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 8),
          _StatCard(
            icon: Icons.event,
            label: 'Events',
            value: eventCount.compact,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          _StatCard(
            icon: Icons.people,
            label: 'Members',
            value: memberCount.compact,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
