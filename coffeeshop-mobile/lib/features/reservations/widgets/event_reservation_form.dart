import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/api_error.dart';
import '../../../data/services/reservation_request_api_service.dart';
import '../reservation_providers.dart';

class EventReservationForm extends ConsumerStatefulWidget {
  const EventReservationForm({
    super.key,
    required this.eventId,
    required this.shopId,
    required this.eventName,
    required this.eventDate,
    this.onSuccess,
    this.onCancel,
    this.showCancel = false,
  });

  final String eventId;
  final String shopId;
  final String eventName;
  final String eventDate;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final bool showCancel;

  @override
  ConsumerState<EventReservationForm> createState() => _EventReservationFormState();
}

class _EventReservationFormState extends ConsumerState<EventReservationForm> {
  final _partySizeController = TextEditingController(text: '2');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _partySizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final partySize = int.tryParse(_partySizeController.text.trim());
    final userId = ref.read(authNotifierProvider).user?.id;
    if (partySize == null || partySize < 1 || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid party size')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(reservationRequestApiServiceProvider).create({
        'userId': userId,
        'shopId': widget.shopId,
        'eventId': widget.eventId,
        'partySize': partySize,
      });
      ref.invalidate(myReservationRequestsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation request submitted')),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiException
            ? e.when(
                networkException: (message, _) => message,
                serverException: (message, statusCode) =>
                    statusCode == 409
                        ? 'You already have a reservation for this event or there are no tables left.'
                        : message,
                unauthorizedException: (message) => message,
                validationException: (message, _) => message,
                unknownException: (message) => message,
              )
            : formatApiError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Request reservation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${widget.eventName} · ${widget.eventDate}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _partySizeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Party size',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit request'),
                  ),
                ),
                if (widget.showCancel && widget.onCancel != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
