import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/dashboard_activity_response.dart';
import '../../../shared/widgets/image_with_placeholder.dart';
import '../../../shared/widgets/shop_card.dart';

class TopShopsCarousel extends StatelessWidget {
  const TopShopsCarousel({super.key, required this.shops});

  final List<TopShopItem> shops;

  @override
  Widget build(BuildContext context) {
    if (shops.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Top Shops',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final shop = shops[index];
              final hasRating = shopHasRating(
                rating: shop.averageRating,
                reviewCount: shop.reviewCount,
              );
              final ratingText = shopRatingLabel(
                rating: shop.averageRating,
                reviewCount: shop.reviewCount,
              );

              return SizedBox(
                width: 260,
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.go('/shops/${shop.shopId}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ImageWithPlaceholder(
                            width: 56,
                            height: 56,
                            borderRadius: BorderRadius.circular(8),
                            placeholderIcon: Icons.store,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  shop.shopName,
                                  style: theme.textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (shop.city != null) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          shop.city!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      hasRating
                                          ? Icons.star
                                          : Icons.star_outline,
                                      size: 14,
                                      color: hasRating
                                          ? Colors.amber
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        ratingText,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: hasRating
                                              ? null
                                              : theme
                                                  .colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
