import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/auth_service.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/dashboard_activity_response.dart';
import '../../data/services/dashboard_api_service.dart';

final dashboardProvider = FutureProvider<DashboardActivityResponse>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (auth.status != AuthStatus.authenticated) {
    throw StateError('Dashboard requires authentication');
  }

  final apiService = ref.watch(dashboardApiServiceProvider);
  try {
    final data = await apiService.getActivity();
    return DashboardActivityResponse.fromJson(data);
  } on ApiException {
    rethrow;
  }
});
