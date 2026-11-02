import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/extensions.dart';
import '../../../data/models/dashboard_activity_response.dart';

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key, required this.activities});

  final List<DashboardActivityItem> activities;

  void _onTap(BuildContext context, DashboardActivityItem item) {
    final shopId = item.shopId;
    if (shopId == null || shopId.isEmpty) return;
    context.go('/shops/$shopId');
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...activities.map((item) {
          IconData icon;
          Color color;
          switch (item.type) {
            case 'review':
              icon = Icons.star;
              color = Colors.amber;
              break;
            case 'event':
              icon = Icons.event;
              color = Colors.orange;
              break;
            default:
              icon = Icons.post_add;
              color = Theme.of(context).colorScheme.primary;
          }

          final tappable = item.shopId != null && item.shopId!.isNotEmpty;

          return ListTile(
            onTap: tappable ? () => _onTap(context, item) : null,
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(item.title ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.body != null)
                  Text(
                    item.body!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (item.shopName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.shopName!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            trailing: item.timestamp != null
                ? Text(
                    DateTime.tryParse(item.timestamp!)?.formatRelative() ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
          );
        }),
      ],
    );
  }
}
