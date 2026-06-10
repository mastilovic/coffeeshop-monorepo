// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventResponseDtoImpl _$$EventResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$EventResponseDtoImpl(
  eventId: json['event_id'] as String,
  eventName: json['event_name'] as String,
  eventDate: json['event_date'] as String,
  description: json['description'] as String?,
  shopId: json['shop_id'] as String?,
  shopName: json['shop_name'] as String?,
  shopCity: json['shop_city'] as String?,
);

Map<String, dynamic> _$$EventResponseDtoImplToJson(
  _$EventResponseDtoImpl instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'event_name': instance.eventName,
  'event_date': instance.eventDate,
  'description': instance.description,
  'shop_id': instance.shopId,
  'shop_name': instance.shopName,
  'shop_city': instance.shopCity,
};

_$EventCreateRequestImpl _$$EventCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$EventCreateRequestImpl(
  eventName: json['event_name'] as String,
  eventDate: json['event_date'] as String,
  description: json['description'] as String?,
  shopId: json['shop_id'] as String?,
);

Map<String, dynamic> _$$EventCreateRequestImplToJson(
  _$EventCreateRequestImpl instance,
) => <String, dynamic>{
  'event_name': instance.eventName,
  'event_date': instance.eventDate,
  'description': instance.description,
  'shop_id': instance.shopId,
};

_$EventUpdateRequestImpl _$$EventUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$EventUpdateRequestImpl(
  eventName: json['event_name'] as String?,
  eventDate: json['event_date'] as String?,
  description: json['description'] as String?,
  shopId: json['shop_id'] as String?,
);

Map<String, dynamic> _$$EventUpdateRequestImplToJson(
  _$EventUpdateRequestImpl instance,
) => <String, dynamic>{
  'event_name': instance.eventName,
  'event_date': instance.eventDate,
  'description': instance.description,
  'shop_id': instance.shopId,
};

_$EventSearchParamsImpl _$$EventSearchParamsImplFromJson(
  Map<String, dynamic> json,
) => _$EventSearchParamsImpl(
  q: json['q'] as String?,
  dateFrom: json['date_from'] as String?,
  dateTo: json['date_to'] as String?,
  page: (json['page'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$$EventSearchParamsImplToJson(
  _$EventSearchParamsImpl instance,
) => <String, dynamic>{
  'q': instance.q,
  'date_from': instance.dateFrom,
  'date_to': instance.dateTo,
  'page': instance.page,
  'size': instance.size,
};
