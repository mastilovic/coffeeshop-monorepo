import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_notifier.dart';
import '../../data/models/subscription_dto.dart';
import '../../data/services/subscription_api_service.dart';
import 'billing_format.dart';

class CustomPlanBuilderScreen extends ConsumerStatefulWidget {
  const CustomPlanBuilderScreen({super.key});

  @override
  ConsumerState<CustomPlanBuilderScreen> createState() =>
      _CustomPlanBuilderScreenState();
}

class _CustomPlanBuilderScreenState
    extends ConsumerState<CustomPlanBuilderScreen> {
  bool _catalogLoaded = false;
  bool _loadError = false;
  List<FeatureCatalogItemDto> _selectableFeatures = [];
  final Set<String> _selectedFeatures = {};
  int _shopCount = 1;
  String _billingInterval = 'monthly';
  QuoteBreakdownDto? _quote;
  bool _quoting = false;
  String? _quoteError;
  bool _applying = false;
  bool _applySuccess = false;
  String? _errorMessage;
  int _quoteRequestId = 0;
  late final TextEditingController _shopCountController;

  @override
  void initState() {
    super.initState();
    _shopCountController = TextEditingController();
    _loadCatalog();
  }

  @override
  void dispose() {
    _shopCountController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    final subscription = ref.read(authNotifierProvider).user?.subscription;
    _shopCount = [
      subscription?.shopsUsed ?? 1,
      subscription?.shopsIncluded ?? 1,
      1,
    ].reduce((a, b) => a > b ? a : b);
    _shopCountController.text = _shopCount.toString();

    try {
      final service = ref.read(subscriptionApiServiceProvider);
      final results = await Future.wait([
        service.getCatalog(),
        service.getMe(),
      ]);
      final catalog = results[0] as CatalogResponseDto;
      final me = results[1] as SubscriptionMeResponseDto;

      final features = catalog.features
          .where((feature) => feature.isSelectableCustom && feature.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      if (me.planMode == 'CUSTOM' && me.features.isNotEmpty) {
        _selectedFeatures
          ..clear()
          ..addAll(me.features);
      }
      if (me.billingInterval != null) {
        _billingInterval = me.billingInterval!;
      }

      setState(() {
        _selectableFeatures = features;
        _catalogLoaded = true;
      });
      await _refreshQuote();
    } catch (_) {
      setState(() => _loadError = true);
    }
  }

  Future<void> _refreshQuote() async {
    if (!_catalogLoaded) return;

    final requestId = ++_quoteRequestId;
    setState(() {
      _quoting = true;
      _quoteError = null;
    });

    try {
      final quote = await ref.read(subscriptionApiServiceProvider).quote(
            QuoteRequestDto(
              planMode: 'CUSTOM',
              features: _selectedFeatures.toList(),
              shopCount: _shopCount,
              billingInterval: _billingInterval,
            ),
          );
      if (!mounted || requestId != _quoteRequestId) return;
      setState(() {
        _quote = quote;
        _quoting = false;
      });
    } catch (_) {
      if (!mounted || requestId != _quoteRequestId) return;
      setState(() {
        _quote = null;
        _quoteError = 'Unable to load quote.';
        _quoting = false;
      });
    }
  }

  void _toggleFeature(String featureKey) {
    setState(() {
      if (_selectedFeatures.contains(featureKey)) {
        _selectedFeatures.remove(featureKey);
      } else {
        _selectedFeatures.add(featureKey);
      }
      _applySuccess = false;
    });
    _refreshQuote();
  }

  void _onShopCountChanged(String value) {
    final parsed = int.tryParse(value);
    setState(() {
      _shopCount = parsed != null && parsed >= 1 ? parsed : 1;
      _applySuccess = false;
    });
    _refreshQuote();
  }

  void _onAnnualChanged(bool? checked) {
    setState(() {
      _billingInterval = checked == true ? 'annual' : 'monthly';
      _applySuccess = false;
    });
    _refreshQuote();
  }

  Future<void> _applyPlan() async {
    if (_applying || _quoting || _quoteError != null) return;

    setState(() {
      _applying = true;
      _applySuccess = false;
      _errorMessage = null;
    });

    try {
      await ref.read(subscriptionApiServiceProvider).changePlan(
            UpdatePlanRequestDto(
              planMode: 'CUSTOM',
              features: _selectedFeatures.toList(),
              billingInterval: _billingInterval,
            ),
          );
      await ref.read(authNotifierProvider.notifier).refreshProfile();
      if (mounted) {
        setState(() {
          _applying = false;
          _applySuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _applying = false;
          _errorMessage = 'Failed to apply plan.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Custom Plan'),
      ),
      body: _loadError
          ? const Center(child: Text('Unable to load plan catalog.'))
          : !_catalogLoaded
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Pick the features you need and see a live price quote.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Features',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ..._selectableFeatures.map(
                              (feature) => CheckboxListTile(
                                key: Key('feature-${feature.featureKey}'),
                                value: _selectedFeatures
                                    .contains(feature.featureKey),
                                onChanged: (_) =>
                                    _toggleFeature(feature.featureKey),
                                title: Text(feature.displayName),
                                subtitle: feature.description != null
                                    ? Text(feature.description!)
                                    : null,
                                secondary: Text(
                                  '${formatCents(feature.monthlyPriceCents)}/mo',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quote',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              key: const Key('shop-count'),
                              decoration: const InputDecoration(
                                labelText: 'Shop count',
                                helperText:
                                    'First shop included; extra shops add to monthly cost.',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _shopCountController,
                              onChanged: _onShopCountChanged,
                            ),
                            CheckboxListTile(
                              key: const Key('annual-toggle'),
                              contentPadding: EdgeInsets.zero,
                              value: _billingInterval == 'annual',
                              onChanged: _onAnnualChanged,
                              title: const Text('Bill annually'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            if (_quoting)
                              const Padding(
                                key: Key('quote-loading'),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Updating quote...'),
                                  ],
                                ),
                              )
                            else if (_quoteError != null)
                              Text(
                                _quoteError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              )
                            else if (_quote != null)
                              _QuoteSummary(
                                quote: _quote!,
                                billingInterval: _billingInterval,
                              ),
                            if (_applySuccess)
                              Padding(
                                key: const Key('apply-success'),
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  'Custom plan applied.',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            FilledButton(
                              key: const Key('apply-plan'),
                              onPressed: _applying || _quoting || _quoteError != null
                                  ? null
                                  : _applyPlan,
                              child: Text(
                                _applying ? 'Applying...' : 'Apply plan',
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

class _QuoteSummary extends StatelessWidget {
  const _QuoteSummary({
    required this.quote,
    required this.billingInterval,
  });

  final QuoteBreakdownDto quote;
  final String billingInterval;

  @override
  Widget build(BuildContext context) {
    final isAnnual = billingInterval == 'annual';
    final total = isAnnual ? quote.annualTotalCents : quote.monthlyTotalCents;

    return Container(
      key: const Key('quote-summary'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isAnnual ? 'Annual total' : 'Monthly total'),
              Text(
                key: const Key('quote-total'),
                formatCents(total),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          if (isAnnual) ...[
            const SizedBox(height: 4),
            Text(
              '${formatCents(quote.monthlyTotalCents)}/mo equivalent',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (quote.lineItems.isNotEmpty) ...[
            const Divider(height: 24),
            ...quote.lineItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.label)),
                    Text(formatCents(item.amountCents)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
