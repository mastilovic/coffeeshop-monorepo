// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_response_dto.freezed.dart';
part 'menu_response_dto.g.dart';

@freezed
class MenuResponseDto with _$MenuResponseDto {
  const factory MenuResponseDto({
    required String id,
    String? label,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'shop_id') String? shopId,
    @Default(false) bool current,
    @Default([]) List<Map<String, dynamic>> items,
  }) = _MenuResponseDto;

  factory MenuResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MenuResponseDtoFromJson(json);
}

@freezed
class MenuItemResponseDto with _$MenuItemResponseDto {
  const factory MenuItemResponseDto({
    required String id,
    required String name,
    String? description,
    required double price,
    @JsonKey(name: 'price_currency') required String priceCurrency,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'item_type') required String itemType,
    @JsonKey(name: 'menu_id') String? menuId,
  }) = _MenuItemResponseDto;

  factory MenuItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MenuItemResponseDtoFromJson(json);
}

@freezed
class MenuCreateRequest with _$MenuCreateRequest {
  const factory MenuCreateRequest({
    String? label,
  }) = _MenuCreateRequest;

  factory MenuCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$MenuCreateRequestFromJson(json);
}

@freezed
class MenuItemCreateRequest with _$MenuItemCreateRequest {
  const factory MenuItemCreateRequest({
    required String name,
    String? description,
    required double price,
    @JsonKey(name: 'price_currency') required String priceCurrency,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'item_type') required String itemType,
    @JsonKey(name: 'menu_id') required String menuId,
  }) = _MenuItemCreateRequest;

  factory MenuItemCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$MenuItemCreateRequestFromJson(json);
}
