// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RoleResponseDto _$RoleResponseDtoFromJson(Map<String, dynamic> json) {
  return _RoleResponseDto.fromJson(json);
}

/// @nodoc
mixin _$RoleResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this RoleResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoleResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoleResponseDtoCopyWith<RoleResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoleResponseDtoCopyWith<$Res> {
  factory $RoleResponseDtoCopyWith(
    RoleResponseDto value,
    $Res Function(RoleResponseDto) then,
  ) = _$RoleResponseDtoCopyWithImpl<$Res, RoleResponseDto>;
  @useResult
  $Res call({String id, String name, String type});
}

/// @nodoc
class _$RoleResponseDtoCopyWithImpl<$Res, $Val extends RoleResponseDto>
    implements $RoleResponseDtoCopyWith<$Res> {
  _$RoleResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoleResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? type = null}) {
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoleResponseDtoImplCopyWith<$Res>
    implements $RoleResponseDtoCopyWith<$Res> {
  factory _$$RoleResponseDtoImplCopyWith(
    _$RoleResponseDtoImpl value,
    $Res Function(_$RoleResponseDtoImpl) then,
  ) = __$$RoleResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String type});
}

/// @nodoc
class __$$RoleResponseDtoImplCopyWithImpl<$Res>
    extends _$RoleResponseDtoCopyWithImpl<$Res, _$RoleResponseDtoImpl>
    implements _$$RoleResponseDtoImplCopyWith<$Res> {
  __$$RoleResponseDtoImplCopyWithImpl(
    _$RoleResponseDtoImpl _value,
    $Res Function(_$RoleResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoleResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? type = null}) {
    return _then(
      _$RoleResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoleResponseDtoImpl implements _RoleResponseDto {
  const _$RoleResponseDtoImpl({
    required this.id,
    required this.name,
    required this.type,
  });

  factory _$RoleResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoleResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;

  @override
  String toString() {
    return 'RoleResponseDto(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoleResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type);

  /// Create a copy of RoleResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoleResponseDtoImplCopyWith<_$RoleResponseDtoImpl> get copyWith =>
      __$$RoleResponseDtoImplCopyWithImpl<_$RoleResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RoleResponseDtoImplToJson(this);
  }
}

abstract class _RoleResponseDto implements RoleResponseDto {
  const factory _RoleResponseDto({
    required final String id,
    required final String name,
    required final String type,
  }) = _$RoleResponseDtoImpl;

  factory _RoleResponseDto.fromJson(Map<String, dynamic> json) =
      _$RoleResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;

  /// Create a copy of RoleResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoleResponseDtoImplCopyWith<_$RoleResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoleCreateRequest _$RoleCreateRequestFromJson(Map<String, dynamic> json) {
  return _RoleCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$RoleCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this RoleCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoleCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoleCreateRequestCopyWith<RoleCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoleCreateRequestCopyWith<$Res> {
  factory $RoleCreateRequestCopyWith(
    RoleCreateRequest value,
    $Res Function(RoleCreateRequest) then,
  ) = _$RoleCreateRequestCopyWithImpl<$Res, RoleCreateRequest>;
  @useResult
  $Res call({String name, String type});
}

/// @nodoc
class _$RoleCreateRequestCopyWithImpl<$Res, $Val extends RoleCreateRequest>
    implements $RoleCreateRequestCopyWith<$Res> {
  _$RoleCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoleCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? type = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoleCreateRequestImplCopyWith<$Res>
    implements $RoleCreateRequestCopyWith<$Res> {
  factory _$$RoleCreateRequestImplCopyWith(
    _$RoleCreateRequestImpl value,
    $Res Function(_$RoleCreateRequestImpl) then,
  ) = __$$RoleCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String type});
}

/// @nodoc
class __$$RoleCreateRequestImplCopyWithImpl<$Res>
    extends _$RoleCreateRequestCopyWithImpl<$Res, _$RoleCreateRequestImpl>
    implements _$$RoleCreateRequestImplCopyWith<$Res> {
  __$$RoleCreateRequestImplCopyWithImpl(
    _$RoleCreateRequestImpl _value,
    $Res Function(_$RoleCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoleCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? type = null}) {
    return _then(
      _$RoleCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoleCreateRequestImpl implements _RoleCreateRequest {
  const _$RoleCreateRequestImpl({required this.name, required this.type});

  factory _$RoleCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoleCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String type;

  @override
  String toString() {
    return 'RoleCreateRequest(name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoleCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, type);

  /// Create a copy of RoleCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoleCreateRequestImplCopyWith<_$RoleCreateRequestImpl> get copyWith =>
      __$$RoleCreateRequestImplCopyWithImpl<_$RoleCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RoleCreateRequestImplToJson(this);
  }
}

abstract class _RoleCreateRequest implements RoleCreateRequest {
  const factory _RoleCreateRequest({
    required final String name,
    required final String type,
  }) = _$RoleCreateRequestImpl;

  factory _RoleCreateRequest.fromJson(Map<String, dynamic> json) =
      _$RoleCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get type;

  /// Create a copy of RoleCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoleCreateRequestImplCopyWith<_$RoleCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
