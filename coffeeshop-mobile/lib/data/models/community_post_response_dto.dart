// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post_response_dto.freezed.dart';
part 'community_post_response_dto.g.dart';

@freezed
class CommunityPostResponseDto with _$CommunityPostResponseDto {
  const factory CommunityPostResponseDto({
    required String id,
    required String body,
    @Default('POST') String type,
    @Default(false) bool pinned,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'author_id') String? authorId,
    Map<String, dynamic>? author,
  }) = _CommunityPostResponseDto;

  factory CommunityPostResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostResponseDtoFromJson(json);
}

@freezed
class CommunityPostCreateRequest with _$CommunityPostCreateRequest {
  const factory CommunityPostCreateRequest({
    required String body,
  }) = _CommunityPostCreateRequest;

  factory CommunityPostCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostCreateRequestFromJson(json);
}

@freezed
class MemberSummaryDto with _$MemberSummaryDto {
  const factory MemberSummaryDto({
    required String id,
    required String name,
    required String username,
  }) = _MemberSummaryDto;

  factory MemberSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$MemberSummaryDtoFromJson(json);
}
