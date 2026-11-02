// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserUpdateRequestImpl _$$UserUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UserUpdateRequestImpl(
  name: json['name'] as String,
  username: json['username'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  userType: json['userType'] as String,
);

Map<String, dynamic> _$$UserUpdateRequestImplToJson(
  _$UserUpdateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
  'userType': instance.userType,
};
