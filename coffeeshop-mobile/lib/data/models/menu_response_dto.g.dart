// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuResponseDtoImpl _$$MenuResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$MenuResponseDtoImpl(
  id: json['id'] as String,
  label: json['label'] as String?,
  createdAt: json['createdAt'] as String?,
  shopId: json['shopId'] as String?,
  current: json['current'] as bool? ?? false,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MenuResponseDtoImplToJson(
  _$MenuResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'createdAt': instance.createdAt,
  'shopId': instance.shopId,
  'current': instance.current,
  'items': instance.items,
};

_$MenuItemResponseDtoImpl _$$MenuItemResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$MenuItemResponseDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  priceCurrency: json['priceCurrency'] as String,
  imageUrl: json['imageUrl'] as String?,
  itemType: json['itemType'] as String,
  menuId: json['menuId'] as String?,
);

Map<String, dynamic> _$$MenuItemResponseDtoImplToJson(
  _$MenuItemResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'priceCurrency': instance.priceCurrency,
  'imageUrl': instance.imageUrl,
  'itemType': instance.itemType,
  'menuId': instance.menuId,
};

_$MenuCreateRequestImpl _$$MenuCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$MenuCreateRequestImpl(label: json['label'] as String?);

Map<String, dynamic> _$$MenuCreateRequestImplToJson(
  _$MenuCreateRequestImpl instance,
) => <String, dynamic>{'label': instance.label};

_$MenuItemCreateRequestImpl _$$MenuItemCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$MenuItemCreateRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  priceCurrency: json['priceCurrency'] as String,
  imageUrl: json['imageUrl'] as String?,
  itemType: json['itemType'] as String,
  menuId: json['menuId'] as String,
);

Map<String, dynamic> _$$MenuItemCreateRequestImplToJson(
  _$MenuItemCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'priceCurrency': instance.priceCurrency,
  'imageUrl': instance.imageUrl,
  'itemType': instance.itemType,
  'menuId': instance.menuId,
};
