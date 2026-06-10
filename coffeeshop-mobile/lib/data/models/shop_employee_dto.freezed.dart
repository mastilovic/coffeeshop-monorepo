// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_employee_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShopEmployeeDto _$ShopEmployeeDtoFromJson(Map<String, dynamic> json) {
  return _ShopEmployeeDto.fromJson(json);
}

/// @nodoc
mixin _$ShopEmployeeDto {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_id')
  String get shopId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_owner')
  bool get isOwner => throw _privateConstructorUsedError;

  /// Serializes this ShopEmployeeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopEmployeeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopEmployeeDtoCopyWith<ShopEmployeeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopEmployeeDtoCopyWith<$Res> {
  factory $ShopEmployeeDtoCopyWith(
    ShopEmployeeDto value,
    $Res Function(ShopEmployeeDto) then,
  ) = _$ShopEmployeeDtoCopyWithImpl<$Res, ShopEmployeeDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'shop_id') String shopId,
    String name,
    String email,
    @JsonKey(name: 'is_owner') bool isOwner,
  });
}

/// @nodoc
class _$ShopEmployeeDtoCopyWithImpl<$Res, $Val extends ShopEmployeeDto>
    implements $ShopEmployeeDtoCopyWith<$Res> {
  _$ShopEmployeeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopEmployeeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? shopId = null,
    Object? name = null,
    Object? email = null,
    Object? isOwner = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            shopId: null == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            isOwner: null == isOwner
                ? _value.isOwner
                : isOwner // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShopEmployeeDtoImplCopyWith<$Res>
    implements $ShopEmployeeDtoCopyWith<$Res> {
  factory _$$ShopEmployeeDtoImplCopyWith(
    _$ShopEmployeeDtoImpl value,
    $Res Function(_$ShopEmployeeDtoImpl) then,
  ) = __$$ShopEmployeeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'shop_id') String shopId,
    String name,
    String email,
    @JsonKey(name: 'is_owner') bool isOwner,
  });
}

/// @nodoc
class __$$ShopEmployeeDtoImplCopyWithImpl<$Res>
    extends _$ShopEmployeeDtoCopyWithImpl<$Res, _$ShopEmployeeDtoImpl>
    implements _$$ShopEmployeeDtoImplCopyWith<$Res> {
  __$$ShopEmployeeDtoImplCopyWithImpl(
    _$ShopEmployeeDtoImpl _value,
    $Res Function(_$ShopEmployeeDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShopEmployeeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? shopId = null,
    Object? name = null,
    Object? email = null,
    Object? isOwner = null,
  }) {
    return _then(
      _$ShopEmployeeDtoImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        shopId: null == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        isOwner: null == isOwner
            ? _value.isOwner
            : isOwner // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopEmployeeDtoImpl implements _ShopEmployeeDto {
  const _$ShopEmployeeDtoImpl({
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'shop_id') required this.shopId,
    required this.name,
    required this.email,
    @JsonKey(name: 'is_owner') this.isOwner = false,
  });

  factory _$ShopEmployeeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopEmployeeDtoImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'shop_id')
  final String shopId;
  @override
  final String name;
  @override
  final String email;
  @override
  @JsonKey(name: 'is_owner')
  final bool isOwner;

  @override
  String toString() {
    return 'ShopEmployeeDto(userId: $userId, shopId: $shopId, name: $name, email: $email, isOwner: $isOwner)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopEmployeeDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isOwner, isOwner) || other.isOwner == isOwner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, shopId, name, email, isOwner);

  /// Create a copy of ShopEmployeeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopEmployeeDtoImplCopyWith<_$ShopEmployeeDtoImpl> get copyWith =>
      __$$ShopEmployeeDtoImplCopyWithImpl<_$ShopEmployeeDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopEmployeeDtoImplToJson(this);
  }
}

abstract class _ShopEmployeeDto implements ShopEmployeeDto {
  const factory _ShopEmployeeDto({
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'shop_id') required final String shopId,
    required final String name,
    required final String email,
    @JsonKey(name: 'is_owner') final bool isOwner,
  }) = _$ShopEmployeeDtoImpl;

  factory _ShopEmployeeDto.fromJson(Map<String, dynamic> json) =
      _$ShopEmployeeDtoImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'shop_id')
  String get shopId;
  @override
  String get name;
  @override
  String get email;
  @override
  @JsonKey(name: 'is_owner')
  bool get isOwner;

  /// Create a copy of ShopEmployeeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopEmployeeDtoImplCopyWith<_$ShopEmployeeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssignEmployeeRequest _$AssignEmployeeRequestFromJson(
  Map<String, dynamic> json,
) {
  return _AssignEmployeeRequest.fromJson(json);
}

/// @nodoc
mixin _$AssignEmployeeRequest {
  @JsonKey(name: 'shop_id')
  String get shopId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this AssignEmployeeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignEmployeeRequestCopyWith<AssignEmployeeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignEmployeeRequestCopyWith<$Res> {
  factory $AssignEmployeeRequestCopyWith(
    AssignEmployeeRequest value,
    $Res Function(AssignEmployeeRequest) then,
  ) = _$AssignEmployeeRequestCopyWithImpl<$Res, AssignEmployeeRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'shop_id') String shopId,
    @JsonKey(name: 'user_id') String userId,
  });
}

/// @nodoc
class _$AssignEmployeeRequestCopyWithImpl<
  $Res,
  $Val extends AssignEmployeeRequest
>
    implements $AssignEmployeeRequestCopyWith<$Res> {
  _$AssignEmployeeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? shopId = null, Object? userId = null}) {
    return _then(
      _value.copyWith(
            shopId: null == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignEmployeeRequestImplCopyWith<$Res>
    implements $AssignEmployeeRequestCopyWith<$Res> {
  factory _$$AssignEmployeeRequestImplCopyWith(
    _$AssignEmployeeRequestImpl value,
    $Res Function(_$AssignEmployeeRequestImpl) then,
  ) = __$$AssignEmployeeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'shop_id') String shopId,
    @JsonKey(name: 'user_id') String userId,
  });
}

/// @nodoc
class __$$AssignEmployeeRequestImplCopyWithImpl<$Res>
    extends
        _$AssignEmployeeRequestCopyWithImpl<$Res, _$AssignEmployeeRequestImpl>
    implements _$$AssignEmployeeRequestImplCopyWith<$Res> {
  __$$AssignEmployeeRequestImplCopyWithImpl(
    _$AssignEmployeeRequestImpl _value,
    $Res Function(_$AssignEmployeeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? shopId = null, Object? userId = null}) {
    return _then(
      _$AssignEmployeeRequestImpl(
        shopId: null == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignEmployeeRequestImpl implements _AssignEmployeeRequest {
  const _$AssignEmployeeRequestImpl({
    @JsonKey(name: 'shop_id') required this.shopId,
    @JsonKey(name: 'user_id') required this.userId,
  });

  factory _$AssignEmployeeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignEmployeeRequestImplFromJson(json);

  @override
  @JsonKey(name: 'shop_id')
  final String shopId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  @override
  String toString() {
    return 'AssignEmployeeRequest(shopId: $shopId, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignEmployeeRequestImpl &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, shopId, userId);

  /// Create a copy of AssignEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignEmployeeRequestImplCopyWith<_$AssignEmployeeRequestImpl>
  get copyWith =>
      __$$AssignEmployeeRequestImplCopyWithImpl<_$AssignEmployeeRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignEmployeeRequestImplToJson(this);
  }
}

abstract class _AssignEmployeeRequest implements AssignEmployeeRequest {
  const factory _AssignEmployeeRequest({
    @JsonKey(name: 'shop_id') required final String shopId,
    @JsonKey(name: 'user_id') required final String userId,
  }) = _$AssignEmployeeRequestImpl;

  factory _AssignEmployeeRequest.fromJson(Map<String, dynamic> json) =
      _$AssignEmployeeRequestImpl.fromJson;

  @override
  @JsonKey(name: 'shop_id')
  String get shopId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// Create a copy of AssignEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignEmployeeRequestImplCopyWith<_$AssignEmployeeRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RemoveEmployeeRequest _$RemoveEmployeeRequestFromJson(
  Map<String, dynamic> json,
) {
  return _RemoveEmployeeRequest.fromJson(json);
}

/// @nodoc
mixin _$RemoveEmployeeRequest {
  @JsonKey(name: 'shop_id')
  String get shopId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this RemoveEmployeeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RemoveEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RemoveEmployeeRequestCopyWith<RemoveEmployeeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoveEmployeeRequestCopyWith<$Res> {
  factory $RemoveEmployeeRequestCopyWith(
    RemoveEmployeeRequest value,
    $Res Function(RemoveEmployeeRequest) then,
  ) = _$RemoveEmployeeRequestCopyWithImpl<$Res, RemoveEmployeeRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'shop_id') String shopId,
    @JsonKey(name: 'user_id') String userId,
  });
}

/// @nodoc
class _$RemoveEmployeeRequestCopyWithImpl<
  $Res,
  $Val extends RemoveEmployeeRequest
>
    implements $RemoveEmployeeRequestCopyWith<$Res> {
  _$RemoveEmployeeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RemoveEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? shopId = null, Object? userId = null}) {
    return _then(
      _value.copyWith(
            shopId: null == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RemoveEmployeeRequestImplCopyWith<$Res>
    implements $RemoveEmployeeRequestCopyWith<$Res> {
  factory _$$RemoveEmployeeRequestImplCopyWith(
    _$RemoveEmployeeRequestImpl value,
    $Res Function(_$RemoveEmployeeRequestImpl) then,
  ) = __$$RemoveEmployeeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'shop_id') String shopId,
    @JsonKey(name: 'user_id') String userId,
  });
}

/// @nodoc
class __$$RemoveEmployeeRequestImplCopyWithImpl<$Res>
    extends
        _$RemoveEmployeeRequestCopyWithImpl<$Res, _$RemoveEmployeeRequestImpl>
    implements _$$RemoveEmployeeRequestImplCopyWith<$Res> {
  __$$RemoveEmployeeRequestImplCopyWithImpl(
    _$RemoveEmployeeRequestImpl _value,
    $Res Function(_$RemoveEmployeeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RemoveEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? shopId = null, Object? userId = null}) {
    return _then(
      _$RemoveEmployeeRequestImpl(
        shopId: null == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RemoveEmployeeRequestImpl implements _RemoveEmployeeRequest {
  const _$RemoveEmployeeRequestImpl({
    @JsonKey(name: 'shop_id') required this.shopId,
    @JsonKey(name: 'user_id') required this.userId,
  });

  factory _$RemoveEmployeeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RemoveEmployeeRequestImplFromJson(json);

  @override
  @JsonKey(name: 'shop_id')
  final String shopId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  @override
  String toString() {
    return 'RemoveEmployeeRequest(shopId: $shopId, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoveEmployeeRequestImpl &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, shopId, userId);

  /// Create a copy of RemoveEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoveEmployeeRequestImplCopyWith<_$RemoveEmployeeRequestImpl>
  get copyWith =>
      __$$RemoveEmployeeRequestImplCopyWithImpl<_$RemoveEmployeeRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RemoveEmployeeRequestImplToJson(this);
  }
}

abstract class _RemoveEmployeeRequest implements RemoveEmployeeRequest {
  const factory _RemoveEmployeeRequest({
    @JsonKey(name: 'shop_id') required final String shopId,
    @JsonKey(name: 'user_id') required final String userId,
  }) = _$RemoveEmployeeRequestImpl;

  factory _RemoveEmployeeRequest.fromJson(Map<String, dynamic> json) =
      _$RemoveEmployeeRequestImpl.fromJson;

  @override
  @JsonKey(name: 'shop_id')
  String get shopId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// Create a copy of RemoveEmployeeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RemoveEmployeeRequestImplCopyWith<_$RemoveEmployeeRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
