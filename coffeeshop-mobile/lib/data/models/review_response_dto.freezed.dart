// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewResponseDto _$ReviewResponseDtoFromJson(Map<String, dynamic> json) {
  return _ReviewResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ReviewResponseDto {
  String get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get reviewDate => throw _privateConstructorUsedError;
  bool get commentsEnabled => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get shopId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get user => throw _privateConstructorUsedError;
  Map<String, dynamic>? get shop => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get comments => throw _privateConstructorUsedError;

  /// Serializes this ReviewResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewResponseDtoCopyWith<ReviewResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewResponseDtoCopyWith<$Res> {
  factory $ReviewResponseDtoCopyWith(
    ReviewResponseDto value,
    $Res Function(ReviewResponseDto) then,
  ) = _$ReviewResponseDtoCopyWithImpl<$Res, ReviewResponseDto>;
  @useResult
  $Res call({
    String id,
    String? title,
    String? description,
    int rating,
    String? reviewDate,
    bool commentsEnabled,
    String? userId,
    String? shopId,
    Map<String, dynamic>? user,
    Map<String, dynamic>? shop,
    List<Map<String, dynamic>> comments,
  });
}

/// @nodoc
class _$ReviewResponseDtoCopyWithImpl<$Res, $Val extends ReviewResponseDto>
    implements $ReviewResponseDtoCopyWith<$Res> {
  _$ReviewResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? rating = null,
    Object? reviewDate = freezed,
    Object? commentsEnabled = null,
    Object? userId = freezed,
    Object? shopId = freezed,
    Object? user = freezed,
    Object? shop = freezed,
    Object? comments = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewDate: freezed == reviewDate
                ? _value.reviewDate
                : reviewDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            commentsEnabled: null == commentsEnabled
                ? _value.commentsEnabled
                : commentsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            shop: freezed == shop
                ? _value.shop
                : shop // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            comments: null == comments
                ? _value.comments
                : comments // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewResponseDtoImplCopyWith<$Res>
    implements $ReviewResponseDtoCopyWith<$Res> {
  factory _$$ReviewResponseDtoImplCopyWith(
    _$ReviewResponseDtoImpl value,
    $Res Function(_$ReviewResponseDtoImpl) then,
  ) = __$$ReviewResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? title,
    String? description,
    int rating,
    String? reviewDate,
    bool commentsEnabled,
    String? userId,
    String? shopId,
    Map<String, dynamic>? user,
    Map<String, dynamic>? shop,
    List<Map<String, dynamic>> comments,
  });
}

/// @nodoc
class __$$ReviewResponseDtoImplCopyWithImpl<$Res>
    extends _$ReviewResponseDtoCopyWithImpl<$Res, _$ReviewResponseDtoImpl>
    implements _$$ReviewResponseDtoImplCopyWith<$Res> {
  __$$ReviewResponseDtoImplCopyWithImpl(
    _$ReviewResponseDtoImpl _value,
    $Res Function(_$ReviewResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? rating = null,
    Object? reviewDate = freezed,
    Object? commentsEnabled = null,
    Object? userId = freezed,
    Object? shopId = freezed,
    Object? user = freezed,
    Object? shop = freezed,
    Object? comments = null,
  }) {
    return _then(
      _$ReviewResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewDate: freezed == reviewDate
            ? _value.reviewDate
            : reviewDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        commentsEnabled: null == commentsEnabled
            ? _value.commentsEnabled
            : commentsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        user: freezed == user
            ? _value._user
            : user // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        shop: freezed == shop
            ? _value._shop
            : shop // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        comments: null == comments
            ? _value._comments
            : comments // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewResponseDtoImpl implements _ReviewResponseDto {
  const _$ReviewResponseDtoImpl({
    required this.id,
    this.title,
    this.description,
    required this.rating,
    this.reviewDate,
    this.commentsEnabled = true,
    this.userId,
    this.shopId,
    final Map<String, dynamic>? user,
    final Map<String, dynamic>? shop,
    final List<Map<String, dynamic>> comments = const [],
  }) : _user = user,
       _shop = shop,
       _comments = comments;

  factory _$ReviewResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final int rating;
  @override
  final String? reviewDate;
  @override
  @JsonKey()
  final bool commentsEnabled;
  @override
  final String? userId;
  @override
  final String? shopId;
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

  final List<Map<String, dynamic>> _comments;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  String toString() {
    return 'ReviewResponseDto(id: $id, title: $title, description: $description, rating: $rating, reviewDate: $reviewDate, commentsEnabled: $commentsEnabled, userId: $userId, shopId: $shopId, user: $user, shop: $shop, comments: $comments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewDate, reviewDate) ||
                other.reviewDate == reviewDate) &&
            (identical(other.commentsEnabled, commentsEnabled) ||
                other.commentsEnabled == commentsEnabled) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            const DeepCollectionEquality().equals(other._user, _user) &&
            const DeepCollectionEquality().equals(other._shop, _shop) &&
            const DeepCollectionEquality().equals(other._comments, _comments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    rating,
    reviewDate,
    commentsEnabled,
    userId,
    shopId,
    const DeepCollectionEquality().hash(_user),
    const DeepCollectionEquality().hash(_shop),
    const DeepCollectionEquality().hash(_comments),
  );

  /// Create a copy of ReviewResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewResponseDtoImplCopyWith<_$ReviewResponseDtoImpl> get copyWith =>
      __$$ReviewResponseDtoImplCopyWithImpl<_$ReviewResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewResponseDtoImplToJson(this);
  }
}

abstract class _ReviewResponseDto implements ReviewResponseDto {
  const factory _ReviewResponseDto({
    required final String id,
    final String? title,
    final String? description,
    required final int rating,
    final String? reviewDate,
    final bool commentsEnabled,
    final String? userId,
    final String? shopId,
    final Map<String, dynamic>? user,
    final Map<String, dynamic>? shop,
    final List<Map<String, dynamic>> comments,
  }) = _$ReviewResponseDtoImpl;

  factory _ReviewResponseDto.fromJson(Map<String, dynamic> json) =
      _$ReviewResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String? get title;
  @override
  String? get description;
  @override
  int get rating;
  @override
  String? get reviewDate;
  @override
  bool get commentsEnabled;
  @override
  String? get userId;
  @override
  String? get shopId;
  @override
  Map<String, dynamic>? get user;
  @override
  Map<String, dynamic>? get shop;
  @override
  List<Map<String, dynamic>> get comments;

  /// Create a copy of ReviewResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewResponseDtoImplCopyWith<_$ReviewResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewCreateRequest _$ReviewCreateRequestFromJson(Map<String, dynamic> json) {
  return _ReviewCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$ReviewCreateRequest {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  bool get commentsEnabled => throw _privateConstructorUsedError;
  String get shopId => throw _privateConstructorUsedError;

  /// Serializes this ReviewCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewCreateRequestCopyWith<ReviewCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewCreateRequestCopyWith<$Res> {
  factory $ReviewCreateRequestCopyWith(
    ReviewCreateRequest value,
    $Res Function(ReviewCreateRequest) then,
  ) = _$ReviewCreateRequestCopyWithImpl<$Res, ReviewCreateRequest>;
  @useResult
  $Res call({
    String? title,
    String? description,
    int rating,
    bool commentsEnabled,
    String shopId,
  });
}

/// @nodoc
class _$ReviewCreateRequestCopyWithImpl<$Res, $Val extends ReviewCreateRequest>
    implements $ReviewCreateRequestCopyWith<$Res> {
  _$ReviewCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? rating = null,
    Object? commentsEnabled = null,
    Object? shopId = null,
  }) {
    return _then(
      _value.copyWith(
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            commentsEnabled: null == commentsEnabled
                ? _value.commentsEnabled
                : commentsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$ReviewCreateRequestImplCopyWith<$Res>
    implements $ReviewCreateRequestCopyWith<$Res> {
  factory _$$ReviewCreateRequestImplCopyWith(
    _$ReviewCreateRequestImpl value,
    $Res Function(_$ReviewCreateRequestImpl) then,
  ) = __$$ReviewCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? title,
    String? description,
    int rating,
    bool commentsEnabled,
    String shopId,
  });
}

/// @nodoc
class __$$ReviewCreateRequestImplCopyWithImpl<$Res>
    extends _$ReviewCreateRequestCopyWithImpl<$Res, _$ReviewCreateRequestImpl>
    implements _$$ReviewCreateRequestImplCopyWith<$Res> {
  __$$ReviewCreateRequestImplCopyWithImpl(
    _$ReviewCreateRequestImpl _value,
    $Res Function(_$ReviewCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? rating = null,
    Object? commentsEnabled = null,
    Object? shopId = null,
  }) {
    return _then(
      _$ReviewCreateRequestImpl(
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        commentsEnabled: null == commentsEnabled
            ? _value.commentsEnabled
            : commentsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$ReviewCreateRequestImpl implements _ReviewCreateRequest {
  const _$ReviewCreateRequestImpl({
    this.title,
    this.description,
    required this.rating,
    this.commentsEnabled = true,
    required this.shopId,
  });

  factory _$ReviewCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewCreateRequestImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  final int rating;
  @override
  @JsonKey()
  final bool commentsEnabled;
  @override
  final String shopId;

  @override
  String toString() {
    return 'ReviewCreateRequest(title: $title, description: $description, rating: $rating, commentsEnabled: $commentsEnabled, shopId: $shopId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewCreateRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.commentsEnabled, commentsEnabled) ||
                other.commentsEnabled == commentsEnabled) &&
            (identical(other.shopId, shopId) || other.shopId == shopId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    description,
    rating,
    commentsEnabled,
    shopId,
  );

  /// Create a copy of ReviewCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewCreateRequestImplCopyWith<_$ReviewCreateRequestImpl> get copyWith =>
      __$$ReviewCreateRequestImplCopyWithImpl<_$ReviewCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewCreateRequestImplToJson(this);
  }
}

abstract class _ReviewCreateRequest implements ReviewCreateRequest {
  const factory _ReviewCreateRequest({
    final String? title,
    final String? description,
    required final int rating,
    final bool commentsEnabled,
    required final String shopId,
  }) = _$ReviewCreateRequestImpl;

  factory _ReviewCreateRequest.fromJson(Map<String, dynamic> json) =
      _$ReviewCreateRequestImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  int get rating;
  @override
  bool get commentsEnabled;
  @override
  String get shopId;

  /// Create a copy of ReviewCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewCreateRequestImplCopyWith<_$ReviewCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewUpdateRequest _$ReviewUpdateRequestFromJson(Map<String, dynamic> json) {
  return _ReviewUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ReviewUpdateRequest {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get rating => throw _privateConstructorUsedError;
  bool? get commentsEnabled => throw _privateConstructorUsedError;

  /// Serializes this ReviewUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewUpdateRequestCopyWith<ReviewUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewUpdateRequestCopyWith<$Res> {
  factory $ReviewUpdateRequestCopyWith(
    ReviewUpdateRequest value,
    $Res Function(ReviewUpdateRequest) then,
  ) = _$ReviewUpdateRequestCopyWithImpl<$Res, ReviewUpdateRequest>;
  @useResult
  $Res call({
    String? title,
    String? description,
    int? rating,
    bool? commentsEnabled,
  });
}

/// @nodoc
class _$ReviewUpdateRequestCopyWithImpl<$Res, $Val extends ReviewUpdateRequest>
    implements $ReviewUpdateRequestCopyWith<$Res> {
  _$ReviewUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? rating = freezed,
    Object? commentsEnabled = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int?,
            commentsEnabled: freezed == commentsEnabled
                ? _value.commentsEnabled
                : commentsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewUpdateRequestImplCopyWith<$Res>
    implements $ReviewUpdateRequestCopyWith<$Res> {
  factory _$$ReviewUpdateRequestImplCopyWith(
    _$ReviewUpdateRequestImpl value,
    $Res Function(_$ReviewUpdateRequestImpl) then,
  ) = __$$ReviewUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? title,
    String? description,
    int? rating,
    bool? commentsEnabled,
  });
}

/// @nodoc
class __$$ReviewUpdateRequestImplCopyWithImpl<$Res>
    extends _$ReviewUpdateRequestCopyWithImpl<$Res, _$ReviewUpdateRequestImpl>
    implements _$$ReviewUpdateRequestImplCopyWith<$Res> {
  __$$ReviewUpdateRequestImplCopyWithImpl(
    _$ReviewUpdateRequestImpl _value,
    $Res Function(_$ReviewUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? rating = freezed,
    Object? commentsEnabled = freezed,
  }) {
    return _then(
      _$ReviewUpdateRequestImpl(
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int?,
        commentsEnabled: freezed == commentsEnabled
            ? _value.commentsEnabled
            : commentsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewUpdateRequestImpl implements _ReviewUpdateRequest {
  const _$ReviewUpdateRequestImpl({
    this.title,
    this.description,
    this.rating,
    this.commentsEnabled,
  });

  factory _$ReviewUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewUpdateRequestImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  final int? rating;
  @override
  final bool? commentsEnabled;

  @override
  String toString() {
    return 'ReviewUpdateRequest(title: $title, description: $description, rating: $rating, commentsEnabled: $commentsEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewUpdateRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.commentsEnabled, commentsEnabled) ||
                other.commentsEnabled == commentsEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, title, description, rating, commentsEnabled);

  /// Create a copy of ReviewUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewUpdateRequestImplCopyWith<_$ReviewUpdateRequestImpl> get copyWith =>
      __$$ReviewUpdateRequestImplCopyWithImpl<_$ReviewUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewUpdateRequestImplToJson(this);
  }
}

abstract class _ReviewUpdateRequest implements ReviewUpdateRequest {
  const factory _ReviewUpdateRequest({
    final String? title,
    final String? description,
    final int? rating,
    final bool? commentsEnabled,
  }) = _$ReviewUpdateRequestImpl;

  factory _ReviewUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$ReviewUpdateRequestImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  int? get rating;
  @override
  bool? get commentsEnabled;

  /// Create a copy of ReviewUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewUpdateRequestImplCopyWith<_$ReviewUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
