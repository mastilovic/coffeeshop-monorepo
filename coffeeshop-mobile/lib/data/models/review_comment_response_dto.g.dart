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
  createdAt: json['created_at'] as String?,
  userId: json['user_id'] as String?,
  reviewId: json['review_id'] as String?,
  user: json['user'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ReviewCommentResponseDtoImplToJson(
  _$ReviewCommentResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'created_at': instance.createdAt,
  'user_id': instance.userId,
  'review_id': instance.reviewId,
  'user': instance.user,
};

_$ReviewCommentCreateRequestImpl _$$ReviewCommentCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewCommentCreateRequestImpl(body: json['body'] as String);

Map<String, dynamic> _$$ReviewCommentCreateRequestImplToJson(
  _$ReviewCommentCreateRequestImpl instance,
) => <String, dynamic>{'body': instance.body};
