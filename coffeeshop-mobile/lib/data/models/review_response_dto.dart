// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_response_dto.freezed.dart';
part 'review_response_dto.g.dart';

@freezed
class ReviewResponseDto with _$ReviewResponseDto {
  const factory ReviewResponseDto({
    required String id,
    String? title,
    String? description,
    required int rating,
    String? reviewDate,
    @Default(true) bool commentsEnabled,
    String? userId,
    String? shopId,
    Map<String, dynamic>? user,
    Map<String, dynamic>? shop,
    @Default([]) List<Map<String, dynamic>> comments,
  }) = _ReviewResponseDto;

  factory ReviewResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewResponseDtoFromJson(json);
}

@freezed
class ReviewCreateRequest with _$ReviewCreateRequest {
  const factory ReviewCreateRequest({
    String? title,
    String? description,
    required int rating,
    @Default(true) bool commentsEnabled,
    required String shopId,
  }) = _ReviewCreateRequest;

  factory ReviewCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewCreateRequestFromJson(json);
}

@freezed
class ReviewUpdateRequest with _$ReviewUpdateRequest {
  const factory ReviewUpdateRequest({
    String? title,
    String? description,
    int? rating,
    bool? commentsEnabled,
  }) = _ReviewUpdateRequest;

  factory ReviewUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewUpdateRequestFromJson(json);
}
