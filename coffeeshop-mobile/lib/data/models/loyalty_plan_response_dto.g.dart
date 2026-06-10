// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_plan_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoyaltyPlanResponseDtoImpl _$$LoyaltyPlanResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$LoyaltyPlanResponseDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  type: json['type'] as String,
);

Map<String, dynamic> _$$LoyaltyPlanResponseDtoImplToJson(
  _$LoyaltyPlanResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': instance.type,
};

_$LoyaltyPlanCreateRequestImpl _$$LoyaltyPlanCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$LoyaltyPlanCreateRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String?,
  type: json['type'] as String,
);

Map<String, dynamic> _$$LoyaltyPlanCreateRequestImplToJson(
  _$LoyaltyPlanCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': instance.type,
};
