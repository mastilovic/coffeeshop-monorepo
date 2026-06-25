// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserCreateRequestImpl _$$UserCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UserCreateRequestImpl(
  name: json['name'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  password: json['password'] as String?,
  userType: json['userType'] as String,
);

Map<String, dynamic> _$$UserCreateRequestImplToJson(
  _$UserCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
  'userType': instance.userType,
};
