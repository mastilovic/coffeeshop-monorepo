// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EventResponseDto _$EventResponseDtoFromJson(Map<String, dynamic> json) {
  return _EventResponseDto.fromJson(json);
}

/// @nodoc
mixin _$EventResponseDto {
  String get eventId => throw _privateConstructorUsedError;
  String get eventName => throw _privateConstructorUsedError;
  String get eventDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get shopId => throw _privateConstructorUsedError;
  String? get shopName => throw _privateConstructorUsedError;
  String? get shopCity => throw _privateConstructorUsedError;

  /// Serializes this EventResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventResponseDtoCopyWith<EventResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventResponseDtoCopyWith<$Res> {
  factory $EventResponseDtoCopyWith(
    EventResponseDto value,
    $Res Function(EventResponseDto) then,
  ) = _$EventResponseDtoCopyWithImpl<$Res, EventResponseDto>;
  @useResult
  $Res call({
    String eventId,
    String eventName,
    String eventDate,
    String? description,
    String? shopId,
    String? shopName,
    String? shopCity,
  });
}

/// @nodoc
class _$EventResponseDtoCopyWithImpl<$Res, $Val extends EventResponseDto>
    implements $EventResponseDtoCopyWith<$Res> {
  _$EventResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? eventName = null,
    Object? eventDate = null,
    Object? description = freezed,
    Object? shopId = freezed,
    Object? shopName = freezed,
    Object? shopCity = freezed,
  }) {
    return _then(
      _value.copyWith(
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            eventName: null == eventName
                ? _value.eventName
                : eventName // ignore: cast_nullable_to_non_nullable
                      as String,
            eventDate: null == eventDate
                ? _value.eventDate
                : eventDate // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopName: freezed == shopName
                ? _value.shopName
                : shopName // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopCity: freezed == shopCity
                ? _value.shopCity
                : shopCity // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventResponseDtoImplCopyWith<$Res>
    implements $EventResponseDtoCopyWith<$Res> {
  factory _$$EventResponseDtoImplCopyWith(
    _$EventResponseDtoImpl value,
    $Res Function(_$EventResponseDtoImpl) then,
  ) = __$$EventResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String eventId,
    String eventName,
    String eventDate,
    String? description,
    String? shopId,
    String? shopName,
    String? shopCity,
  });
}

/// @nodoc
class __$$EventResponseDtoImplCopyWithImpl<$Res>
    extends _$EventResponseDtoCopyWithImpl<$Res, _$EventResponseDtoImpl>
    implements _$$EventResponseDtoImplCopyWith<$Res> {
  __$$EventResponseDtoImplCopyWithImpl(
    _$EventResponseDtoImpl _value,
    $Res Function(_$EventResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? eventName = null,
    Object? eventDate = null,
    Object? description = freezed,
    Object? shopId = freezed,
    Object? shopName = freezed,
    Object? shopCity = freezed,
  }) {
    return _then(
      _$EventResponseDtoImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventName: null == eventName
            ? _value.eventName
            : eventName // ignore: cast_nullable_to_non_nullable
                  as String,
        eventDate: null == eventDate
            ? _value.eventDate
            : eventDate // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopName: freezed == shopName
            ? _value.shopName
            : shopName // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopCity: freezed == shopCity
            ? _value.shopCity
            : shopCity // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventResponseDtoImpl implements _EventResponseDto {
  const _$EventResponseDtoImpl({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    this.description,
    this.shopId,
    this.shopName,
    this.shopCity,
  });

  factory _$EventResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventResponseDtoImplFromJson(json);

  @override
  final String eventId;
  @override
  final String eventName;
  @override
  final String eventDate;
  @override
  final String? description;
  @override
  final String? shopId;
  @override
  final String? shopName;
  @override
  final String? shopCity;

  @override
  String toString() {
    return 'EventResponseDto(eventId: $eventId, eventName: $eventName, eventDate: $eventDate, description: $description, shopId: $shopId, shopName: $shopName, shopCity: $shopCity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventResponseDtoImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.shopCity, shopCity) ||
                other.shopCity == shopCity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eventId,
    eventName,
    eventDate,
    description,
    shopId,
    shopName,
    shopCity,
  );

  /// Create a copy of EventResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventResponseDtoImplCopyWith<_$EventResponseDtoImpl> get copyWith =>
      __$$EventResponseDtoImplCopyWithImpl<_$EventResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventResponseDtoImplToJson(this);
  }
}

abstract class _EventResponseDto implements EventResponseDto {
  const factory _EventResponseDto({
    required final String eventId,
    required final String eventName,
    required final String eventDate,
    final String? description,
    final String? shopId,
    final String? shopName,
    final String? shopCity,
  }) = _$EventResponseDtoImpl;

  factory _EventResponseDto.fromJson(Map<String, dynamic> json) =
      _$EventResponseDtoImpl.fromJson;

  @override
  String get eventId;
  @override
  String get eventName;
  @override
  String get eventDate;
  @override
  String? get description;
  @override
  String? get shopId;
  @override
  String? get shopName;
  @override
  String? get shopCity;

  /// Create a copy of EventResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventResponseDtoImplCopyWith<_$EventResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventCreateRequest _$EventCreateRequestFromJson(Map<String, dynamic> json) {
  return _EventCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$EventCreateRequest {
  String get eventName => throw _privateConstructorUsedError;
  String get eventDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get shopId => throw _privateConstructorUsedError;

  /// Serializes this EventCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCreateRequestCopyWith<EventCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCreateRequestCopyWith<$Res> {
  factory $EventCreateRequestCopyWith(
    EventCreateRequest value,
    $Res Function(EventCreateRequest) then,
  ) = _$EventCreateRequestCopyWithImpl<$Res, EventCreateRequest>;
  @useResult
  $Res call({
    String eventName,
    String eventDate,
    String? description,
    String? shopId,
  });
}

/// @nodoc
class _$EventCreateRequestCopyWithImpl<$Res, $Val extends EventCreateRequest>
    implements $EventCreateRequestCopyWith<$Res> {
  _$EventCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventName = null,
    Object? eventDate = null,
    Object? description = freezed,
    Object? shopId = freezed,
  }) {
    return _then(
      _value.copyWith(
            eventName: null == eventName
                ? _value.eventName
                : eventName // ignore: cast_nullable_to_non_nullable
                      as String,
            eventDate: null == eventDate
                ? _value.eventDate
                : eventDate // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$EventCreateRequestImplCopyWith<$Res>
    implements $EventCreateRequestCopyWith<$Res> {
  factory _$$EventCreateRequestImplCopyWith(
    _$EventCreateRequestImpl value,
    $Res Function(_$EventCreateRequestImpl) then,
  ) = __$$EventCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String eventName,
    String eventDate,
    String? description,
    String? shopId,
  });
}

/// @nodoc
class __$$EventCreateRequestImplCopyWithImpl<$Res>
    extends _$EventCreateRequestCopyWithImpl<$Res, _$EventCreateRequestImpl>
    implements _$$EventCreateRequestImplCopyWith<$Res> {
  __$$EventCreateRequestImplCopyWithImpl(
    _$EventCreateRequestImpl _value,
    $Res Function(_$EventCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventName = null,
    Object? eventDate = null,
    Object? description = freezed,
    Object? shopId = freezed,
  }) {
    return _then(
      _$EventCreateRequestImpl(
        eventName: null == eventName
            ? _value.eventName
            : eventName // ignore: cast_nullable_to_non_nullable
                  as String,
        eventDate: null == eventDate
            ? _value.eventDate
            : eventDate // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$EventCreateRequestImpl implements _EventCreateRequest {
  const _$EventCreateRequestImpl({
    required this.eventName,
    required this.eventDate,
    this.description,
    this.shopId,
  });

  factory _$EventCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventCreateRequestImplFromJson(json);

  @override
  final String eventName;
  @override
  final String eventDate;
  @override
  final String? description;
  @override
  final String? shopId;

  @override
  String toString() {
    return 'EventCreateRequest(eventName: $eventName, eventDate: $eventDate, description: $description, shopId: $shopId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventCreateRequestImpl &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.shopId, shopId) || other.shopId == shopId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, eventName, eventDate, description, shopId);

  /// Create a copy of EventCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventCreateRequestImplCopyWith<_$EventCreateRequestImpl> get copyWith =>
      __$$EventCreateRequestImplCopyWithImpl<_$EventCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventCreateRequestImplToJson(this);
  }
}

abstract class _EventCreateRequest implements EventCreateRequest {
  const factory _EventCreateRequest({
    required final String eventName,
    required final String eventDate,
    final String? description,
    final String? shopId,
  }) = _$EventCreateRequestImpl;

  factory _EventCreateRequest.fromJson(Map<String, dynamic> json) =
      _$EventCreateRequestImpl.fromJson;

  @override
  String get eventName;
  @override
  String get eventDate;
  @override
  String? get description;
  @override
  String? get shopId;

  /// Create a copy of EventCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventCreateRequestImplCopyWith<_$EventCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventUpdateRequest _$EventUpdateRequestFromJson(Map<String, dynamic> json) {
  return _EventUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$EventUpdateRequest {
  String? get eventName => throw _privateConstructorUsedError;
  String? get eventDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get shopId => throw _privateConstructorUsedError;

  /// Serializes this EventUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventUpdateRequestCopyWith<EventUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventUpdateRequestCopyWith<$Res> {
  factory $EventUpdateRequestCopyWith(
    EventUpdateRequest value,
    $Res Function(EventUpdateRequest) then,
  ) = _$EventUpdateRequestCopyWithImpl<$Res, EventUpdateRequest>;
  @useResult
  $Res call({
    String? eventName,
    String? eventDate,
    String? description,
    String? shopId,
  });
}

/// @nodoc
class _$EventUpdateRequestCopyWithImpl<$Res, $Val extends EventUpdateRequest>
    implements $EventUpdateRequestCopyWith<$Res> {
  _$EventUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventName = freezed,
    Object? eventDate = freezed,
    Object? description = freezed,
    Object? shopId = freezed,
  }) {
    return _then(
      _value.copyWith(
            eventName: freezed == eventName
                ? _value.eventName
                : eventName // ignore: cast_nullable_to_non_nullable
                      as String?,
            eventDate: freezed == eventDate
                ? _value.eventDate
                : eventDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$EventUpdateRequestImplCopyWith<$Res>
    implements $EventUpdateRequestCopyWith<$Res> {
  factory _$$EventUpdateRequestImplCopyWith(
    _$EventUpdateRequestImpl value,
    $Res Function(_$EventUpdateRequestImpl) then,
  ) = __$$EventUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? eventName,
    String? eventDate,
    String? description,
    String? shopId,
  });
}

/// @nodoc
class __$$EventUpdateRequestImplCopyWithImpl<$Res>
    extends _$EventUpdateRequestCopyWithImpl<$Res, _$EventUpdateRequestImpl>
    implements _$$EventUpdateRequestImplCopyWith<$Res> {
  __$$EventUpdateRequestImplCopyWithImpl(
    _$EventUpdateRequestImpl _value,
    $Res Function(_$EventUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventName = freezed,
    Object? eventDate = freezed,
    Object? description = freezed,
    Object? shopId = freezed,
  }) {
    return _then(
      _$EventUpdateRequestImpl(
        eventName: freezed == eventName
            ? _value.eventName
            : eventName // ignore: cast_nullable_to_non_nullable
                  as String?,
        eventDate: freezed == eventDate
            ? _value.eventDate
            : eventDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$EventUpdateRequestImpl implements _EventUpdateRequest {
  const _$EventUpdateRequestImpl({
    this.eventName,
    this.eventDate,
    this.description,
    this.shopId,
  });

  factory _$EventUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventUpdateRequestImplFromJson(json);

  @override
  final String? eventName;
  @override
  final String? eventDate;
  @override
  final String? description;
  @override
  final String? shopId;

  @override
  String toString() {
    return 'EventUpdateRequest(eventName: $eventName, eventDate: $eventDate, description: $description, shopId: $shopId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventUpdateRequestImpl &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.shopId, shopId) || other.shopId == shopId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, eventName, eventDate, description, shopId);

  /// Create a copy of EventUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventUpdateRequestImplCopyWith<_$EventUpdateRequestImpl> get copyWith =>
      __$$EventUpdateRequestImplCopyWithImpl<_$EventUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventUpdateRequestImplToJson(this);
  }
}

abstract class _EventUpdateRequest implements EventUpdateRequest {
  const factory _EventUpdateRequest({
    final String? eventName,
    final String? eventDate,
    final String? description,
    final String? shopId,
  }) = _$EventUpdateRequestImpl;

  factory _EventUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$EventUpdateRequestImpl.fromJson;

  @override
  String? get eventName;
  @override
  String? get eventDate;
  @override
  String? get description;
  @override
  String? get shopId;

  /// Create a copy of EventUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventUpdateRequestImplCopyWith<_$EventUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventSearchParams _$EventSearchParamsFromJson(Map<String, dynamic> json) {
  return _EventSearchParams.fromJson(json);
}

/// @nodoc
mixin _$EventSearchParams {
  String? get q => throw _privateConstructorUsedError;
  String? get dateFrom => throw _privateConstructorUsedError;
  String? get dateTo => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;

  /// Serializes this EventSearchParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventSearchParamsCopyWith<EventSearchParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventSearchParamsCopyWith<$Res> {
  factory $EventSearchParamsCopyWith(
    EventSearchParams value,
    $Res Function(EventSearchParams) then,
  ) = _$EventSearchParamsCopyWithImpl<$Res, EventSearchParams>;
  @useResult
  $Res call({String? q, String? dateFrom, String? dateTo, int page, int size});
}

/// @nodoc
class _$EventSearchParamsCopyWithImpl<$Res, $Val extends EventSearchParams>
    implements $EventSearchParamsCopyWith<$Res> {
  _$EventSearchParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? q = freezed,
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? page = null,
    Object? size = null,
  }) {
    return _then(
      _value.copyWith(
            q: freezed == q
                ? _value.q
                : q // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateFrom: freezed == dateFrom
                ? _value.dateFrom
                : dateFrom // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateTo: freezed == dateTo
                ? _value.dateTo
                : dateTo // ignore: cast_nullable_to_non_nullable
                      as String?,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventSearchParamsImplCopyWith<$Res>
    implements $EventSearchParamsCopyWith<$Res> {
  factory _$$EventSearchParamsImplCopyWith(
    _$EventSearchParamsImpl value,
    $Res Function(_$EventSearchParamsImpl) then,
  ) = __$$EventSearchParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? q, String? dateFrom, String? dateTo, int page, int size});
}

/// @nodoc
class __$$EventSearchParamsImplCopyWithImpl<$Res>
    extends _$EventSearchParamsCopyWithImpl<$Res, _$EventSearchParamsImpl>
    implements _$$EventSearchParamsImplCopyWith<$Res> {
  __$$EventSearchParamsImplCopyWithImpl(
    _$EventSearchParamsImpl _value,
    $Res Function(_$EventSearchParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? q = freezed,
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? page = null,
    Object? size = null,
  }) {
    return _then(
      _$EventSearchParamsImpl(
        q: freezed == q
            ? _value.q
            : q // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateFrom: freezed == dateFrom
            ? _value.dateFrom
            : dateFrom // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateTo: freezed == dateTo
            ? _value.dateTo
            : dateTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventSearchParamsImpl implements _EventSearchParams {
  const _$EventSearchParamsImpl({
    this.q,
    this.dateFrom,
    this.dateTo,
    this.page = 0,
    this.size = 20,
  });

  factory _$EventSearchParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventSearchParamsImplFromJson(json);

  @override
  final String? q;
  @override
  final String? dateFrom;
  @override
  final String? dateTo;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int size;

  @override
  String toString() {
    return 'EventSearchParams(q: $q, dateFrom: $dateFrom, dateTo: $dateTo, page: $page, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventSearchParamsImpl &&
            (identical(other.q, q) || other.q == q) &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, q, dateFrom, dateTo, page, size);

  /// Create a copy of EventSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventSearchParamsImplCopyWith<_$EventSearchParamsImpl> get copyWith =>
      __$$EventSearchParamsImplCopyWithImpl<_$EventSearchParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventSearchParamsImplToJson(this);
  }
}

abstract class _EventSearchParams implements EventSearchParams {
  const factory _EventSearchParams({
    final String? q,
    final String? dateFrom,
    final String? dateTo,
    final int page,
    final int size,
  }) = _$EventSearchParamsImpl;

  factory _EventSearchParams.fromJson(Map<String, dynamic> json) =
      _$EventSearchParamsImpl.fromJson;

  @override
  String? get q;
  @override
  String? get dateFrom;
  @override
  String? get dateTo;
  @override
  int get page;
  @override
  int get size;

  /// Create a copy of EventSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventSearchParamsImplCopyWith<_$EventSearchParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
