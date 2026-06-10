// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationResponseDtoImpl _$$ReservationResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationResponseDtoImpl(
  id: json['id'] as String,
  partySize: (json['party_size'] as num).toInt(),
  userId: json['user_id'] as String?,
  shopId: json['shop_id'] as String?,
  tableId: json['table_id'] as String?,
  eventId: json['event_id'] as String?,
  reservationRequestId: json['reservation_request_id'] as String?,
  eventName: json['event_name'] as String?,
  eventDate: json['event_date'] as String?,
  user: json['user'] as Map<String, dynamic>?,
  shop: json['shop'] as Map<String, dynamic>?,
  table: json['table'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ReservationResponseDtoImplToJson(
  _$ReservationResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'party_size': instance.partySize,
  'user_id': instance.userId,
  'shop_id': instance.shopId,
  'table_id': instance.tableId,
  'event_id': instance.eventId,
  'reservation_request_id': instance.reservationRequestId,
  'event_name': instance.eventName,
  'event_date': instance.eventDate,
  'user': instance.user,
  'shop': instance.shop,
  'table': instance.table,
};

_$ReservationCreateRequestImpl _$$ReservationCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationCreateRequestImpl(
  partySize: (json['party_size'] as num).toInt(),
  userId: json['user_id'] as String?,
  shopId: json['shop_id'] as String?,
  tableId: json['table_id'] as String?,
  eventId: json['event_id'] as String?,
);

Map<String, dynamic> _$$ReservationCreateRequestImplToJson(
  _$ReservationCreateRequestImpl instance,
) => <String, dynamic>{
  'party_size': instance.partySize,
  'user_id': instance.userId,
  'shop_id': instance.shopId,
  'table_id': instance.tableId,
  'event_id': instance.eventId,
};

_$ReservationUpdateRequestImpl _$$ReservationUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationUpdateRequestImpl(
  partySize: (json['party_size'] as num?)?.toInt(),
  tableId: json['table_id'] as String?,
);

Map<String, dynamic> _$$ReservationUpdateRequestImplToJson(
  _$ReservationUpdateRequestImpl instance,
) => <String, dynamic>{
  'party_size': instance.partySize,
  'table_id': instance.tableId,
};
