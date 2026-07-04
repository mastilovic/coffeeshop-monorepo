import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/shop_api_service.dart';

/// Used for fetching owned shop data (needed for display, not just IDs).
final ownedShopsProvider = FutureProvider((ref) async {
  return ref.watch(shopApiServiceProvider).getMine();
});

