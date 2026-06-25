// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserListItemDtoImpl _$$UserListItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UserListItemDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  username: json['username'] as String,
  userType: json['userType'] as String,
);

Map<String, dynamic> _$$UserListItemDtoImplToJson(
  _$UserListItemDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'userType': instance.userType,
};
