import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/dashboard_provider.dart';
import '../../features/shop_details/shop_manage_permission.dart';
import '../../features/shops/shop_providers.dart';
import 'auth_notifier.dart';
import 'auth_service.dart';
import 'user_permissions.dart';

final authSessionInvalidatorProvider = Provider<void>((ref) {
  ref.listen(authNotifierProvider, (previous, next) {
    if (previous?.status == next.status) return;

    if (next.status == AuthStatus.authenticated ||
        next.status == AuthStatus.unauthenticated) {
      ref.invalidate(dashboardProvider);
      ref.invalidate(ownedShopsProvider);
      ref.invalidate(userPermissionsProvider);
      ref.invalidate(shopListProvider);
    }
  });
});
