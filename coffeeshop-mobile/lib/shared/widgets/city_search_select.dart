import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/reference_api_service.dart';

/// Non-null when the user explicitly picked a city (or "all cities").
class CityPickerSelection {
  const CityPickerSelection(this.city);
  final String? city;
}

class CitySearchSelect extends ConsumerWidget {
  const CitySearchSelect({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowAll = false,
    this.label = 'City',
    this.hint = 'All cities',
    this.errorText,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool allowAll;
  final String label;
  final String hint;
  final String? errorText;

  String get _displayText => value ?? hint;

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final selection = await showModalBottomSheet<CityPickerSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _CityPickerSheet(
        selectedCity: value,
        allowAll: allowAll,
        allLabel: hint,
        referenceApi: ref.read(referenceApiServiceProvider),
      ),
    );

    if (selection != null) {
      onChanged(selection.city);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasValue = value != null;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_city_outlined),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasValue)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => onChanged(null),
                tooltip: allowAll ? hint : 'Clear',
              ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => _openPicker(context, ref),
              tooltip: 'Select city',
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        errorText: errorText,
      ),
      child: InkWell(
        onTap: () => _openPicker(context, ref),
        child: Text(
          _displayText,
          style: hasValue
              ? null
              : TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({
    required this.selectedCity,
    required this.allowAll,
    required this.allLabel,
    required this.referenceApi,
  });

  final String? selectedCity;
  final bool allowAll;
  final String allLabel;
  final ReferenceApiService referenceApi;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<String> _cities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCities([String? query]) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cities = await widget.referenceApi.getCities(
        q: query?.trim().isEmpty ?? true ? null : query!.trim(),
      );
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _loadCities(value);
    });
  }

  void _select(String? city) {
    Navigator.of(context).pop(CityPickerSelection(city));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sheetHeight = MediaQuery.of(context).size.height * 0.65;

    return SizedBox(
      height: sheetHeight,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select city',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search cities...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildList(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildList(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load cities', style: TextStyle(color: colorScheme.error)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _loadCities(_searchController.text),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = _cities.length + (widget.allowAll ? 1 : 0);
    if (itemCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No cities found',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (widget.allowAll && index == 0) {
          return _CityTile(
            label: widget.allLabel,
            isSelected: widget.selectedCity == null,
            onTap: () => _select(null),
          );
        }

        final cityIndex = widget.allowAll ? index - 1 : index;
        final city = _cities[cityIndex];
        return _CityTile(
          label: city,
          isSelected: widget.selectedCity == city,
          onTap: () => _select(city),
        );
      },
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              if (isSelected)
                Icon(Icons.check, color: colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
