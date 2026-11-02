// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_employee_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShopEmployeeDtoImpl _$$ShopEmployeeDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ShopEmployeeDtoImpl(
  userId: json['userId'] as String,
  shopId: json['shopId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  isOwner: json['isOwner'] as bool? ?? false,
);

Map<String, dynamic> _$$ShopEmployeeDtoImplToJson(
  _$ShopEmployeeDtoImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'shopId': instance.shopId,
  'name': instance.name,
  'email': instance.email,
  'isOwner': instance.isOwner,
};

_$AssignEmployeeRequestImpl _$$AssignEmployeeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AssignEmployeeRequestImpl(
  shopId: json['shopId'] as String,
  userId: json['userId'] as String,
);

Map<String, dynamic> _$$AssignEmployeeRequestImplToJson(
  _$AssignEmployeeRequestImpl instance,
) => <String, dynamic>{'shopId': instance.shopId, 'userId': instance.userId};

_$RemoveEmployeeRequestImpl _$$RemoveEmployeeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RemoveEmployeeRequestImpl(
  shopId: json['shopId'] as String,
  userId: json['userId'] as String,
);

Map<String, dynamic> _$$RemoveEmployeeRequestImplToJson(
  _$RemoveEmployeeRequestImpl instance,
) => <String, dynamic>{'shopId': instance.shopId, 'userId': instance.userId};
