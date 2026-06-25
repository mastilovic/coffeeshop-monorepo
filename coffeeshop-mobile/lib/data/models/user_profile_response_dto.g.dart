// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
};
