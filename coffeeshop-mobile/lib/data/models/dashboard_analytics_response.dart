// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_analytics_response.freezed.dart';
part 'dashboard_analytics_response.g.dart';

@freezed
class DashboardAnalyticsResponse with _$DashboardAnalyticsResponse {
  const factory DashboardAnalyticsResponse({
    required DashboardAnalyticsAggregate aggregate,
    @Default([]) List<DashboardShopAnalytics> shops,
  }) = _DashboardAnalyticsResponse;

  factory DashboardAnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardAnalyticsResponseFromJson(json);
}

@freezed
class DashboardAnalyticsAggregate with _$DashboardAnalyticsAggregate {
  const factory DashboardAnalyticsAggregate({
    @Default(0) int shopCount,
    @Default(0) int reservationCount,
    @Default(0) int pendingReservationRequestCount,
    @Default(0) int eventCount,
    @Default(0) int reviewCount,
    double? averageRating,
    @Default(0) int communityPostCount,
    @Default(0) int memberCount,
    @Default(0) int employeeCount,
    @Default(0) int tableCount,
    @Default(0) int menuCount,
  }) = _DashboardAnalyticsAggregate;

  factory DashboardAnalyticsAggregate.fromJson(Map<String, dynamic> json) =>
      _$DashboardAnalyticsAggregateFromJson(json);
}

@freezed
class DashboardShopAnalytics with _$DashboardShopAnalytics {
  const factory DashboardShopAnalytics({
    required String shopId,
    required String shopName,
    String? city,
    @Default(0) int reservationCount,
    @Default(0) int pendingReservationRequestCount,
    @Default(0) int eventCount,
    @Default(0) int reviewCount,
    double? averageRating,
    @Default(0) int communityPostCount,
    @Default(0) int memberCount,
    @Default(0) int employeeCount,
    @Default(0) int tableCount,
    @Default(0) int menuCount,
  }) = _DashboardShopAnalytics;

  factory DashboardShopAnalytics.fromJson(Map<String, dynamic> json) =>
      _$DashboardShopAnalyticsFromJson(json);
}
