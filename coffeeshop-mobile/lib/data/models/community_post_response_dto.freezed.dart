// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_post_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommunityPostResponseDto _$CommunityPostResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityPostResponseDto.fromJson(json);
}

/// @nodoc
mixin _$CommunityPostResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get pinned => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_id')
  String? get shopId => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_id')
  String? get authorId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get author => throw _privateConstructorUsedError;

  /// Serializes this CommunityPostResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostResponseDtoCopyWith<CommunityPostResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostResponseDtoCopyWith<$Res> {
  factory $CommunityPostResponseDtoCopyWith(
    CommunityPostResponseDto value,
    $Res Function(CommunityPostResponseDto) then,
  ) = _$CommunityPostResponseDtoCopyWithImpl<$Res, CommunityPostResponseDto>;
  @useResult
  $Res call({
    String id,
    String body,
    String type,
    bool pinned,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'author_id') String? authorId,
    Map<String, dynamic>? author,
  });
}

/// @nodoc
class _$CommunityPostResponseDtoCopyWithImpl<
  $Res,
  $Val extends CommunityPostResponseDto
>
    implements $CommunityPostResponseDtoCopyWith<$Res> {
  _$CommunityPostResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? type = null,
    Object? pinned = null,
    Object? createdAt = freezed,
    Object? shopId = freezed,
    Object? authorId = freezed,
    Object? author = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            pinned: null == pinned
                ? _value.pinned
                : pinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorId: freezed == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            author: freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityPostResponseDtoImplCopyWith<$Res>
    implements $CommunityPostResponseDtoCopyWith<$Res> {
  factory _$$CommunityPostResponseDtoImplCopyWith(
    _$CommunityPostResponseDtoImpl value,
    $Res Function(_$CommunityPostResponseDtoImpl) then,
  ) = __$$CommunityPostResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String body,
    String type,
    bool pinned,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'author_id') String? authorId,
    Map<String, dynamic>? author,
  });
}

/// @nodoc
class __$$CommunityPostResponseDtoImplCopyWithImpl<$Res>
    extends
        _$CommunityPostResponseDtoCopyWithImpl<
          $Res,
          _$CommunityPostResponseDtoImpl
        >
    implements _$$CommunityPostResponseDtoImplCopyWith<$Res> {
  __$$CommunityPostResponseDtoImplCopyWithImpl(
    _$CommunityPostResponseDtoImpl _value,
    $Res Function(_$CommunityPostResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? type = null,
    Object? pinned = null,
    Object? createdAt = freezed,
    Object? shopId = freezed,
    Object? authorId = freezed,
    Object? author = freezed,
  }) {
    return _then(
      _$CommunityPostResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        pinned: null == pinned
            ? _value.pinned
            : pinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorId: freezed == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        author: freezed == author
            ? _value._author
            : author // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityPostResponseDtoImpl implements _CommunityPostResponseDto {
  const _$CommunityPostResponseDtoImpl({
    required this.id,
    required this.body,
    this.type = 'POST',
    this.pinned = false,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'shop_id') this.shopId,
    @JsonKey(name: 'author_id') this.authorId,
    final Map<String, dynamic>? author,
  }) : _author = author;

  factory _$CommunityPostResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityPostResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String body;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final bool pinned;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'shop_id')
  final String? shopId;
  @override
  @JsonKey(name: 'author_id')
  final String? authorId;
  final Map<String, dynamic>? _author;
  @override
  Map<String, dynamic>? get author {
    final value = _author;
    if (value == null) return null;
    if (_author is EqualUnmodifiableMapView) return _author;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CommunityPostResponseDto(id: $id, body: $body, type: $type, pinned: $pinned, createdAt: $createdAt, shopId: $shopId, authorId: $authorId, author: $author)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            const DeepCollectionEquality().equals(other._author, _author));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    body,
    type,
    pinned,
    createdAt,
    shopId,
    authorId,
    const DeepCollectionEquality().hash(_author),
  );

  /// Create a copy of CommunityPostResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostResponseDtoImplCopyWith<_$CommunityPostResponseDtoImpl>
  get copyWith =>
      __$$CommunityPostResponseDtoImplCopyWithImpl<
        _$CommunityPostResponseDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPostResponseDtoImplToJson(this);
  }
}

abstract class _CommunityPostResponseDto implements CommunityPostResponseDto {
  const factory _CommunityPostResponseDto({
    required final String id,
    required final String body,
    final String type,
    final bool pinned,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'shop_id') final String? shopId,
    @JsonKey(name: 'author_id') final String? authorId,
    final Map<String, dynamic>? author,
  }) = _$CommunityPostResponseDtoImpl;

  factory _CommunityPostResponseDto.fromJson(Map<String, dynamic> json) =
      _$CommunityPostResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get body;
  @override
  String get type;
  @override
  bool get pinned;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'shop_id')
  String? get shopId;
  @override
  @JsonKey(name: 'author_id')
  String? get authorId;
  @override
  Map<String, dynamic>? get author;

  /// Create a copy of CommunityPostResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostResponseDtoImplCopyWith<_$CommunityPostResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CommunityPostCreateRequest _$CommunityPostCreateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityPostCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$CommunityPostCreateRequest {
  String get body => throw _privateConstructorUsedError;

  /// Serializes this CommunityPostCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityPostCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityPostCreateRequestCopyWith<CommunityPostCreateRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityPostCreateRequestCopyWith<$Res> {
  factory $CommunityPostCreateRequestCopyWith(
    CommunityPostCreateRequest value,
    $Res Function(CommunityPostCreateRequest) then,
  ) =
      _$CommunityPostCreateRequestCopyWithImpl<
        $Res,
        CommunityPostCreateRequest
      >;
  @useResult
  $Res call({String body});
}

/// @nodoc
class _$CommunityPostCreateRequestCopyWithImpl<
  $Res,
  $Val extends CommunityPostCreateRequest
>
    implements $CommunityPostCreateRequestCopyWith<$Res> {
  _$CommunityPostCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityPostCreateRequest
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
abstract class _$$CommunityPostCreateRequestImplCopyWith<$Res>
    implements $CommunityPostCreateRequestCopyWith<$Res> {
  factory _$$CommunityPostCreateRequestImplCopyWith(
    _$CommunityPostCreateRequestImpl value,
    $Res Function(_$CommunityPostCreateRequestImpl) then,
  ) = __$$CommunityPostCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String body});
}

/// @nodoc
class __$$CommunityPostCreateRequestImplCopyWithImpl<$Res>
    extends
        _$CommunityPostCreateRequestCopyWithImpl<
          $Res,
          _$CommunityPostCreateRequestImpl
        >
    implements _$$CommunityPostCreateRequestImplCopyWith<$Res> {
  __$$CommunityPostCreateRequestImplCopyWithImpl(
    _$CommunityPostCreateRequestImpl _value,
    $Res Function(_$CommunityPostCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityPostCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? body = null}) {
    return _then(
      _$CommunityPostCreateRequestImpl(
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
class _$CommunityPostCreateRequestImpl implements _CommunityPostCreateRequest {
  const _$CommunityPostCreateRequestImpl({required this.body});

  factory _$CommunityPostCreateRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CommunityPostCreateRequestImplFromJson(json);

  @override
  final String body;

  @override
  String toString() {
    return 'CommunityPostCreateRequest(body: $body)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityPostCreateRequestImpl &&
            (identical(other.body, body) || other.body == body));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, body);

  /// Create a copy of CommunityPostCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityPostCreateRequestImplCopyWith<_$CommunityPostCreateRequestImpl>
  get copyWith =>
      __$$CommunityPostCreateRequestImplCopyWithImpl<
        _$CommunityPostCreateRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityPostCreateRequestImplToJson(this);
  }
}

abstract class _CommunityPostCreateRequest
    implements CommunityPostCreateRequest {
  const factory _CommunityPostCreateRequest({required final String body}) =
      _$CommunityPostCreateRequestImpl;

  factory _CommunityPostCreateRequest.fromJson(Map<String, dynamic> json) =
      _$CommunityPostCreateRequestImpl.fromJson;

  @override
  String get body;

  /// Create a copy of CommunityPostCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityPostCreateRequestImplCopyWith<_$CommunityPostCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MemberSummaryDto _$MemberSummaryDtoFromJson(Map<String, dynamic> json) {
  return _MemberSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$MemberSummaryDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;

  /// Serializes this MemberSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberSummaryDtoCopyWith<MemberSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberSummaryDtoCopyWith<$Res> {
  factory $MemberSummaryDtoCopyWith(
    MemberSummaryDto value,
    $Res Function(MemberSummaryDto) then,
  ) = _$MemberSummaryDtoCopyWithImpl<$Res, MemberSummaryDto>;
  @useResult
  $Res call({String id, String name, String username});
}

/// @nodoc
class _$MemberSummaryDtoCopyWithImpl<$Res, $Val extends MemberSummaryDto>
    implements $MemberSummaryDtoCopyWith<$Res> {
  _$MemberSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? username = null}) {
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
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemberSummaryDtoImplCopyWith<$Res>
    implements $MemberSummaryDtoCopyWith<$Res> {
  factory _$$MemberSummaryDtoImplCopyWith(
    _$MemberSummaryDtoImpl value,
    $Res Function(_$MemberSummaryDtoImpl) then,
  ) = __$$MemberSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String username});
}

/// @nodoc
class __$$MemberSummaryDtoImplCopyWithImpl<$Res>
    extends _$MemberSummaryDtoCopyWithImpl<$Res, _$MemberSummaryDtoImpl>
    implements _$$MemberSummaryDtoImplCopyWith<$Res> {
  __$$MemberSummaryDtoImplCopyWithImpl(
    _$MemberSummaryDtoImpl _value,
    $Res Function(_$MemberSummaryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemberSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? username = null}) {
    return _then(
      _$MemberSummaryDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberSummaryDtoImpl implements _MemberSummaryDto {
  const _$MemberSummaryDtoImpl({
    required this.id,
    required this.name,
    required this.username,
  });

  factory _$MemberSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String username;

  @override
  String toString() {
    return 'MemberSummaryDto(id: $id, name: $name, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username);

  /// Create a copy of MemberSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberSummaryDtoImplCopyWith<_$MemberSummaryDtoImpl> get copyWith =>
      __$$MemberSummaryDtoImplCopyWithImpl<_$MemberSummaryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberSummaryDtoImplToJson(this);
  }
}

abstract class _MemberSummaryDto implements MemberSummaryDto {
  const factory _MemberSummaryDto({
    required final String id,
    required final String name,
    required final String username,
  }) = _$MemberSummaryDtoImpl;

  factory _MemberSummaryDto.fromJson(Map<String, dynamic> json) =
      _$MemberSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get username;

  /// Create a copy of MemberSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberSummaryDtoImplCopyWith<_$MemberSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
