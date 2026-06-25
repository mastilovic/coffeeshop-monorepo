import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/user_permissions.dart';
import '../../data/models/reservation_request_response_dto.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/reservation_api_service.dart';
import '../../data/services/reservation_request_api_service.dart';
import '../shop_details/shop_manage_permission.dart';

final myReservationRequestsProvider = FutureProvider<List<ReservationRequestResponseDto>>((ref) async {
  final api = ref.watch(reservationRequestApiServiceProvider);
  return api.getAll();
});

final myReservationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(reservationApiServiceProvider);
  final data = await api.getAll();
  return data.cast<Map<String, dynamic>>();
});

final ownerManagedShopsProvider = FutureProvider<List<ShopResponseDto>>((ref) async {
  return ref.watch(ownedShopsProvider.future);
});

final allOwnerReservationRequestsProvider = FutureProvider<List<ReservationRequestResponseDto>>((ref) async {
  final shops = await ref.watch(ownerManagedShopsProvider.future);
  if (shops.isEmpty) return [];

  final api = ref.watch(reservationRequestApiServiceProvider);
  final results = await Future.wait(shops.map((s) => api.getAll(shopId: s.id)));
  return results.expand((list) => list).toList();
});

final allOwnerReservationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final shops = await ref.watch(ownerManagedShopsProvider.future);
  if (shops.isEmpty) return [];

  final api = ref.watch(reservationApiServiceProvider);
  final results = await Future.wait(shops.map((s) => api.getAll(shopId: s.id)));
  return results.expand((list) => list.cast<Map<String, dynamic>>()).toList();
});

bool isShopOwner(WidgetRef ref) {
  final permissions = ref.watch(userPermissionsProvider).valueOrNull;
  return permissions?.isShopOwner ?? false;
}
