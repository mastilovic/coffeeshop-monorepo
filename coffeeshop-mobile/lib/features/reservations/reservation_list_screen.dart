import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/utils/api_error.dart';
import '../../core/utils/reservation_event_utils.dart';
import '../../data/models/event_response_dto.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/event_api_service.dart';
import '../../data/services/reservation_request_api_service.dart';
import '../../data/services/shop_api_service.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/form_select.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../shop_details/tabs/reservations_tab.dart';
import '../shops/shop_providers.dart';
import 'reservation_providers.dart';

class ReservationListScreen extends ConsumerStatefulWidget {
  const ReservationListScreen({
    super.key,
    this.initialShopId,
    this.initialEventId,
  });

  final String? initialShopId;
  final String? initialEventId;

  @override
  ConsumerState<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends ConsumerState<ReservationListScreen> {
  bool _showRequestForm = false;
  bool _appliedQueryPrefill = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialShopId != null && widget.initialEventId != null) {
      _showRequestForm = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = isShopOwner(ref);

    if (isOwner) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Reservations'),
            actions: [
              IconButton(
                icon: Icon(_showRequestForm ? Icons.close : Icons.add),
                onPressed: () => setState(() => _showRequestForm = !_showRequestForm),
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'My Reservations'),
                Tab(text: 'Manage Shops'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (_showRequestForm)
                Expanded(
                  child: _ReservationRequestForm(
                    onClose: () => setState(() => _showRequestForm = false),
                    initialShopId: widget.initialShopId,
                    initialEventId: widget.initialEventId,
                    appliedPrefill: _appliedQueryPrefill,
                    onPrefillApplied: () => _appliedQueryPrefill = true,
                  ),
                ),
              if (!_showRequestForm)
                Expanded(
                  child: TabBarView(
                    children: [
                      const _MyReservationsPanel(),
                      _ManageShopsPanel(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        actions: [
          IconButton(
            icon: Icon(_showRequestForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showRequestForm = !_showRequestForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showRequestForm)
            Expanded(
              child: _ReservationRequestForm(
                onClose: () => setState(() => _showRequestForm = false),
                initialShopId: widget.initialShopId,
                initialEventId: widget.initialEventId,
                appliedPrefill: _appliedQueryPrefill,
                onPrefillApplied: () => _appliedQueryPrefill = true,
              ),
            ),
          if (!_showRequestForm)
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(tabs: [Tab(text: 'My Requests'), Tab(text: 'My Reservations')]),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _MyRequestsPanel(),
                          const _MyReservationsPanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MyRequestsPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(myReservationRequestsProvider);

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(myReservationRequestsProvider)),
      data: (requests) {
        if (requests.isEmpty) {
          return const EmptyStateView(icon: Icons.send, message: 'No reservation requests.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final shopName = req.shop?['name'] as String? ?? 'Shop';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(shopName),
                subtitle: Text('Party of ${req.partySize} · ${req.status}'),
                trailing: req.eventName != null ? Text(req.eventName!, style: Theme.of(context).textTheme.bodySmall) : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _MyReservationsPanel extends ConsumerWidget {
  const _MyReservationsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(myReservationsProvider);

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(myReservationsProvider)),
      data: (reservations) {
        if (reservations.isEmpty) {
          return const EmptyStateView(icon: Icons.confirmation_number, message: 'No reservations.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final res = reservations[index];
            final shop = res['shop'] as Map<String, dynamic>?;
            final shopName = shop?['name'] as String? ?? 'Shop';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(shopName),
                subtitle: Text('Party of ${res['partySize'] ?? '?'}'),
                trailing: res['eventName'] != null
                    ? Text(res['eventName'] as String, style: Theme.of(context).textTheme.bodySmall)
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _ManageShopsPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(ownerManagedShopsProvider);

    return shopsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(ownerManagedShopsProvider)),
      data: (shops) {
        if (shops.isEmpty) {
          return const EmptyStateView(icon: Icons.store, message: 'No shops to manage.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(shop.name),
                children: [
                  SizedBox(
                    height: 400,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final detail = ref.watch(shopDetailProvider(shop.id));
                        return detail.when(
                          loading: () => const LoadingIndicator(),
                          error: (e, _) => ErrorView(
                            message: e.toString(),
                            onRetry: () => ref.invalidate(shopDetailProvider(shop.id)),
                          ),
                          data: (shopDetail) => ReservationsTab(
                            shopId: shop.id,
                            tables: shopDetail.tables,
                            canManage: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ReservationRequestForm extends ConsumerStatefulWidget {
  const _ReservationRequestForm({
    required this.onClose,
    this.initialShopId,
    this.initialEventId,
    this.appliedPrefill = false,
    this.onPrefillApplied,
  });

  final VoidCallback onClose;
  final String? initialShopId;
  final String? initialEventId;
  final bool appliedPrefill;
  final VoidCallback? onPrefillApplied;

  @override
  ConsumerState<_ReservationRequestForm> createState() => _ReservationRequestFormState();
}

class _ReservationRequestFormState extends ConsumerState<_ReservationRequestForm> {
  final _partySizeController = TextEditingController(text: '2');
  String? _selectedShopId;
  String? _selectedEventId;
  List<ShopResponseDto> _shops = [];
  List<EventResponseDto> _events = [];
  bool _isLoadingShops = true;
  bool _isLoadingEvents = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      final isOwner = isShopOwner(ref);
      var shops = isOwner
          ? await ref.read(shopApiServiceProvider).getMine()
          : await _loadAllShops();

      if (widget.initialShopId != null &&
          !shops.any((s) => s.id == widget.initialShopId)) {
        try {
          final shopData = await ref.read(shopApiServiceProvider).getById(widget.initialShopId!);
          shops = [...shops, ShopResponseDto.fromJson(shopData)];
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _shops = shops;
          _isLoadingShops = false;
        });
        _applyPrefillIfNeeded();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingShops = false);
    }
  }

  Future<List<ShopResponseDto>> _loadAllShops() async {
    final data = await ref.read(shopApiServiceProvider).getShops(size: 100);
    return (data['content'] as List<dynamic>?)
            ?.map((e) => ShopResponseDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  void _applyPrefillIfNeeded() {
    if (widget.appliedPrefill) return;
    if (widget.initialShopId == null) return;

    widget.onPrefillApplied?.call();
    setState(() => _selectedShopId = widget.initialShopId);
    _loadEvents(widget.initialShopId!, preselectEventId: widget.initialEventId);
  }

  Future<void> _loadEvents(String shopId, {String? preselectEventId}) async {
    setState(() {
      _isLoadingEvents = true;
      if (preselectEventId == null) _selectedEventId = null;
      _events = [];
    });
    try {
      final data = await ref.read(eventApiServiceProvider).getAll(shopId: shopId);
      List<EventResponseDto> events = [];
      if (data is List) {
        events = data.map((e) => EventResponseDto.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map<String, dynamic>) {
        events = (data['content'] as List<dynamic>?)
                ?.map((e) => EventResponseDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }

      String? selectedId;
      if (preselectEventId != null) {
        final match = events.where((e) => e.eventId == preselectEventId && canReserveForEvent(e));
        if (match.isNotEmpty) selectedId = preselectEventId;
      }

      if (mounted) {
        setState(() {
          _events = events;
          _selectedEventId = selectedId;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  @override
  void dispose() {
    _partySizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final partySize = int.tryParse(_partySizeController.text.trim());
    final userId = ref.read(authNotifierProvider).user?.id;
    if (partySize == null || partySize < 1 || _selectedShopId == null || _selectedEventId == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(reservationRequestApiServiceProvider).create({
        'userId': userId,
        'shopId': _selectedShopId,
        'eventId': _selectedEventId,
        'partySize': partySize,
      });
      ref.invalidate(myReservationRequestsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation request submitted')),
        );
        widget.onClose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingShops) return const LoadingIndicator();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Request Reservation', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_shops.isEmpty)
          const Text('No shops available for reservation requests.')
        else ...[
          FormSelect<String>(
            label: 'Shop',
            value: _selectedShopId,
            items: _shops.map((s) => s.id).toList(),
            itemLabel: (id) => _shops.firstWhere((s) => s.id == id).name,
            onChanged: (v) {
              setState(() => _selectedShopId = v);
              if (v != null) _loadEvents(v);
            },
          ),
          const SizedBox(height: 12),
          if (_isLoadingEvents)
            const LinearProgressIndicator()
          else if (_selectedShopId != null)
            FormSelect<String>(
              label: 'Event',
              value: _selectedEventId,
              items: _events.map((e) => e.eventId).toList(),
              itemLabel: (id) {
                final event = _events.firstWhere((e) => e.eventId == id);
                return event.eventName.isNotEmpty ? event.eventName : event.eventId;
              },
              onChanged: (v) => setState(() => _selectedEventId = v),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _partySizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Party size', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit Request'),
          ),
        ],
      ],
    );
  }
}
