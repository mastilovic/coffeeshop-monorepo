// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationResponseDtoImpl _$$ReservationResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationResponseDtoImpl(
  id: json['id'] as String,
  partySize: (json['partySize'] as num).toInt(),
  userId: json['userId'] as String?,
  shopId: json['shopId'] as String?,
  tableId: json['tableId'] as String?,
  eventId: json['eventId'] as String?,
  reservationRequestId: json['reservationRequestId'] as String?,
  eventName: json['eventName'] as String?,
  eventDate: json['eventDate'] as String?,
  user: json['user'] as Map<String, dynamic>?,
  shop: json['shop'] as Map<String, dynamic>?,
  table: json['table'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ReservationResponseDtoImplToJson(
  _$ReservationResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'partySize': instance.partySize,
  'userId': instance.userId,
  'shopId': instance.shopId,
  'tableId': instance.tableId,
  'eventId': instance.eventId,
  'reservationRequestId': instance.reservationRequestId,
  'eventName': instance.eventName,
  'eventDate': instance.eventDate,
  'user': instance.user,
  'shop': instance.shop,
  'table': instance.table,
};

_$ReservationCreateRequestImpl _$$ReservationCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationCreateRequestImpl(
  partySize: (json['partySize'] as num).toInt(),
  userId: json['userId'] as String?,
  shopId: json['shopId'] as String?,
  tableId: json['tableId'] as String?,
  eventId: json['eventId'] as String?,
);

Map<String, dynamic> _$$ReservationCreateRequestImplToJson(
  _$ReservationCreateRequestImpl instance,
) => <String, dynamic>{
  'partySize': instance.partySize,
  'userId': instance.userId,
  'shopId': instance.shopId,
  'tableId': instance.tableId,
  'eventId': instance.eventId,
};

_$ReservationUpdateRequestImpl _$$ReservationUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationUpdateRequestImpl(
  partySize: (json['partySize'] as num?)?.toInt(),
  tableId: json['tableId'] as String?,
);

Map<String, dynamic> _$$ReservationUpdateRequestImplToJson(
  _$ReservationUpdateRequestImpl instance,
) => <String, dynamic>{
  'partySize': instance.partySize,
  'tableId': instance.tableId,
};
