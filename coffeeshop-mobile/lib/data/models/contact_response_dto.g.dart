// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactResponseDtoImpl _$$ContactResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ContactResponseDtoImpl(
  id: json['id'] as String,
  shopId: json['shopId'] as String?,
);

Map<String, dynamic> _$$ContactResponseDtoImplToJson(
  _$ContactResponseDtoImpl instance,
) => <String, dynamic>{'id': instance.id, 'shopId': instance.shopId};

_$ContactCreateRequestImpl _$$ContactCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ContactCreateRequestImpl(shopId: json['shopId'] as String);

Map<String, dynamic> _$$ContactCreateRequestImplToJson(
  _$ContactCreateRequestImpl instance,
) => <String, dynamic>{'shopId': instance.shopId};
