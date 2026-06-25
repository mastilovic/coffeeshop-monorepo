import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/utils/api_error.dart';
import '../../../data/models/community_post_response_dto.dart';
import '../../../data/services/community_api_service.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';

final communityPostsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, shopId) async {
  final api = ref.watch(communityApiServiceProvider);
  return api.getPosts(shopId);
});

class CommunityTab extends ConsumerStatefulWidget {
  const CommunityTab({super.key, required this.shopId, required this.canManage});

  final String shopId;
  final bool canManage;

  @override
  ConsumerState<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends ConsumerState<CommunityTab> {
  final _announcementController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  Future<void> _postAnnouncement() async {
    final body = _announcementController.text.trim();
    if (body.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      await ref.read(communityApiServiceProvider).createAnnouncement(widget.shopId, {'body': body});
      _announcementController.clear();
      ref.invalidate(communityPostsProvider(widget.shopId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: ${formatApiError(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _deletePost(CommunityPostResponseDto post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(communityApiServiceProvider).deletePost(widget.shopId, post.id);
      ref.invalidate(communityPostsProvider(widget.shopId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${formatApiError(e)}')),
        );
      }
    }
  }

  bool _canDeletePost(CommunityPostResponseDto post) {
    if (widget.canManage) return true;
    final userId = ref.read(authNotifierProvider).user?.id;
    return userId != null && post.authorId == userId;
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(communityPostsProvider(widget.shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(communityPostsProvider(widget.shopId)),
      ),
      data: (data) {
        final posts = (data['content'] as List<dynamic>?)
                ?.map((e) => CommunityPostResponseDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.canManage) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Post announcement', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _announcementController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Write an announcement for your community...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _isPosting ? null : _postAnnouncement,
                          child: _isPosting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Post'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (posts.isEmpty)
              const EmptyStateView(
                icon: Icons.forum_outlined,
                message: 'No posts yet.',
              )
            else
              ...posts.map((post) => _PostCard(
                    post: post,
                    canDelete: _canDeletePost(post),
                    onDelete: () => _deletePost(post),
                  )),
          ],
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.canDelete, required this.onDelete});

  final CommunityPostResponseDto post;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final author = post.author;
    final authorName = author?['name'] as String? ?? 'Unknown';

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
                  child: Text(authorName.isNotEmpty ? authorName[0].toUpperCase() : '?'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName, style: Theme.of(context).textTheme.titleSmall),
                      if (post.createdAt != null)
                        Text(post.createdAt!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (post.pinned) const Icon(Icons.push_pin, size: 18, color: Colors.orange),
                if (post.type == 'ANNOUNCEMENT')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Announcement', style: Theme.of(context).textTheme.labelSmall),
                  ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.body),
          ],
        ),
      ),
    );
  }
}
