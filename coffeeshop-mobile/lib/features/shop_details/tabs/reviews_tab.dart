import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/review_response_dto.dart';
import '../../../data/services/review_api_service.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/star_rating.dart';

final shopReviewsProvider =
    FutureProvider.family<List<ReviewResponseDto>, String>((ref, shopId) async {
  final api = ref.watch(reviewApiServiceProvider);
  final data = await api.getAll();
  return data.map((e) => ReviewResponseDto.fromJson(e as Map<String, dynamic>)).toList();
});

class ReviewsTab extends ConsumerWidget {
  const ReviewsTab({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(shopReviewsProvider(shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(shopReviewsProvider(shopId)),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(child: Text('No reviews yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final user = review.user;
            final userName = user?['name'] as String? ?? 'Anonymous';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userName, style: Theme.of(context).textTheme.titleSmall),
                              if (review.reviewDate != null)
                                Text(review.reviewDate!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        StarRating(rating: review.rating.toDouble(), size: 16),
                      ],
                    ),
                    if (review.title != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        review.title!,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (review.description != null) ...[
                      const SizedBox(height: 4),
                      Text(review.description!, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
