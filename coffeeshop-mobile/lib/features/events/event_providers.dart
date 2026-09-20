import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/user_permissions.dart';
import '../../core/auth/auth_notifier.dart';
import '../../data/models/event_response_dto.dart';
import '../../data/models/shop_response_dto.dart';
import '../../data/services/event_api_service.dart';
import '../../data/services/shop_api_service.dart';

class EventFilter {
  const EventFilter({
    this.query = '',
    this.filter = EventTimeFilter.all,
    this.dateFrom,
    this.dateTo,
    this.page = 0,
  });

  final String query;
  final EventTimeFilter filter;
  final String? dateFrom;
  final String? dateTo;
  final int page;

  static const pageSize = 20;

  EventFilter copyWith({
    String? query,
    EventTimeFilter? filter,
    String? dateFrom,
    bool clearDateFrom = false,
    String? dateTo,
    bool clearDateTo = false,
    int? page,
  }) {
    return EventFilter(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      dateFrom: clearDateFrom ? null : dateFrom ?? this.dateFrom,
      dateTo: clearDateTo ? null : dateTo ?? this.dateTo,
      page: page ?? this.page,
    );
  }
}

enum EventTimeFilter { all, today, thisWeek, thisMonth }

class EventListResult {
  const EventListResult({
    required this.events,
    required this.totalPages,
    required this.totalElements,
  });

  final List<EventResponseDto> events;
  final int totalPages;
  final int totalElements;
}

/// Formats a calendar day as `yyyy-MM-dd` for the events API.
String eventApiDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Resolves dateFrom/dateTo for the time-filter chips.
({String? dateFrom, String? dateTo}) eventFilterDateRange(EventTimeFilter filter) {
  final now = DateTime.now();
  switch (filter) {
    case EventTimeFilter.all:
      return (dateFrom: null, dateTo: null);
    case EventTimeFilter.today:
      final day = eventApiDate(now);
      return (dateFrom: day, dateTo: day);
    case EventTimeFilter.thisWeek:
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return (
        dateFrom: eventApiDate(startOfWeek),
        dateTo: eventApiDate(endOfWeek),
      );
    case EventTimeFilter.thisMonth:
      return (
        dateFrom: eventApiDate(DateTime(now.year, now.month, 1)),
        dateTo: eventApiDate(DateTime(now.year, now.month + 1, 0)),
      );
  }
}

final eventFilterProvider = StateProvider<EventFilter>((ref) {
  return const EventFilter();
});

final eventListProvider = FutureProvider.autoDispose<EventListResult>((ref) async {
  final filter = ref.watch(eventFilterProvider);
  final apiService = ref.watch(eventApiServiceProvider);
  final range = eventFilterDateRange(filter.filter);

  final data = await apiService.getAll(
    q: filter.query.isEmpty ? null : filter.query,
    dateFrom: filter.dateFrom ?? range.dateFrom,
    dateTo: filter.dateTo ?? range.dateTo,
    page: filter.page,
    size: EventFilter.pageSize,
  );

  if (data is Map<String, dynamic>) {
    final events = (data['content'] as List<dynamic>?)
            ?.map((e) => EventResponseDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return EventListResult(
      events: events,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (data['totalElements'] as num?)?.toInt() ?? 0,
    );
  }
  if (data is List) {
    final events =
        data.map((e) => EventResponseDto.fromJson(e as Map<String, dynamic>)).toList();
    return EventListResult(
      events: events,
      totalPages: events.isEmpty ? 0 : 1,
      totalElements: events.length,
    );
  }
  return const EventListResult(events: [], totalPages: 0, totalElements: 0);
});

final eventDetailProvider = FutureProvider.family<EventResponseDto, String>((ref, id) async {
  final apiService = ref.watch(eventApiServiceProvider);
  return apiService.getById(id);
});

/// Shops the current user can assign when creating an event.
/// Admins see all shops; shop owners see only shops they own.
final eventCreatableShopsProvider = FutureProvider<List<ShopResponseDto>>((ref) async {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return [];

  final api = ref.watch(shopApiServiceProvider);
  final permissions = ref.watch(userPermissionsProvider).valueOrNull;
  if (permissions == null) return [];

  if (permissions.isAdmin) {
    return api.getAllShops();
  }

  if (permissions.isShopOwner) {
    return api.getMine();
  }

  return [];
});
