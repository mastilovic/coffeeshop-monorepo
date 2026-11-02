// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_activity_response.freezed.dart';
part 'dashboard_activity_response.g.dart';

@freezed
class DashboardActivityResponse with _$DashboardActivityResponse {
  const factory DashboardActivityResponse({
    required DashboardAggregate aggregate,
    @Default([]) List<DashboardActivityItem> activities,
    @Default([]) List<TopShopItem> topShops,
    @Default([]) List<UpcomingEventItem> upcomingEvents,
    DashboardPersonalSummary? personalSummary,
    @Default([]) List<DashboardNotification> notifications,
  }) = _DashboardActivityResponse;

  factory DashboardActivityResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardActivityResponseFromJson(json);
}

@freezed
class DashboardActivityItem with _$DashboardActivityItem {
  const factory DashboardActivityItem({
    required String type,
    String? timestamp,
    String? shopId,
    String? shopName,
    String? title,
    String? body,
    String? actorName,
    double? rating,
  }) = _DashboardActivityItem;

  factory DashboardActivityItem.fromJson(Map<String, dynamic> json) =>
      _$DashboardActivityItemFromJson(json);
}

@freezed
class DashboardAggregate with _$DashboardAggregate {
  const factory DashboardAggregate({
    @Default(0) int shopCount,
    @Default(0) int reviewCount,
    double? averageRating,
    @Default(0) int eventCount,
    @Default(0) int memberCount,
  }) = _DashboardAggregate;

  factory DashboardAggregate.fromJson(Map<String, dynamic> json) =>
      _$DashboardAggregateFromJson(json);
}

@freezed
class TopShopItem with _$TopShopItem {
  const factory TopShopItem({
    required String shopId,
    required String shopName,
    String? city,
    double? averageRating,
    @Default(0) int reviewCount,
  }) = _TopShopItem;

  factory TopShopItem.fromJson(Map<String, dynamic> json) =>
      _$TopShopItemFromJson(json);
}

@freezed
class UpcomingEventItem with _$UpcomingEventItem {
  const factory UpcomingEventItem({
    required String eventId,
    required String eventName,
    String? eventDate,
    String? shopId,
    String? shopName,
  }) = _UpcomingEventItem;

  factory UpcomingEventItem.fromJson(Map<String, dynamic> json) =>
      _$UpcomingEventItemFromJson(json);
}

@freezed
class DashboardPersonalSummary with _$DashboardPersonalSummary {
  const factory DashboardPersonalSummary({
    @Default(0) int favouriteShops,
    @Default(0) int reservations,
    @Default(0) int reviewsWritten,
  }) = _DashboardPersonalSummary;

  factory DashboardPersonalSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardPersonalSummaryFromJson(json);
}

@freezed
class DashboardNotification with _$DashboardNotification {
  const factory DashboardNotification({
    required String type,
    required String message,
    @Default(0) int count,
    String? link,
  }) = _DashboardNotification;

  factory DashboardNotification.fromJson(Map<String, dynamic> json) =>
      _$DashboardNotificationFromJson(json);
}
