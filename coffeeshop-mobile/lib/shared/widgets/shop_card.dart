import 'package:flutter/material.dart';

import 'image_with_placeholder.dart';
import 'loyalty_badge.dart';

/// Returns a display label for shop ratings.
///
/// Shows a numeric rating when [rating] is non-null and > 0 and [reviewCount]
/// is > 0; otherwise returns "No rating yet".
String shopRatingLabel({double? rating, int? reviewCount}) {
  final reviews = reviewCount ?? 0;
  if (rating == null || rating <= 0 || reviews <= 0) {
    return 'No rating yet';
  }
  return '${rating.toStringAsFixed(1)} ($reviews)';
}

bool shopHasRating({double? rating, int? reviewCount}) {
  final reviews = reviewCount ?? 0;
  return rating != null && rating > 0 && reviews > 0;
}

class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.name,
    this.city,
    this.rating,
    this.reviewCount,
    this.memberCount,
    this.imageUrl,
    this.loyaltyPlanType,
    this.isFavourite = false,
    this.isOwned = false,
    this.onTap,
    this.onFavouriteToggle,
    this.onEmployees,
    this.onDelete,
  });

  final String name;
  final String? city;
  final double? rating;
  final int? reviewCount;
  final int? memberCount;
  final String? imageUrl;
  final String? loyaltyPlanType;
  final bool isFavourite;
  final bool isOwned;
  final VoidCallback? onTap;
  final VoidCallback? onFavouriteToggle;
  final VoidCallback? onEmployees;
  final VoidCallback? onDelete;

  bool get _hasManagementActions => onEmployees != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRating = shopHasRating(rating: rating, reviewCount: reviewCount);
    final ratingText = shopRatingLabel(rating: rating, reviewCount: reviewCount);
    final cardShape = isOwned
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.primary, width: 2),
          )
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: cardShape,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageWithPlaceholder(
                    imageUrl: imageUrl,
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.circular(8),
                    placeholderIcon: Icons.store,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isOwned) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Your Shop',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            if (onFavouriteToggle != null)
                              IconButton(
                                onPressed: onFavouriteToggle,
                                icon: Icon(
                                  isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavourite
                                      ? Colors.red
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        if (city != null || memberCount != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (city != null) ...[
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    city!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              if (city != null && memberCount != null)
                                Text(
                                  ' · ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              if (memberCount != null) ...[
                                Icon(
                                  Icons.people_outline,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$memberCount members',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (hasRating)
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              )
                            else
                              Icon(
                                Icons.star_outline,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                ratingText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: hasRating
                                      ? null
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (loyaltyPlanType != null) ...[
                              const SizedBox(width: 8),
                              LoyaltyBadge(
                                planType: loyaltyPlanType!,
                                compact: true,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_hasManagementActions)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Row(
                children: [
                  if (onEmployees != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onEmployees,
                        icon: const Icon(Icons.people_outline, size: 18),
                        label: const Text('Employees'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: theme.colorScheme.error,
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
