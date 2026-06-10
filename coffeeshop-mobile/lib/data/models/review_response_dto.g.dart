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
  reviewDate: json['review_date'] as String?,
  commentsEnabled: json['comments_enabled'] as bool? ?? true,
  userId: json['user_id'] as String?,
  shopId: json['shop_id'] as String?,
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
  'review_date': instance.reviewDate,
  'comments_enabled': instance.commentsEnabled,
  'user_id': instance.userId,
  'shop_id': instance.shopId,
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
  commentsEnabled: json['comments_enabled'] as bool? ?? true,
  shopId: json['shop_id'] as String,
);

Map<String, dynamic> _$$ReviewCreateRequestImplToJson(
  _$ReviewCreateRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'rating': instance.rating,
  'comments_enabled': instance.commentsEnabled,
  'shop_id': instance.shopId,
};

_$ReviewUpdateRequestImpl _$$ReviewUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewUpdateRequestImpl(
  title: json['title'] as String?,
  description: json['description'] as String?,
  rating: (json['rating'] as num?)?.toInt(),
  commentsEnabled: json['comments_enabled'] as bool?,
);

Map<String, dynamic> _$$ReviewUpdateRequestImplToJson(
  _$ReviewUpdateRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'rating': instance.rating,
  'comments_enabled': instance.commentsEnabled,
};
