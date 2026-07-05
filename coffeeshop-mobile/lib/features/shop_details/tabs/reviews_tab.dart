import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/user_permissions.dart';
import '../../../core/utils/api_error.dart';
import '../../../data/models/review_response_dto.dart';
import '../../../data/services/review_api_service.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/star_rating.dart';

bool _reviewBelongsToShop(ReviewResponseDto review, String shopId) {
  if (review.shopId == shopId) return true;
  final shop = review.shop;
  if (shop == null) return false;
  return (shop['id'] as String?) == shopId;
}

final shopReviewsProvider =
    FutureProvider.family<List<ReviewResponseDto>, String>((ref, shopId) async {
  final api = ref.watch(reviewApiServiceProvider);
  final data = await api.getAll();
  return data
      .map((e) => ReviewResponseDto.fromJson(e as Map<String, dynamic>))
      .where((review) => _reviewBelongsToShop(review, shopId))
      .toList();
});

class ReviewsTab extends ConsumerStatefulWidget {
  const ReviewsTab({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends ConsumerState<ReviewsTab> {
  bool _showReviewForm = false;
  bool _isSubmittingReview = false;
  int _newRating = 5;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmittingReview = true);
    try {
      await ref.read(reviewApiServiceProvider).create({
        'shopId': widget.shopId,
        'rating': _newRating,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'commentsEnabled': true,
      });
      ref.invalidate(shopReviewsProvider(widget.shopId));
      if (mounted) {
        setState(() {
          _showReviewForm = false;
          _newRating = 5;
        });
        _titleController.clear();
        _descriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete review?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(reviewApiServiceProvider).delete(reviewId);
      ref.invalidate(shopReviewsProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete review: ${formatApiError(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(shopReviewsProvider(widget.shopId));
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    final canLeaveReview = permissions != null && !permissions.canManageContent(widget.shopId);
    final currentUserId = ref.watch(authNotifierProvider).user?.id;

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(shopReviewsProvider(widget.shopId)),
      ),
      data: (reviews) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (canLeaveReview) ...[
              if (!_showReviewForm)
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _showReviewForm = true),
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Leave a review'),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Your review', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        StarRating(
                          rating: _newRating.toDouble(),
                          onRatingChanged: (value) => setState(() => _newRating = value),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmittingReview
                                    ? null
                                    : () => setState(() => _showReviewForm = false),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isSubmittingReview ? null : _submitReview,
                                child: _isSubmittingReview
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
            if (reviews.isEmpty)
              const Center(child: Text('No reviews yet'))
            else
              ...reviews.map(
                (review) => _ReviewCard(
                  review: review,
                  shopId: widget.shopId,
                  currentUserId: currentUserId,
                  onDelete: () => _deleteReview(review.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReviewCard extends ConsumerStatefulWidget {
  const _ReviewCard({
    required this.review,
    required this.shopId,
    required this.currentUserId,
    required this.onDelete,
  });

  final ReviewResponseDto review;
  final String shopId;
  final String? currentUserId;
  final VoidCallback onDelete;

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isAuthor {
    final userId = widget.currentUserId;
    if (userId == null) return false;
    final reviewUserId = widget.review.user?['id'] as String? ?? widget.review.userId;
    return reviewUserId == userId;
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingComment = true);
    try {
      await ref.read(reviewApiServiceProvider).createComment(widget.review.id, {
        'body': text,
      });
      ref.invalidate(shopReviewsProvider(widget.shopId));
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
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
                if (_isAuthor)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete review',
                  ),
              ],
            ),
            if (review.title != null && review.title!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.title!,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            if (review.description != null && review.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(review.description!),
            ],
            if (review.comments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Comments', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              ...review.comments.map((comment) {
                final author = comment['user'] as Map<String, dynamic>?;
                final authorName = author?['name'] as String? ?? 'User';
                final text = comment['body'] as String? ?? comment['text'] as String? ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text.rich(
                    TextSpan(
                      text: '$authorName: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: text,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            if (review.commentsEnabled) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmittingComment ? null : _submitComment,
                    icon: _isSubmittingComment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
