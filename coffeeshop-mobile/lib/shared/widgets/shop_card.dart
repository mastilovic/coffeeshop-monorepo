import 'package:flutter/material.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.name,
    this.city,
    this.rating,
    this.reviewCount,
    this.memberCount,
    this.imageUrl,
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
    final cardShape = isOwned
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.primary, width: 2),
          )
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: cardShape,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.store,
                              size: 48,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      if (isOwned)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
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
                        ),
                      if (onFavouriteToggle != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            onPressed: onFavouriteToggle,
                            icon: Icon(
                              isFavourite ? Icons.favorite : Icons.favorite_border,
                              color: isFavourite ? Colors.red : Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black26,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (city != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
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
                          ),
                        ],
                        if (rating != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                rating!.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall,
                              ),
                              if (reviewCount != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '($reviewCount)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ],
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
