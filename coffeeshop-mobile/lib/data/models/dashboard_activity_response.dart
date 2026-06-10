// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_activity_response.freezed.dart';
part 'dashboard_activity_response.g.dart';

@freezed
class DashboardActivityResponse with _$DashboardActivityResponse {
  const factory DashboardActivityResponse({
    required DashboardAggregate aggregate,
    @Default([]) List<DashboardActivityItem> activities,
    @JsonKey(name: 'top_shops') @Default([]) List<TopShopItem> topShops,
    @JsonKey(name: 'upcoming_events') @Default([]) List<UpcomingEventItem> upcomingEvents,
    @JsonKey(name: 'personal_summary') DashboardPersonalSummary? personalSummary,
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
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'shop_name') String? shopName,
    String? title,
    String? body,
    @JsonKey(name: 'actor_name') String? actorName,
    double? rating,
  }) = _DashboardActivityItem;

  factory DashboardActivityItem.fromJson(Map<String, dynamic> json) =>
      _$DashboardActivityItemFromJson(json);
}

@freezed
class DashboardAggregate with _$DashboardAggregate {
  const factory DashboardAggregate({
    @JsonKey(name: 'shop_count') @Default(0) int shopCount,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'event_count') @Default(0) int eventCount,
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
  }) = _DashboardAggregate;

  factory DashboardAggregate.fromJson(Map<String, dynamic> json) =>
      _$DashboardAggregateFromJson(json);
}

@freezed
class TopShopItem with _$TopShopItem {
  const factory TopShopItem({
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'shop_name') required String shopName,
    String? city,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
  }) = _TopShopItem;

  factory TopShopItem.fromJson(Map<String, dynamic> json) =>
      _$TopShopItemFromJson(json);
}

@freezed
class UpcomingEventItem with _$UpcomingEventItem {
  const factory UpcomingEventItem({
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'event_name') required String eventName,
    @JsonKey(name: 'event_date') String? eventDate,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'shop_name') String? shopName,
  }) = _UpcomingEventItem;

  factory UpcomingEventItem.fromJson(Map<String, dynamic> json) =>
      _$UpcomingEventItemFromJson(json);
}

@freezed
class DashboardPersonalSummary with _$DashboardPersonalSummary {
  const factory DashboardPersonalSummary({
    @JsonKey(name: 'favourite_shops') @Default(0) int favouriteShops,
    @Default(0) int reservations,
    @JsonKey(name: 'reviews_written') @Default(0) int reviewsWritten,
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
