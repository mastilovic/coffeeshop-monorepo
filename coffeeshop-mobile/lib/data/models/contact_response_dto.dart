// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_response_dto.freezed.dart';
part 'contact_response_dto.g.dart';

@freezed
class ContactResponseDto with _$ContactResponseDto {
  const factory ContactResponseDto({
    required String id,
    @JsonKey(name: 'shop_id') String? shopId,
  }) = _ContactResponseDto;

  factory ContactResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ContactResponseDtoFromJson(json);
}

@freezed
class ContactCreateRequest with _$ContactCreateRequest {
  const factory ContactCreateRequest({
    @JsonKey(name: 'shop_id') required String shopId,
  }) = _ContactCreateRequest;

  factory ContactCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ContactCreateRequestFromJson(json);
}
