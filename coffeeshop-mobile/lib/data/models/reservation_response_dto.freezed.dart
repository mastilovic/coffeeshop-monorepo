// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReservationResponseDto _$ReservationResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ReservationResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ReservationResponseDto {
  String get id => throw _privateConstructorUsedError;
  int get partySize => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get shopId => throw _privateConstructorUsedError;
  String? get tableId => throw _privateConstructorUsedError;
  String? get eventId => throw _privateConstructorUsedError;
  String? get reservationRequestId => throw _privateConstructorUsedError;
  String? get eventName => throw _privateConstructorUsedError;
  String? get eventDate => throw _privateConstructorUsedError;
  Map<String, dynamic>? get user => throw _privateConstructorUsedError;
  Map<String, dynamic>? get shop => throw _privateConstructorUsedError;
  Map<String, dynamic>? get table => throw _privateConstructorUsedError;

  /// Serializes this ReservationResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReservationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationResponseDtoCopyWith<ReservationResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationResponseDtoCopyWith<$Res> {
  factory $ReservationResponseDtoCopyWith(
    ReservationResponseDto value,
    $Res Function(ReservationResponseDto) then,
  ) = _$ReservationResponseDtoCopyWithImpl<$Res, ReservationResponseDto>;
  @useResult
  $Res call({
    String id,
    int partySize,
    String? userId,
    String? shopId,
    String? tableId,
    String? eventId,
    String? reservationRequestId,
    String? eventName,
    String? eventDate,
    Map<String, dynamic>? user,
    Map<String, dynamic>? shop,
    Map<String, dynamic>? table,
  });
}

/// @nodoc
class _$ReservationResponseDtoCopyWithImpl<
  $Res,
  $Val extends ReservationResponseDto
>
    implements $ReservationResponseDtoCopyWith<$Res> {
  _$ReservationResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? partySize = null,
    Object? userId = freezed,
    Object? shopId = freezed,
    Object? tableId = freezed,
    Object? eventId = freezed,
    Object? reservationRequestId = freezed,
    Object? eventName = freezed,
    Object? eventDate = freezed,
    Object? user = freezed,
    Object? shop = freezed,
    Object? table = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            partySize: null == partySize
                ? _value.partySize
                : partySize // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            tableId: freezed == tableId
                ? _value.tableId
                : tableId // ignore: cast_nullable_to_non_nullable
                      as String?,
            eventId: freezed == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String?,
            reservationRequestId: freezed == reservationRequestId
                ? _value.reservationRequestId
                : reservationRequestId // ignore: cast_nullable_to_non_nullable
                      as String?,
            eventName: freezed == eventName
                ? _value.eventName
                : eventName // ignore: cast_nullable_to_non_nullable
                      as String?,
            eventDate: freezed == eventDate
                ? _value.eventDate
                : eventDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            shop: freezed == shop
                ? _value.shop
                : shop // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            table: freezed == table
                ? _value.table
                : table // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReservationResponseDtoImplCopyWith<$Res>
    implements $ReservationResponseDtoCopyWith<$Res> {
  factory _$$ReservationResponseDtoImplCopyWith(
    _$ReservationResponseDtoImpl value,
    $Res Function(_$ReservationResponseDtoImpl) then,
  ) = __$$ReservationResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int partySize,
    String? userId,
    String? shopId,
    String? tableId,
    String? eventId,
    String? reservationRequestId,
    String? eventName,
    String? eventDate,
    Map<String, dynamic>? user,
    Map<String, dynamic>? shop,
    Map<String, dynamic>? table,
  });
}

/// @nodoc
class __$$ReservationResponseDtoImplCopyWithImpl<$Res>
    extends
        _$ReservationResponseDtoCopyWithImpl<$Res, _$ReservationResponseDtoImpl>
    implements _$$ReservationResponseDtoImplCopyWith<$Res> {
  __$$ReservationResponseDtoImplCopyWithImpl(
    _$ReservationResponseDtoImpl _value,
    $Res Function(_$ReservationResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReservationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? partySize = null,
    Object? userId = freezed,
    Object? shopId = freezed,
    Object? tableId = freezed,
    Object? eventId = freezed,
    Object? reservationRequestId = freezed,
    Object? eventName = freezed,
    Object? eventDate = freezed,
    Object? user = freezed,
    Object? shop = freezed,
    Object? table = freezed,
  }) {
    return _then(
      _$ReservationResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        partySize: null == partySize
            ? _value.partySize
            : partySize // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        tableId: freezed == tableId
            ? _value.tableId
            : tableId // ignore: cast_nullable_to_non_nullable
                  as String?,
        eventId: freezed == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String?,
        reservationRequestId: freezed == reservationRequestId
            ? _value.reservationRequestId
            : reservationRequestId // ignore: cast_nullable_to_non_nullable
                  as String?,
        eventName: freezed == eventName
            ? _value.eventName
            : eventName // ignore: cast_nullable_to_non_nullable
                  as String?,
        eventDate: freezed == eventDate
            ? _value.eventDate
            : eventDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        user: freezed == user
            ? _value._user
            : user // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        shop: freezed == shop
            ? _value._shop
            : shop // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        table: freezed == table
            ? _value._table
            : table // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReservationResponseDtoImpl implements _ReservationResponseDto {
  const _$ReservationResponseDtoImpl({
    required this.id,
    required this.partySize,
    this.userId,
    this.shopId,
    this.tableId,
    this.eventId,
    this.reservationRequestId,
    this.eventName,
    this.eventDate,
    final Map<String, dynamic>? user,
    final Map<String, dynamic>? shop,
    final Map<String, dynamic>? table,
  }) : _user = user,
       _shop = shop,
       _table = table;

  factory _$ReservationResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final int partySize;
  @override
  final String? userId;
  @override
  final String? shopId;
  @override
  final String? tableId;
  @override
  final String? eventId;
  @override
  final String? reservationRequestId;
  @override
  final String? eventName;
  @override
  final String? eventDate;
  final Map<String, dynamic>? _user;
  @override
  Map<String, dynamic>? get user {
    final value = _user;
    if (value == null) return null;
    if (_user is EqualUnmodifiableMapView) return _user;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _shop;
  @override
  Map<String, dynamic>? get shop {
    final value = _shop;
    if (value == null) return null;
    if (_shop is EqualUnmodifiableMapView) return _shop;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _table;
  @override
  Map<String, dynamic>? get table {
    final value = _table;
    if (value == null) return null;
    if (_table is EqualUnmodifiableMapView) return _table;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ReservationResponseDto(id: $id, partySize: $partySize, userId: $userId, shopId: $shopId, tableId: $tableId, eventId: $eventId, reservationRequestId: $reservationRequestId, eventName: $eventName, eventDate: $eventDate, user: $user, shop: $shop, table: $table)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.partySize, partySize) ||
                other.partySize == partySize) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.tableId, tableId) || other.tableId == tableId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.reservationRequestId, reservationRequestId) ||
                other.reservationRequestId == reservationRequestId) &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            const DeepCollectionEquality().equals(other._user, _user) &&
            const DeepCollectionEquality().equals(other._shop, _shop) &&
            const DeepCollectionEquality().equals(other._table, _table));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    partySize,
    userId,
    shopId,
    tableId,
    eventId,
    reservationRequestId,
    eventName,
    eventDate,
    const DeepCollectionEquality().hash(_user),
    const DeepCollectionEquality().hash(_shop),
    const DeepCollectionEquality().hash(_table),
  );

  /// Create a copy of ReservationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationResponseDtoImplCopyWith<_$ReservationResponseDtoImpl>
  get copyWith =>
      __$$ReservationResponseDtoImplCopyWithImpl<_$ReservationResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationResponseDtoImplToJson(this);
  }
}

abstract class _ReservationResponseDto implements ReservationResponseDto {
  const factory _ReservationResponseDto({
    required final String id,
    required final int partySize,
    final String? userId,
    final String? shopId,
    final String? tableId,
    final String? eventId,
    final String? reservationRequestId,
    final String? eventName,
    final String? eventDate,
    final Map<String, dynamic>? user,
    final Map<String, dynamic>? shop,
    final Map<String, dynamic>? table,
  }) = _$ReservationResponseDtoImpl;

  factory _ReservationResponseDto.fromJson(Map<String, dynamic> json) =
      _$ReservationResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  int get partySize;
  @override
  String? get userId;
  @override
  String? get shopId;
  @override
  String? get tableId;
  @override
  String? get eventId;
  @override
  String? get reservationRequestId;
  @override
  String? get eventName;
  @override
  String? get eventDate;
  @override
  Map<String, dynamic>? get user;
  @override
  Map<String, dynamic>? get shop;
  @override
  Map<String, dynamic>? get table;

  /// Create a copy of ReservationResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationResponseDtoImplCopyWith<_$ReservationResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ReservationCreateRequest _$ReservationCreateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ReservationCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$ReservationCreateRequest {
  int get partySize => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get shopId => throw _privateConstructorUsedError;
  String? get tableId => throw _privateConstructorUsedError;
  String? get eventId => throw _privateConstructorUsedError;

  /// Serializes this ReservationCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReservationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationCreateRequestCopyWith<ReservationCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationCreateRequestCopyWith<$Res> {
  factory $ReservationCreateRequestCopyWith(
    ReservationCreateRequest value,
    $Res Function(ReservationCreateRequest) then,
  ) = _$ReservationCreateRequestCopyWithImpl<$Res, ReservationCreateRequest>;
  @useResult
  $Res call({
    int partySize,
    String? userId,
    String? shopId,
    String? tableId,
    String? eventId,
  });
}

/// @nodoc
class _$ReservationCreateRequestCopyWithImpl<
  $Res,
  $Val extends ReservationCreateRequest
>
    implements $ReservationCreateRequestCopyWith<$Res> {
  _$ReservationCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? partySize = null,
    Object? userId = freezed,
    Object? shopId = freezed,
    Object? tableId = freezed,
    Object? eventId = freezed,
  }) {
    return _then(
      _value.copyWith(
            partySize: null == partySize
                ? _value.partySize
                : partySize // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            tableId: freezed == tableId
                ? _value.tableId
                : tableId // ignore: cast_nullable_to_non_nullable
                      as String?,
            eventId: freezed == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReservationCreateRequestImplCopyWith<$Res>
    implements $ReservationCreateRequestCopyWith<$Res> {
  factory _$$ReservationCreateRequestImplCopyWith(
    _$ReservationCreateRequestImpl value,
    $Res Function(_$ReservationCreateRequestImpl) then,
  ) = __$$ReservationCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int partySize,
    String? userId,
    String? shopId,
    String? tableId,
    String? eventId,
  });
}

/// @nodoc
class __$$ReservationCreateRequestImplCopyWithImpl<$Res>
    extends
        _$ReservationCreateRequestCopyWithImpl<
          $Res,
          _$ReservationCreateRequestImpl
        >
    implements _$$ReservationCreateRequestImplCopyWith<$Res> {
  __$$ReservationCreateRequestImplCopyWithImpl(
    _$ReservationCreateRequestImpl _value,
    $Res Function(_$ReservationCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReservationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? partySize = null,
    Object? userId = freezed,
    Object? shopId = freezed,
    Object? tableId = freezed,
    Object? eventId = freezed,
  }) {
    return _then(
      _$ReservationCreateRequestImpl(
        partySize: null == partySize
            ? _value.partySize
            : partySize // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        tableId: freezed == tableId
            ? _value.tableId
            : tableId // ignore: cast_nullable_to_non_nullable
                  as String?,
        eventId: freezed == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReservationCreateRequestImpl implements _ReservationCreateRequest {
  const _$ReservationCreateRequestImpl({
    required this.partySize,
    this.userId,
    this.shopId,
    this.tableId,
    this.eventId,
  });

  factory _$ReservationCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationCreateRequestImplFromJson(json);

  @override
  final int partySize;
  @override
  final String? userId;
  @override
  final String? shopId;
  @override
  final String? tableId;
  @override
  final String? eventId;

  @override
  String toString() {
    return 'ReservationCreateRequest(partySize: $partySize, userId: $userId, shopId: $shopId, tableId: $tableId, eventId: $eventId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationCreateRequestImpl &&
            (identical(other.partySize, partySize) ||
                other.partySize == partySize) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.tableId, tableId) || other.tableId == tableId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, partySize, userId, shopId, tableId, eventId);

  /// Create a copy of ReservationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationCreateRequestImplCopyWith<_$ReservationCreateRequestImpl>
  get copyWith =>
      __$$ReservationCreateRequestImplCopyWithImpl<
        _$ReservationCreateRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationCreateRequestImplToJson(this);
  }
}

abstract class _ReservationCreateRequest implements ReservationCreateRequest {
  const factory _ReservationCreateRequest({
    required final int partySize,
    final String? userId,
    final String? shopId,
    final String? tableId,
    final String? eventId,
  }) = _$ReservationCreateRequestImpl;

  factory _ReservationCreateRequest.fromJson(Map<String, dynamic> json) =
      _$ReservationCreateRequestImpl.fromJson;

  @override
  int get partySize;
  @override
  String? get userId;
  @override
  String? get shopId;
  @override
  String? get tableId;
  @override
  String? get eventId;

  /// Create a copy of ReservationCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationCreateRequestImplCopyWith<_$ReservationCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ReservationUpdateRequest _$ReservationUpdateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ReservationUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ReservationUpdateRequest {
  int? get partySize => throw _privateConstructorUsedError;
  String? get tableId => throw _privateConstructorUsedError;

  /// Serializes this ReservationUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReservationUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationUpdateRequestCopyWith<ReservationUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationUpdateRequestCopyWith<$Res> {
  factory $ReservationUpdateRequestCopyWith(
    ReservationUpdateRequest value,
    $Res Function(ReservationUpdateRequest) then,
  ) = _$ReservationUpdateRequestCopyWithImpl<$Res, ReservationUpdateRequest>;
  @useResult
  $Res call({int? partySize, String? tableId});
}

/// @nodoc
class _$ReservationUpdateRequestCopyWithImpl<
  $Res,
  $Val extends ReservationUpdateRequest
>
    implements $ReservationUpdateRequestCopyWith<$Res> {
  _$ReservationUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservationUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? partySize = freezed, Object? tableId = freezed}) {
    return _then(
      _value.copyWith(
            partySize: freezed == partySize
                ? _value.partySize
                : partySize // ignore: cast_nullable_to_non_nullable
                      as int?,
            tableId: freezed == tableId
                ? _value.tableId
                : tableId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReservationUpdateRequestImplCopyWith<$Res>
    implements $ReservationUpdateRequestCopyWith<$Res> {
  factory _$$ReservationUpdateRequestImplCopyWith(
    _$ReservationUpdateRequestImpl value,
    $Res Function(_$ReservationUpdateRequestImpl) then,
  ) = __$$ReservationUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? partySize, String? tableId});
}

/// @nodoc
class __$$ReservationUpdateRequestImplCopyWithImpl<$Res>
    extends
        _$ReservationUpdateRequestCopyWithImpl<
          $Res,
          _$ReservationUpdateRequestImpl
        >
    implements _$$ReservationUpdateRequestImplCopyWith<$Res> {
  __$$ReservationUpdateRequestImplCopyWithImpl(
    _$ReservationUpdateRequestImpl _value,
    $Res Function(_$ReservationUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReservationUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? partySize = freezed, Object? tableId = freezed}) {
    return _then(
      _$ReservationUpdateRequestImpl(
        partySize: freezed == partySize
            ? _value.partySize
            : partySize // ignore: cast_nullable_to_non_nullable
                  as int?,
        tableId: freezed == tableId
            ? _value.tableId
            : tableId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReservationUpdateRequestImpl implements _ReservationUpdateRequest {
  const _$ReservationUpdateRequestImpl({this.partySize, this.tableId});

  factory _$ReservationUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationUpdateRequestImplFromJson(json);

  @override
  final int? partySize;
  @override
  final String? tableId;

  @override
  String toString() {
    return 'ReservationUpdateRequest(partySize: $partySize, tableId: $tableId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationUpdateRequestImpl &&
            (identical(other.partySize, partySize) ||
                other.partySize == partySize) &&
            (identical(other.tableId, tableId) || other.tableId == tableId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, partySize, tableId);

  /// Create a copy of ReservationUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationUpdateRequestImplCopyWith<_$ReservationUpdateRequestImpl>
  get copyWith =>
      __$$ReservationUpdateRequestImplCopyWithImpl<
        _$ReservationUpdateRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationUpdateRequestImplToJson(this);
  }
}

abstract class _ReservationUpdateRequest implements ReservationUpdateRequest {
  const factory _ReservationUpdateRequest({
    final int? partySize,
    final String? tableId,
  }) = _$ReservationUpdateRequestImpl;

  factory _ReservationUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$ReservationUpdateRequestImpl.fromJson;

  @override
  int? get partySize;
  @override
  String? get tableId;

  /// Create a copy of ReservationUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationUpdateRequestImplCopyWith<_$ReservationUpdateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
