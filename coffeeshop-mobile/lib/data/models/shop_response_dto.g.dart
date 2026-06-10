// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShopResponseDtoImpl _$$ShopResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ShopResponseDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  city: json['city'] as String,
  phoneNumber: json['phone_number'] as String?,
  email: json['email'] as String?,
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
  favouriteByCurrentUser: json['favourite_by_current_user'] as bool? ?? false,
  events: (json['events'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  tables: (json['tables'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  reviews: (json['reviews'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  contacts: (json['contacts'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  currentMenu: json['currentMenu'] as Map<String, dynamic>?,
  loyaltyPlan: json['loyaltyPlan'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ShopResponseDtoImplToJson(
  _$ShopResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'city': instance.city,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'average_rating': instance.averageRating,
  'review_count': instance.reviewCount,
  'member_count': instance.memberCount,
  'favourite_by_current_user': instance.favouriteByCurrentUser,
  'events': instance.events,
  'tables': instance.tables,
  'reviews': instance.reviews,
  'contacts': instance.contacts,
  'currentMenu': instance.currentMenu,
  'loyaltyPlan': instance.loyaltyPlan,
};

_$ShopSummaryDtoImpl _$$ShopSummaryDtoImplFromJson(Map<String, dynamic> json) =>
    _$ShopSummaryDtoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$ShopSummaryDtoImplToJson(
  _$ShopSummaryDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'city': instance.city,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
};

_$ShopCreateRequestImpl _$$ShopCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ShopCreateRequestImpl(
  name: json['name'] as String,
  address: json['address'] as String,
  city: json['city'] as String,
  phoneNumber: json['phone_number'] as String?,
  email: json['email'] as String?,
  ownerUserId: json['owner_user_id'] as String?,
  loyaltyPlanId: json['loyalty_plan_id'] as String?,
);

Map<String, dynamic> _$$ShopCreateRequestImplToJson(
  _$ShopCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'address': instance.address,
  'city': instance.city,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'owner_user_id': instance.ownerUserId,
  'loyalty_plan_id': instance.loyaltyPlanId,
};

_$ShopUpdateRequestImpl _$$ShopUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ShopUpdateRequestImpl(
  name: json['name'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  phoneNumber: json['phone_number'] as String?,
  email: json['email'] as String?,
  newOwnerUserId: json['new_owner_user_id'] as String?,
  loyaltyPlanId: json['loyalty_plan_id'] as String?,
);

Map<String, dynamic> _$$ShopUpdateRequestImplToJson(
  _$ShopUpdateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'address': instance.address,
  'city': instance.city,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'new_owner_user_id': instance.newOwnerUserId,
  'loyalty_plan_id': instance.loyaltyPlanId,
};

_$ShopSearchParamsImpl _$$ShopSearchParamsImplFromJson(
  Map<String, dynamic> json,
) => _$ShopSearchParamsImpl(
  q: json['q'] as String?,
  page: (json['page'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$$ShopSearchParamsImplToJson(
  _$ShopSearchParamsImpl instance,
) => <String, dynamic>{
  'q': instance.q,
  'page': instance.page,
  'size': instance.size,
};
