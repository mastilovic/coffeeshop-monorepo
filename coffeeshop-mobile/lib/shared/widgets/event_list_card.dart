import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/extensions.dart';
import 'event_reserve_button.dart';

/// Shared event list row: bold name, formatted date, labeled shop, Reserve.
class EventListCard extends StatelessWidget {
  const EventListCard({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    this.shopId,
    this.shopName,
    this.shopCity,
    this.trailing,
    this.margin = const EdgeInsets.only(bottom: 8),
  });

  final String eventId;
  final String eventName;
  final String eventDate;
  final String? shopId;
  final String? shopName;
  final String? shopCity;

  /// When null, a default [EventReserveButton] is used.
  final Widget? trailing;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shopLabel = formatEventShopLabel(shopName, shopCity: shopCity);
    final dateLabel = formatEventDateTime(eventDate);
    final countdown = formatEventCountdown(eventDate);
    final action = trailing ??
        EventReserveButton(
          eventId: eventId,
          shopId: shopId,
          eventDate: eventDate,
        );

    return Card(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/events/$eventId'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.event, color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (shopLabel != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.store,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              shopLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (countdown != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 88,
                  height: 28,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Center(
                        child: Text(
                          countdown,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
