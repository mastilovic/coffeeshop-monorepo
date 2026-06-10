// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_comment_response_dto.freezed.dart';
part 'review_comment_response_dto.g.dart';

@freezed
class ReviewCommentResponseDto with _$ReviewCommentResponseDto {
  const factory ReviewCommentResponseDto({
    required String id,
    required String body,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'review_id') String? reviewId,
    Map<String, dynamic>? user,
  }) = _ReviewCommentResponseDto;

  factory ReviewCommentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewCommentResponseDtoFromJson(json);
}

@freezed
class ReviewCommentCreateRequest with _$ReviewCommentCreateRequest {
  const factory ReviewCommentCreateRequest({
    required String body,
  }) = _ReviewCommentCreateRequest;

  factory ReviewCommentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewCommentCreateRequestFromJson(json);
}
