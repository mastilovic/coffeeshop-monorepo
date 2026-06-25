// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_activity_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardActivityResponseImpl _$$DashboardActivityResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardActivityResponseImpl(
  aggregate: DashboardAggregate.fromJson(
    json['aggregate'] as Map<String, dynamic>,
  ),
  activities:
      (json['activities'] as List<dynamic>?)
          ?.map(
            (e) => DashboardActivityItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  topShops:
      (json['topShops'] as List<dynamic>?)
          ?.map((e) => TopShopItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  upcomingEvents:
      (json['upcomingEvents'] as List<dynamic>?)
          ?.map((e) => UpcomingEventItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  personalSummary: json['personalSummary'] == null
      ? null
      : DashboardPersonalSummary.fromJson(
          json['personalSummary'] as Map<String, dynamic>,
        ),
  notifications:
      (json['notifications'] as List<dynamic>?)
          ?.map(
            (e) => DashboardNotification.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$DashboardActivityResponseImplToJson(
  _$DashboardActivityResponseImpl instance,
) => <String, dynamic>{
  'aggregate': instance.aggregate,
  'activities': instance.activities,
  'topShops': instance.topShops,
  'upcomingEvents': instance.upcomingEvents,
  'personalSummary': instance.personalSummary,
  'notifications': instance.notifications,
};

_$DashboardActivityItemImpl _$$DashboardActivityItemImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardActivityItemImpl(
  type: json['type'] as String,
  timestamp: json['timestamp'] as String?,
  shopId: json['shopId'] as String?,
  shopName: json['shopName'] as String?,
  title: json['title'] as String?,
  body: json['body'] as String?,
  actorName: json['actorName'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$DashboardActivityItemImplToJson(
  _$DashboardActivityItemImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'timestamp': instance.timestamp,
  'shopId': instance.shopId,
  'shopName': instance.shopName,
  'title': instance.title,
  'body': instance.body,
  'actorName': instance.actorName,
  'rating': instance.rating,
};

_$DashboardAggregateImpl _$$DashboardAggregateImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardAggregateImpl(
  shopCount: (json['shopCount'] as num?)?.toInt() ?? 0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DashboardAggregateImplToJson(
  _$DashboardAggregateImpl instance,
) => <String, dynamic>{
  'shopCount': instance.shopCount,
  'reviewCount': instance.reviewCount,
  'averageRating': instance.averageRating,
  'eventCount': instance.eventCount,
  'memberCount': instance.memberCount,
};

_$TopShopItemImpl _$$TopShopItemImplFromJson(Map<String, dynamic> json) =>
    _$TopShopItemImpl(
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String,
      city: json['city'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TopShopItemImplToJson(_$TopShopItemImpl instance) =>
    <String, dynamic>{
      'shopId': instance.shopId,
      'shopName': instance.shopName,
      'city': instance.city,
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
    };

_$UpcomingEventItemImpl _$$UpcomingEventItemImplFromJson(
  Map<String, dynamic> json,
) => _$UpcomingEventItemImpl(
  eventId: json['eventId'] as String,
  eventName: json['eventName'] as String,
  eventDate: json['eventDate'] as String?,
  shopId: json['shopId'] as String?,
  shopName: json['shopName'] as String?,
);

Map<String, dynamic> _$$UpcomingEventItemImplToJson(
  _$UpcomingEventItemImpl instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'eventName': instance.eventName,
  'eventDate': instance.eventDate,
  'shopId': instance.shopId,
  'shopName': instance.shopName,
};

_$DashboardPersonalSummaryImpl _$$DashboardPersonalSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardPersonalSummaryImpl(
  favouriteShops: (json['favouriteShops'] as num?)?.toInt() ?? 0,
  reservations: (json['reservations'] as num?)?.toInt() ?? 0,
  reviewsWritten: (json['reviewsWritten'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DashboardPersonalSummaryImplToJson(
  _$DashboardPersonalSummaryImpl instance,
) => <String, dynamic>{
  'favouriteShops': instance.favouriteShops,
  'reservations': instance.reservations,
  'reviewsWritten': instance.reviewsWritten,
};

_$DashboardNotificationImpl _$$DashboardNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardNotificationImpl(
  type: json['type'] as String,
  message: json['message'] as String,
  count: (json['count'] as num?)?.toInt() ?? 0,
  link: json['link'] as String?,
);

Map<String, dynamic> _$$DashboardNotificationImplToJson(
  _$DashboardNotificationImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'message': instance.message,
  'count': instance.count,
  'link': instance.link,
};
