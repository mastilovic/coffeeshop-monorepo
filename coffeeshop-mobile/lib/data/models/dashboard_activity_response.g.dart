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
      (json['top_shops'] as List<dynamic>?)
          ?.map((e) => TopShopItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  upcomingEvents:
      (json['upcoming_events'] as List<dynamic>?)
          ?.map((e) => UpcomingEventItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  personalSummary: json['personal_summary'] == null
      ? null
      : DashboardPersonalSummary.fromJson(
          json['personal_summary'] as Map<String, dynamic>,
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
  'top_shops': instance.topShops,
  'upcoming_events': instance.upcomingEvents,
  'personal_summary': instance.personalSummary,
  'notifications': instance.notifications,
};

_$DashboardActivityItemImpl _$$DashboardActivityItemImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardActivityItemImpl(
  type: json['type'] as String,
  timestamp: json['timestamp'] as String?,
  shopId: json['shop_id'] as String?,
  shopName: json['shop_name'] as String?,
  title: json['title'] as String?,
  body: json['body'] as String?,
  actorName: json['actor_name'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$DashboardActivityItemImplToJson(
  _$DashboardActivityItemImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'timestamp': instance.timestamp,
  'shop_id': instance.shopId,
  'shop_name': instance.shopName,
  'title': instance.title,
  'body': instance.body,
  'actor_name': instance.actorName,
  'rating': instance.rating,
};

_$DashboardAggregateImpl _$$DashboardAggregateImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardAggregateImpl(
  shopCount: (json['shop_count'] as num?)?.toInt() ?? 0,
  reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  eventCount: (json['event_count'] as num?)?.toInt() ?? 0,
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DashboardAggregateImplToJson(
  _$DashboardAggregateImpl instance,
) => <String, dynamic>{
  'shop_count': instance.shopCount,
  'review_count': instance.reviewCount,
  'average_rating': instance.averageRating,
  'event_count': instance.eventCount,
  'member_count': instance.memberCount,
};

_$TopShopItemImpl _$$TopShopItemImplFromJson(Map<String, dynamic> json) =>
    _$TopShopItemImpl(
      shopId: json['shop_id'] as String,
      shopName: json['shop_name'] as String,
      city: json['city'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TopShopItemImplToJson(_$TopShopItemImpl instance) =>
    <String, dynamic>{
      'shop_id': instance.shopId,
      'shop_name': instance.shopName,
      'city': instance.city,
      'average_rating': instance.averageRating,
      'review_count': instance.reviewCount,
    };

_$UpcomingEventItemImpl _$$UpcomingEventItemImplFromJson(
  Map<String, dynamic> json,
) => _$UpcomingEventItemImpl(
  eventId: json['event_id'] as String,
  eventName: json['event_name'] as String,
  eventDate: json['event_date'] as String?,
  shopId: json['shop_id'] as String?,
  shopName: json['shop_name'] as String?,
);

Map<String, dynamic> _$$UpcomingEventItemImplToJson(
  _$UpcomingEventItemImpl instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'event_name': instance.eventName,
  'event_date': instance.eventDate,
  'shop_id': instance.shopId,
  'shop_name': instance.shopName,
};

_$DashboardPersonalSummaryImpl _$$DashboardPersonalSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardPersonalSummaryImpl(
  favouriteShops: (json['favourite_shops'] as num?)?.toInt() ?? 0,
  reservations: (json['reservations'] as num?)?.toInt() ?? 0,
  reviewsWritten: (json['reviews_written'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DashboardPersonalSummaryImplToJson(
  _$DashboardPersonalSummaryImpl instance,
) => <String, dynamic>{
  'favourite_shops': instance.favouriteShops,
  'reservations': instance.reservations,
  'reviews_written': instance.reviewsWritten,
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
