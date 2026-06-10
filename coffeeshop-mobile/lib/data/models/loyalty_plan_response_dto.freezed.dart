// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loyalty_plan_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoyaltyPlanResponseDto _$LoyaltyPlanResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _LoyaltyPlanResponseDto.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyPlanResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyPlanResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyPlanResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyPlanResponseDtoCopyWith<LoyaltyPlanResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyPlanResponseDtoCopyWith<$Res> {
  factory $LoyaltyPlanResponseDtoCopyWith(
    LoyaltyPlanResponseDto value,
    $Res Function(LoyaltyPlanResponseDto) then,
  ) = _$LoyaltyPlanResponseDtoCopyWithImpl<$Res, LoyaltyPlanResponseDto>;
  @useResult
  $Res call({String id, String name, String? description, String type});
}

/// @nodoc
class _$LoyaltyPlanResponseDtoCopyWithImpl<
  $Res,
  $Val extends LoyaltyPlanResponseDto
>
    implements $LoyaltyPlanResponseDtoCopyWith<$Res> {
  _$LoyaltyPlanResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyPlanResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
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
abstract class _$$LoyaltyPlanResponseDtoImplCopyWith<$Res>
    implements $LoyaltyPlanResponseDtoCopyWith<$Res> {
  factory _$$LoyaltyPlanResponseDtoImplCopyWith(
    _$LoyaltyPlanResponseDtoImpl value,
    $Res Function(_$LoyaltyPlanResponseDtoImpl) then,
  ) = __$$LoyaltyPlanResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? description, String type});
}

/// @nodoc
class __$$LoyaltyPlanResponseDtoImplCopyWithImpl<$Res>
    extends
        _$LoyaltyPlanResponseDtoCopyWithImpl<$Res, _$LoyaltyPlanResponseDtoImpl>
    implements _$$LoyaltyPlanResponseDtoImplCopyWith<$Res> {
  __$$LoyaltyPlanResponseDtoImplCopyWithImpl(
    _$LoyaltyPlanResponseDtoImpl _value,
    $Res Function(_$LoyaltyPlanResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoyaltyPlanResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
  }) {
    return _then(
      _$LoyaltyPlanResponseDtoImpl(
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
class _$LoyaltyPlanResponseDtoImpl implements _LoyaltyPlanResponseDto {
  const _$LoyaltyPlanResponseDtoImpl({
    required this.id,
    required this.name,
    this.description,
    required this.type,
  });

  factory _$LoyaltyPlanResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyPlanResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String type;

  @override
  String toString() {
    return 'LoyaltyPlanResponseDto(id: $id, name: $name, description: $description, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyPlanResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, type);

  /// Create a copy of LoyaltyPlanResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyPlanResponseDtoImplCopyWith<_$LoyaltyPlanResponseDtoImpl>
  get copyWith =>
      __$$LoyaltyPlanResponseDtoImplCopyWithImpl<_$LoyaltyPlanResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyPlanResponseDtoImplToJson(this);
  }
}

abstract class _LoyaltyPlanResponseDto implements LoyaltyPlanResponseDto {
  const factory _LoyaltyPlanResponseDto({
    required final String id,
    required final String name,
    final String? description,
    required final String type,
  }) = _$LoyaltyPlanResponseDtoImpl;

  factory _LoyaltyPlanResponseDto.fromJson(Map<String, dynamic> json) =
      _$LoyaltyPlanResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get type;

  /// Create a copy of LoyaltyPlanResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyPlanResponseDtoImplCopyWith<_$LoyaltyPlanResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LoyaltyPlanCreateRequest _$LoyaltyPlanCreateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _LoyaltyPlanCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyPlanCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyPlanCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyPlanCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyPlanCreateRequestCopyWith<LoyaltyPlanCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyPlanCreateRequestCopyWith<$Res> {
  factory $LoyaltyPlanCreateRequestCopyWith(
    LoyaltyPlanCreateRequest value,
    $Res Function(LoyaltyPlanCreateRequest) then,
  ) = _$LoyaltyPlanCreateRequestCopyWithImpl<$Res, LoyaltyPlanCreateRequest>;
  @useResult
  $Res call({String name, String? description, String type});
}

/// @nodoc
class _$LoyaltyPlanCreateRequestCopyWithImpl<
  $Res,
  $Val extends LoyaltyPlanCreateRequest
>
    implements $LoyaltyPlanCreateRequestCopyWith<$Res> {
  _$LoyaltyPlanCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyPlanCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
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
abstract class _$$LoyaltyPlanCreateRequestImplCopyWith<$Res>
    implements $LoyaltyPlanCreateRequestCopyWith<$Res> {
  factory _$$LoyaltyPlanCreateRequestImplCopyWith(
    _$LoyaltyPlanCreateRequestImpl value,
    $Res Function(_$LoyaltyPlanCreateRequestImpl) then,
  ) = __$$LoyaltyPlanCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? description, String type});
}

/// @nodoc
class __$$LoyaltyPlanCreateRequestImplCopyWithImpl<$Res>
    extends
        _$LoyaltyPlanCreateRequestCopyWithImpl<
          $Res,
          _$LoyaltyPlanCreateRequestImpl
        >
    implements _$$LoyaltyPlanCreateRequestImplCopyWith<$Res> {
  __$$LoyaltyPlanCreateRequestImplCopyWithImpl(
    _$LoyaltyPlanCreateRequestImpl _value,
    $Res Function(_$LoyaltyPlanCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoyaltyPlanCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
  }) {
    return _then(
      _$LoyaltyPlanCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$LoyaltyPlanCreateRequestImpl implements _LoyaltyPlanCreateRequest {
  const _$LoyaltyPlanCreateRequestImpl({
    required this.name,
    this.description,
    required this.type,
  });

  factory _$LoyaltyPlanCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyPlanCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final String type;

  @override
  String toString() {
    return 'LoyaltyPlanCreateRequest(name: $name, description: $description, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyPlanCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, description, type);

  /// Create a copy of LoyaltyPlanCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyPlanCreateRequestImplCopyWith<_$LoyaltyPlanCreateRequestImpl>
  get copyWith =>
      __$$LoyaltyPlanCreateRequestImplCopyWithImpl<
        _$LoyaltyPlanCreateRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyPlanCreateRequestImplToJson(this);
  }
}

abstract class _LoyaltyPlanCreateRequest implements LoyaltyPlanCreateRequest {
  const factory _LoyaltyPlanCreateRequest({
    required final String name,
    final String? description,
    required final String type,
  }) = _$LoyaltyPlanCreateRequestImpl;

  factory _LoyaltyPlanCreateRequest.fromJson(Map<String, dynamic> json) =
      _$LoyaltyPlanCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  String get type;

  /// Create a copy of LoyaltyPlanCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyPlanCreateRequestImplCopyWith<_$LoyaltyPlanCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
