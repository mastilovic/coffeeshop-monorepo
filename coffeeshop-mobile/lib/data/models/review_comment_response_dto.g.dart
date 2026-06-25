// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_comment_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewCommentResponseDtoImpl _$$ReviewCommentResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewCommentResponseDtoImpl(
  id: json['id'] as String,
  body: json['body'] as String,
  createdAt: json['createdAt'] as String?,
  userId: json['userId'] as String?,
  reviewId: json['reviewId'] as String?,
  user: json['user'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ReviewCommentResponseDtoImplToJson(
  _$ReviewCommentResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'createdAt': instance.createdAt,
  'userId': instance.userId,
  'reviewId': instance.reviewId,
  'user': instance.user,
};

_$ReviewCommentCreateRequestImpl _$$ReviewCommentCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewCommentCreateRequestImpl(body: json['body'] as String);

Map<String, dynamic> _$$ReviewCommentCreateRequestImplToJson(
  _$ReviewCommentCreateRequestImpl instance,
) => <String, dynamic>{'body': instance.body};
