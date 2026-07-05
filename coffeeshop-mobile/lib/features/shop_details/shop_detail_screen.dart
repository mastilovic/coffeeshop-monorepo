import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/user_permissions.dart';
import '../../data/models/shop_response_dto.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../shops/shop_providers.dart';
import 'tabs/community_tab.dart';
import 'tabs/employees_tab.dart';
import 'tabs/events_tab.dart';
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
      ref,
      canManageContent: permissions.canManageContent(shopId),
      canManageShop: permissions.canManageShop(shopId),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref, {
    required bool canManageContent,
    required bool canManageShop,
  }) {
    final tabs = <String>[
      'Community',
      'Menu',
      if (canManageContent) 'Tables',
      'Reservations',
      'Events',
      'Reviews',
      if (canManageShop) 'Employees',
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(shop.name),
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
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: TabBarView(
          children: [
            CommunityTab(shopId: shopId, canManage: canManageContent),
            MenuTab(shopId: shopId, menu: shop.currentMenu, canManage: canManageContent),
            if (canManageContent) TablesTab(shopId: shopId, tables: shop.tables, canManage: canManageContent),
            ReservationsTab(shopId: shopId, tables: shop.tables, canManage: canManageContent),
            EventsTab(shopId: shopId, events: shop.events, canManage: canManageContent),
            ReviewsTab(shopId: shopId),
            if (canManageShop) EmployeesTab(shopId: shopId),
          ],
        ),
      ),
    );
  }
}
