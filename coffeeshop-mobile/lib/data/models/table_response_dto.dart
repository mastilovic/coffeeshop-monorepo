// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_response_dto.freezed.dart';
part 'table_response_dto.g.dart';

@freezed
class TableResponseDto with _$TableResponseDto {
  const factory TableResponseDto({
    required String id,
    required int number,
    required int capacity,
    @JsonKey(name: 'shop_id') String? shopId,
    @Default([]) List<Map<String, dynamic>> reservations,
  }) = _TableResponseDto;

  factory TableResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TableResponseDtoFromJson(json);
}

@freezed
class TableSummaryDto with _$TableSummaryDto {
  const factory TableSummaryDto({
    required String id,
    required int number,
    required int capacity,
  }) = _TableSummaryDto;

  factory TableSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$TableSummaryDtoFromJson(json);
}

@freezed
class TableCreateRequest with _$TableCreateRequest {
  const factory TableCreateRequest({
    required int number,
    required int capacity,
    @JsonKey(name: 'shop_id') required String shopId,
  }) = _TableCreateRequest;

  factory TableCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$TableCreateRequestFromJson(json);
}
