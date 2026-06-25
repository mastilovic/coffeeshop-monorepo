// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_response_dto.freezed.dart';
part 'user_response_dto.g.dart';

@freezed
class UserResponseDto with _$UserResponseDto {
  const factory UserResponseDto({
    required String id,
    required String name,
    required String username,
    required String email,
    required String userType,
  }) = _UserResponseDto;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);
}
