// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_request_response_dto.freezed.dart';
part 'reservation_request_response_dto.g.dart';

@freezed
class ReservationRequestResponseDto with _$ReservationRequestResponseDto {
  const factory ReservationRequestResponseDto({
    required String id,
    required int partySize,
    @Default('PENDING') String status,
    String? userId,
    String? shopId,
    String? eventId,
    String? reservationId,
    String? eventName,
    String? eventDate,
    Map<String, dynamic>? user,
    Map<String, dynamic>? shop,
  }) = _ReservationRequestResponseDto;

  factory ReservationRequestResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReservationRequestResponseDtoFromJson(json);
}

@freezed
class ReservationRequestCreateRequest with _$ReservationRequestCreateRequest {
  const factory ReservationRequestCreateRequest({
    required int partySize,
    String? userId,
    String? shopId,
    String? eventId,
  }) = _ReservationRequestCreateRequest;

  factory ReservationRequestCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationRequestCreateRequestFromJson(json);
}

@freezed
class ReservationAcceptRequest with _$ReservationAcceptRequest {
  const factory ReservationAcceptRequest({
    String? tableId,
  }) = _ReservationAcceptRequest;

  factory ReservationAcceptRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationAcceptRequestFromJson(json);
}
