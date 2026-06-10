import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../data/models/community_post_response_dto.dart';
import '../../data/models/event_response_dto.dart';
import '../../data/models/review_response_dto.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/community_api_service.dart';
import '../../data/services/event_api_service.dart';
import '../../data/services/review_api_service.dart';
import '../../data/services/shop_employee_api_service.dart';
import '../../data/services/table_api_service.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/star_rating.dart';
import '../shops/shop_providers.dart';

class ShopDetailScreen extends ConsumerWidget {
  const ShopDetailScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopDetailProvider(shopId));

    return shopAsync.when(
      loading: () => const Scaffold(
        body: LoadingIndicator(message: 'Loading shop...'),
      ),
      error: (error, _) => Scaffold(
        body: ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(shopDetailProvider(shopId)),
        ),
      ),
      data: (shop) => _ShopDetailContent(shop: shop, shopId: shopId),
    );
  }
}

class _ShopDetailContent extends ConsumerWidget {
  const _ShopDetailContent({required this.shop, required this.shopId});

  final ShopResponseDto shop;
  final String shopId;

  bool _canManage(WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    final userType = authState.user?.userType;
    return userType == 'shop_owner' || userType == 'admin';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = _canManage(ref);

    final tabs = <String>[
      'Community',
      'Menu',
      if (canManage) 'Tables',
      'Reservations',
      'Events',
      'Reviews',
      if (canManage) 'Employees',
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(shop.name),
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: TabBarView(
          children: [
            _CommunityTab(shopId: shopId, canManage: canManage),
            _MenuTab(shopId: shopId, menu: shop.currentMenu),
            if (canManage) _TablesTab(shopId: shopId),
            _ReservationsTab(shopId: shopId),
            _EventsTab(shopId: shopId),
            _ReviewsTab(shopId: shopId),
            if (canManage) _EmployeesTab(shopId: shopId),
          ],
        ),
      ),
    );
  }
}

// ── Community Tab ──

class _CommunityTab extends ConsumerStatefulWidget {
  const _CommunityTab({required this.shopId, required this.canManage});

  final String shopId;
  final bool canManage;

  @override
  ConsumerState<_CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends ConsumerState<_CommunityTab> {
  @override
  Widget build(BuildContext context) {
    final communityProvider = FutureProvider<Map<String, dynamic>>((ref) async {
      final api = ref.watch(communityApiServiceProvider);
      final posts = await api.getPosts(widget.shopId);
      return posts;
    });

    final asyncData = ref.watch(communityProvider);

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(communityProvider)),
      data: (data) {
        final posts = (data['content'] as List<dynamic>?)
                ?.map((e) => CommunityPostResponseDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
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
                          child: Text(
                            (authorName.isNotEmpty ? authorName[0].toUpperCase() : '?'),
                          ),
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
                        if (post.pinned)
                          const Icon(Icons.push_pin, size: 18, color: Colors.orange),
                        if (post.type == 'ANNOUNCEMENT')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Announcement', style: Theme.of(context).textTheme.labelSmall),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(post.body),
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

// ── Menu Tab ──

class _MenuTab extends ConsumerWidget {
  const _MenuTab({required this.shopId, this.menu});

  final String shopId;
  final Map<String, dynamic>? menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (menu == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No menu available', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    final items = (menu!['items'] as List<dynamic>?) ?? [];

    if (items.isEmpty) {
      return const Center(child: Text('No items in menu'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index] as Map<String, dynamic>;
        final type = item['type'] as String? ?? 'Other';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_iconForType(type), color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] as String? ?? '', style: Theme.of(context).textTheme.titleSmall),
                      if (item['description'] != null) ...[
                        const SizedBox(height: 4),
                        Text(item['description'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item['price'] != null)
                      Text('\$${item['price']}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              )),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(type, style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'drinks':
        return Icons.local_drink;
      case 'desserts':
        return Icons.cake;
      default:
        return Icons.fastfood;
    }
  }
}

// ── Tables Tab ──

final _tablesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, shopId) async {
  final api = ref.watch(tableApiServiceProvider);
  final data = await api.getAll();
  return data.cast<Map<String, dynamic>>();
});

class _TablesTab extends ConsumerWidget {
  const _TablesTab({required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_tablesProvider(shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(_tablesProvider(shopId))),
      data: (tables) {
        if (tables.isEmpty) {
          return const Center(child: Text('No tables configured'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.table_bar, size: 32, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('Table ${table['number'] ?? '?'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Capacity: ${table['capacity'] ?? '?'}',
                        style: Theme.of(context).textTheme.bodySmall),
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

// ── Reservations Tab ──

class _ReservationsTab extends ConsumerWidget {
  const _ReservationsTab({required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_seat, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Reservations - coming soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Events Tab ──

final _shopEventsProvider = FutureProvider.family<List<EventResponseDto>, String>((ref, shopId) async {
  final api = ref.watch(eventApiServiceProvider);
  final data = await api.getAll(shopId: shopId);
  if (data is Map<String, dynamic>) {
    final content = (data['content'] as List<dynamic>?)
            ?.map((e) => EventResponseDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return content;
  }
  return [];
});

class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_shopEventsProvider(shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(_shopEventsProvider(shopId))),
      data: (events) {
        if (events.isEmpty) {
          return const Center(child: Text('No events scheduled'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.event, color: Colors.orange),
                title: Text(event.eventName),
                subtitle: Text(event.eventDate),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Reviews Tab ──

final _shopReviewsProvider = FutureProvider.family<List<ReviewResponseDto>, String>((ref, shopId) async {
  final api = ref.watch(reviewApiServiceProvider);
  final data = await api.getAll();
  return data.map((e) => ReviewResponseDto.fromJson(e as Map<String, dynamic>)).toList();
});

class _ReviewsTab extends ConsumerWidget {
  const _ReviewsTab({required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_shopReviewsProvider(shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(_shopReviewsProvider(shopId))),
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
                      Text(review.title!, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
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

// ── Employees Tab ──

final _shopEmployeesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, shopId) async {
  final api = ref.watch(shopEmployeeApiServiceProvider);
  final data = await api.getEmployees(shopId);
  return data.cast<Map<String, dynamic>>();
});

class _EmployeesTab extends ConsumerWidget {
  const _EmployeesTab({required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_shopEmployeesProvider(shopId));

    return asyncData.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(_shopEmployeesProvider(shopId))),
      data: (employees) {
        if (employees.isEmpty) {
          return const Center(child: Text('No employees assigned'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final emp = employees[index];
            final name = emp['name'] as String? ?? 'Unknown';
            final email = emp['email'] as String? ?? '';
            final roleName = emp['role_name'] as String? ?? 'Employee';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                title: Text(name),
                subtitle: Text(email),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(roleName, style: Theme.of(context).textTheme.labelSmall),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
