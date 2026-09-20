// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_analytics_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardAnalyticsResponseImpl _$$DashboardAnalyticsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardAnalyticsResponseImpl(
  aggregate: DashboardAnalyticsAggregate.fromJson(
    json['aggregate'] as Map<String, dynamic>,
  ),
  shops:
      (json['shops'] as List<dynamic>?)
          ?.map(
            (e) => DashboardShopAnalytics.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$DashboardAnalyticsResponseImplToJson(
  _$DashboardAnalyticsResponseImpl instance,
) => <String, dynamic>{
  'aggregate': instance.aggregate,
  'shops': instance.shops,
};

_$DashboardAnalyticsAggregateImpl _$$DashboardAnalyticsAggregateImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardAnalyticsAggregateImpl(
  shopCount: (json['shopCount'] as num?)?.toInt() ?? 0,
  reservationCount: (json['reservationCount'] as num?)?.toInt() ?? 0,
  pendingReservationRequestCount:
      (json['pendingReservationRequestCount'] as num?)?.toInt() ?? 0,
  eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  communityPostCount: (json['communityPostCount'] as num?)?.toInt() ?? 0,
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  employeeCount: (json['employeeCount'] as num?)?.toInt() ?? 0,
  tableCount: (json['tableCount'] as num?)?.toInt() ?? 0,
  menuCount: (json['menuCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DashboardAnalyticsAggregateImplToJson(
  _$DashboardAnalyticsAggregateImpl instance,
) => <String, dynamic>{
  'shopCount': instance.shopCount,
  'reservationCount': instance.reservationCount,
  'pendingReservationRequestCount': instance.pendingReservationRequestCount,
  'eventCount': instance.eventCount,
  'reviewCount': instance.reviewCount,
  'averageRating': instance.averageRating,
  'communityPostCount': instance.communityPostCount,
  'memberCount': instance.memberCount,
  'employeeCount': instance.employeeCount,
  'tableCount': instance.tableCount,
  'menuCount': instance.menuCount,
};

_$DashboardShopAnalyticsImpl _$$DashboardShopAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardShopAnalyticsImpl(
  shopId: json['shopId'] as String,
  shopName: json['shopName'] as String,
  city: json['city'] as String?,
  reservationCount: (json['reservationCount'] as num?)?.toInt() ?? 0,
  pendingReservationRequestCount:
      (json['pendingReservationRequestCount'] as num?)?.toInt() ?? 0,
  eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  communityPostCount: (json['communityPostCount'] as num?)?.toInt() ?? 0,
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  employeeCount: (json['employeeCount'] as num?)?.toInt() ?? 0,
  tableCount: (json['tableCount'] as num?)?.toInt() ?? 0,
  menuCount: (json['menuCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DashboardShopAnalyticsImplToJson(
  _$DashboardShopAnalyticsImpl instance,
) => <String, dynamic>{
  'shopId': instance.shopId,
  'shopName': instance.shopName,
  'city': instance.city,
  'reservationCount': instance.reservationCount,
  'pendingReservationRequestCount': instance.pendingReservationRequestCount,
  'eventCount': instance.eventCount,
  'reviewCount': instance.reviewCount,
  'averageRating': instance.averageRating,
  'communityPostCount': instance.communityPostCount,
  'memberCount': instance.memberCount,
  'employeeCount': instance.employeeCount,
  'tableCount': instance.tableCount,
  'menuCount': instance.menuCount,
};
