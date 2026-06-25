// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventResponseDtoImpl _$$EventResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$EventResponseDtoImpl(
  eventId: json['eventId'] as String,
  eventName: json['eventName'] as String,
  eventDate: json['eventDate'] as String,
  description: json['description'] as String?,
  shopId: json['shopId'] as String?,
  shopName: json['shopName'] as String?,
  shopCity: json['shopCity'] as String?,
);

Map<String, dynamic> _$$EventResponseDtoImplToJson(
  _$EventResponseDtoImpl instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'eventName': instance.eventName,
  'eventDate': instance.eventDate,
  'description': instance.description,
  'shopId': instance.shopId,
  'shopName': instance.shopName,
  'shopCity': instance.shopCity,
};

_$EventCreateRequestImpl _$$EventCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$EventCreateRequestImpl(
  eventName: json['eventName'] as String,
  eventDate: json['eventDate'] as String,
  description: json['description'] as String?,
  shopId: json['shopId'] as String?,
);

Map<String, dynamic> _$$EventCreateRequestImplToJson(
  _$EventCreateRequestImpl instance,
) => <String, dynamic>{
  'eventName': instance.eventName,
  'eventDate': instance.eventDate,
  'description': instance.description,
  'shopId': instance.shopId,
};

_$EventUpdateRequestImpl _$$EventUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$EventUpdateRequestImpl(
  eventName: json['eventName'] as String?,
  eventDate: json['eventDate'] as String?,
  description: json['description'] as String?,
  shopId: json['shopId'] as String?,
);

Map<String, dynamic> _$$EventUpdateRequestImplToJson(
  _$EventUpdateRequestImpl instance,
) => <String, dynamic>{
  'eventName': instance.eventName,
  'eventDate': instance.eventDate,
  'description': instance.description,
  'shopId': instance.shopId,
};

_$EventSearchParamsImpl _$$EventSearchParamsImplFromJson(
  Map<String, dynamic> json,
) => _$EventSearchParamsImpl(
  q: json['q'] as String?,
  dateFrom: json['dateFrom'] as String?,
  dateTo: json['dateTo'] as String?,
  page: (json['page'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$$EventSearchParamsImplToJson(
  _$EventSearchParamsImpl instance,
) => <String, dynamic>{
  'q': instance.q,
  'dateFrom': instance.dateFrom,
  'dateTo': instance.dateTo,
  'page': instance.page,
  'size': instance.size,
};
