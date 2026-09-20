import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/user_permissions.dart';
import '../../core/utils/api_error.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/reservation_event_utils.dart';
import '../../data/models/event_response_dto.dart';
import '../../data/models/reservation_request_response_dto.dart';
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

enum _ReservationRequestMode { guest, self }

class ReservationListScreen extends ConsumerStatefulWidget {
  const ReservationListScreen({
    super.key,
    this.initialShopId,
    this.initialEventId,
    this.openRequest = false,
  });

  final String? initialShopId;
  final String? initialEventId;
  final bool openRequest;

  @override
  ConsumerState<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends ConsumerState<ReservationListScreen> {
  late bool _showRequestForm;
  bool _appliedQueryPrefill = false;

  static bool _shouldOpenForm(ReservationListScreen widget) =>
      widget.openRequest ||
      widget.initialShopId != null ||
      widget.initialEventId != null;

  @override
  void initState() {
    super.initState();
    _showRequestForm = _shouldOpenForm(widget);
  }

  @override
  void didUpdateWidget(covariant ReservationListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final paramsChanged = widget.initialShopId != oldWidget.initialShopId ||
        widget.initialEventId != oldWidget.initialEventId ||
        widget.openRequest != oldWidget.openRequest;
    if (paramsChanged && _shouldOpenForm(widget)) {
      setState(() {
        _showRequestForm = true;
        _appliedQueryPrefill = false;
      });
    }
  }

  void _openRequestForm() => setState(() => _showRequestForm = true);

  @override
  Widget build(BuildContext context) {
    final isOwner = isShopOwner(ref);

    if (isOwner) {
      return DefaultTabController(
        length: 3,
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
                Tab(text: 'My Requests'),
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
                    key: ValueKey(
                      '${widget.initialShopId}-${widget.initialEventId}-$_appliedQueryPrefill',
                    ),
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
                      _MyRequestsPanel(onRequestReservation: _openRequestForm),
                      _MyReservationsPanel(onRequestReservation: _openRequestForm),
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
                key: ValueKey(
                  '${widget.initialShopId}-${widget.initialEventId}-$_appliedQueryPrefill',
                ),
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
                          _MyRequestsPanel(onRequestReservation: _openRequestForm),
                          _MyReservationsPanel(onRequestReservation: _openRequestForm),
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
  const _MyRequestsPanel({required this.onRequestReservation});

  final VoidCallback onRequestReservation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(myReservationRequestsProvider);

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(myReservationRequestsProvider)),
      data: (requests) {
        if (requests.isEmpty) {
          return EmptyStateView(
            icon: Icons.send,
            message: 'No reservation requests.',
            actionLabel: 'Request a reservation',
            onAction: onRequestReservation,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final shopName = req.shop?['name'] as String? ?? 'Shop';
            final eventDateLine = formatEventDateWithRelative(req.eventDate);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(shopName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Party of ${req.partySize} · ${req.status}'),
                    if (eventDateLine != null)
                      Text(
                        eventDateLine,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                isThreeLine: eventDateLine != null,
                trailing: req.eventName != null
                    ? Text(req.eventName!, style: Theme.of(context).textTheme.bodySmall)
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _MyReservationsPanel extends ConsumerWidget {
  const _MyReservationsPanel({required this.onRequestReservation});

  final VoidCallback onRequestReservation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(myReservationsProvider);

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(myReservationsProvider)),
      data: (reservations) {
        if (reservations.isEmpty) {
          return EmptyStateView(
            icon: Icons.confirmation_number,
            message: 'No reservations.',
            actionLabel: 'Request a reservation',
            onAction: onRequestReservation,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final res = reservations[index];
            final shop = res['shop'] as Map<String, dynamic>?;
            final shopName = shop?['name'] as String? ?? 'Shop';
            final eventDateLine = formatEventDateWithRelative(res['eventDate'] as String?);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(shopName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Party of ${res['partySize'] ?? '?'}'),
                    if (eventDateLine != null)
                      Text(
                        eventDateLine,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                isThreeLine: eventDateLine != null,
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
    final allRequestsAsync = ref.watch(allOwnerReservationRequestsProvider);

    return shopsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(ownerManagedShopsProvider)),
      data: (shops) {
        if (shops.isEmpty) {
          return const EmptyStateView(icon: Icons.store, message: 'No shops to manage.');
        }

        return allRequestsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(allOwnerReservationRequestsProvider),
          ),
          data: (requests) {
            final pendingByShop = <String, int>{};
            for (final request in requests) {
              final shopId = request.resolvedShopId;
              if (request.status == 'PENDING' && shopId != null) {
                pendingByShop.update(shopId, (count) => count + 1, ifAbsent: () => 1);
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                final pendingCount = pendingByShop[shop.id] ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(shop.name)),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 8),
                          _PendingCountBadge(count: pendingCount),
                        ],
                      ],
                    ),
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        ref.invalidate(shopReservationRequestsProvider(shop.id));
                        ref.invalidate(shopReservationsProvider(shop.id));
                      }
                    },
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
      },
    );
  }
}

class _PendingCountBadge extends StatelessWidget {
  const _PendingCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onError,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ReservationRequestForm extends ConsumerStatefulWidget {
  const _ReservationRequestForm({
    super.key,
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
  String? _shopsError;
  String? _eventsError;
  _ReservationRequestMode _mode = _ReservationRequestMode.guest;

  bool get _isOwner {
    final permissions = ref.read(userPermissionsProvider).valueOrNull;
    return permissions?.isShopOwner ?? false;
  }

  List<EventResponseDto> get _reservableEvents =>
      _events.where(canReserveForEvent).toList();

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  void _onModeChanged(_ReservationRequestMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _selectedShopId = null;
      _selectedEventId = null;
      _events = [];
      _eventsError = null;
      _isLoadingShops = true;
    });
    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() {
      _isLoadingShops = true;
      _shopsError = null;
    });

    try {
      final permissions = ref.read(userPermissionsProvider).valueOrNull;
      final isOwner = permissions?.isShopOwner ?? false;
      List<ShopResponseDto> shops;

      if (!isOwner) {
        shops = await _loadAllShops();
      } else if (_mode == _ReservationRequestMode.guest) {
        shops = await ref.read(shopApiServiceProvider).getMine();
      } else {
        final allShops = await _loadAllShops();
        final ownedIds = permissions!.ownedShopIds.toSet();
        shops = allShops.where((shop) => !ownedIds.contains(shop.id)).toList();
      }

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingShops = false;
          _shopsError = formatApiError(e);
        });
      }
    }
  }

  Future<List<ShopResponseDto>> _loadAllShops() async {
    return ref.read(shopApiServiceProvider).getAllShops();
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
      _eventsError = null;
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
    } catch (e) {
      if (mounted) {
        setState(() => _eventsError = formatApiError(e));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: ${formatApiError(e)}')),
        );
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
        if (_isOwner) ...[
          SegmentedButton<_ReservationRequestMode>(
            segments: const [
              ButtonSegment(
                value: _ReservationRequestMode.guest,
                label: Text('For guest'),
                icon: Icon(Icons.person_add),
              ),
              ButtonSegment(
                value: _ReservationRequestMode.self,
                label: Text('For myself'),
                icon: Icon(Icons.person),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) => _onModeChanged(selection.first),
          ),
          const SizedBox(height: 12),
        ],
        if (_shopsError != null)
          ErrorView(message: _shopsError!, onRetry: _loadShops)
        else if (_shops.isEmpty)
          Text(
            _isOwner && _mode == _ReservationRequestMode.self
                ? 'No other shops available for self-reservations.'
                : 'No shops available for reservation requests.',
          )
        else ...[
          FormSelect<String>(
            label: 'Shop',
            value: _selectedShopId,
            items: _shops.map((s) => s.id).toList(),
            itemLabel: (id) => _shops.firstWhere((s) => s.id == id).name,
            onChanged: (v) {
              setState(() {
                _selectedShopId = v;
                _eventsError = null;
              });
              if (v != null) _loadEvents(v);
            },
          ),
          const SizedBox(height: 12),
          if (_isLoadingEvents)
            const LinearProgressIndicator()
          else if (_eventsError != null)
            ErrorView(
              message: _eventsError!,
              onRetry: _selectedShopId == null
                  ? null
                  : () => _loadEvents(_selectedShopId!),
            )
          else if (_selectedShopId != null)
            FormSelect<String>(
              label: 'Event',
              value: _selectedEventId,
              items: _reservableEvents.map((e) => e.eventId).toList(),
              itemLabel: (id) {
                final event = _reservableEvents.firstWhere((e) => e.eventId == id);
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
