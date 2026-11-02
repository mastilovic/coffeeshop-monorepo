import 'package:flutter/material.dart';

import '../../../../data/models/dashboard_activity_response.dart';
import '../../../shared/widgets/event_list_card.dart';

class UpcomingEventsList extends StatelessWidget {
  const UpcomingEventsList({super.key, required this.events});

  final List<UpcomingEventItem> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Upcoming Events',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...events.map((event) {
          return EventListCard(
            eventId: event.eventId,
            eventName: event.eventName,
            eventDate: event.eventDate ?? '',
            shopId: event.shopId,
            shopName: event.shopName,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          );
        }),
      ],
    );
  }
}
