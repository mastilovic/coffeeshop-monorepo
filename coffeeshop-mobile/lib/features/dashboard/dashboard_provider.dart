import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/dashboard_activity_response.dart';
import '../../data/services/dashboard_api_service.dart';

final dashboardProvider = FutureProvider<DashboardActivityResponse>((ref) async {
  final apiService = ref.watch(dashboardApiServiceProvider);
  try {
    final data = await apiService.getActivity();
    return DashboardActivityResponse.fromJson(data);
  } on ApiException {
    rethrow;
  }
});
