import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/user_permissions.dart';
import '../../core/utils/api_error.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/event_api_service.dart';
import '../../shared/widgets/form_select.dart';
import 'event_providers.dart';

class EventCreateScreen extends ConsumerStatefulWidget {
  const EventCreateScreen({super.key});

  @override
  ConsumerState<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends ConsumerState<EventCreateScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedShopId;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _maybeAutoSelectShop(List<ShopResponseDto> shops) {
    if (shops.length == 1) {
      final id = shops.first.id;
      if (_selectedShopId != id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedShopId = id);
        });
      }
      return;
    }

    if (_selectedShopId != null &&
        !shops.any((s) => s.id == _selectedShopId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedShopId = null);
      });
    }
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final date = _dateController.text.trim();
    if (name.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter event name and date')),
      );
      return;
    }

    final permissions = ref.read(userPermissionsProvider).valueOrNull;
    final canCreate = permissions?.canCreateEvent ?? false;
    if (canCreate && _selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shop')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(eventApiServiceProvider).create({
        'eventName': name,
        'eventDate': date,
        'description': _descriptionController.text.trim(),
        if (_selectedShopId != null) 'shopId': _selectedShopId,
      });
      ref.invalidate(eventListProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildShopSection(AsyncValue<List<ShopResponseDto>> shopsAsync) {
    return shopsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Failed to load shops: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            TextButton(
              onPressed: () => ref.invalidate(eventCreatableShopsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (shops) {
        _maybeAutoSelectShop(shops);

        if (shops.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No shops available. Create a shop first.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                TextButton(
                  onPressed: () => context.push('/shops/new'),
                  child: const Text('Create Shop'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            FormSelect<String>(
              label: 'Shop',
              hint: shops.length > 1 ? 'Select shop' : null,
              value: _selectedShopId,
              items: shops.map((s) => s.id).toList(),
              itemLabel: (id) => shops.firstWhere((s) => s.id == id).name,
              onChanged: (v) => setState(() => _selectedShopId = v),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final canCreate = permissions?.canCreateEvent ?? false;
    final shopsAsync = ref.watch(eventCreatableShopsProvider);

    final shops = shopsAsync.valueOrNull ?? [];
    final shopRequiredButMissing =
        canCreate && shops.isNotEmpty && _selectedShopId == null;
    final canSubmit = !_isSaving && !shopRequiredButMissing && !(canCreate && shops.isEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (canCreate) _buildShopSection(shopsAsync),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Event name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: canSubmit ? _save : null,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create Event'),
          ),
        ],
      ),
    );
  }
}
