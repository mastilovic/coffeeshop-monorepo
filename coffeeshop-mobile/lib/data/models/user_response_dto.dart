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
    @JsonKey(name: 'user_type') required String userType,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserResponseDto;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);
}
