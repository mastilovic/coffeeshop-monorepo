// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'loyalty_plan_response_dto.freezed.dart';
part 'loyalty_plan_response_dto.g.dart';

@freezed
class LoyaltyPlanResponseDto with _$LoyaltyPlanResponseDto {
  const factory LoyaltyPlanResponseDto({
    required String id,
    required String name,
    String? description,
    required String type,
  }) = _LoyaltyPlanResponseDto;

  factory LoyaltyPlanResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyPlanResponseDtoFromJson(json);
}

@freezed
class LoyaltyPlanCreateRequest with _$LoyaltyPlanCreateRequest {
  const factory LoyaltyPlanCreateRequest({
    required String name,
    String? description,
    required String type,
  }) = _LoyaltyPlanCreateRequest;

  factory LoyaltyPlanCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyPlanCreateRequestFromJson(json);
}
