// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubscriptionSummaryDto _$SubscriptionSummaryDtoFromJson(
  Map<String, dynamic> json,
) {
  return _SubscriptionSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionSummaryDto {
  String get planMode => throw _privateConstructorUsedError;
  String? get planTier => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get shopsIncluded => throw _privateConstructorUsedError;
  int get shopsUsed => throw _privateConstructorUsedError;
  String? get periodEnd => throw _privateConstructorUsedError;
  int get monthlyAmountCents => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionSummaryDtoCopyWith<SubscriptionSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionSummaryDtoCopyWith<$Res> {
  factory $SubscriptionSummaryDtoCopyWith(
    SubscriptionSummaryDto value,
    $Res Function(SubscriptionSummaryDto) then,
  ) = _$SubscriptionSummaryDtoCopyWithImpl<$Res, SubscriptionSummaryDto>;
  @useResult
  $Res call({
    String planMode,
    String? planTier,
    String status,
    int shopsIncluded,
    int shopsUsed,
    String? periodEnd,
    int monthlyAmountCents,
  });
}

/// @nodoc
class _$SubscriptionSummaryDtoCopyWithImpl<
  $Res,
  $Val extends SubscriptionSummaryDto
>
    implements $SubscriptionSummaryDtoCopyWith<$Res> {
  _$SubscriptionSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planMode = null,
    Object? planTier = freezed,
    Object? status = null,
    Object? shopsIncluded = null,
    Object? shopsUsed = null,
    Object? periodEnd = freezed,
    Object? monthlyAmountCents = null,
  }) {
    return _then(
      _value.copyWith(
            planMode: null == planMode
                ? _value.planMode
                : planMode // ignore: cast_nullable_to_non_nullable
                      as String,
            planTier: freezed == planTier
                ? _value.planTier
                : planTier // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            shopsIncluded: null == shopsIncluded
                ? _value.shopsIncluded
                : shopsIncluded // ignore: cast_nullable_to_non_nullable
                      as int,
            shopsUsed: null == shopsUsed
                ? _value.shopsUsed
                : shopsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            periodEnd: freezed == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as String?,
            monthlyAmountCents: null == monthlyAmountCents
                ? _value.monthlyAmountCents
                : monthlyAmountCents // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionSummaryDtoImplCopyWith<$Res>
    implements $SubscriptionSummaryDtoCopyWith<$Res> {
  factory _$$SubscriptionSummaryDtoImplCopyWith(
    _$SubscriptionSummaryDtoImpl value,
    $Res Function(_$SubscriptionSummaryDtoImpl) then,
  ) = __$$SubscriptionSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String planMode,
    String? planTier,
    String status,
    int shopsIncluded,
    int shopsUsed,
    String? periodEnd,
    int monthlyAmountCents,
  });
}

/// @nodoc
class __$$SubscriptionSummaryDtoImplCopyWithImpl<$Res>
    extends
        _$SubscriptionSummaryDtoCopyWithImpl<$Res, _$SubscriptionSummaryDtoImpl>
    implements _$$SubscriptionSummaryDtoImplCopyWith<$Res> {
  __$$SubscriptionSummaryDtoImplCopyWithImpl(
    _$SubscriptionSummaryDtoImpl _value,
    $Res Function(_$SubscriptionSummaryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planMode = null,
    Object? planTier = freezed,
    Object? status = null,
    Object? shopsIncluded = null,
    Object? shopsUsed = null,
    Object? periodEnd = freezed,
    Object? monthlyAmountCents = null,
  }) {
    return _then(
      _$SubscriptionSummaryDtoImpl(
        planMode: null == planMode
            ? _value.planMode
            : planMode // ignore: cast_nullable_to_non_nullable
                  as String,
        planTier: freezed == planTier
            ? _value.planTier
            : planTier // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        shopsIncluded: null == shopsIncluded
            ? _value.shopsIncluded
            : shopsIncluded // ignore: cast_nullable_to_non_nullable
                  as int,
        shopsUsed: null == shopsUsed
            ? _value.shopsUsed
            : shopsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        periodEnd: freezed == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as String?,
        monthlyAmountCents: null == monthlyAmountCents
            ? _value.monthlyAmountCents
            : monthlyAmountCents // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionSummaryDtoImpl implements _SubscriptionSummaryDto {
  const _$SubscriptionSummaryDtoImpl({
    required this.planMode,
    this.planTier,
    required this.status,
    this.shopsIncluded = 0,
    this.shopsUsed = 0,
    this.periodEnd,
    this.monthlyAmountCents = 0,
  });

  factory _$SubscriptionSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionSummaryDtoImplFromJson(json);

  @override
  final String planMode;
  @override
  final String? planTier;
  @override
  final String status;
  @override
  @JsonKey()
  final int shopsIncluded;
  @override
  @JsonKey()
  final int shopsUsed;
  @override
  final String? periodEnd;
  @override
  @JsonKey()
  final int monthlyAmountCents;

  @override
  String toString() {
    return 'SubscriptionSummaryDto(planMode: $planMode, planTier: $planTier, status: $status, shopsIncluded: $shopsIncluded, shopsUsed: $shopsUsed, periodEnd: $periodEnd, monthlyAmountCents: $monthlyAmountCents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionSummaryDtoImpl &&
            (identical(other.planMode, planMode) ||
                other.planMode == planMode) &&
            (identical(other.planTier, planTier) ||
                other.planTier == planTier) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.shopsIncluded, shopsIncluded) ||
                other.shopsIncluded == shopsIncluded) &&
            (identical(other.shopsUsed, shopsUsed) ||
                other.shopsUsed == shopsUsed) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.monthlyAmountCents, monthlyAmountCents) ||
                other.monthlyAmountCents == monthlyAmountCents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    planMode,
    planTier,
    status,
    shopsIncluded,
    shopsUsed,
    periodEnd,
    monthlyAmountCents,
  );

  /// Create a copy of SubscriptionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionSummaryDtoImplCopyWith<_$SubscriptionSummaryDtoImpl>
  get copyWith =>
      __$$SubscriptionSummaryDtoImplCopyWithImpl<_$SubscriptionSummaryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionSummaryDtoImplToJson(this);
  }
}

abstract class _SubscriptionSummaryDto implements SubscriptionSummaryDto {
  const factory _SubscriptionSummaryDto({
    required final String planMode,
    final String? planTier,
    required final String status,
    final int shopsIncluded,
    final int shopsUsed,
    final String? periodEnd,
    final int monthlyAmountCents,
  }) = _$SubscriptionSummaryDtoImpl;

  factory _SubscriptionSummaryDto.fromJson(Map<String, dynamic> json) =
      _$SubscriptionSummaryDtoImpl.fromJson;

  @override
  String get planMode;
  @override
  String? get planTier;
  @override
  String get status;
  @override
  int get shopsIncluded;
  @override
  int get shopsUsed;
  @override
  String? get periodEnd;
  @override
  int get monthlyAmountCents;

  /// Create a copy of SubscriptionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionSummaryDtoImplCopyWith<_$SubscriptionSummaryDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LimitUsageDto _$LimitUsageDtoFromJson(Map<String, dynamic> json) {
  return _LimitUsageDto.fromJson(json);
}

/// @nodoc
mixin _$LimitUsageDto {
  int get used => throw _privateConstructorUsedError;
  int get max => throw _privateConstructorUsedError;

  /// Serializes this LimitUsageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LimitUsageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LimitUsageDtoCopyWith<LimitUsageDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LimitUsageDtoCopyWith<$Res> {
  factory $LimitUsageDtoCopyWith(
    LimitUsageDto value,
    $Res Function(LimitUsageDto) then,
  ) = _$LimitUsageDtoCopyWithImpl<$Res, LimitUsageDto>;
  @useResult
  $Res call({int used, int max});
}

/// @nodoc
class _$LimitUsageDtoCopyWithImpl<$Res, $Val extends LimitUsageDto>
    implements $LimitUsageDtoCopyWith<$Res> {
  _$LimitUsageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LimitUsageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? used = null, Object? max = null}) {
    return _then(
      _value.copyWith(
            used: null == used
                ? _value.used
                : used // ignore: cast_nullable_to_non_nullable
                      as int,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LimitUsageDtoImplCopyWith<$Res>
    implements $LimitUsageDtoCopyWith<$Res> {
  factory _$$LimitUsageDtoImplCopyWith(
    _$LimitUsageDtoImpl value,
    $Res Function(_$LimitUsageDtoImpl) then,
  ) = __$$LimitUsageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int used, int max});
}

/// @nodoc
class __$$LimitUsageDtoImplCopyWithImpl<$Res>
    extends _$LimitUsageDtoCopyWithImpl<$Res, _$LimitUsageDtoImpl>
    implements _$$LimitUsageDtoImplCopyWith<$Res> {
  __$$LimitUsageDtoImplCopyWithImpl(
    _$LimitUsageDtoImpl _value,
    $Res Function(_$LimitUsageDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LimitUsageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? used = null, Object? max = null}) {
    return _then(
      _$LimitUsageDtoImpl(
        used: null == used
            ? _value.used
            : used // ignore: cast_nullable_to_non_nullable
                  as int,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LimitUsageDtoImpl implements _LimitUsageDto {
  const _$LimitUsageDtoImpl({required this.used, required this.max});

  factory _$LimitUsageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LimitUsageDtoImplFromJson(json);

  @override
  final int used;
  @override
  final int max;

  @override
  String toString() {
    return 'LimitUsageDto(used: $used, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LimitUsageDtoImpl &&
            (identical(other.used, used) || other.used == used) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, used, max);

  /// Create a copy of LimitUsageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LimitUsageDtoImplCopyWith<_$LimitUsageDtoImpl> get copyWith =>
      __$$LimitUsageDtoImplCopyWithImpl<_$LimitUsageDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LimitUsageDtoImplToJson(this);
  }
}

abstract class _LimitUsageDto implements LimitUsageDto {
  const factory _LimitUsageDto({
    required final int used,
    required final int max,
  }) = _$LimitUsageDtoImpl;

  factory _LimitUsageDto.fromJson(Map<String, dynamic> json) =
      _$LimitUsageDtoImpl.fromJson;

  @override
  int get used;
  @override
  int get max;

  /// Create a copy of LimitUsageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LimitUsageDtoImplCopyWith<_$LimitUsageDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfileResponseDto _$UserProfileResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _UserProfileResponseDto.fromJson(json);
}

/// @nodoc
mixin _$UserProfileResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get userType => throw _privateConstructorUsedError;
  List<ShopSummaryDto> get favouriteShops => throw _privateConstructorUsedError;
  SubscriptionSummaryDto? get subscription =>
      throw _privateConstructorUsedError;
  Map<String, bool> get entitlements => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _limitsFromJson, toJson: _limitsToJson)
  Map<String, LimitUsageDto> get limits => throw _privateConstructorUsedError;

  /// Serializes this UserProfileResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileResponseDtoCopyWith<UserProfileResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileResponseDtoCopyWith<$Res> {
  factory $UserProfileResponseDtoCopyWith(
    UserProfileResponseDto value,
    $Res Function(UserProfileResponseDto) then,
  ) = _$UserProfileResponseDtoCopyWithImpl<$Res, UserProfileResponseDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String username,
    String email,
    String userType,
    List<ShopSummaryDto> favouriteShops,
    SubscriptionSummaryDto? subscription,
    Map<String, bool> entitlements,
    @JsonKey(fromJson: _limitsFromJson, toJson: _limitsToJson)
    Map<String, LimitUsageDto> limits,
  });

  $SubscriptionSummaryDtoCopyWith<$Res>? get subscription;
}

/// @nodoc
class _$UserProfileResponseDtoCopyWithImpl<
  $Res,
  $Val extends UserProfileResponseDto
>
    implements $UserProfileResponseDtoCopyWith<$Res> {
  _$UserProfileResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = null,
    Object? email = null,
    Object? userType = null,
    Object? favouriteShops = null,
    Object? subscription = freezed,
    Object? entitlements = null,
    Object? limits = null,
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
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            userType: null == userType
                ? _value.userType
                : userType // ignore: cast_nullable_to_non_nullable
                      as String,
            favouriteShops: null == favouriteShops
                ? _value.favouriteShops
                : favouriteShops // ignore: cast_nullable_to_non_nullable
                      as List<ShopSummaryDto>,
            subscription: freezed == subscription
                ? _value.subscription
                : subscription // ignore: cast_nullable_to_non_nullable
                      as SubscriptionSummaryDto?,
            entitlements: null == entitlements
                ? _value.entitlements
                : entitlements // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
            limits: null == limits
                ? _value.limits
                : limits // ignore: cast_nullable_to_non_nullable
                      as Map<String, LimitUsageDto>,
          )
          as $Val,
    );
  }

  /// Create a copy of UserProfileResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionSummaryDtoCopyWith<$Res>? get subscription {
    if (_value.subscription == null) {
      return null;
    }

    return $SubscriptionSummaryDtoCopyWith<$Res>(_value.subscription!, (value) {
      return _then(_value.copyWith(subscription: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileResponseDtoImplCopyWith<$Res>
    implements $UserProfileResponseDtoCopyWith<$Res> {
  factory _$$UserProfileResponseDtoImplCopyWith(
    _$UserProfileResponseDtoImpl value,
    $Res Function(_$UserProfileResponseDtoImpl) then,
  ) = __$$UserProfileResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String username,
    String email,
    String userType,
    List<ShopSummaryDto> favouriteShops,
    SubscriptionSummaryDto? subscription,
    Map<String, bool> entitlements,
    @JsonKey(fromJson: _limitsFromJson, toJson: _limitsToJson)
    Map<String, LimitUsageDto> limits,
  });

  @override
  $SubscriptionSummaryDtoCopyWith<$Res>? get subscription;
}

/// @nodoc
class __$$UserProfileResponseDtoImplCopyWithImpl<$Res>
    extends
        _$UserProfileResponseDtoCopyWithImpl<$Res, _$UserProfileResponseDtoImpl>
    implements _$$UserProfileResponseDtoImplCopyWith<$Res> {
  __$$UserProfileResponseDtoImplCopyWithImpl(
    _$UserProfileResponseDtoImpl _value,
    $Res Function(_$UserProfileResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = null,
    Object? email = null,
    Object? userType = null,
    Object? favouriteShops = null,
    Object? subscription = freezed,
    Object? entitlements = null,
    Object? limits = null,
  }) {
    return _then(
      _$UserProfileResponseDtoImpl(
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
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        userType: null == userType
            ? _value.userType
            : userType // ignore: cast_nullable_to_non_nullable
                  as String,
        favouriteShops: null == favouriteShops
            ? _value._favouriteShops
            : favouriteShops // ignore: cast_nullable_to_non_nullable
                  as List<ShopSummaryDto>,
        subscription: freezed == subscription
            ? _value.subscription
            : subscription // ignore: cast_nullable_to_non_nullable
                  as SubscriptionSummaryDto?,
        entitlements: null == entitlements
            ? _value._entitlements
            : entitlements // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
        limits: null == limits
            ? _value._limits
            : limits // ignore: cast_nullable_to_non_nullable
                  as Map<String, LimitUsageDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileResponseDtoImpl implements _UserProfileResponseDto {
  const _$UserProfileResponseDtoImpl({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.userType,
    final List<ShopSummaryDto> favouriteShops = const [],
    this.subscription,
    final Map<String, bool> entitlements = const {},
    @JsonKey(fromJson: _limitsFromJson, toJson: _limitsToJson)
    final Map<String, LimitUsageDto> limits = const {},
  }) : _favouriteShops = favouriteShops,
       _entitlements = entitlements,
       _limits = limits;

  factory _$UserProfileResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String username;
  @override
  final String email;
  @override
  final String userType;
  final List<ShopSummaryDto> _favouriteShops;
  @override
  @JsonKey()
  List<ShopSummaryDto> get favouriteShops {
    if (_favouriteShops is EqualUnmodifiableListView) return _favouriteShops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favouriteShops);
  }

  @override
  final SubscriptionSummaryDto? subscription;
  final Map<String, bool> _entitlements;
  @override
  @JsonKey()
  Map<String, bool> get entitlements {
    if (_entitlements is EqualUnmodifiableMapView) return _entitlements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_entitlements);
  }

  final Map<String, LimitUsageDto> _limits;
  @override
  @JsonKey(fromJson: _limitsFromJson, toJson: _limitsToJson)
  Map<String, LimitUsageDto> get limits {
    if (_limits is EqualUnmodifiableMapView) return _limits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_limits);
  }

  @override
  String toString() {
    return 'UserProfileResponseDto(id: $id, name: $name, username: $username, email: $email, userType: $userType, favouriteShops: $favouriteShops, subscription: $subscription, entitlements: $entitlements, limits: $limits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            const DeepCollectionEquality().equals(
              other._favouriteShops,
              _favouriteShops,
            ) &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription) &&
            const DeepCollectionEquality().equals(
              other._entitlements,
              _entitlements,
            ) &&
            const DeepCollectionEquality().equals(other._limits, _limits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    username,
    email,
    userType,
    const DeepCollectionEquality().hash(_favouriteShops),
    subscription,
    const DeepCollectionEquality().hash(_entitlements),
    const DeepCollectionEquality().hash(_limits),
  );

  /// Create a copy of UserProfileResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileResponseDtoImplCopyWith<_$UserProfileResponseDtoImpl>
  get copyWith =>
      __$$UserProfileResponseDtoImplCopyWithImpl<_$UserProfileResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileResponseDtoImplToJson(this);
  }
}

abstract class _UserProfileResponseDto implements UserProfileResponseDto {
  const factory _UserProfileResponseDto({
    required final String id,
    required final String name,
    required final String username,
    required final String email,
    required final String userType,
    final List<ShopSummaryDto> favouriteShops,
    final SubscriptionSummaryDto? subscription,
    final Map<String, bool> entitlements,
    @JsonKey(fromJson: _limitsFromJson, toJson: _limitsToJson)
    final Map<String, LimitUsageDto> limits,
  }) = _$UserProfileResponseDtoImpl;

  factory _UserProfileResponseDto.fromJson(Map<String, dynamic> json) =
      _$UserProfileResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get username;
  @override
  String get email;
  @override
  String get userType;
  @override
  List<ShopSummaryDto> get favouriteShops;
  @override
  SubscriptionSummaryDto? get subscription;
  @override
  Map<String, bool> get entitlements;
  @override
  @JsonKey(fromJson: _limitsFromJson, toJson: _limitsToJson)
  Map<String, LimitUsageDto> get limits;

  /// Create a copy of UserProfileResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileResponseDtoImplCopyWith<_$UserProfileResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
