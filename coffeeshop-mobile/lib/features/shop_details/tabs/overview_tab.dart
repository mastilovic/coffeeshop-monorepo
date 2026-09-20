import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/utils/api_error.dart';
import '../../../data/models/event_response_dto.dart';
import '../../../data/models/shop_response_dto.dart';
import '../../../data/services/shop_api_service.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/event_list_card.dart';
import '../../../shared/widgets/loyalty_badge.dart';
import '../../../shared/widgets/shop_card.dart';
import '../../../shared/widgets/star_rating.dart';
import '../../dashboard/dashboard_provider.dart';
import '../../shops/shop_providers.dart';
import 'events_tab.dart';

List<Map<String, dynamic>> menuPreviewItems(
  Map<String, dynamic>? menu, {
  int limit = 3,
}) {
  final raw = menu?['items'];
  if (raw is! List) return const [];
  return raw
      .map((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        return null;
      })
      .whereType<Map<String, dynamic>>()
      .take(limit)
      .toList();
}

List<EventResponseDto> upcomingEventsPreview(
  List<Map<String, dynamic>>? events, {
  int limit = 3,
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final parsed = parseShopEvents(events)
    ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  return parsed
      .where((e) {
        final date = DateTime.tryParse(e.eventDate);
        return date == null || !date.isBefore(reference);
      })
      .take(limit)
      .toList();
}

int upcomingEventCount(List<Map<String, dynamic>>? events, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  return parseShopEvents(events).where((e) {
    final date = DateTime.tryParse(e.eventDate);
    return date == null || !date.isBefore(reference);
  }).length;
}

List<Map<String, dynamic>> reviewsPreview(
  List<Map<String, dynamic>>? reviews, {
  int limit = 2,
}) {
  if (reviews == null) return const [];
  final parsed = List<Map<String, dynamic>>.from(reviews)
    ..sort((a, b) {
      final aDate = a['reviewDate'] as String? ?? '';
      final bDate = b['reviewDate'] as String? ?? '';
      return bDate.compareTo(aDate);
    });
  return parsed.take(limit).toList();
}

class OverviewTab extends ConsumerStatefulWidget {
  const OverviewTab({
    super.key,
    required this.shop,
    required this.canManageShop,
    this.onSeeMenu,
    this.onSeeEvents,
    this.onSeeReviews,
  });

  final ShopResponseDto shop;
  final bool canManageShop;
  final VoidCallback? onSeeMenu;
  final VoidCallback? onSeeEvents;
  final VoidCallback? onSeeReviews;

  @override
  ConsumerState<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<OverviewTab> {
  bool _togglingFavourite = false;

  Future<void> _toggleFavourite() async {
    if (_togglingFavourite) return;
    final shop = widget.shop;
    final wasFavourite = shop.favouriteByCurrentUser;

    if (wasFavourite) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Leave community',
        message:
            'Are you sure you want to leave ${shop.name}\'s community?',
        confirmLabel: 'Leave',
        isDestructive: true,
      );
      if (!confirmed || !mounted) return;
    }

    setState(() => _togglingFavourite = true);
    final api = ref.read(shopApiServiceProvider);
    try {
      if (wasFavourite) {
        await api.removeFavourite(shop.id);
      } else {
        await api.addFavourite(shop.id);
      }
      await ref.read(authNotifierProvider.notifier).refreshProfile();
      ref.invalidate(shopDetailProvider(shop.id));
      ref.invalidate(dashboardProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favourite: ${formatApiError(e)}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _togglingFavourite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shop = widget.shop;
    final planType = loyaltyPlanType(shop.loyaltyPlan);
    final menuItems = menuPreviewItems(shop.currentMenu);
    final events = upcomingEventsPreview(shop.events);
    final reviews = reviewsPreview(shop.reviews);
    final eventCount = upcomingEventCount(shop.events);
    final ratingText = shopRatingLabel(
      rating: shop.averageRating,
      reviewCount: shop.reviewCount,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shop.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (planType != null) LoyaltyBadge(planType: planType),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${shop.city} · ${shop.address}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (shop.phoneNumber != null && shop.phoneNumber!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    label: shop.phoneNumber!,
                  ),
                ],
                if (shop.email != null && shop.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    label: shop.email!,
                  ),
                ],
                if (!widget.canManageShop) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _togglingFavourite ? null : _toggleFavourite,
                      icon: Icon(
                        shop.favouriteByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                      ),
                      label: Text(
                        shop.favouriteByCurrentUser
                            ? 'Leave community'
                            : 'Join community',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.star_outline,
                label: 'Rating',
                value: ratingText,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.people_outline,
                label: 'Members',
                value: '${shop.memberCount}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.event_outlined,
                label: 'Events',
                value: '$eventCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          _PreviewSection(
            title: 'Upcoming events',
            onSeeAll: widget.onSeeEvents,
            emptyMessage: 'No upcoming events.',
            isEmpty: true,
            children: const [],
          )
        else ...[
          _EventsPreviewHeader(onSeeAll: widget.onSeeEvents),
          ...events.map((event) {
            return EventListCard(
              eventId: event.eventId,
              eventName: eventLabel(event),
              eventDate: event.eventDate,
              shopId: shop.id,
            );
          }),
        ],
        const SizedBox(height: 12),
        _PreviewSection(
          title: 'Recent reviews',
          onSeeAll: widget.onSeeReviews,
          emptyMessage: 'No reviews yet.',
          isEmpty: reviews.isEmpty,
          children: reviews.map((review) {
            final rating = (review['rating'] as num?)?.toDouble() ?? 0;
            final description = review['description'] as String? ?? '';
            final user = review['user'];
            final author = user is Map
                ? (user['name'] as String? ??
                    user['username'] as String? ??
                    'Anonymous')
                : 'Anonymous';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StarRating(rating: rating, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          author,
                          style: theme.textTheme.labelMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _PreviewSection(
          title: 'Menu',
          onSeeAll: widget.onSeeMenu,
          emptyMessage: 'No menu yet.',
          isEmpty: menuItems.isEmpty,
          children: menuItems.map((item) {
            final name = item['name'] as String? ?? 'Item';
            final price = item['price'];
            final currency = item['priceCurrency'] as String? ?? '';
            final priceLabel = price == null
                ? null
                : currency.isEmpty
                    ? '$price'
                    : '$price $currency';
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(name),
              trailing: priceLabel == null ? null : Text(priceLabel),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsPreviewHeader extends StatelessWidget {
  const _EventsPreviewHeader({this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Upcoming events',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.title,
    required this.isEmpty,
    required this.emptyMessage,
    required this.children,
    this.onSeeAll,
  });

  final String title;
  final bool isEmpty;
  final String emptyMessage;
  final List<Widget> children;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    child: const Text('See all'),
                  ),
              ],
            ),
            if (isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  emptyMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}
