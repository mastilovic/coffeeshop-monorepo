// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_response.freezed.dart';
part 'page_response.g.dart';

@freezed
class PageResponseDto with _$PageResponseDto {
  const factory PageResponseDto({
    @Default([]) List<Map<String, dynamic>> content,
    required int page,
    required int size,
    @JsonKey(name: 'total_elements') required int totalElements,
    @JsonKey(name: 'total_pages') required int totalPages,
  }) = _PageResponseDto;

  factory PageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PageResponseDtoFromJson(json);
}
