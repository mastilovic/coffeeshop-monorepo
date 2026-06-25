// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_list_item_dto.freezed.dart';
part 'user_list_item_dto.g.dart';

@freezed
class UserListItemDto with _$UserListItemDto {
  const factory UserListItemDto({
    required String id,
    required String name,
    required String username,
    required String userType,
  }) = _UserListItemDto;

  factory UserListItemDto.fromJson(Map<String, dynamic> json) =>
      _$UserListItemDtoFromJson(json);
}
