// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'shop_response_dto.dart';

part 'user_profile_response_dto.freezed.dart';
part 'user_profile_response_dto.g.dart';

@freezed
class UserProfileResponseDto with _$UserProfileResponseDto {
  const factory UserProfileResponseDto({
    required String id,
    required String name,
    required String username,
    required String email,
    required String userType,
    @Default([]) List<ShopSummaryDto> favouriteShops,
  }) = _UserProfileResponseDto;

  factory UserProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseDtoFromJson(json);
}
