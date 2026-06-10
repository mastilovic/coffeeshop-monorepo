// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'table_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TableResponseDto _$TableResponseDtoFromJson(Map<String, dynamic> json) {
  return _TableResponseDto.fromJson(json);
}

/// @nodoc
mixin _$TableResponseDto {
  String get id => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_id')
  String? get shopId => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get reservations =>
      throw _privateConstructorUsedError;

  /// Serializes this TableResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TableResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TableResponseDtoCopyWith<TableResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TableResponseDtoCopyWith<$Res> {
  factory $TableResponseDtoCopyWith(
    TableResponseDto value,
    $Res Function(TableResponseDto) then,
  ) = _$TableResponseDtoCopyWithImpl<$Res, TableResponseDto>;
  @useResult
  $Res call({
    String id,
    int number,
    int capacity,
    @JsonKey(name: 'shop_id') String? shopId,
    List<Map<String, dynamic>> reservations,
  });
}

/// @nodoc
class _$TableResponseDtoCopyWithImpl<$Res, $Val extends TableResponseDto>
    implements $TableResponseDtoCopyWith<$Res> {
  _$TableResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TableResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? capacity = null,
    Object? shopId = freezed,
    Object? reservations = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            number: null == number
                ? _value.number
                : number // ignore: cast_nullable_to_non_nullable
                      as int,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            reservations: null == reservations
                ? _value.reservations
                : reservations // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TableResponseDtoImplCopyWith<$Res>
    implements $TableResponseDtoCopyWith<$Res> {
  factory _$$TableResponseDtoImplCopyWith(
    _$TableResponseDtoImpl value,
    $Res Function(_$TableResponseDtoImpl) then,
  ) = __$$TableResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int number,
    int capacity,
    @JsonKey(name: 'shop_id') String? shopId,
    List<Map<String, dynamic>> reservations,
  });
}

/// @nodoc
class __$$TableResponseDtoImplCopyWithImpl<$Res>
    extends _$TableResponseDtoCopyWithImpl<$Res, _$TableResponseDtoImpl>
    implements _$$TableResponseDtoImplCopyWith<$Res> {
  __$$TableResponseDtoImplCopyWithImpl(
    _$TableResponseDtoImpl _value,
    $Res Function(_$TableResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TableResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? capacity = null,
    Object? shopId = freezed,
    Object? reservations = null,
  }) {
    return _then(
      _$TableResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        number: null == number
            ? _value.number
            : number // ignore: cast_nullable_to_non_nullable
                  as int,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        reservations: null == reservations
            ? _value._reservations
            : reservations // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TableResponseDtoImpl implements _TableResponseDto {
  const _$TableResponseDtoImpl({
    required this.id,
    required this.number,
    required this.capacity,
    @JsonKey(name: 'shop_id') this.shopId,
    final List<Map<String, dynamic>> reservations = const [],
  }) : _reservations = reservations;

  factory _$TableResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TableResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final int number;
  @override
  final int capacity;
  @override
  @JsonKey(name: 'shop_id')
  final String? shopId;
  final List<Map<String, dynamic>> _reservations;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get reservations {
    if (_reservations is EqualUnmodifiableListView) return _reservations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reservations);
  }

  @override
  String toString() {
    return 'TableResponseDto(id: $id, number: $number, capacity: $capacity, shopId: $shopId, reservations: $reservations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TableResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            const DeepCollectionEquality().equals(
              other._reservations,
              _reservations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    number,
    capacity,
    shopId,
    const DeepCollectionEquality().hash(_reservations),
  );

  /// Create a copy of TableResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TableResponseDtoImplCopyWith<_$TableResponseDtoImpl> get copyWith =>
      __$$TableResponseDtoImplCopyWithImpl<_$TableResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TableResponseDtoImplToJson(this);
  }
}

abstract class _TableResponseDto implements TableResponseDto {
  const factory _TableResponseDto({
    required final String id,
    required final int number,
    required final int capacity,
    @JsonKey(name: 'shop_id') final String? shopId,
    final List<Map<String, dynamic>> reservations,
  }) = _$TableResponseDtoImpl;

  factory _TableResponseDto.fromJson(Map<String, dynamic> json) =
      _$TableResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  int get number;
  @override
  int get capacity;
  @override
  @JsonKey(name: 'shop_id')
  String? get shopId;
  @override
  List<Map<String, dynamic>> get reservations;

  /// Create a copy of TableResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TableResponseDtoImplCopyWith<_$TableResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TableSummaryDto _$TableSummaryDtoFromJson(Map<String, dynamic> json) {
  return _TableSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$TableSummaryDto {
  String get id => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;

  /// Serializes this TableSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TableSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TableSummaryDtoCopyWith<TableSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TableSummaryDtoCopyWith<$Res> {
  factory $TableSummaryDtoCopyWith(
    TableSummaryDto value,
    $Res Function(TableSummaryDto) then,
  ) = _$TableSummaryDtoCopyWithImpl<$Res, TableSummaryDto>;
  @useResult
  $Res call({String id, int number, int capacity});
}

/// @nodoc
class _$TableSummaryDtoCopyWithImpl<$Res, $Val extends TableSummaryDto>
    implements $TableSummaryDtoCopyWith<$Res> {
  _$TableSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TableSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? capacity = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            number: null == number
                ? _value.number
                : number // ignore: cast_nullable_to_non_nullable
                      as int,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TableSummaryDtoImplCopyWith<$Res>
    implements $TableSummaryDtoCopyWith<$Res> {
  factory _$$TableSummaryDtoImplCopyWith(
    _$TableSummaryDtoImpl value,
    $Res Function(_$TableSummaryDtoImpl) then,
  ) = __$$TableSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int number, int capacity});
}

/// @nodoc
class __$$TableSummaryDtoImplCopyWithImpl<$Res>
    extends _$TableSummaryDtoCopyWithImpl<$Res, _$TableSummaryDtoImpl>
    implements _$$TableSummaryDtoImplCopyWith<$Res> {
  __$$TableSummaryDtoImplCopyWithImpl(
    _$TableSummaryDtoImpl _value,
    $Res Function(_$TableSummaryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TableSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? capacity = null,
  }) {
    return _then(
      _$TableSummaryDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        number: null == number
            ? _value.number
            : number // ignore: cast_nullable_to_non_nullable
                  as int,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TableSummaryDtoImpl implements _TableSummaryDto {
  const _$TableSummaryDtoImpl({
    required this.id,
    required this.number,
    required this.capacity,
  });

  factory _$TableSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TableSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  final int number;
  @override
  final int capacity;

  @override
  String toString() {
    return 'TableSummaryDto(id: $id, number: $number, capacity: $capacity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TableSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, number, capacity);

  /// Create a copy of TableSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TableSummaryDtoImplCopyWith<_$TableSummaryDtoImpl> get copyWith =>
      __$$TableSummaryDtoImplCopyWithImpl<_$TableSummaryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TableSummaryDtoImplToJson(this);
  }
}

abstract class _TableSummaryDto implements TableSummaryDto {
  const factory _TableSummaryDto({
    required final String id,
    required final int number,
    required final int capacity,
  }) = _$TableSummaryDtoImpl;

  factory _TableSummaryDto.fromJson(Map<String, dynamic> json) =
      _$TableSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  int get number;
  @override
  int get capacity;

  /// Create a copy of TableSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TableSummaryDtoImplCopyWith<_$TableSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TableCreateRequest _$TableCreateRequestFromJson(Map<String, dynamic> json) {
  return _TableCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$TableCreateRequest {
  int get number => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_id')
  String get shopId => throw _privateConstructorUsedError;

  /// Serializes this TableCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TableCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TableCreateRequestCopyWith<TableCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TableCreateRequestCopyWith<$Res> {
  factory $TableCreateRequestCopyWith(
    TableCreateRequest value,
    $Res Function(TableCreateRequest) then,
  ) = _$TableCreateRequestCopyWithImpl<$Res, TableCreateRequest>;
  @useResult
  $Res call({
    int number,
    int capacity,
    @JsonKey(name: 'shop_id') String shopId,
  });
}

/// @nodoc
class _$TableCreateRequestCopyWithImpl<$Res, $Val extends TableCreateRequest>
    implements $TableCreateRequestCopyWith<$Res> {
  _$TableCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TableCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? capacity = null,
    Object? shopId = null,
  }) {
    return _then(
      _value.copyWith(
            number: null == number
                ? _value.number
                : number // ignore: cast_nullable_to_non_nullable
                      as int,
            capacity: null == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$TableCreateRequestImplCopyWith<$Res>
    implements $TableCreateRequestCopyWith<$Res> {
  factory _$$TableCreateRequestImplCopyWith(
    _$TableCreateRequestImpl value,
    $Res Function(_$TableCreateRequestImpl) then,
  ) = __$$TableCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int number,
    int capacity,
    @JsonKey(name: 'shop_id') String shopId,
  });
}

/// @nodoc
class __$$TableCreateRequestImplCopyWithImpl<$Res>
    extends _$TableCreateRequestCopyWithImpl<$Res, _$TableCreateRequestImpl>
    implements _$$TableCreateRequestImplCopyWith<$Res> {
  __$$TableCreateRequestImplCopyWithImpl(
    _$TableCreateRequestImpl _value,
    $Res Function(_$TableCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TableCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? capacity = null,
    Object? shopId = null,
  }) {
    return _then(
      _$TableCreateRequestImpl(
        number: null == number
            ? _value.number
            : number // ignore: cast_nullable_to_non_nullable
                  as int,
        capacity: null == capacity
            ? _value.capacity
            : capacity // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$TableCreateRequestImpl implements _TableCreateRequest {
  const _$TableCreateRequestImpl({
    required this.number,
    required this.capacity,
    @JsonKey(name: 'shop_id') required this.shopId,
  });

  factory _$TableCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TableCreateRequestImplFromJson(json);

  @override
  final int number;
  @override
  final int capacity;
  @override
  @JsonKey(name: 'shop_id')
  final String shopId;

  @override
  String toString() {
    return 'TableCreateRequest(number: $number, capacity: $capacity, shopId: $shopId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TableCreateRequestImpl &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.shopId, shopId) || other.shopId == shopId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, number, capacity, shopId);

  /// Create a copy of TableCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TableCreateRequestImplCopyWith<_$TableCreateRequestImpl> get copyWith =>
      __$$TableCreateRequestImplCopyWithImpl<_$TableCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TableCreateRequestImplToJson(this);
  }
}

abstract class _TableCreateRequest implements TableCreateRequest {
  const factory _TableCreateRequest({
    required final int number,
    required final int capacity,
    @JsonKey(name: 'shop_id') required final String shopId,
  }) = _$TableCreateRequestImpl;

  factory _TableCreateRequest.fromJson(Map<String, dynamic> json) =
      _$TableCreateRequestImpl.fromJson;

  @override
  int get number;
  @override
  int get capacity;
  @override
  @JsonKey(name: 'shop_id')
  String get shopId;

  /// Create a copy of TableCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TableCreateRequestImplCopyWith<_$TableCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
