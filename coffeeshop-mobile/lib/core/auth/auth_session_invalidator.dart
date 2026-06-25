import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/dashboard_provider.dart';
import 'auth_notifier.dart';
import 'auth_service.dart';

final authSessionInvalidatorProvider = Provider<void>((ref) {
  ref.listen(authNotifierProvider, (previous, next) {
    if (previous?.status == next.status) return;

    if (next.status == AuthStatus.authenticated ||
        next.status == AuthStatus.unauthenticated) {
      ref.invalidate(dashboardProvider);
    }
  });
});
