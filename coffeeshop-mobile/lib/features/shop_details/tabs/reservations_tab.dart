import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/api_error.dart';
import '../../../data/models/reservation_request_response_dto.dart';
import '../../../data/services/reservation_api_service.dart';
import '../../../data/services/reservation_request_api_service.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/form_select.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../reservations/reservation_providers.dart';

final shopReservationRequestsProvider =
    FutureProvider.family<List<ReservationRequestResponseDto>, String>((ref, shopId) async {
  final api = ref.watch(reservationRequestApiServiceProvider);
  return api.getAll(shopId: shopId);
});

final shopReservationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, shopId) async {
  final api = ref.watch(reservationApiServiceProvider);
  final data = await api.getAll(shopId: shopId);
  return data.cast<Map<String, dynamic>>();
});

class ReservationsTab extends ConsumerWidget {
  const ReservationsTab({
    super.key,
    required this.shopId,
    required this.tables,
    required this.canManage,
  });

  final String shopId;
  final List<Map<String, dynamic>>? tables;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!canManage) {
      return const _CustomerReservationsView();
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Denied'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PendingReservationsTab(shopId: shopId, tables: tables ?? []),
                _ApprovedReservationsTab(shopId: shopId),
                _DeniedReservationsTab(shopId: shopId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerReservationsView extends ConsumerWidget {
  const _CustomerReservationsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myReservationRequestsProvider);

    return requestsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(myReservationRequestsProvider)),
      data: (requests) {
        final pending = requests.where((r) => r.status == 'PENDING').toList();
        if (pending.isEmpty) {
          return const EmptyStateView(icon: Icons.event_seat, message: 'No pending reservation requests.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pending.length,
          itemBuilder: (context, index) => _RequestCard(request: pending[index]),
        );
      },
    );
  }
}

class _PendingReservationsTab extends ConsumerWidget {
  const _PendingReservationsTab({required this.shopId, required this.tables});

  final String shopId;
  final List<Map<String, dynamic>> tables;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(shopReservationRequestsProvider(shopId));
    final reservationsAsync = ref.watch(shopReservationsProvider(shopId));

    void retry() {
      ref.invalidate(shopReservationRequestsProvider(shopId));
      ref.invalidate(shopReservationsProvider(shopId));
    }

    if ((requestsAsync.isLoading && !requestsAsync.hasValue) ||
        (reservationsAsync.isLoading && !reservationsAsync.hasValue)) {
      return const LoadingIndicator();
    }

    if (requestsAsync.hasError) {
      return ErrorView(
        message: requestsAsync.error.toString(),
        onRetry: retry,
      );
    }

    if (reservationsAsync.hasError) {
      return ErrorView(
        message: reservationsAsync.error.toString(),
        onRetry: retry,
      );
    }

    final requests = requestsAsync.requireValue;
    final reservations = reservationsAsync.requireValue;
    final pending = requests.where((r) => r.status == 'PENDING').toList();

    if (pending.isEmpty) {
      return const EmptyStateView(icon: Icons.hourglass_empty, message: 'No pending requests.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) => _PendingRequestCard(
        key: ValueKey(pending[index].id),
        shopId: shopId,
        request: pending[index],
        tables: tables,
        reservations: reservations,
      ),
    );
  }
}

class _ApprovedReservationsTab extends ConsumerWidget {
  const _ApprovedReservationsTab({required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(shopReservationsProvider(shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(shopReservationsProvider(shopId)),
      ),
      data: (reservations) {
        if (reservations.isEmpty) {
          return const EmptyStateView(icon: Icons.check_circle_outline, message: 'No approved reservations.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) => _ReservationCard(reservation: reservations[index]),
        );
      },
    );
  }
}

class _DeniedReservationsTab extends ConsumerWidget {
  const _DeniedReservationsTab({required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(shopReservationRequestsProvider(shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(shopReservationRequestsProvider(shopId)),
      ),
      data: (requests) {
        final denied = requests.where((r) => r.status == 'DENIED').toList();
        if (denied.isEmpty) {
          return const EmptyStateView(icon: Icons.block, message: 'No denied requests.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: denied.length,
          itemBuilder: (context, index) => _RequestCard(request: denied[index]),
        );
      },
    );
  }
}

class _PendingRequestCard extends ConsumerStatefulWidget {
  const _PendingRequestCard({
    super.key,
    required this.shopId,
    required this.request,
    required this.tables,
    required this.reservations,
  });

  final String shopId;
  final ReservationRequestResponseDto request;
  final List<Map<String, dynamic>> tables;
  final List<Map<String, dynamic>> reservations;

  @override
  ConsumerState<_PendingRequestCard> createState() => _PendingRequestCardState();
}

class _PendingRequestCardState extends ConsumerState<_PendingRequestCard> {
  String? _selectedTableId;
  bool _isProcessing = false;

  @override
  void didUpdateWidget(covariant _PendingRequestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.id != widget.request.id ||
        oldWidget.request.partySize != widget.request.partySize) {
      _selectedTableId = null;
    }
  }

  /// IDs of tables already assigned to a reservation for the same event.
  /// Standing requests (no eventId) block any reserved table at the shop.
  Set<String> get _takenTableIds {
    return widget.reservations
        .where((r) =>
            widget.request.eventId == null ||
            r['eventId'] == widget.request.eventId)
        .map((r) => (r['table'] as Map<String, dynamic>?)?['id'] as String?)
        .whereType<String>()
        .toSet();
  }

  Future<void> _refreshReservationData() async {
    await Future.wait([
      ref.refresh(shopReservationRequestsProvider(widget.shopId).future),
      ref.refresh(shopReservationsProvider(widget.shopId).future),
    ]);
  }

  List<Map<String, dynamic>> get _suitableTables {
    final taken = _takenTableIds;
    return widget.tables.where((t) {
      final capacity = t['capacity'] as int? ?? 0;
      final id = t['id'] as String?;
      return capacity >= widget.request.partySize && !taken.contains(id);
    }).toList();
  }

  Future<void> _accept() async {
    if (_selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a table')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await ref.read(reservationRequestApiServiceProvider).accept(
            widget.request.id,
            tableId: _selectedTableId,
          );
      await _refreshReservationData();
      ref.invalidate(myReservationRequestsProvider);
      ref.invalidate(myReservationsProvider);
      ref.invalidate(allOwnerReservationRequestsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deny() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(reservationRequestApiServiceProvider).deny(widget.request.id);
      await _refreshReservationData();
      ref.invalidate(myReservationRequestsProvider);
      ref.invalidate(myReservationsProvider);
      ref.invalidate(allOwnerReservationRequestsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to deny: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.request.user?['name'] as String? ?? 'Guest';
    final suitable = _suitableTables;

    if (_selectedTableId != null &&
        !suitable.any((t) => t['id'] == _selectedTableId)) {
      _selectedTableId = null;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName, style: Theme.of(context).textTheme.titleSmall),
            Text('Party of ${widget.request.partySize}', style: Theme.of(context).textTheme.bodySmall),
            if (widget.request.eventName != null)
              Text(widget.request.eventName!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (suitable.isEmpty)
              Text(
                'No table for party of ${widget.request.partySize}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              )
            else
              FormSelect<String>(
                label: 'Table',
                value: _selectedTableId,
                items: suitable.map((t) => t['id'] as String).toList(),
                itemLabel: (id) {
                  final table = suitable.firstWhere((t) => t['id'] == id);
                  return 'Table ${table['number']} (cap ${table['capacity']})';
                },
                onTap: () => ref.invalidate(shopReservationsProvider(widget.shopId)),
                onChanged: (v) => setState(() => _selectedTableId = v),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isProcessing || suitable.isEmpty ? null : _accept,
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : _deny,
                    child: const Text('Deny'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final ReservationRequestResponseDto request;

  @override
  Widget build(BuildContext context) {
    final userName = request.user?['name'] as String? ?? 'Guest';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(userName),
        subtitle: Text('Party of ${request.partySize} · ${request.status}'),
        trailing: request.eventName != null ? Text(request.eventName!, style: Theme.of(context).textTheme.bodySmall) : null,
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation});

  final Map<String, dynamic> reservation;

  @override
  Widget build(BuildContext context) {
    final user = reservation['user'] as Map<String, dynamic>?;
    final table = reservation['table'] as Map<String, dynamic>?;
    final userName = user?['name'] as String? ?? 'Guest';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(userName),
        subtitle: Text(
          'Party of ${reservation['partySize'] ?? '?'}'
          '${table != null ? ' · Table ${table['number']}' : ''}',
        ),
        trailing: reservation['eventName'] != null
            ? Text(reservation['eventName'] as String, style: Theme.of(context).textTheme.bodySmall)
            : null,
      ),
    );
  }
}
