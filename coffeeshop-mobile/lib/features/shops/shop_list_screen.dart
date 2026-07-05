import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/user_permissions.dart';
import '../../core/utils/api_error.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/shop_api_service.dart';
import '../../shared/widgets/city_search_select.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/pagination_controls.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/shop_card.dart';
import '../dashboard/dashboard_provider.dart';
import '../shop_details/shop_manage_permission.dart';
import 'shop_providers.dart';

bool isShopFavourite(WidgetRef ref, String shopId) {
  final favourites = ref.watch(authNotifierProvider).user?.favouriteShops ?? [];
  return favourites.any((shop) => shop.id == shopId);
}

(List<ShopResponseDto> favourites, List<ShopResponseDto> others) splitShopsByFavourite(
  WidgetRef ref,
  List<ShopResponseDto> shops,
) {
  final favouriteShops = <ShopResponseDto>[];
  final otherShops = <ShopResponseDto>[];
  for (final shop in shops) {
    (isShopFavourite(ref, shop.id) ? favouriteShops : otherShops).add(shop);
  }
  return (favouriteShops, otherShops);
}

bool matchesShopFilters(ShopResponseDto shop, ShopListParams params) {
  final query = params.query.trim().toLowerCase();
  if (query.isNotEmpty) {
    final name = shop.name.toLowerCase();
    final city = shop.city.toLowerCase();
    if (!name.contains(query) && !city.contains(query)) {
      return false;
    }
  }
  final cityFilter = params.city;
  if (cityFilter != null && cityFilter.isNotEmpty && shop.city != cityFilter) {
    return false;
  }
  return true;
}

class ShopListScreen extends ConsumerStatefulWidget {
  const ShopListScreen({super.key});

  @override
  ConsumerState<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends ConsumerState<ShopListScreen> {
  final _searchController = TextEditingController();

  bool _canCreateShop(WidgetRef ref) {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;
    return permissions?.canCreateShop ?? false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavourite(ShopResponseDto shop) async {
    final api = ref.read(shopApiServiceProvider);
    final isFavourite = isShopFavourite(ref, shop.id);
    try {
      if (isFavourite) {
        await api.removeFavourite(shop.id);
      } else {
        await api.addFavourite(shop.id);
      }
      await ref.read(authNotifierProvider.notifier).refreshProfile();
      ref.invalidate(dashboardProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favourite: ${formatApiError(e)}')),
      );
    }
  }

  Future<void> _deleteShop(ShopResponseDto shop) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Shop',
      message: 'Are you sure you want to delete "${shop.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(shopApiServiceProvider).delete(shop.id);
      ref.invalidate(shopListProvider);
      ref.invalidate(ownedShopsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete shop: ${formatApiError(e)}')),
      );
    }
  }

  Widget _buildShopCard(ShopResponseDto shop, {required bool isOwned}) {
    final canManage = canManageShopInList(ref, shop.id);

    return ShopCard(
      name: shop.name,
      city: shop.city,
      rating: shop.averageRating,
      reviewCount: shop.reviewCount,
      memberCount: shop.memberCount,
      isOwned: isOwned,
      isFavourite: isShopFavourite(ref, shop.id),
      onTap: () => context.push('/shops/${shop.id}'),
      onFavouriteToggle: isOwned ? null : (canManage ? null : () => _toggleFavourite(shop)),
      onEmployees: canManage ? () => context.push('/shops/${shop.id}') : null,
      onDelete: canManage ? () => _deleteShop(shop) : null,
    );
  }

  SliverGrid _buildShopGrid({
    required List<ShopResponseDto> shops,
    required int crossAxisCount,
    required bool isOwned,
  }) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildShopCard(shops[index], isOwned: isOwned),
        childCount: shops.length,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopListAsync = ref.watch(shopListProvider);
    final params = ref.watch(shopListParamsProvider);
    ref.watch(ownedShopsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shops'),
      ),
      floatingActionButton: _canCreateShop(ref)
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
                ref.read(shopListParamsProvider.notifier).update(
                      (current) => current.copyWith(query: value, page: 0),
                    );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: CitySearchSelect(
              value: params.city,
              allowAll: true,
              hint: 'All cities',
              onChanged: (city) {
                ref.read(shopListParamsProvider.notifier).update(
                      (current) => current.copyWith(
                        city: city,
                        clearCity: city == null,
                        page: 0,
                      ),
                    );
              },
            ),
          ),
          Expanded(
            child: shopListAsync.when(
              loading: () => const LoadingIndicator(message: 'Loading shops...'),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(shopListProvider),
              ),
              data: (result) {
                final isShopOwner =
                    ref.watch(userPermissionsProvider).valueOrNull?.isShopOwner ??
                        false;
                final owned = isShopOwner
                    ? (ref.watch(ownedShopsProvider).valueOrNull ?? [])
                    : <ShopResponseDto>[];
                final ownedIds = owned.map((shop) => shop.id).toSet();
                final myShops =
                    owned.where((shop) => matchesShopFilters(shop, params)).toList();
                final otherShops = result.shops
                    .where((shop) => !ownedIds.contains(shop.id))
                    .where((shop) => matchesShopFilters(shop, params))
                    .toList();
                final (favouriteOtherShops, remainingOtherShops) =
                    splitShopsByFavourite(ref, otherShops);

                if (myShops.isEmpty &&
                    favouriteOtherShops.isEmpty &&
                    remainingOtherShops.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.store,
                    message: 'No shops found',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(shopListProvider);
                    ref.invalidate(ownedShopsProvider);
                    await ref.read(shopListProvider.future);
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return Column(
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              slivers: [
                                if (myShops.isNotEmpty) ...[
                                  SliverToBoxAdapter(
                                    child: _buildSectionTitle('My shops'),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                    sliver: _buildShopGrid(
                                      shops: myShops,
                                      crossAxisCount: crossAxisCount,
                                      isOwned: true,
                                    ),
                                  ),
                                ],
                                if (favouriteOtherShops.isNotEmpty) ...[
                                  SliverToBoxAdapter(
                                    child: _buildSectionTitle('Your communities'),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                    sliver: _buildShopGrid(
                                      shops: favouriteOtherShops,
                                      crossAxisCount: crossAxisCount,
                                      isOwned: false,
                                    ),
                                  ),
                                ],
                                if (remainingOtherShops.isNotEmpty) ...[
                                  SliverToBoxAdapter(
                                    child: _buildSectionTitle(
                                      favouriteOtherShops.isNotEmpty ? 'All shops' : 'Shops',
                                    ),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    sliver: _buildShopGrid(
                                      shops: remainingOtherShops,
                                      crossAxisCount: crossAxisCount,
                                      isOwned: false,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          PaginationControls(
                            currentPage: params.page,
                            totalPages: result.totalPages,
                            onPageChanged: (page) {
                              ref.read(shopListParamsProvider.notifier).update(
                                    (current) => current.copyWith(page: page),
                                  );
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
