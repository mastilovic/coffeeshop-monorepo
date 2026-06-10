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
  userType: json['user_type'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$UserProfileResponseDtoImplToJson(
  _$UserProfileResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'user_type': instance.userType,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
