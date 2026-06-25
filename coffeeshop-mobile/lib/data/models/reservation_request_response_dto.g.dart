// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_request_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationRequestResponseDtoImpl
_$$ReservationRequestResponseDtoImplFromJson(Map<String, dynamic> json) =>
    _$ReservationRequestResponseDtoImpl(
      id: json['id'] as String,
      partySize: (json['partySize'] as num).toInt(),
      status: json['status'] as String? ?? 'PENDING',
      userId: json['userId'] as String?,
      shopId: json['shopId'] as String?,
      eventId: json['eventId'] as String?,
      reservationId: json['reservationId'] as String?,
      eventName: json['eventName'] as String?,
      eventDate: json['eventDate'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      shop: json['shop'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ReservationRequestResponseDtoImplToJson(
  _$ReservationRequestResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'partySize': instance.partySize,
  'status': instance.status,
  'userId': instance.userId,
  'shopId': instance.shopId,
  'eventId': instance.eventId,
  'reservationId': instance.reservationId,
  'eventName': instance.eventName,
  'eventDate': instance.eventDate,
  'user': instance.user,
  'shop': instance.shop,
};

_$ReservationRequestCreateRequestImpl
_$$ReservationRequestCreateRequestImplFromJson(Map<String, dynamic> json) =>
    _$ReservationRequestCreateRequestImpl(
      partySize: (json['partySize'] as num).toInt(),
      userId: json['userId'] as String?,
      shopId: json['shopId'] as String?,
      eventId: json['eventId'] as String?,
    );

Map<String, dynamic> _$$ReservationRequestCreateRequestImplToJson(
  _$ReservationRequestCreateRequestImpl instance,
) => <String, dynamic>{
  'partySize': instance.partySize,
  'userId': instance.userId,
  'shopId': instance.shopId,
  'eventId': instance.eventId,
};

_$ReservationAcceptRequestImpl _$$ReservationAcceptRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationAcceptRequestImpl(tableId: json['tableId'] as String?);

Map<String, dynamic> _$$ReservationAcceptRequestImplToJson(
  _$ReservationAcceptRequestImpl instance,
) => <String, dynamic>{'tableId': instance.tableId};
