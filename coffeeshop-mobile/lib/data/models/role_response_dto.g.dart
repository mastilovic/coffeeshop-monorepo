// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoleResponseDtoImpl _$$RoleResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$RoleResponseDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$$RoleResponseDtoImplToJson(
  _$RoleResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
};

_$RoleCreateRequestImpl _$$RoleCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RoleCreateRequestImpl(
  name: json['name'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$$RoleCreateRequestImplToJson(
  _$RoleCreateRequestImpl instance,
) => <String, dynamic>{'name': instance.name, 'type': instance.type};
