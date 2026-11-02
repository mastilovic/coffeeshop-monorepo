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
import 'tabs/overview_tab.dart';
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

    final canManageContent = permissions.canManageContent(shopId);
    final canManageShop = permissions.canManageShop(shopId);
    final tabSpecs = _tabSpecs(
      permissions: permissions,
      canManageContent: canManageContent,
    );

    return _ShopDetailTabs(
      shop: shop,
      shopId: shopId,
      canManageShop: canManageShop,
      canManageContent: canManageContent,
      tabSpecs: tabSpecs,
    );
  }

  List<({String key, String label})> _tabSpecs({
    required UserPermissions permissions,
    required bool canManageContent,
  }) {
    if (canManageContent) {
      return [
        (key: 'overview', label: 'Overview'),
        (key: 'community', label: 'Community'),
        (key: 'menu', label: 'Menu'),
        (key: 'tables', label: 'Tables'),
        (key: 'reservations', label: 'Reservations'),
        (key: 'events', label: 'Events'),
        (key: 'reviews', label: 'Reviews'),
        if (permissions.canManageShop(shopId))
          (key: 'employees', label: 'Employees'),
        if (permissions.showLoyaltyTab) (key: 'loyalty', label: 'Loyalty'),
      ];
    }

    return [
      (key: 'overview', label: 'Overview'),
      (key: 'menu', label: 'Menu'),
      (key: 'events', label: 'Events'),
      (key: 'community', label: 'Community'),
      (key: 'reviews', label: 'Reviews'),
      (key: 'reservations', label: 'Reservations'),
    ];
  }
}

class _ShopDetailTabs extends StatefulWidget {
  const _ShopDetailTabs({
    required this.shop,
    required this.shopId,
    required this.canManageShop,
    required this.canManageContent,
    required this.tabSpecs,
  });

  final ShopResponseDto shop;
  final String shopId;
  final bool canManageShop;
  final bool canManageContent;
  final List<({String key, String label})> tabSpecs;

  @override
  State<_ShopDetailTabs> createState() => _ShopDetailTabsState();
}

class _ShopDetailTabsState extends State<_ShopDetailTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabSpecs.length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant _ShopDetailTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabSpecs.length != widget.tabSpecs.length) {
      final previousIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(
        length: widget.tabSpecs.length,
        vsync: this,
        initialIndex: previousIndex.clamp(0, widget.tabSpecs.length - 1),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int? _indexOf(String key) {
    final index = widget.tabSpecs.indexWhere((t) => t.key == key);
    return index >= 0 ? index : null;
  }

  void _goToTab(String key) {
    final index = _indexOf(key);
    if (index == null) return;
    _tabController.animateTo(index);
  }

  Widget _viewFor(String key) {
    final shop = widget.shop;
    final shopId = widget.shopId;
    final canManage = widget.canManageContent;

    switch (key) {
      case 'overview':
        return OverviewTab(
          shop: shop,
          canManageShop: widget.canManageShop,
          onSeeMenu: () => _goToTab('menu'),
          onSeeEvents: () => _goToTab('events'),
          onSeeReviews: () => _goToTab('reviews'),
        );
      case 'community':
        return CommunityTab(shopId: shopId, canManage: canManage);
      case 'menu':
        return MenuTab(
          shopId: shopId,
          menu: shop.currentMenu,
          canManage: canManage,
        );
      case 'tables':
        return TablesTab(
          shopId: shopId,
          tables: shop.tables,
          canManage: canManage,
        );
      case 'reservations':
        return ReservationsTab(
          shopId: shopId,
          tables: shop.tables,
          canManage: canManage,
        );
      case 'events':
        return EventsTab(
          shopId: shopId,
          events: shop.events,
          canManage: canManage,
        );
      case 'reviews':
        return ReviewsTab(shopId: shopId);
      case 'employees':
        return EmployeesTab(shopId: shopId);
      case 'loyalty':
        return LoyaltyTab(shopId: shopId, loyaltyPlan: shop.loyaltyPlan);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return Scaffold(
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
          if (widget.canManageShop)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit shop',
              onPressed: () => context.push('/shops/${widget.shopId}/edit'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: widget.tabSpecs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.tabSpecs.map((t) => _viewFor(t.key)).toList(),
      ),
    );
  }
}
