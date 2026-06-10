import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/event_response_dto.dart';
import '../../data/services/event_api_service.dart';

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

final eventFilterProvider = StateProvider<EventFilter>((ref) {
  return const EventFilter();
});

final eventListProvider = FutureProvider<List<EventResponseDto>>((ref) async {
  final filter = ref.watch(eventFilterProvider);
  final apiService = ref.watch(eventApiServiceProvider);

  String? dateFrom;
  String? dateTo;

  if (filter.filter == EventTimeFilter.today) {
    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, now.day).toIso8601String();
    dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
  }

  final data = await apiService.getAll(
    q: filter.query.isEmpty ? null : filter.query,
    dateFrom: filter.dateFrom ?? dateFrom,
    dateTo: filter.dateTo ?? dateTo,
    page: filter.page,
  );

  if (data is Map<String, dynamic>) {
    return (data['content'] as List<dynamic>?)
            ?.map((e) => EventResponseDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }
  if (data is List) {
    return data.map((e) => EventResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
});

final eventDetailProvider = FutureProvider.family<EventResponseDto, String>((ref, id) async {
  final apiService = ref.watch(eventApiServiceProvider);
  return apiService.getById(id);
});
