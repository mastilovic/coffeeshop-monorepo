// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MenuResponseDto _$MenuResponseDtoFromJson(Map<String, dynamic> json) {
  return _MenuResponseDto.fromJson(json);
}

/// @nodoc
mixin _$MenuResponseDto {
  String get id => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_id')
  String? get shopId => throw _privateConstructorUsedError;
  bool get current => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get items => throw _privateConstructorUsedError;

  /// Serializes this MenuResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuResponseDtoCopyWith<MenuResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuResponseDtoCopyWith<$Res> {
  factory $MenuResponseDtoCopyWith(
    MenuResponseDto value,
    $Res Function(MenuResponseDto) then,
  ) = _$MenuResponseDtoCopyWithImpl<$Res, MenuResponseDto>;
  @useResult
  $Res call({
    String id,
    String? label,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'shop_id') String? shopId,
    bool current,
    List<Map<String, dynamic>> items,
  });
}

/// @nodoc
class _$MenuResponseDtoCopyWithImpl<$Res, $Val extends MenuResponseDto>
    implements $MenuResponseDtoCopyWith<$Res> {
  _$MenuResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = freezed,
    Object? createdAt = freezed,
    Object? shopId = freezed,
    Object? current = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            current: null == current
                ? _value.current
                : current // ignore: cast_nullable_to_non_nullable
                      as bool,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MenuResponseDtoImplCopyWith<$Res>
    implements $MenuResponseDtoCopyWith<$Res> {
  factory _$$MenuResponseDtoImplCopyWith(
    _$MenuResponseDtoImpl value,
    $Res Function(_$MenuResponseDtoImpl) then,
  ) = __$$MenuResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? label,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'shop_id') String? shopId,
    bool current,
    List<Map<String, dynamic>> items,
  });
}

/// @nodoc
class __$$MenuResponseDtoImplCopyWithImpl<$Res>
    extends _$MenuResponseDtoCopyWithImpl<$Res, _$MenuResponseDtoImpl>
    implements _$$MenuResponseDtoImplCopyWith<$Res> {
  __$$MenuResponseDtoImplCopyWithImpl(
    _$MenuResponseDtoImpl _value,
    $Res Function(_$MenuResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = freezed,
    Object? createdAt = freezed,
    Object? shopId = freezed,
    Object? current = null,
    Object? items = null,
  }) {
    return _then(
      _$MenuResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        current: null == current
            ? _value.current
            : current // ignore: cast_nullable_to_non_nullable
                  as bool,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuResponseDtoImpl implements _MenuResponseDto {
  const _$MenuResponseDtoImpl({
    required this.id,
    this.label,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'shop_id') this.shopId,
    this.current = false,
    final List<Map<String, dynamic>> items = const [],
  }) : _items = items;

  factory _$MenuResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String? label;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'shop_id')
  final String? shopId;
  @override
  @JsonKey()
  final bool current;
  final List<Map<String, dynamic>> _items;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'MenuResponseDto(id: $id, label: $label, createdAt: $createdAt, shopId: $shopId, current: $current, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.current, current) || other.current == current) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    createdAt,
    shopId,
    current,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of MenuResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuResponseDtoImplCopyWith<_$MenuResponseDtoImpl> get copyWith =>
      __$$MenuResponseDtoImplCopyWithImpl<_$MenuResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuResponseDtoImplToJson(this);
  }
}

abstract class _MenuResponseDto implements MenuResponseDto {
  const factory _MenuResponseDto({
    required final String id,
    final String? label,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'shop_id') final String? shopId,
    final bool current,
    final List<Map<String, dynamic>> items,
  }) = _$MenuResponseDtoImpl;

  factory _MenuResponseDto.fromJson(Map<String, dynamic> json) =
      _$MenuResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String? get label;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'shop_id')
  String? get shopId;
  @override
  bool get current;
  @override
  List<Map<String, dynamic>> get items;

  /// Create a copy of MenuResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuResponseDtoImplCopyWith<_$MenuResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuItemResponseDto _$MenuItemResponseDtoFromJson(Map<String, dynamic> json) {
  return _MenuItemResponseDto.fromJson(json);
}

/// @nodoc
mixin _$MenuItemResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_currency')
  String get priceCurrency => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_type')
  String get itemType => throw _privateConstructorUsedError;
  @JsonKey(name: 'menu_id')
  String? get menuId => throw _privateConstructorUsedError;

  /// Serializes this MenuItemResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuItemResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuItemResponseDtoCopyWith<MenuItemResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuItemResponseDtoCopyWith<$Res> {
  factory $MenuItemResponseDtoCopyWith(
    MenuItemResponseDto value,
    $Res Function(MenuItemResponseDto) then,
  ) = _$MenuItemResponseDtoCopyWithImpl<$Res, MenuItemResponseDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    double price,
    @JsonKey(name: 'price_currency') String priceCurrency,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'item_type') String itemType,
    @JsonKey(name: 'menu_id') String? menuId,
  });
}

/// @nodoc
class _$MenuItemResponseDtoCopyWithImpl<$Res, $Val extends MenuItemResponseDto>
    implements $MenuItemResponseDtoCopyWith<$Res> {
  _$MenuItemResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuItemResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? priceCurrency = null,
    Object? imageUrl = freezed,
    Object? itemType = null,
    Object? menuId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            priceCurrency: null == priceCurrency
                ? _value.priceCurrency
                : priceCurrency // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemType: null == itemType
                ? _value.itemType
                : itemType // ignore: cast_nullable_to_non_nullable
                      as String,
            menuId: freezed == menuId
                ? _value.menuId
                : menuId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MenuItemResponseDtoImplCopyWith<$Res>
    implements $MenuItemResponseDtoCopyWith<$Res> {
  factory _$$MenuItemResponseDtoImplCopyWith(
    _$MenuItemResponseDtoImpl value,
    $Res Function(_$MenuItemResponseDtoImpl) then,
  ) = __$$MenuItemResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    double price,
    @JsonKey(name: 'price_currency') String priceCurrency,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'item_type') String itemType,
    @JsonKey(name: 'menu_id') String? menuId,
  });
}

/// @nodoc
class __$$MenuItemResponseDtoImplCopyWithImpl<$Res>
    extends _$MenuItemResponseDtoCopyWithImpl<$Res, _$MenuItemResponseDtoImpl>
    implements _$$MenuItemResponseDtoImplCopyWith<$Res> {
  __$$MenuItemResponseDtoImplCopyWithImpl(
    _$MenuItemResponseDtoImpl _value,
    $Res Function(_$MenuItemResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuItemResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? priceCurrency = null,
    Object? imageUrl = freezed,
    Object? itemType = null,
    Object? menuId = freezed,
  }) {
    return _then(
      _$MenuItemResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        priceCurrency: null == priceCurrency
            ? _value.priceCurrency
            : priceCurrency // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemType: null == itemType
            ? _value.itemType
            : itemType // ignore: cast_nullable_to_non_nullable
                  as String,
        menuId: freezed == menuId
            ? _value.menuId
            : menuId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuItemResponseDtoImpl implements _MenuItemResponseDto {
  const _$MenuItemResponseDtoImpl({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    @JsonKey(name: 'price_currency') required this.priceCurrency,
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'item_type') required this.itemType,
    @JsonKey(name: 'menu_id') this.menuId,
  });

  factory _$MenuItemResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuItemResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double price;
  @override
  @JsonKey(name: 'price_currency')
  final String priceCurrency;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'item_type')
  final String itemType;
  @override
  @JsonKey(name: 'menu_id')
  final String? menuId;

  @override
  String toString() {
    return 'MenuItemResponseDto(id: $id, name: $name, description: $description, price: $price, priceCurrency: $priceCurrency, imageUrl: $imageUrl, itemType: $itemType, menuId: $menuId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuItemResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceCurrency, priceCurrency) ||
                other.priceCurrency == priceCurrency) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.menuId, menuId) || other.menuId == menuId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    price,
    priceCurrency,
    imageUrl,
    itemType,
    menuId,
  );

  /// Create a copy of MenuItemResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuItemResponseDtoImplCopyWith<_$MenuItemResponseDtoImpl> get copyWith =>
      __$$MenuItemResponseDtoImplCopyWithImpl<_$MenuItemResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuItemResponseDtoImplToJson(this);
  }
}

abstract class _MenuItemResponseDto implements MenuItemResponseDto {
  const factory _MenuItemResponseDto({
    required final String id,
    required final String name,
    final String? description,
    required final double price,
    @JsonKey(name: 'price_currency') required final String priceCurrency,
    @JsonKey(name: 'image_url') final String? imageUrl,
    @JsonKey(name: 'item_type') required final String itemType,
    @JsonKey(name: 'menu_id') final String? menuId,
  }) = _$MenuItemResponseDtoImpl;

  factory _MenuItemResponseDto.fromJson(Map<String, dynamic> json) =
      _$MenuItemResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get price;
  @override
  @JsonKey(name: 'price_currency')
  String get priceCurrency;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'item_type')
  String get itemType;
  @override
  @JsonKey(name: 'menu_id')
  String? get menuId;

  /// Create a copy of MenuItemResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuItemResponseDtoImplCopyWith<_$MenuItemResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuCreateRequest _$MenuCreateRequestFromJson(Map<String, dynamic> json) {
  return _MenuCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$MenuCreateRequest {
  String? get label => throw _privateConstructorUsedError;

  /// Serializes this MenuCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuCreateRequestCopyWith<MenuCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuCreateRequestCopyWith<$Res> {
  factory $MenuCreateRequestCopyWith(
    MenuCreateRequest value,
    $Res Function(MenuCreateRequest) then,
  ) = _$MenuCreateRequestCopyWithImpl<$Res, MenuCreateRequest>;
  @useResult
  $Res call({String? label});
}

/// @nodoc
class _$MenuCreateRequestCopyWithImpl<$Res, $Val extends MenuCreateRequest>
    implements $MenuCreateRequestCopyWith<$Res> {
  _$MenuCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? label = freezed}) {
    return _then(
      _value.copyWith(
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MenuCreateRequestImplCopyWith<$Res>
    implements $MenuCreateRequestCopyWith<$Res> {
  factory _$$MenuCreateRequestImplCopyWith(
    _$MenuCreateRequestImpl value,
    $Res Function(_$MenuCreateRequestImpl) then,
  ) = __$$MenuCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? label});
}

/// @nodoc
class __$$MenuCreateRequestImplCopyWithImpl<$Res>
    extends _$MenuCreateRequestCopyWithImpl<$Res, _$MenuCreateRequestImpl>
    implements _$$MenuCreateRequestImplCopyWith<$Res> {
  __$$MenuCreateRequestImplCopyWithImpl(
    _$MenuCreateRequestImpl _value,
    $Res Function(_$MenuCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? label = freezed}) {
    return _then(
      _$MenuCreateRequestImpl(
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuCreateRequestImpl implements _MenuCreateRequest {
  const _$MenuCreateRequestImpl({this.label});

  factory _$MenuCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuCreateRequestImplFromJson(json);

  @override
  final String? label;

  @override
  String toString() {
    return 'MenuCreateRequest(label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuCreateRequestImpl &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label);

  /// Create a copy of MenuCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuCreateRequestImplCopyWith<_$MenuCreateRequestImpl> get copyWith =>
      __$$MenuCreateRequestImplCopyWithImpl<_$MenuCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuCreateRequestImplToJson(this);
  }
}

abstract class _MenuCreateRequest implements MenuCreateRequest {
  const factory _MenuCreateRequest({final String? label}) =
      _$MenuCreateRequestImpl;

  factory _MenuCreateRequest.fromJson(Map<String, dynamic> json) =
      _$MenuCreateRequestImpl.fromJson;

  @override
  String? get label;

  /// Create a copy of MenuCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuCreateRequestImplCopyWith<_$MenuCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuItemCreateRequest _$MenuItemCreateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _MenuItemCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$MenuItemCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_currency')
  String get priceCurrency => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_type')
  String get itemType => throw _privateConstructorUsedError;
  @JsonKey(name: 'menu_id')
  String get menuId => throw _privateConstructorUsedError;

  /// Serializes this MenuItemCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuItemCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuItemCreateRequestCopyWith<MenuItemCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuItemCreateRequestCopyWith<$Res> {
  factory $MenuItemCreateRequestCopyWith(
    MenuItemCreateRequest value,
    $Res Function(MenuItemCreateRequest) then,
  ) = _$MenuItemCreateRequestCopyWithImpl<$Res, MenuItemCreateRequest>;
  @useResult
  $Res call({
    String name,
    String? description,
    double price,
    @JsonKey(name: 'price_currency') String priceCurrency,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'item_type') String itemType,
    @JsonKey(name: 'menu_id') String menuId,
  });
}

/// @nodoc
class _$MenuItemCreateRequestCopyWithImpl<
  $Res,
  $Val extends MenuItemCreateRequest
>
    implements $MenuItemCreateRequestCopyWith<$Res> {
  _$MenuItemCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuItemCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? priceCurrency = null,
    Object? imageUrl = freezed,
    Object? itemType = null,
    Object? menuId = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            priceCurrency: null == priceCurrency
                ? _value.priceCurrency
                : priceCurrency // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemType: null == itemType
                ? _value.itemType
                : itemType // ignore: cast_nullable_to_non_nullable
                      as String,
            menuId: null == menuId
                ? _value.menuId
                : menuId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MenuItemCreateRequestImplCopyWith<$Res>
    implements $MenuItemCreateRequestCopyWith<$Res> {
  factory _$$MenuItemCreateRequestImplCopyWith(
    _$MenuItemCreateRequestImpl value,
    $Res Function(_$MenuItemCreateRequestImpl) then,
  ) = __$$MenuItemCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? description,
    double price,
    @JsonKey(name: 'price_currency') String priceCurrency,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'item_type') String itemType,
    @JsonKey(name: 'menu_id') String menuId,
  });
}

/// @nodoc
class __$$MenuItemCreateRequestImplCopyWithImpl<$Res>
    extends
        _$MenuItemCreateRequestCopyWithImpl<$Res, _$MenuItemCreateRequestImpl>
    implements _$$MenuItemCreateRequestImplCopyWith<$Res> {
  __$$MenuItemCreateRequestImplCopyWithImpl(
    _$MenuItemCreateRequestImpl _value,
    $Res Function(_$MenuItemCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuItemCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? priceCurrency = null,
    Object? imageUrl = freezed,
    Object? itemType = null,
    Object? menuId = null,
  }) {
    return _then(
      _$MenuItemCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        priceCurrency: null == priceCurrency
            ? _value.priceCurrency
            : priceCurrency // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemType: null == itemType
            ? _value.itemType
            : itemType // ignore: cast_nullable_to_non_nullable
                  as String,
        menuId: null == menuId
            ? _value.menuId
            : menuId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuItemCreateRequestImpl implements _MenuItemCreateRequest {
  const _$MenuItemCreateRequestImpl({
    required this.name,
    this.description,
    required this.price,
    @JsonKey(name: 'price_currency') required this.priceCurrency,
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'item_type') required this.itemType,
    @JsonKey(name: 'menu_id') required this.menuId,
  });

  factory _$MenuItemCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuItemCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final double price;
  @override
  @JsonKey(name: 'price_currency')
  final String priceCurrency;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'item_type')
  final String itemType;
  @override
  @JsonKey(name: 'menu_id')
  final String menuId;

  @override
  String toString() {
    return 'MenuItemCreateRequest(name: $name, description: $description, price: $price, priceCurrency: $priceCurrency, imageUrl: $imageUrl, itemType: $itemType, menuId: $menuId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuItemCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceCurrency, priceCurrency) ||
                other.priceCurrency == priceCurrency) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.menuId, menuId) || other.menuId == menuId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    price,
    priceCurrency,
    imageUrl,
    itemType,
    menuId,
  );

  /// Create a copy of MenuItemCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuItemCreateRequestImplCopyWith<_$MenuItemCreateRequestImpl>
  get copyWith =>
      __$$MenuItemCreateRequestImplCopyWithImpl<_$MenuItemCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuItemCreateRequestImplToJson(this);
  }
}

abstract class _MenuItemCreateRequest implements MenuItemCreateRequest {
  const factory _MenuItemCreateRequest({
    required final String name,
    final String? description,
    required final double price,
    @JsonKey(name: 'price_currency') required final String priceCurrency,
    @JsonKey(name: 'image_url') final String? imageUrl,
    @JsonKey(name: 'item_type') required final String itemType,
    @JsonKey(name: 'menu_id') required final String menuId,
  }) = _$MenuItemCreateRequestImpl;

  factory _MenuItemCreateRequest.fromJson(Map<String, dynamic> json) =
      _$MenuItemCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  double get price;
  @override
  @JsonKey(name: 'price_currency')
  String get priceCurrency;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'item_type')
  String get itemType;
  @override
  @JsonKey(name: 'menu_id')
  String get menuId;

  /// Create a copy of MenuItemCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuItemCreateRequestImplCopyWith<_$MenuItemCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
