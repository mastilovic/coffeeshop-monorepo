// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_response_dto.freezed.dart';
part 'shop_response_dto.g.dart';

@freezed
class ShopResponseDto with _$ShopResponseDto {
  const factory ShopResponseDto({
    required String id,
    required String name,
    required String address,
    required String city,
    String? phoneNumber,
    String? email,
    double? averageRating,
    @Default(0) int reviewCount,
    @Default(0) int memberCount,
    @Default(false) bool favouriteByCurrentUser,
    List<Map<String, dynamic>>? events,
    List<Map<String, dynamic>>? tables,
    List<Map<String, dynamic>>? reviews,
    List<Map<String, dynamic>>? contacts,
    Map<String, dynamic>? currentMenu,
    Map<String, dynamic>? loyaltyPlan,
  }) = _ShopResponseDto;

  factory ShopResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ShopResponseDtoFromJson(json);
}

@freezed
class ShopSummaryDto with _$ShopSummaryDto {
  const factory ShopSummaryDto({
    required String id,
    required String name,
    String? address,
    String? city,
    String? phoneNumber,
    String? email,
  }) = _ShopSummaryDto;

  factory ShopSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ShopSummaryDtoFromJson(json);
}

@freezed
class ShopCreateRequest with _$ShopCreateRequest {
  const factory ShopCreateRequest({
    required String name,
    required String address,
    required String city,
    String? phoneNumber,
    String? email,
    String? ownerUserId,
    String? loyaltyPlanId,
  }) = _ShopCreateRequest;

  factory ShopCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ShopCreateRequestFromJson(json);
}

@freezed
class ShopUpdateRequest with _$ShopUpdateRequest {
  const factory ShopUpdateRequest({
    String? name,
    String? address,
    String? city,
    String? phoneNumber,
    String? email,
    String? newOwnerUserId,
    String? loyaltyPlanId,
  }) = _ShopUpdateRequest;

  factory ShopUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ShopUpdateRequestFromJson(json);
}

@freezed
class ShopSearchParams with _$ShopSearchParams {
  const factory ShopSearchParams({
    String? q,
    @Default(0) int page,
    @Default(20) int size,
  }) = _ShopSearchParams;

  factory ShopSearchParams.fromJson(Map<String, dynamic> json) =>
      _$ShopSearchParamsFromJson(json);
}
