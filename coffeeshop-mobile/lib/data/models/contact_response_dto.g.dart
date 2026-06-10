// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactResponseDtoImpl _$$ContactResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ContactResponseDtoImpl(
  id: json['id'] as String,
  shopId: json['shop_id'] as String?,
);

Map<String, dynamic> _$$ContactResponseDtoImplToJson(
  _$ContactResponseDtoImpl instance,
) => <String, dynamic>{'id': instance.id, 'shop_id': instance.shopId};

_$ContactCreateRequestImpl _$$ContactCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ContactCreateRequestImpl(shopId: json['shop_id'] as String);

Map<String, dynamic> _$$ContactCreateRequestImplToJson(
  _$ContactCreateRequestImpl instance,
) => <String, dynamic>{'shop_id': instance.shopId};
