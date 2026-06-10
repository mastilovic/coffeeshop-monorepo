import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_notifier.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/pagination_controls.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/shop_card.dart';
import 'shop_providers.dart';

class ShopListScreen extends ConsumerStatefulWidget {
  const ShopListScreen({super.key});

  @override
  ConsumerState<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends ConsumerState<ShopListScreen> {
  final _searchController = TextEditingController();
  int? _selectedCityIndex;

  bool get _canCreateShop {
    final authState = ref.read(authNotifierProvider);
    final userType = authState.user?.userType;
    return userType == 'shop_owner' || userType == 'admin';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopListAsync = ref.watch(shopListProvider);
    final citiesAsync = ref.watch(citiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shops'),
      ),
      floatingActionButton: _canCreateShop
          ? FloatingActionButton(
              onPressed: () => context.push('/shops/new'),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search shops...',
              onChanged: (String value) {
                ref.read(shopListParamsProvider.notifier).state =
                    ref.read(shopListParamsProvider).copyWith(query: value, page: 0);
              },
            ),
          ),
          citiesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (cities) {
              if (cities.isEmpty) return const SizedBox.shrink();
              final tabs = ['All', ...cities];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = index == (_selectedCityIndex ?? 0);
                      return ChoiceChip(
                        label: Text(tabs[index]),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCityIndex = index);
                          final params = ref.read(shopListParamsProvider);
                          ref.read(shopListParamsProvider.notifier).state =
                              params.copyWith(
                            city: index == 0 ? null : tabs[index],
                            page: 0,
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: shopListAsync.when(
              loading: () => const LoadingIndicator(message: 'Loading shops...'),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(shopListProvider),
              ),
              data: (result) {
                if (result.shops.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.store,
                    message: 'No shops found',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(shopListProvider);
                    await ref.read(shopListProvider.future);
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: result.shops.length,
                              itemBuilder: (context, index) {
                                final shop = result.shops[index];
                                return ShopCard(
                                  name: shop.name,
                                  city: shop.city,
                                  rating: shop.averageRating,
                                  reviewCount: shop.reviewCount,
                                  memberCount: shop.memberCount,
                                  isFavourite: shop.favouriteByCurrentUser,
                                  onTap: () => context.push('/shops/${shop.id}'),
                                  onFavouriteToggle: () {
                                    ref.invalidate(shopListProvider);
                                  },
                                );
                              },
                            ),
                          ),
                          PaginationControls(
                            currentPage: ref.read(shopListParamsProvider).page,
                            totalPages: result.totalPages,
                            onPageChanged: (page) {
                              final params = ref.read(shopListParamsProvider);
                              ref.read(shopListParamsProvider.notifier).state =
                                  params.copyWith(page: page);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
