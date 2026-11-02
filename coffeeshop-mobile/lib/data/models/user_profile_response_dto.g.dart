// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionSummaryDtoImpl _$$SubscriptionSummaryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionSummaryDtoImpl(
  planMode: json['planMode'] as String,
  planTier: json['planTier'] as String?,
  status: json['status'] as String,
  shopsIncluded: (json['shopsIncluded'] as num?)?.toInt() ?? 0,
  shopsUsed: (json['shopsUsed'] as num?)?.toInt() ?? 0,
  periodEnd: json['periodEnd'] as String?,
  monthlyAmountCents: (json['monthlyAmountCents'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$SubscriptionSummaryDtoImplToJson(
  _$SubscriptionSummaryDtoImpl instance,
) => <String, dynamic>{
  'planMode': instance.planMode,
  'planTier': instance.planTier,
  'status': instance.status,
  'shopsIncluded': instance.shopsIncluded,
  'shopsUsed': instance.shopsUsed,
  'periodEnd': instance.periodEnd,
  'monthlyAmountCents': instance.monthlyAmountCents,
};

_$LimitUsageDtoImpl _$$LimitUsageDtoImplFromJson(Map<String, dynamic> json) =>
    _$LimitUsageDtoImpl(
      used: (json['used'] as num).toInt(),
      max: (json['max'] as num).toInt(),
    );

Map<String, dynamic> _$$LimitUsageDtoImplToJson(_$LimitUsageDtoImpl instance) =>
    <String, dynamic>{'used': instance.used, 'max': instance.max};

_$UserProfileResponseDtoImpl _$$UserProfileResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UserProfileResponseDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  userType: json['userType'] as String,
  favouriteShops:
      (json['favouriteShops'] as List<dynamic>?)
          ?.map((e) => ShopSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  subscription: json['subscription'] == null
      ? null
      : SubscriptionSummaryDto.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
  entitlements:
      (json['entitlements'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  limits: json['limits'] == null
      ? const {}
      : _limitsFromJson(json['limits'] as Map<String, dynamic>?),
);

Map<String, dynamic> _$$UserProfileResponseDtoImplToJson(
  _$UserProfileResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'userType': instance.userType,
  'favouriteShops': instance.favouriteShops,
  'subscription': instance.subscription,
  'entitlements': instance.entitlements,
  'limits': _limitsToJson(instance.limits),
};
