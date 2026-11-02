// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_response_dto.freezed.dart';
part 'event_response_dto.g.dart';

@freezed
class EventResponseDto with _$EventResponseDto {
  const factory EventResponseDto({
    required String eventId,
    required String eventName,
    required String eventDate,
    String? description,
    String? shopId,
    String? shopName,
    String? shopCity,
  }) = _EventResponseDto;

  factory EventResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EventResponseDtoFromJson(json);
}

@freezed
class EventCreateRequest with _$EventCreateRequest {
  const factory EventCreateRequest({
    required String eventName,
    required String eventDate,
    String? description,
    String? shopId,
  }) = _EventCreateRequest;

  factory EventCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$EventCreateRequestFromJson(json);
}

@freezed
class EventUpdateRequest with _$EventUpdateRequest {
  const factory EventUpdateRequest({
    String? eventName,
    String? eventDate,
    String? description,
    String? shopId,
  }) = _EventUpdateRequest;

  factory EventUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$EventUpdateRequestFromJson(json);
}

@freezed
class EventSearchParams with _$EventSearchParams {
  const factory EventSearchParams({
    String? q,
    String? dateFrom,
    String? dateTo,
    @Default(0) int page,
    @Default(20) int size,
  }) = _EventSearchParams;

  factory EventSearchParams.fromJson(Map<String, dynamic> json) =>
      _$EventSearchParamsFromJson(json);
}
