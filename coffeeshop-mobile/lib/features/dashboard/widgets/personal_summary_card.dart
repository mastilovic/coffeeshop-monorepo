import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/dashboard_activity_response.dart';

class PersonalSummaryCard extends StatelessWidget {
  const PersonalSummaryCard({super.key, required this.summary});

  final DashboardPersonalSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  icon: Icons.favorite,
                  label: 'Favourites',
                  value: summary.favouriteShops.toString(),
                  color: Colors.red,
                  onTap: () => context.go('/shops'),
                ),
                _SummaryItem(
                  icon: Icons.calendar_month,
                  label: 'Reservations',
                  value: summary.reservations.toString(),
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => context.go('/reservations'),
                ),
                _SummaryItem(
                  icon: Icons.star,
                  label: 'Reviews',
                  value: summary.reviewsWritten.toString(),
                  color: Colors.amber,
                  onTap: () => context.go('/shops'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
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
