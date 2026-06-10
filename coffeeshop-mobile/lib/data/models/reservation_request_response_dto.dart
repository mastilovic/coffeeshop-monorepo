// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_request_response_dto.freezed.dart';
part 'reservation_request_response_dto.g.dart';

@freezed
class ReservationRequestResponseDto with _$ReservationRequestResponseDto {
  const factory ReservationRequestResponseDto({
    required String id,
    @JsonKey(name: 'party_size') required int partySize,
    @Default('PENDING') String status,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'event_id') String? eventId,
    @JsonKey(name: 'reservation_id') String? reservationId,
    @JsonKey(name: 'event_name') String? eventName,
    @JsonKey(name: 'event_date') String? eventDate,
    Map<String, dynamic>? user,
    Map<String, dynamic>? shop,
  }) = _ReservationRequestResponseDto;

  factory ReservationRequestResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReservationRequestResponseDtoFromJson(json);
}

@freezed
class ReservationRequestCreateRequest with _$ReservationRequestCreateRequest {
  const factory ReservationRequestCreateRequest({
    @JsonKey(name: 'party_size') required int partySize,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'event_id') String? eventId,
  }) = _ReservationRequestCreateRequest;

  factory ReservationRequestCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationRequestCreateRequestFromJson(json);
}

@freezed
class ReservationAcceptRequest with _$ReservationAcceptRequest {
  const factory ReservationAcceptRequest({
    @JsonKey(name: 'table_id') String? tableId,
  }) = _ReservationAcceptRequest;

  factory ReservationAcceptRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationAcceptRequestFromJson(json);
}
