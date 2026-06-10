// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_response_dto.freezed.dart';
part 'reservation_response_dto.g.dart';

@freezed
class ReservationResponseDto with _$ReservationResponseDto {
  const factory ReservationResponseDto({
    required String id,
    @JsonKey(name: 'party_size') required int partySize,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'table_id') String? tableId,
    @JsonKey(name: 'event_id') String? eventId,
    @JsonKey(name: 'reservation_request_id') String? reservationRequestId,
    @JsonKey(name: 'event_name') String? eventName,
    @JsonKey(name: 'event_date') String? eventDate,
    Map<String, dynamic>? user,
    Map<String, dynamic>? shop,
    Map<String, dynamic>? table,
  }) = _ReservationResponseDto;

  factory ReservationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReservationResponseDtoFromJson(json);
}

@freezed
class ReservationCreateRequest with _$ReservationCreateRequest {
  const factory ReservationCreateRequest({
    @JsonKey(name: 'party_size') required int partySize,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'table_id') String? tableId,
    @JsonKey(name: 'event_id') String? eventId,
  }) = _ReservationCreateRequest;

  factory ReservationCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationCreateRequestFromJson(json);
}

@freezed
class ReservationUpdateRequest with _$ReservationUpdateRequest {
  const factory ReservationUpdateRequest({
    @JsonKey(name: 'party_size') int? partySize,
    @JsonKey(name: 'table_id') String? tableId,
  }) = _ReservationUpdateRequest;

  factory ReservationUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationUpdateRequestFromJson(json);
}
