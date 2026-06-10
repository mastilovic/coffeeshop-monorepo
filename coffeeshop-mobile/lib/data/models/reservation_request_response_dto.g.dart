// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_request_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationRequestResponseDtoImpl
_$$ReservationRequestResponseDtoImplFromJson(Map<String, dynamic> json) =>
    _$ReservationRequestResponseDtoImpl(
      id: json['id'] as String,
      partySize: (json['party_size'] as num).toInt(),
      status: json['status'] as String? ?? 'PENDING',
      userId: json['user_id'] as String?,
      shopId: json['shop_id'] as String?,
      eventId: json['event_id'] as String?,
      reservationId: json['reservation_id'] as String?,
      eventName: json['event_name'] as String?,
      eventDate: json['event_date'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      shop: json['shop'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ReservationRequestResponseDtoImplToJson(
  _$ReservationRequestResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'party_size': instance.partySize,
  'status': instance.status,
  'user_id': instance.userId,
  'shop_id': instance.shopId,
  'event_id': instance.eventId,
  'reservation_id': instance.reservationId,
  'event_name': instance.eventName,
  'event_date': instance.eventDate,
  'user': instance.user,
  'shop': instance.shop,
};

_$ReservationRequestCreateRequestImpl
_$$ReservationRequestCreateRequestImplFromJson(Map<String, dynamic> json) =>
    _$ReservationRequestCreateRequestImpl(
      partySize: (json['party_size'] as num).toInt(),
      userId: json['user_id'] as String?,
      shopId: json['shop_id'] as String?,
      eventId: json['event_id'] as String?,
    );

Map<String, dynamic> _$$ReservationRequestCreateRequestImplToJson(
  _$ReservationRequestCreateRequestImpl instance,
) => <String, dynamic>{
  'party_size': instance.partySize,
  'user_id': instance.userId,
  'shop_id': instance.shopId,
  'event_id': instance.eventId,
};

_$ReservationAcceptRequestImpl _$$ReservationAcceptRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationAcceptRequestImpl(tableId: json['table_id'] as String?);

Map<String, dynamic> _$$ReservationAcceptRequestImplToJson(
  _$ReservationAcceptRequestImpl instance,
) => <String, dynamic>{'table_id': instance.tableId};
