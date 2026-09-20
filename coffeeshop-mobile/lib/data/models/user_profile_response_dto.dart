// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'shop_response_dto.dart';

part 'user_profile_response_dto.freezed.dart';
part 'user_profile_response_dto.g.dart';

@freezed
class SubscriptionSummaryDto with _$SubscriptionSummaryDto {
  const factory SubscriptionSummaryDto({
    required String planMode,
    String? planTier,
    required String status,
    @Default(0) int shopsIncluded,
    @Default(0) int shopsUsed,
    String? periodEnd,
    @Default(0) int monthlyAmountCents,
  }) = _SubscriptionSummaryDto;

  factory SubscriptionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionSummaryDtoFromJson(json);
}

@freezed
class LimitUsageDto with _$LimitUsageDto {
  const factory LimitUsageDto({
    required int used,
    required int max,
  }) = _LimitUsageDto;

  factory LimitUsageDto.fromJson(Map<String, dynamic> json) =>
      _$LimitUsageDtoFromJson(json);
}

Map<String, LimitUsageDto> _limitsFromJson(Map<String, dynamic>? json) {
  if (json == null) return {};
  return json.map(
    (key, value) => MapEntry(
      key,
      LimitUsageDto.fromJson(value as Map<String, dynamic>),
    ),
  );
}

Map<String, dynamic> _limitsToJson(Map<String, LimitUsageDto> limits) =>
    limits.map((key, value) => MapEntry(key, value.toJson()));

@freezed
class UserProfileResponseDto with _$UserProfileResponseDto {
  const factory UserProfileResponseDto({
    required String id,
    required String name,
    required String username,
    required String email,
    required String userType,
    @Default([]) List<ShopSummaryDto> favouriteShops,
    SubscriptionSummaryDto? subscription,
    @Default({}) Map<String, bool> entitlements,
    @JsonKey(fromJson: _limitsFromJson, toJson: _limitsToJson)
    @Default({})
    Map<String, LimitUsageDto> limits,
  }) = _UserProfileResponseDto;

  factory UserProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseDtoFromJson(json);
}
