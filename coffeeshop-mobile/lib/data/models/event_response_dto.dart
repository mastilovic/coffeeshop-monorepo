// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_response_dto.freezed.dart';
part 'event_response_dto.g.dart';

@freezed
class EventResponseDto with _$EventResponseDto {
  const factory EventResponseDto({
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'event_name') required String eventName,
    @JsonKey(name: 'event_date') required String eventDate,
    String? description,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'shop_name') String? shopName,
    @JsonKey(name: 'shop_city') String? shopCity,
  }) = _EventResponseDto;

  factory EventResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EventResponseDtoFromJson(json);
}

@freezed
class EventCreateRequest with _$EventCreateRequest {
  const factory EventCreateRequest({
    @JsonKey(name: 'event_name') required String eventName,
    @JsonKey(name: 'event_date') required String eventDate,
    String? description,
    @JsonKey(name: 'shop_id') String? shopId,
  }) = _EventCreateRequest;

  factory EventCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$EventCreateRequestFromJson(json);
}

@freezed
class EventUpdateRequest with _$EventUpdateRequest {
  const factory EventUpdateRequest({
    @JsonKey(name: 'event_name') String? eventName,
    @JsonKey(name: 'event_date') String? eventDate,
    String? description,
    @JsonKey(name: 'shop_id') String? shopId,
  }) = _EventUpdateRequest;

  factory EventUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$EventUpdateRequestFromJson(json);
}

@freezed
class EventSearchParams with _$EventSearchParams {
  const factory EventSearchParams({
    String? q,
    @JsonKey(name: 'date_from') String? dateFrom,
    @JsonKey(name: 'date_to') String? dateTo,
    @Default(0) int page,
    @Default(20) int size,
  }) = _EventSearchParams;

  factory EventSearchParams.fromJson(Map<String, dynamic> json) =>
      _$EventSearchParamsFromJson(json);
}
