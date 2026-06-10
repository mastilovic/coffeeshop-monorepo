// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_employee_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShopEmployeeDtoImpl _$$ShopEmployeeDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ShopEmployeeDtoImpl(
  userId: json['user_id'] as String,
  shopId: json['shop_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  isOwner: json['is_owner'] as bool? ?? false,
);

Map<String, dynamic> _$$ShopEmployeeDtoImplToJson(
  _$ShopEmployeeDtoImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'shop_id': instance.shopId,
  'name': instance.name,
  'email': instance.email,
  'is_owner': instance.isOwner,
};

_$AssignEmployeeRequestImpl _$$AssignEmployeeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AssignEmployeeRequestImpl(
  shopId: json['shop_id'] as String,
  userId: json['user_id'] as String,
);

Map<String, dynamic> _$$AssignEmployeeRequestImplToJson(
  _$AssignEmployeeRequestImpl instance,
) => <String, dynamic>{'shop_id': instance.shopId, 'user_id': instance.userId};

_$RemoveEmployeeRequestImpl _$$RemoveEmployeeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RemoveEmployeeRequestImpl(
  shopId: json['shop_id'] as String,
  userId: json['user_id'] as String,
);

Map<String, dynamic> _$$RemoveEmployeeRequestImplToJson(
  _$RemoveEmployeeRequestImpl instance,
) => <String, dynamic>{'shop_id': instance.shopId, 'user_id': instance.userId};
