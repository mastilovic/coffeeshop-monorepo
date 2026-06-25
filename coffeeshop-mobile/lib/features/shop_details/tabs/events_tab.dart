import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/utils/api_error.dart';
import '../../../core/utils/reservation_event_utils.dart';
import '../../../data/models/event_response_dto.dart';
import '../../../data/services/event_api_service.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../reservations/reservation_providers.dart';
import '../../reservations/widgets/event_reservation_form.dart';
import '../../shops/shop_providers.dart';

String eventLabel(EventResponseDto event) {
  if (event.eventName.isNotEmpty) return event.eventName;
  return event.eventId;
}

List<EventResponseDto> parseShopEvents(List<Map<String, dynamic>>? events) {
  if (events == null) return [];
  return events.map((e) => EventResponseDto.fromJson(e)).toList();
}

class EventsTab extends ConsumerStatefulWidget {
  const EventsTab({
    super.key,
    required this.shopId,
    required this.events,
    required this.canManage,
  });

  final String shopId;
  final List<Map<String, dynamic>>? events;
  final bool canManage;

  @override
  ConsumerState<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends ConsumerState<EventsTab> {
  bool _showForm = false;
  bool _isSaving = false;
  String? _editingEventId;
  EventResponseDto? _selectedEventForRequest;

  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _dateController.clear();
    _descriptionController.clear();
    _editingEventId = null;
    _showForm = false;
  }

  void _cancelEventRequest() {
    setState(() => _selectedEventForRequest = null);
  }

  void _startEdit(EventResponseDto event) {
    setState(() {
      _showForm = true;
      _editingEventId = event.eventId;
      _nameController.text = event.eventName;
      _dateController.text = event.eventDate;
      _descriptionController.text = event.description ?? '';
      _selectedEventForRequest = null;
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _dateController.text = dateTime.toIso8601String();
  }

  Future<void> _saveEvent() async {
    final name = _nameController.text.trim();
    final date = _dateController.text.trim();
    if (name.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter event name and date')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final api = ref.read(eventApiServiceProvider);
      final data = {
        'eventName': name,
        'eventDate': date,
        'description': _descriptionController.text.trim(),
      };

      if (_editingEventId != null) {
        await api.update(_editingEventId!, data);
      } else {
        await api.create({...data, 'shopId': widget.shopId});
      }

      _resetForm();
      ref.invalidate(shopDetailProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(eventApiServiceProvider).delete(eventId);
      ref.invalidate(shopDetailProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${formatApiError(e)}')),
        );
      }
    }
  }

  Set<String> _blockedEventIds() {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId == null) return {};

    final requests = ref.watch(myReservationRequestsProvider).valueOrNull ?? [];
    final reservations = ref.watch(myReservationsProvider).valueOrNull ?? [];

    return eventIdsBlockedForUser(
      requests: requests,
      reservations: reservations,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = parseShopEvents(widget.events);
    final blocked = _blockedEventIds();
    final canSelfReserve = !widget.canManage;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.canManage) ...[
          FilledButton.tonalIcon(
            onPressed: () => setState(() {
              _showForm = !_showForm;
              if (!_showForm) _resetForm();
            }),
            icon: Icon(_showForm ? Icons.close : Icons.add),
            label: Text(_showForm ? 'Cancel' : 'Add Event'),
          ),
          if (_showForm) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Event name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDateTime,
                      decoration: const InputDecoration(
                        labelText: 'Event date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _isSaving ? null : _saveEvent,
                      child: Text(_editingEventId != null ? 'Update Event' : 'Save Event'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
        if (events.isEmpty)
          EmptyStateView(
            icon: Icons.event,
            message: 'No events.',
            actionLabel: widget.canManage && !_showForm ? 'Add Event' : null,
            onAction: widget.canManage && !_showForm ? () => setState(() => _showForm = true) : null,
          )
        else
          ...events.map((event) {
            final showReserve = canSelfReserve &&
                canShowReserveButton(
                  event: event,
                  canManageShopContent: widget.canManage,
                  blockedEventIds: blocked,
                );

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.event, color: Colors.orange),
                title: Text(eventLabel(event)),
                subtitle: Text(event.eventDate),
                trailing: widget.canManage
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _startEdit(event);
                          if (value == 'delete') _deleteEvent(event.eventId);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      )
                    : showReserve
                        ? TextButton(
                            onPressed: () => setState(() => _selectedEventForRequest = event),
                            child: const Text('Reserve'),
                          )
                        : const Icon(Icons.chevron_right),
                onTap: () => context.push('/events/${event.eventId}'),
              ),
            );
          }),
        if (_selectedEventForRequest != null) ...[
          const SizedBox(height: 12),
          EventReservationForm(
            eventId: _selectedEventForRequest!.eventId,
            shopId: widget.shopId,
            eventName: _selectedEventForRequest!.eventName,
            eventDate: _selectedEventForRequest!.eventDate,
            showCancel: true,
            onCancel: _cancelEventRequest,
            onSuccess: _cancelEventRequest,
          ),
        ],
      ],
    );
  }
}
