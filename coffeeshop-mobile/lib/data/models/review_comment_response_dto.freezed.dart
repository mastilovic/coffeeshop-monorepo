// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_comment_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewCommentResponseDto _$ReviewCommentResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ReviewCommentResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ReviewCommentResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_id')
  String? get reviewId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get user => throw _privateConstructorUsedError;

  /// Serializes this ReviewCommentResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewCommentResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewCommentResponseDtoCopyWith<ReviewCommentResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewCommentResponseDtoCopyWith<$Res> {
  factory $ReviewCommentResponseDtoCopyWith(
    ReviewCommentResponseDto value,
    $Res Function(ReviewCommentResponseDto) then,
  ) = _$ReviewCommentResponseDtoCopyWithImpl<$Res, ReviewCommentResponseDto>;
  @useResult
  $Res call({
    String id,
    String body,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'review_id') String? reviewId,
    Map<String, dynamic>? user,
  });
}

/// @nodoc
class _$ReviewCommentResponseDtoCopyWithImpl<
  $Res,
  $Val extends ReviewCommentResponseDto
>
    implements $ReviewCommentResponseDtoCopyWith<$Res> {
  _$ReviewCommentResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewCommentResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? createdAt = freezed,
    Object? userId = freezed,
    Object? reviewId = freezed,
    Object? user = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewId: freezed == reviewId
                ? _value.reviewId
                : reviewId // ignore: cast_nullable_to_non_nullable
                      as String?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewCommentResponseDtoImplCopyWith<$Res>
    implements $ReviewCommentResponseDtoCopyWith<$Res> {
  factory _$$ReviewCommentResponseDtoImplCopyWith(
    _$ReviewCommentResponseDtoImpl value,
    $Res Function(_$ReviewCommentResponseDtoImpl) then,
  ) = __$$ReviewCommentResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String body,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'review_id') String? reviewId,
    Map<String, dynamic>? user,
  });
}

/// @nodoc
class __$$ReviewCommentResponseDtoImplCopyWithImpl<$Res>
    extends
        _$ReviewCommentResponseDtoCopyWithImpl<
          $Res,
          _$ReviewCommentResponseDtoImpl
        >
    implements _$$ReviewCommentResponseDtoImplCopyWith<$Res> {
  __$$ReviewCommentResponseDtoImplCopyWithImpl(
    _$ReviewCommentResponseDtoImpl _value,
    $Res Function(_$ReviewCommentResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewCommentResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? createdAt = freezed,
    Object? userId = freezed,
    Object? reviewId = freezed,
    Object? user = freezed,
  }) {
    return _then(
      _$ReviewCommentResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewId: freezed == reviewId
            ? _value.reviewId
            : reviewId // ignore: cast_nullable_to_non_nullable
                  as String?,
        user: freezed == user
            ? _value._user
            : user // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewCommentResponseDtoImpl implements _ReviewCommentResponseDto {
  const _$ReviewCommentResponseDtoImpl({
    required this.id,
    required this.body,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'review_id') this.reviewId,
    final Map<String, dynamic>? user,
  }) : _user = user;

  factory _$ReviewCommentResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewCommentResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String body;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'review_id')
  final String? reviewId;
  final Map<String, dynamic>? _user;
  @override
  Map<String, dynamic>? get user {
    final value = _user;
    if (value == null) return null;
    if (_user is EqualUnmodifiableMapView) return _user;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ReviewCommentResponseDto(id: $id, body: $body, createdAt: $createdAt, userId: $userId, reviewId: $reviewId, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewCommentResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.reviewId, reviewId) ||
                other.reviewId == reviewId) &&
            const DeepCollectionEquality().equals(other._user, _user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    body,
    createdAt,
    userId,
    reviewId,
    const DeepCollectionEquality().hash(_user),
  );

  /// Create a copy of ReviewCommentResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewCommentResponseDtoImplCopyWith<_$ReviewCommentResponseDtoImpl>
  get copyWith =>
      __$$ReviewCommentResponseDtoImplCopyWithImpl<
        _$ReviewCommentResponseDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewCommentResponseDtoImplToJson(this);
  }
}

abstract class _ReviewCommentResponseDto implements ReviewCommentResponseDto {
  const factory _ReviewCommentResponseDto({
    required final String id,
    required final String body,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'user_id') final String? userId,
    @JsonKey(name: 'review_id') final String? reviewId,
    final Map<String, dynamic>? user,
  }) = _$ReviewCommentResponseDtoImpl;

  factory _ReviewCommentResponseDto.fromJson(Map<String, dynamic> json) =
      _$ReviewCommentResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get body;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'review_id')
  String? get reviewId;
  @override
  Map<String, dynamic>? get user;

  /// Create a copy of ReviewCommentResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewCommentResponseDtoImplCopyWith<_$ReviewCommentResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ReviewCommentCreateRequest _$ReviewCommentCreateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ReviewCommentCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$ReviewCommentCreateRequest {
  String get body => throw _privateConstructorUsedError;

  /// Serializes this ReviewCommentCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewCommentCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewCommentCreateRequestCopyWith<ReviewCommentCreateRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewCommentCreateRequestCopyWith<$Res> {
  factory $ReviewCommentCreateRequestCopyWith(
    ReviewCommentCreateRequest value,
    $Res Function(ReviewCommentCreateRequest) then,
  ) =
      _$ReviewCommentCreateRequestCopyWithImpl<
        $Res,
        ReviewCommentCreateRequest
      >;
  @useResult
  $Res call({String body});
}

/// @nodoc
class _$ReviewCommentCreateRequestCopyWithImpl<
  $Res,
  $Val extends ReviewCommentCreateRequest
>
    implements $ReviewCommentCreateRequestCopyWith<$Res> {
  _$ReviewCommentCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewCommentCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? body = null}) {
    return _then(
      _value.copyWith(
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewCommentCreateRequestImplCopyWith<$Res>
    implements $ReviewCommentCreateRequestCopyWith<$Res> {
  factory _$$ReviewCommentCreateRequestImplCopyWith(
    _$ReviewCommentCreateRequestImpl value,
    $Res Function(_$ReviewCommentCreateRequestImpl) then,
  ) = __$$ReviewCommentCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String body});
}

/// @nodoc
class __$$ReviewCommentCreateRequestImplCopyWithImpl<$Res>
    extends
        _$ReviewCommentCreateRequestCopyWithImpl<
          $Res,
          _$ReviewCommentCreateRequestImpl
        >
    implements _$$ReviewCommentCreateRequestImplCopyWith<$Res> {
  __$$ReviewCommentCreateRequestImplCopyWithImpl(
    _$ReviewCommentCreateRequestImpl _value,
    $Res Function(_$ReviewCommentCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewCommentCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? body = null}) {
    return _then(
      _$ReviewCommentCreateRequestImpl(
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewCommentCreateRequestImpl implements _ReviewCommentCreateRequest {
  const _$ReviewCommentCreateRequestImpl({required this.body});

  factory _$ReviewCommentCreateRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$ReviewCommentCreateRequestImplFromJson(json);

  @override
  final String body;

  @override
  String toString() {
    return 'ReviewCommentCreateRequest(body: $body)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewCommentCreateRequestImpl &&
            (identical(other.body, body) || other.body == body));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, body);

  /// Create a copy of ReviewCommentCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewCommentCreateRequestImplCopyWith<_$ReviewCommentCreateRequestImpl>
  get copyWith =>
      __$$ReviewCommentCreateRequestImplCopyWithImpl<
        _$ReviewCommentCreateRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewCommentCreateRequestImplToJson(this);
  }
}

abstract class _ReviewCommentCreateRequest
    implements ReviewCommentCreateRequest {
  const factory _ReviewCommentCreateRequest({required final String body}) =
      _$ReviewCommentCreateRequestImpl;

  factory _ReviewCommentCreateRequest.fromJson(Map<String, dynamic> json) =
      _$ReviewCommentCreateRequestImpl.fromJson;

  @override
  String get body;

  /// Create a copy of ReviewCommentCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewCommentCreateRequestImplCopyWith<_$ReviewCommentCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
