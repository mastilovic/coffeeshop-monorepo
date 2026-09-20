import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/user_permissions.dart';
import '../../data/models/shop_response_dto.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/loyalty_badge.dart';
import '../shops/shop_providers.dart';
import 'tabs/community_tab.dart';
import 'tabs/employees_tab.dart';
import 'tabs/events_tab.dart';
import 'tabs/loyalty_tab.dart';
import 'tabs/menu_tab.dart';
import 'tabs/reservations_tab.dart';
import 'tabs/reviews_tab.dart';
import 'tabs/tables_tab.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(userPermissionsProvider).valueOrNull;

    if (permissions == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    return _buildScaffold(
      context,
      permissions: permissions,
      canManageContent: permissions.canManageContent(shopId),
      canManageShop: permissions.canManageShop(shopId),
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required UserPermissions permissions,
    required bool canManageContent,
    required bool canManageShop,
  }) {
    final tabs = <({String label, Widget view})>[];

    if (canManageContent) {
      tabs.addAll([
        (
          label: 'Community',
          view: CommunityTab(shopId: shopId, canManage: canManageContent),
        ),
        (
          label: 'Menu',
          view: MenuTab(
            shopId: shopId,
            menu: shop.currentMenu,
            canManage: canManageContent,
          ),
        ),
        (
          label: 'Tables',
          view: TablesTab(
            shopId: shopId,
            tables: shop.tables,
            canManage: canManageContent,
          ),
        ),
        (
          label: 'Reservations',
          view: ReservationsTab(
            shopId: shopId,
            tables: shop.tables,
            canManage: canManageContent,
          ),
        ),
        (
          label: 'Events',
          view: EventsTab(
            shopId: shopId,
            events: shop.events,
            canManage: canManageContent,
          ),
        ),
        (label: 'Reviews', view: ReviewsTab(shopId: shopId)),
      ]);
      if (canManageShop) {
        tabs.add((label: 'Employees', view: EmployeesTab(shopId: shopId)));
      }
      if (permissions.showLoyaltyTab) {
        tabs.add((
          label: 'Loyalty',
          view: LoyaltyTab(shopId: shopId, loyaltyPlan: shop.loyaltyPlan),
        ));
      }
    } else {
      // Customer: Menu first, then Events, Community, Reviews, Reservations.
      tabs.addAll([
        (
          label: 'Menu',
          view: MenuTab(
            shopId: shopId,
            menu: shop.currentMenu,
            canManage: false,
          ),
        ),
        (
          label: 'Events',
          view: EventsTab(
            shopId: shopId,
            events: shop.events,
            canManage: false,
          ),
        ),
        (
          label: 'Community',
          view: CommunityTab(shopId: shopId, canManage: false),
        ),
        (label: 'Reviews', view: ReviewsTab(shopId: shopId)),
        (
          label: 'Reservations',
          view: ReservationsTab(
            shopId: shopId,
            tables: shop.tables,
            canManage: false,
          ),
        ),
      ]);
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shop.name),
              if (loyaltyPlanType(shop.loyaltyPlan) != null) ...[
                const SizedBox(height: 4),
                LoyaltyBadge(planType: loyaltyPlanType(shop.loyaltyPlan)!),
              ],
            ],
          ),
          actions: [
            if (canManageShop)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit shop',
                onPressed: () => context.push('/shops/$shopId/edit'),
              ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((t) => t.view).toList(),
        ),
      ),
    );
  }
}
