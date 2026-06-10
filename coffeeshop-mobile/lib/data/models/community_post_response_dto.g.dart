// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_post_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityPostResponseDtoImpl _$$CommunityPostResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityPostResponseDtoImpl(
  id: json['id'] as String,
  body: json['body'] as String,
  type: json['type'] as String? ?? 'POST',
  pinned: json['pinned'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  shopId: json['shop_id'] as String?,
  authorId: json['author_id'] as String?,
  author: json['author'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$CommunityPostResponseDtoImplToJson(
  _$CommunityPostResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'type': instance.type,
  'pinned': instance.pinned,
  'created_at': instance.createdAt,
  'shop_id': instance.shopId,
  'author_id': instance.authorId,
  'author': instance.author,
};

_$CommunityPostCreateRequestImpl _$$CommunityPostCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityPostCreateRequestImpl(body: json['body'] as String);

Map<String, dynamic> _$$CommunityPostCreateRequestImplToJson(
  _$CommunityPostCreateRequestImpl instance,
) => <String, dynamic>{'body': instance.body};

_$MemberSummaryDtoImpl _$$MemberSummaryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$MemberSummaryDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$$MemberSummaryDtoImplToJson(
  _$MemberSummaryDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
};
