// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_analytics_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardAnalyticsResponse _$DashboardAnalyticsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _DashboardAnalyticsResponse.fromJson(json);
}

/// @nodoc
mixin _$DashboardAnalyticsResponse {
  DashboardAnalyticsAggregate get aggregate =>
      throw _privateConstructorUsedError;
  List<DashboardShopAnalytics> get shops => throw _privateConstructorUsedError;

  /// Serializes this DashboardAnalyticsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardAnalyticsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardAnalyticsResponseCopyWith<DashboardAnalyticsResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardAnalyticsResponseCopyWith<$Res> {
  factory $DashboardAnalyticsResponseCopyWith(
    DashboardAnalyticsResponse value,
    $Res Function(DashboardAnalyticsResponse) then,
  ) =
      _$DashboardAnalyticsResponseCopyWithImpl<
        $Res,
        DashboardAnalyticsResponse
      >;
  @useResult
  $Res call({
    DashboardAnalyticsAggregate aggregate,
    List<DashboardShopAnalytics> shops,
  });

  $DashboardAnalyticsAggregateCopyWith<$Res> get aggregate;
}

/// @nodoc
class _$DashboardAnalyticsResponseCopyWithImpl<
  $Res,
  $Val extends DashboardAnalyticsResponse
>
    implements $DashboardAnalyticsResponseCopyWith<$Res> {
  _$DashboardAnalyticsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardAnalyticsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aggregate = null, Object? shops = null}) {
    return _then(
      _value.copyWith(
            aggregate: null == aggregate
                ? _value.aggregate
                : aggregate // ignore: cast_nullable_to_non_nullable
                      as DashboardAnalyticsAggregate,
            shops: null == shops
                ? _value.shops
                : shops // ignore: cast_nullable_to_non_nullable
                      as List<DashboardShopAnalytics>,
          )
          as $Val,
    );
  }

  /// Create a copy of DashboardAnalyticsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardAnalyticsAggregateCopyWith<$Res> get aggregate {
    return $DashboardAnalyticsAggregateCopyWith<$Res>(_value.aggregate, (
      value,
    ) {
      return _then(_value.copyWith(aggregate: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardAnalyticsResponseImplCopyWith<$Res>
    implements $DashboardAnalyticsResponseCopyWith<$Res> {
  factory _$$DashboardAnalyticsResponseImplCopyWith(
    _$DashboardAnalyticsResponseImpl value,
    $Res Function(_$DashboardAnalyticsResponseImpl) then,
  ) = __$$DashboardAnalyticsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DashboardAnalyticsAggregate aggregate,
    List<DashboardShopAnalytics> shops,
  });

  @override
  $DashboardAnalyticsAggregateCopyWith<$Res> get aggregate;
}

/// @nodoc
class __$$DashboardAnalyticsResponseImplCopyWithImpl<$Res>
    extends
        _$DashboardAnalyticsResponseCopyWithImpl<
          $Res,
          _$DashboardAnalyticsResponseImpl
        >
    implements _$$DashboardAnalyticsResponseImplCopyWith<$Res> {
  __$$DashboardAnalyticsResponseImplCopyWithImpl(
    _$DashboardAnalyticsResponseImpl _value,
    $Res Function(_$DashboardAnalyticsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardAnalyticsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? aggregate = null, Object? shops = null}) {
    return _then(
      _$DashboardAnalyticsResponseImpl(
        aggregate: null == aggregate
            ? _value.aggregate
            : aggregate // ignore: cast_nullable_to_non_nullable
                  as DashboardAnalyticsAggregate,
        shops: null == shops
            ? _value._shops
            : shops // ignore: cast_nullable_to_non_nullable
                  as List<DashboardShopAnalytics>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardAnalyticsResponseImpl implements _DashboardAnalyticsResponse {
  const _$DashboardAnalyticsResponseImpl({
    required this.aggregate,
    final List<DashboardShopAnalytics> shops = const [],
  }) : _shops = shops;

  factory _$DashboardAnalyticsResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$DashboardAnalyticsResponseImplFromJson(json);

  @override
  final DashboardAnalyticsAggregate aggregate;
  final List<DashboardShopAnalytics> _shops;
  @override
  @JsonKey()
  List<DashboardShopAnalytics> get shops {
    if (_shops is EqualUnmodifiableListView) return _shops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shops);
  }

  @override
  String toString() {
    return 'DashboardAnalyticsResponse(aggregate: $aggregate, shops: $shops)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardAnalyticsResponseImpl &&
            (identical(other.aggregate, aggregate) ||
                other.aggregate == aggregate) &&
            const DeepCollectionEquality().equals(other._shops, _shops));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    aggregate,
    const DeepCollectionEquality().hash(_shops),
  );

  /// Create a copy of DashboardAnalyticsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardAnalyticsResponseImplCopyWith<_$DashboardAnalyticsResponseImpl>
  get copyWith =>
      __$$DashboardAnalyticsResponseImplCopyWithImpl<
        _$DashboardAnalyticsResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardAnalyticsResponseImplToJson(this);
  }
}

abstract class _DashboardAnalyticsResponse
    implements DashboardAnalyticsResponse {
  const factory _DashboardAnalyticsResponse({
    required final DashboardAnalyticsAggregate aggregate,
    final List<DashboardShopAnalytics> shops,
  }) = _$DashboardAnalyticsResponseImpl;

  factory _DashboardAnalyticsResponse.fromJson(Map<String, dynamic> json) =
      _$DashboardAnalyticsResponseImpl.fromJson;

  @override
  DashboardAnalyticsAggregate get aggregate;
  @override
  List<DashboardShopAnalytics> get shops;

  /// Create a copy of DashboardAnalyticsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardAnalyticsResponseImplCopyWith<_$DashboardAnalyticsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DashboardAnalyticsAggregate _$DashboardAnalyticsAggregateFromJson(
  Map<String, dynamic> json,
) {
  return _DashboardAnalyticsAggregate.fromJson(json);
}

/// @nodoc
mixin _$DashboardAnalyticsAggregate {
  int get shopCount => throw _privateConstructorUsedError;
  int get reservationCount => throw _privateConstructorUsedError;
  int get pendingReservationRequestCount => throw _privateConstructorUsedError;
  int get eventCount => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  double? get averageRating => throw _privateConstructorUsedError;
  int get communityPostCount => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  int get employeeCount => throw _privateConstructorUsedError;
  int get tableCount => throw _privateConstructorUsedError;
  int get menuCount => throw _privateConstructorUsedError;

  /// Serializes this DashboardAnalyticsAggregate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardAnalyticsAggregate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardAnalyticsAggregateCopyWith<DashboardAnalyticsAggregate>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardAnalyticsAggregateCopyWith<$Res> {
  factory $DashboardAnalyticsAggregateCopyWith(
    DashboardAnalyticsAggregate value,
    $Res Function(DashboardAnalyticsAggregate) then,
  ) =
      _$DashboardAnalyticsAggregateCopyWithImpl<
        $Res,
        DashboardAnalyticsAggregate
      >;
  @useResult
  $Res call({
    int shopCount,
    int reservationCount,
    int pendingReservationRequestCount,
    int eventCount,
    int reviewCount,
    double? averageRating,
    int communityPostCount,
    int memberCount,
    int employeeCount,
    int tableCount,
    int menuCount,
  });
}

/// @nodoc
class _$DashboardAnalyticsAggregateCopyWithImpl<
  $Res,
  $Val extends DashboardAnalyticsAggregate
>
    implements $DashboardAnalyticsAggregateCopyWith<$Res> {
  _$DashboardAnalyticsAggregateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardAnalyticsAggregate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shopCount = null,
    Object? reservationCount = null,
    Object? pendingReservationRequestCount = null,
    Object? eventCount = null,
    Object? reviewCount = null,
    Object? averageRating = freezed,
    Object? communityPostCount = null,
    Object? memberCount = null,
    Object? employeeCount = null,
    Object? tableCount = null,
    Object? menuCount = null,
  }) {
    return _then(
      _value.copyWith(
            shopCount: null == shopCount
                ? _value.shopCount
                : shopCount // ignore: cast_nullable_to_non_nullable
                      as int,
            reservationCount: null == reservationCount
                ? _value.reservationCount
                : reservationCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingReservationRequestCount:
                null == pendingReservationRequestCount
                ? _value.pendingReservationRequestCount
                : pendingReservationRequestCount // ignore: cast_nullable_to_non_nullable
                      as int,
            eventCount: null == eventCount
                ? _value.eventCount
                : eventCount // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            communityPostCount: null == communityPostCount
                ? _value.communityPostCount
                : communityPostCount // ignore: cast_nullable_to_non_nullable
                      as int,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
            employeeCount: null == employeeCount
                ? _value.employeeCount
                : employeeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            tableCount: null == tableCount
                ? _value.tableCount
                : tableCount // ignore: cast_nullable_to_non_nullable
                      as int,
            menuCount: null == menuCount
                ? _value.menuCount
                : menuCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardAnalyticsAggregateImplCopyWith<$Res>
    implements $DashboardAnalyticsAggregateCopyWith<$Res> {
  factory _$$DashboardAnalyticsAggregateImplCopyWith(
    _$DashboardAnalyticsAggregateImpl value,
    $Res Function(_$DashboardAnalyticsAggregateImpl) then,
  ) = __$$DashboardAnalyticsAggregateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int shopCount,
    int reservationCount,
    int pendingReservationRequestCount,
    int eventCount,
    int reviewCount,
    double? averageRating,
    int communityPostCount,
    int memberCount,
    int employeeCount,
    int tableCount,
    int menuCount,
  });
}

/// @nodoc
class __$$DashboardAnalyticsAggregateImplCopyWithImpl<$Res>
    extends
        _$DashboardAnalyticsAggregateCopyWithImpl<
          $Res,
          _$DashboardAnalyticsAggregateImpl
        >
    implements _$$DashboardAnalyticsAggregateImplCopyWith<$Res> {
  __$$DashboardAnalyticsAggregateImplCopyWithImpl(
    _$DashboardAnalyticsAggregateImpl _value,
    $Res Function(_$DashboardAnalyticsAggregateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardAnalyticsAggregate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shopCount = null,
    Object? reservationCount = null,
    Object? pendingReservationRequestCount = null,
    Object? eventCount = null,
    Object? reviewCount = null,
    Object? averageRating = freezed,
    Object? communityPostCount = null,
    Object? memberCount = null,
    Object? employeeCount = null,
    Object? tableCount = null,
    Object? menuCount = null,
  }) {
    return _then(
      _$DashboardAnalyticsAggregateImpl(
        shopCount: null == shopCount
            ? _value.shopCount
            : shopCount // ignore: cast_nullable_to_non_nullable
                  as int,
        reservationCount: null == reservationCount
            ? _value.reservationCount
            : reservationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingReservationRequestCount: null == pendingReservationRequestCount
            ? _value.pendingReservationRequestCount
            : pendingReservationRequestCount // ignore: cast_nullable_to_non_nullable
                  as int,
        eventCount: null == eventCount
            ? _value.eventCount
            : eventCount // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        communityPostCount: null == communityPostCount
            ? _value.communityPostCount
            : communityPostCount // ignore: cast_nullable_to_non_nullable
                  as int,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
        employeeCount: null == employeeCount
            ? _value.employeeCount
            : employeeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        tableCount: null == tableCount
            ? _value.tableCount
            : tableCount // ignore: cast_nullable_to_non_nullable
                  as int,
        menuCount: null == menuCount
            ? _value.menuCount
            : menuCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardAnalyticsAggregateImpl
    implements _DashboardAnalyticsAggregate {
  const _$DashboardAnalyticsAggregateImpl({
    this.shopCount = 0,
    this.reservationCount = 0,
    this.pendingReservationRequestCount = 0,
    this.eventCount = 0,
    this.reviewCount = 0,
    this.averageRating,
    this.communityPostCount = 0,
    this.memberCount = 0,
    this.employeeCount = 0,
    this.tableCount = 0,
    this.menuCount = 0,
  });

  factory _$DashboardAnalyticsAggregateImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$DashboardAnalyticsAggregateImplFromJson(json);

  @override
  @JsonKey()
  final int shopCount;
  @override
  @JsonKey()
  final int reservationCount;
  @override
  @JsonKey()
  final int pendingReservationRequestCount;
  @override
  @JsonKey()
  final int eventCount;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  final double? averageRating;
  @override
  @JsonKey()
  final int communityPostCount;
  @override
  @JsonKey()
  final int memberCount;
  @override
  @JsonKey()
  final int employeeCount;
  @override
  @JsonKey()
  final int tableCount;
  @override
  @JsonKey()
  final int menuCount;

  @override
  String toString() {
    return 'DashboardAnalyticsAggregate(shopCount: $shopCount, reservationCount: $reservationCount, pendingReservationRequestCount: $pendingReservationRequestCount, eventCount: $eventCount, reviewCount: $reviewCount, averageRating: $averageRating, communityPostCount: $communityPostCount, memberCount: $memberCount, employeeCount: $employeeCount, tableCount: $tableCount, menuCount: $menuCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardAnalyticsAggregateImpl &&
            (identical(other.shopCount, shopCount) ||
                other.shopCount == shopCount) &&
            (identical(other.reservationCount, reservationCount) ||
                other.reservationCount == reservationCount) &&
            (identical(
                  other.pendingReservationRequestCount,
                  pendingReservationRequestCount,
                ) ||
                other.pendingReservationRequestCount ==
                    pendingReservationRequestCount) &&
            (identical(other.eventCount, eventCount) ||
                other.eventCount == eventCount) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.communityPostCount, communityPostCount) ||
                other.communityPostCount == communityPostCount) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.employeeCount, employeeCount) ||
                other.employeeCount == employeeCount) &&
            (identical(other.tableCount, tableCount) ||
                other.tableCount == tableCount) &&
            (identical(other.menuCount, menuCount) ||
                other.menuCount == menuCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    shopCount,
    reservationCount,
    pendingReservationRequestCount,
    eventCount,
    reviewCount,
    averageRating,
    communityPostCount,
    memberCount,
    employeeCount,
    tableCount,
    menuCount,
  );

  /// Create a copy of DashboardAnalyticsAggregate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardAnalyticsAggregateImplCopyWith<_$DashboardAnalyticsAggregateImpl>
  get copyWith =>
      __$$DashboardAnalyticsAggregateImplCopyWithImpl<
        _$DashboardAnalyticsAggregateImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardAnalyticsAggregateImplToJson(this);
  }
}

abstract class _DashboardAnalyticsAggregate
    implements DashboardAnalyticsAggregate {
  const factory _DashboardAnalyticsAggregate({
    final int shopCount,
    final int reservationCount,
    final int pendingReservationRequestCount,
    final int eventCount,
    final int reviewCount,
    final double? averageRating,
    final int communityPostCount,
    final int memberCount,
    final int employeeCount,
    final int tableCount,
    final int menuCount,
  }) = _$DashboardAnalyticsAggregateImpl;

  factory _DashboardAnalyticsAggregate.fromJson(Map<String, dynamic> json) =
      _$DashboardAnalyticsAggregateImpl.fromJson;

  @override
  int get shopCount;
  @override
  int get reservationCount;
  @override
  int get pendingReservationRequestCount;
  @override
  int get eventCount;
  @override
  int get reviewCount;
  @override
  double? get averageRating;
  @override
  int get communityPostCount;
  @override
  int get memberCount;
  @override
  int get employeeCount;
  @override
  int get tableCount;
  @override
  int get menuCount;

  /// Create a copy of DashboardAnalyticsAggregate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardAnalyticsAggregateImplCopyWith<_$DashboardAnalyticsAggregateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DashboardShopAnalytics _$DashboardShopAnalyticsFromJson(
  Map<String, dynamic> json,
) {
  return _DashboardShopAnalytics.fromJson(json);
}

/// @nodoc
mixin _$DashboardShopAnalytics {
  String get shopId => throw _privateConstructorUsedError;
  String get shopName => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  int get reservationCount => throw _privateConstructorUsedError;
  int get pendingReservationRequestCount => throw _privateConstructorUsedError;
  int get eventCount => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  double? get averageRating => throw _privateConstructorUsedError;
  int get communityPostCount => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  int get employeeCount => throw _privateConstructorUsedError;
  int get tableCount => throw _privateConstructorUsedError;
  int get menuCount => throw _privateConstructorUsedError;

  /// Serializes this DashboardShopAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardShopAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardShopAnalyticsCopyWith<DashboardShopAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardShopAnalyticsCopyWith<$Res> {
  factory $DashboardShopAnalyticsCopyWith(
    DashboardShopAnalytics value,
    $Res Function(DashboardShopAnalytics) then,
  ) = _$DashboardShopAnalyticsCopyWithImpl<$Res, DashboardShopAnalytics>;
  @useResult
  $Res call({
    String shopId,
    String shopName,
    String? city,
    int reservationCount,
    int pendingReservationRequestCount,
    int eventCount,
    int reviewCount,
    double? averageRating,
    int communityPostCount,
    int memberCount,
    int employeeCount,
    int tableCount,
    int menuCount,
  });
}

/// @nodoc
class _$DashboardShopAnalyticsCopyWithImpl<
  $Res,
  $Val extends DashboardShopAnalytics
>
    implements $DashboardShopAnalyticsCopyWith<$Res> {
  _$DashboardShopAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardShopAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shopId = null,
    Object? shopName = null,
    Object? city = freezed,
    Object? reservationCount = null,
    Object? pendingReservationRequestCount = null,
    Object? eventCount = null,
    Object? reviewCount = null,
    Object? averageRating = freezed,
    Object? communityPostCount = null,
    Object? memberCount = null,
    Object? employeeCount = null,
    Object? tableCount = null,
    Object? menuCount = null,
  }) {
    return _then(
      _value.copyWith(
            shopId: null == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String,
            shopName: null == shopName
                ? _value.shopName
                : shopName // ignore: cast_nullable_to_non_nullable
                      as String,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            reservationCount: null == reservationCount
                ? _value.reservationCount
                : reservationCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingReservationRequestCount:
                null == pendingReservationRequestCount
                ? _value.pendingReservationRequestCount
                : pendingReservationRequestCount // ignore: cast_nullable_to_non_nullable
                      as int,
            eventCount: null == eventCount
                ? _value.eventCount
                : eventCount // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            communityPostCount: null == communityPostCount
                ? _value.communityPostCount
                : communityPostCount // ignore: cast_nullable_to_non_nullable
                      as int,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
            employeeCount: null == employeeCount
                ? _value.employeeCount
                : employeeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            tableCount: null == tableCount
                ? _value.tableCount
                : tableCount // ignore: cast_nullable_to_non_nullable
                      as int,
            menuCount: null == menuCount
                ? _value.menuCount
                : menuCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardShopAnalyticsImplCopyWith<$Res>
    implements $DashboardShopAnalyticsCopyWith<$Res> {
  factory _$$DashboardShopAnalyticsImplCopyWith(
    _$DashboardShopAnalyticsImpl value,
    $Res Function(_$DashboardShopAnalyticsImpl) then,
  ) = __$$DashboardShopAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String shopId,
    String shopName,
    String? city,
    int reservationCount,
    int pendingReservationRequestCount,
    int eventCount,
    int reviewCount,
    double? averageRating,
    int communityPostCount,
    int memberCount,
    int employeeCount,
    int tableCount,
    int menuCount,
  });
}

/// @nodoc
class __$$DashboardShopAnalyticsImplCopyWithImpl<$Res>
    extends
        _$DashboardShopAnalyticsCopyWithImpl<$Res, _$DashboardShopAnalyticsImpl>
    implements _$$DashboardShopAnalyticsImplCopyWith<$Res> {
  __$$DashboardShopAnalyticsImplCopyWithImpl(
    _$DashboardShopAnalyticsImpl _value,
    $Res Function(_$DashboardShopAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardShopAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shopId = null,
    Object? shopName = null,
    Object? city = freezed,
    Object? reservationCount = null,
    Object? pendingReservationRequestCount = null,
    Object? eventCount = null,
    Object? reviewCount = null,
    Object? averageRating = freezed,
    Object? communityPostCount = null,
    Object? memberCount = null,
    Object? employeeCount = null,
    Object? tableCount = null,
    Object? menuCount = null,
  }) {
    return _then(
      _$DashboardShopAnalyticsImpl(
        shopId: null == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String,
        shopName: null == shopName
            ? _value.shopName
            : shopName // ignore: cast_nullable_to_non_nullable
                  as String,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        reservationCount: null == reservationCount
            ? _value.reservationCount
            : reservationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingReservationRequestCount: null == pendingReservationRequestCount
            ? _value.pendingReservationRequestCount
            : pendingReservationRequestCount // ignore: cast_nullable_to_non_nullable
                  as int,
        eventCount: null == eventCount
            ? _value.eventCount
            : eventCount // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        communityPostCount: null == communityPostCount
            ? _value.communityPostCount
            : communityPostCount // ignore: cast_nullable_to_non_nullable
                  as int,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
        employeeCount: null == employeeCount
            ? _value.employeeCount
            : employeeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        tableCount: null == tableCount
            ? _value.tableCount
            : tableCount // ignore: cast_nullable_to_non_nullable
                  as int,
        menuCount: null == menuCount
            ? _value.menuCount
            : menuCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardShopAnalyticsImpl implements _DashboardShopAnalytics {
  const _$DashboardShopAnalyticsImpl({
    required this.shopId,
    required this.shopName,
    this.city,
    this.reservationCount = 0,
    this.pendingReservationRequestCount = 0,
    this.eventCount = 0,
    this.reviewCount = 0,
    this.averageRating,
    this.communityPostCount = 0,
    this.memberCount = 0,
    this.employeeCount = 0,
    this.tableCount = 0,
    this.menuCount = 0,
  });

  factory _$DashboardShopAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardShopAnalyticsImplFromJson(json);

  @override
  final String shopId;
  @override
  final String shopName;
  @override
  final String? city;
  @override
  @JsonKey()
  final int reservationCount;
  @override
  @JsonKey()
  final int pendingReservationRequestCount;
  @override
  @JsonKey()
  final int eventCount;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  final double? averageRating;
  @override
  @JsonKey()
  final int communityPostCount;
  @override
  @JsonKey()
  final int memberCount;
  @override
  @JsonKey()
  final int employeeCount;
  @override
  @JsonKey()
  final int tableCount;
  @override
  @JsonKey()
  final int menuCount;

  @override
  String toString() {
    return 'DashboardShopAnalytics(shopId: $shopId, shopName: $shopName, city: $city, reservationCount: $reservationCount, pendingReservationRequestCount: $pendingReservationRequestCount, eventCount: $eventCount, reviewCount: $reviewCount, averageRating: $averageRating, communityPostCount: $communityPostCount, memberCount: $memberCount, employeeCount: $employeeCount, tableCount: $tableCount, menuCount: $menuCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardShopAnalyticsImpl &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.reservationCount, reservationCount) ||
                other.reservationCount == reservationCount) &&
            (identical(
                  other.pendingReservationRequestCount,
                  pendingReservationRequestCount,
                ) ||
                other.pendingReservationRequestCount ==
                    pendingReservationRequestCount) &&
            (identical(other.eventCount, eventCount) ||
                other.eventCount == eventCount) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.communityPostCount, communityPostCount) ||
                other.communityPostCount == communityPostCount) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.employeeCount, employeeCount) ||
                other.employeeCount == employeeCount) &&
            (identical(other.tableCount, tableCount) ||
                other.tableCount == tableCount) &&
            (identical(other.menuCount, menuCount) ||
                other.menuCount == menuCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    shopId,
    shopName,
    city,
    reservationCount,
    pendingReservationRequestCount,
    eventCount,
    reviewCount,
    averageRating,
    communityPostCount,
    memberCount,
    employeeCount,
    tableCount,
    menuCount,
  );

  /// Create a copy of DashboardShopAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardShopAnalyticsImplCopyWith<_$DashboardShopAnalyticsImpl>
  get copyWith =>
      __$$DashboardShopAnalyticsImplCopyWithImpl<_$DashboardShopAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardShopAnalyticsImplToJson(this);
  }
}

abstract class _DashboardShopAnalytics implements DashboardShopAnalytics {
  const factory _DashboardShopAnalytics({
    required final String shopId,
    required final String shopName,
    final String? city,
    final int reservationCount,
    final int pendingReservationRequestCount,
    final int eventCount,
    final int reviewCount,
    final double? averageRating,
    final int communityPostCount,
    final int memberCount,
    final int employeeCount,
    final int tableCount,
    final int menuCount,
  }) = _$DashboardShopAnalyticsImpl;

  factory _DashboardShopAnalytics.fromJson(Map<String, dynamic> json) =
      _$DashboardShopAnalyticsImpl.fromJson;

  @override
  String get shopId;
  @override
  String get shopName;
  @override
  String? get city;
  @override
  int get reservationCount;
  @override
  int get pendingReservationRequestCount;
  @override
  int get eventCount;
  @override
  int get reviewCount;
  @override
  double? get averageRating;
  @override
  int get communityPostCount;
  @override
  int get memberCount;
  @override
  int get employeeCount;
  @override
  int get tableCount;
  @override
  int get menuCount;

  /// Create a copy of DashboardShopAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardShopAnalyticsImplCopyWith<_$DashboardShopAnalyticsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
