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
  createdAt: json['created_at'] as String?,
  shopId: json['shop_id'] as String?,
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
  'created_at': instance.createdAt,
  'shop_id': instance.shopId,
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
  priceCurrency: json['price_currency'] as String,
  imageUrl: json['image_url'] as String?,
  itemType: json['item_type'] as String,
  menuId: json['menu_id'] as String?,
);

Map<String, dynamic> _$$MenuItemResponseDtoImplToJson(
  _$MenuItemResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'price_currency': instance.priceCurrency,
  'image_url': instance.imageUrl,
  'item_type': instance.itemType,
  'menu_id': instance.menuId,
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
  priceCurrency: json['price_currency'] as String,
  imageUrl: json['image_url'] as String?,
  itemType: json['item_type'] as String,
  menuId: json['menu_id'] as String,
);

Map<String, dynamic> _$$MenuItemCreateRequestImplToJson(
  _$MenuItemCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'price_currency': instance.priceCurrency,
  'image_url': instance.imageUrl,
  'item_type': instance.itemType,
  'menu_id': instance.menuId,
};
