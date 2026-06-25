// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserResponseDtoImpl _$$UserResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UserResponseDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  userType: json['userType'] as String,
);

Map<String, dynamic> _$$UserResponseDtoImplToJson(
  _$UserResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'userType': instance.userType,
};
