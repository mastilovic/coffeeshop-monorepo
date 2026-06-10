// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ContactResponseDto _$ContactResponseDtoFromJson(Map<String, dynamic> json) {
  return _ContactResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ContactResponseDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_id')
  String? get shopId => throw _privateConstructorUsedError;

  /// Serializes this ContactResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContactResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContactResponseDtoCopyWith<ContactResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContactResponseDtoCopyWith<$Res> {
  factory $ContactResponseDtoCopyWith(
    ContactResponseDto value,
    $Res Function(ContactResponseDto) then,
  ) = _$ContactResponseDtoCopyWithImpl<$Res, ContactResponseDto>;
  @useResult
  $Res call({String id, @JsonKey(name: 'shop_id') String? shopId});
}

/// @nodoc
class _$ContactResponseDtoCopyWithImpl<$Res, $Val extends ContactResponseDto>
    implements $ContactResponseDtoCopyWith<$Res> {
  _$ContactResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContactResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? shopId = freezed}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContactResponseDtoImplCopyWith<$Res>
    implements $ContactResponseDtoCopyWith<$Res> {
  factory _$$ContactResponseDtoImplCopyWith(
    _$ContactResponseDtoImpl value,
    $Res Function(_$ContactResponseDtoImpl) then,
  ) = __$$ContactResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, @JsonKey(name: 'shop_id') String? shopId});
}

/// @nodoc
class __$$ContactResponseDtoImplCopyWithImpl<$Res>
    extends _$ContactResponseDtoCopyWithImpl<$Res, _$ContactResponseDtoImpl>
    implements _$$ContactResponseDtoImplCopyWith<$Res> {
  __$$ContactResponseDtoImplCopyWithImpl(
    _$ContactResponseDtoImpl _value,
    $Res Function(_$ContactResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContactResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? shopId = freezed}) {
    return _then(
      _$ContactResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactResponseDtoImpl implements _ContactResponseDto {
  const _$ContactResponseDtoImpl({
    required this.id,
    @JsonKey(name: 'shop_id') this.shopId,
  });

  factory _$ContactResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'shop_id')
  final String? shopId;

  @override
  String toString() {
    return 'ContactResponseDto(id: $id, shopId: $shopId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shopId, shopId) || other.shopId == shopId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, shopId);

  /// Create a copy of ContactResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactResponseDtoImplCopyWith<_$ContactResponseDtoImpl> get copyWith =>
      __$$ContactResponseDtoImplCopyWithImpl<_$ContactResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactResponseDtoImplToJson(this);
  }
}

abstract class _ContactResponseDto implements ContactResponseDto {
  const factory _ContactResponseDto({
    required final String id,
    @JsonKey(name: 'shop_id') final String? shopId,
  }) = _$ContactResponseDtoImpl;

  factory _ContactResponseDto.fromJson(Map<String, dynamic> json) =
      _$ContactResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'shop_id')
  String? get shopId;

  /// Create a copy of ContactResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactResponseDtoImplCopyWith<_$ContactResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ContactCreateRequest _$ContactCreateRequestFromJson(Map<String, dynamic> json) {
  return _ContactCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$ContactCreateRequest {
  @JsonKey(name: 'shop_id')
  String get shopId => throw _privateConstructorUsedError;

  /// Serializes this ContactCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContactCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContactCreateRequestCopyWith<ContactCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContactCreateRequestCopyWith<$Res> {
  factory $ContactCreateRequestCopyWith(
    ContactCreateRequest value,
    $Res Function(ContactCreateRequest) then,
  ) = _$ContactCreateRequestCopyWithImpl<$Res, ContactCreateRequest>;
  @useResult
  $Res call({@JsonKey(name: 'shop_id') String shopId});
}

/// @nodoc
class _$ContactCreateRequestCopyWithImpl<
  $Res,
  $Val extends ContactCreateRequest
>
    implements $ContactCreateRequestCopyWith<$Res> {
  _$ContactCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContactCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? shopId = null}) {
    return _then(
      _value.copyWith(
            shopId: null == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContactCreateRequestImplCopyWith<$Res>
    implements $ContactCreateRequestCopyWith<$Res> {
  factory _$$ContactCreateRequestImplCopyWith(
    _$ContactCreateRequestImpl value,
    $Res Function(_$ContactCreateRequestImpl) then,
  ) = __$$ContactCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'shop_id') String shopId});
}

/// @nodoc
class __$$ContactCreateRequestImplCopyWithImpl<$Res>
    extends _$ContactCreateRequestCopyWithImpl<$Res, _$ContactCreateRequestImpl>
    implements _$$ContactCreateRequestImplCopyWith<$Res> {
  __$$ContactCreateRequestImplCopyWithImpl(
    _$ContactCreateRequestImpl _value,
    $Res Function(_$ContactCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContactCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? shopId = null}) {
    return _then(
      _$ContactCreateRequestImpl(
        shopId: null == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactCreateRequestImpl implements _ContactCreateRequest {
  const _$ContactCreateRequestImpl({
    @JsonKey(name: 'shop_id') required this.shopId,
  });

  factory _$ContactCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactCreateRequestImplFromJson(json);

  @override
  @JsonKey(name: 'shop_id')
  final String shopId;

  @override
  String toString() {
    return 'ContactCreateRequest(shopId: $shopId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactCreateRequestImpl &&
            (identical(other.shopId, shopId) || other.shopId == shopId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, shopId);

  /// Create a copy of ContactCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactCreateRequestImplCopyWith<_$ContactCreateRequestImpl>
  get copyWith =>
      __$$ContactCreateRequestImplCopyWithImpl<_$ContactCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactCreateRequestImplToJson(this);
  }
}

abstract class _ContactCreateRequest implements ContactCreateRequest {
  const factory _ContactCreateRequest({
    @JsonKey(name: 'shop_id') required final String shopId,
  }) = _$ContactCreateRequestImpl;

  factory _ContactCreateRequest.fromJson(Map<String, dynamic> json) =
      _$ContactCreateRequestImpl.fromJson;

  @override
  @JsonKey(name: 'shop_id')
  String get shopId;

  /// Create a copy of ContactCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactCreateRequestImplCopyWith<_$ContactCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
