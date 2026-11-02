// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewResponseDtoImpl _$$ReviewResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewResponseDtoImpl(
  id: json['id'] as String,
  title: json['title'] as String?,
  description: json['description'] as String?,
  rating: (json['rating'] as num).toInt(),
  reviewDate: json['reviewDate'] as String?,
  commentsEnabled: json['commentsEnabled'] as bool? ?? true,
  userId: json['userId'] as String?,
  shopId: json['shopId'] as String?,
  user: json['user'] as Map<String, dynamic>?,
  shop: json['shop'] as Map<String, dynamic>?,
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ReviewResponseDtoImplToJson(
  _$ReviewResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'rating': instance.rating,
  'reviewDate': instance.reviewDate,
  'commentsEnabled': instance.commentsEnabled,
  'userId': instance.userId,
  'shopId': instance.shopId,
  'user': instance.user,
  'shop': instance.shop,
  'comments': instance.comments,
};

_$ReviewCreateRequestImpl _$$ReviewCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewCreateRequestImpl(
  title: json['title'] as String?,
  description: json['description'] as String?,
  rating: (json['rating'] as num).toInt(),
  commentsEnabled: json['commentsEnabled'] as bool? ?? true,
  shopId: json['shopId'] as String,
);

Map<String, dynamic> _$$ReviewCreateRequestImplToJson(
  _$ReviewCreateRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'rating': instance.rating,
  'commentsEnabled': instance.commentsEnabled,
  'shopId': instance.shopId,
};

_$ReviewUpdateRequestImpl _$$ReviewUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewUpdateRequestImpl(
  title: json['title'] as String?,
  description: json['description'] as String?,
  rating: (json['rating'] as num?)?.toInt(),
  commentsEnabled: json['commentsEnabled'] as bool?,
);

Map<String, dynamic> _$$ReviewUpdateRequestImplToJson(
  _$ReviewUpdateRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'rating': instance.rating,
  'commentsEnabled': instance.commentsEnabled,
};
