// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_response_dto.freezed.dart';
part 'role_response_dto.g.dart';

@freezed
class RoleResponseDto with _$RoleResponseDto {
  const factory RoleResponseDto({
    required String id,
    required String name,
    required String type,
  }) = _RoleResponseDto;

  factory RoleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RoleResponseDtoFromJson(json);
}

@freezed
class RoleCreateRequest with _$RoleCreateRequest {
  const factory RoleCreateRequest({
    required String name,
    required String type,
  }) = _RoleCreateRequest;

  factory RoleCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$RoleCreateRequestFromJson(json);
}
