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
    this.onTap,
    this.onFavouriteToggle,
  });

  final String name;
  final String? city;
  final double? rating;
  final int? reviewCount;
  final int? memberCount;
  final String? imageUrl;
  final bool isFavourite;
  final VoidCallback? onTap;
  final VoidCallback? onFavouriteToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.store,
                        size: 48,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (city != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (reviewCount != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '($reviewCount)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }
}
