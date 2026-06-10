import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/dashboard_activity_response.dart';
import '../../../core/utils/extensions.dart';

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
        ...events.map((event) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                onTap: () => context.go('/events/${event.eventId}'),
                leading: const Icon(Icons.event, color: Colors.orange),
                title: Text(event.eventName),
                subtitle: Text(event.shopName ?? ''),
                trailing: event.eventDate != null
                    ? Text(
                        DateTime.tryParse(event.eventDate!)?.formatDate() ?? event.eventDate!,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : null,
              ),
            )),
      ],
    );
  }
}
