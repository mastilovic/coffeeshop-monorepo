// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_activity_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardActivityResponse _$DashboardActivityResponseFromJson(
  Map<String, dynamic> json,
) {
  return _DashboardActivityResponse.fromJson(json);
}

/// @nodoc
mixin _$DashboardActivityResponse {
  DashboardAggregate get aggregate => throw _privateConstructorUsedError;
  List<DashboardActivityItem> get activities =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'top_shops')
  List<TopShopItem> get topShops => throw _privateConstructorUsedError;
  @JsonKey(name: 'upcoming_events')
  List<UpcomingEventItem> get upcomingEvents =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'personal_summary')
  DashboardPersonalSummary? get personalSummary =>
      throw _privateConstructorUsedError;
  List<DashboardNotification> get notifications =>
      throw _privateConstructorUsedError;

  /// Serializes this DashboardActivityResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardActivityResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardActivityResponseCopyWith<DashboardActivityResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardActivityResponseCopyWith<$Res> {
  factory $DashboardActivityResponseCopyWith(
    DashboardActivityResponse value,
    $Res Function(DashboardActivityResponse) then,
  ) = _$DashboardActivityResponseCopyWithImpl<$Res, DashboardActivityResponse>;
  @useResult
  $Res call({
    DashboardAggregate aggregate,
    List<DashboardActivityItem> activities,
    @JsonKey(name: 'top_shops') List<TopShopItem> topShops,
    @JsonKey(name: 'upcoming_events') List<UpcomingEventItem> upcomingEvents,
    @JsonKey(name: 'personal_summary')
    DashboardPersonalSummary? personalSummary,
    List<DashboardNotification> notifications,
  });

  $DashboardAggregateCopyWith<$Res> get aggregate;
  $DashboardPersonalSummaryCopyWith<$Res>? get personalSummary;
}

/// @nodoc
class _$DashboardActivityResponseCopyWithImpl<
  $Res,
  $Val extends DashboardActivityResponse
>
    implements $DashboardActivityResponseCopyWith<$Res> {
  _$DashboardActivityResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardActivityResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aggregate = null,
    Object? activities = null,
    Object? topShops = null,
    Object? upcomingEvents = null,
    Object? personalSummary = freezed,
    Object? notifications = null,
  }) {
    return _then(
      _value.copyWith(
            aggregate: null == aggregate
                ? _value.aggregate
                : aggregate // ignore: cast_nullable_to_non_nullable
                      as DashboardAggregate,
            activities: null == activities
                ? _value.activities
                : activities // ignore: cast_nullable_to_non_nullable
                      as List<DashboardActivityItem>,
            topShops: null == topShops
                ? _value.topShops
                : topShops // ignore: cast_nullable_to_non_nullable
                      as List<TopShopItem>,
            upcomingEvents: null == upcomingEvents
                ? _value.upcomingEvents
                : upcomingEvents // ignore: cast_nullable_to_non_nullable
                      as List<UpcomingEventItem>,
            personalSummary: freezed == personalSummary
                ? _value.personalSummary
                : personalSummary // ignore: cast_nullable_to_non_nullable
                      as DashboardPersonalSummary?,
            notifications: null == notifications
                ? _value.notifications
                : notifications // ignore: cast_nullable_to_non_nullable
                      as List<DashboardNotification>,
          )
          as $Val,
    );
  }

  /// Create a copy of DashboardActivityResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardAggregateCopyWith<$Res> get aggregate {
    return $DashboardAggregateCopyWith<$Res>(_value.aggregate, (value) {
      return _then(_value.copyWith(aggregate: value) as $Val);
    });
  }

  /// Create a copy of DashboardActivityResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardPersonalSummaryCopyWith<$Res>? get personalSummary {
    if (_value.personalSummary == null) {
      return null;
    }

    return $DashboardPersonalSummaryCopyWith<$Res>(_value.personalSummary!, (
      value,
    ) {
      return _then(_value.copyWith(personalSummary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardActivityResponseImplCopyWith<$Res>
    implements $DashboardActivityResponseCopyWith<$Res> {
  factory _$$DashboardActivityResponseImplCopyWith(
    _$DashboardActivityResponseImpl value,
    $Res Function(_$DashboardActivityResponseImpl) then,
  ) = __$$DashboardActivityResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DashboardAggregate aggregate,
    List<DashboardActivityItem> activities,
    @JsonKey(name: 'top_shops') List<TopShopItem> topShops,
    @JsonKey(name: 'upcoming_events') List<UpcomingEventItem> upcomingEvents,
    @JsonKey(name: 'personal_summary')
    DashboardPersonalSummary? personalSummary,
    List<DashboardNotification> notifications,
  });

  @override
  $DashboardAggregateCopyWith<$Res> get aggregate;
  @override
  $DashboardPersonalSummaryCopyWith<$Res>? get personalSummary;
}

/// @nodoc
class __$$DashboardActivityResponseImplCopyWithImpl<$Res>
    extends
        _$DashboardActivityResponseCopyWithImpl<
          $Res,
          _$DashboardActivityResponseImpl
        >
    implements _$$DashboardActivityResponseImplCopyWith<$Res> {
  __$$DashboardActivityResponseImplCopyWithImpl(
    _$DashboardActivityResponseImpl _value,
    $Res Function(_$DashboardActivityResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardActivityResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aggregate = null,
    Object? activities = null,
    Object? topShops = null,
    Object? upcomingEvents = null,
    Object? personalSummary = freezed,
    Object? notifications = null,
  }) {
    return _then(
      _$DashboardActivityResponseImpl(
        aggregate: null == aggregate
            ? _value.aggregate
            : aggregate // ignore: cast_nullable_to_non_nullable
                  as DashboardAggregate,
        activities: null == activities
            ? _value._activities
            : activities // ignore: cast_nullable_to_non_nullable
                  as List<DashboardActivityItem>,
        topShops: null == topShops
            ? _value._topShops
            : topShops // ignore: cast_nullable_to_non_nullable
                  as List<TopShopItem>,
        upcomingEvents: null == upcomingEvents
            ? _value._upcomingEvents
            : upcomingEvents // ignore: cast_nullable_to_non_nullable
                  as List<UpcomingEventItem>,
        personalSummary: freezed == personalSummary
            ? _value.personalSummary
            : personalSummary // ignore: cast_nullable_to_non_nullable
                  as DashboardPersonalSummary?,
        notifications: null == notifications
            ? _value._notifications
            : notifications // ignore: cast_nullable_to_non_nullable
                  as List<DashboardNotification>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardActivityResponseImpl implements _DashboardActivityResponse {
  const _$DashboardActivityResponseImpl({
    required this.aggregate,
    final List<DashboardActivityItem> activities = const [],
    @JsonKey(name: 'top_shops') final List<TopShopItem> topShops = const [],
    @JsonKey(name: 'upcoming_events')
    final List<UpcomingEventItem> upcomingEvents = const [],
    @JsonKey(name: 'personal_summary') this.personalSummary,
    final List<DashboardNotification> notifications = const [],
  }) : _activities = activities,
       _topShops = topShops,
       _upcomingEvents = upcomingEvents,
       _notifications = notifications;

  factory _$DashboardActivityResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardActivityResponseImplFromJson(json);

  @override
  final DashboardAggregate aggregate;
  final List<DashboardActivityItem> _activities;
  @override
  @JsonKey()
  List<DashboardActivityItem> get activities {
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activities);
  }

  final List<TopShopItem> _topShops;
  @override
  @JsonKey(name: 'top_shops')
  List<TopShopItem> get topShops {
    if (_topShops is EqualUnmodifiableListView) return _topShops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topShops);
  }

  final List<UpcomingEventItem> _upcomingEvents;
  @override
  @JsonKey(name: 'upcoming_events')
  List<UpcomingEventItem> get upcomingEvents {
    if (_upcomingEvents is EqualUnmodifiableListView) return _upcomingEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcomingEvents);
  }

  @override
  @JsonKey(name: 'personal_summary')
  final DashboardPersonalSummary? personalSummary;
  final List<DashboardNotification> _notifications;
  @override
  @JsonKey()
  List<DashboardNotification> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  String toString() {
    return 'DashboardActivityResponse(aggregate: $aggregate, activities: $activities, topShops: $topShops, upcomingEvents: $upcomingEvents, personalSummary: $personalSummary, notifications: $notifications)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardActivityResponseImpl &&
            (identical(other.aggregate, aggregate) ||
                other.aggregate == aggregate) &&
            const DeepCollectionEquality().equals(
              other._activities,
              _activities,
            ) &&
            const DeepCollectionEquality().equals(other._topShops, _topShops) &&
            const DeepCollectionEquality().equals(
              other._upcomingEvents,
              _upcomingEvents,
            ) &&
            (identical(other.personalSummary, personalSummary) ||
                other.personalSummary == personalSummary) &&
            const DeepCollectionEquality().equals(
              other._notifications,
              _notifications,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    aggregate,
    const DeepCollectionEquality().hash(_activities),
    const DeepCollectionEquality().hash(_topShops),
    const DeepCollectionEquality().hash(_upcomingEvents),
    personalSummary,
    const DeepCollectionEquality().hash(_notifications),
  );

  /// Create a copy of DashboardActivityResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardActivityResponseImplCopyWith<_$DashboardActivityResponseImpl>
  get copyWith =>
      __$$DashboardActivityResponseImplCopyWithImpl<
        _$DashboardActivityResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardActivityResponseImplToJson(this);
  }
}

abstract class _DashboardActivityResponse implements DashboardActivityResponse {
  const factory _DashboardActivityResponse({
    required final DashboardAggregate aggregate,
    final List<DashboardActivityItem> activities,
    @JsonKey(name: 'top_shops') final List<TopShopItem> topShops,
    @JsonKey(name: 'upcoming_events')
    final List<UpcomingEventItem> upcomingEvents,
    @JsonKey(name: 'personal_summary')
    final DashboardPersonalSummary? personalSummary,
    final List<DashboardNotification> notifications,
  }) = _$DashboardActivityResponseImpl;

  factory _DashboardActivityResponse.fromJson(Map<String, dynamic> json) =
      _$DashboardActivityResponseImpl.fromJson;

  @override
  DashboardAggregate get aggregate;
  @override
  List<DashboardActivityItem> get activities;
  @override
  @JsonKey(name: 'top_shops')
  List<TopShopItem> get topShops;
  @override
  @JsonKey(name: 'upcoming_events')
  List<UpcomingEventItem> get upcomingEvents;
  @override
  @JsonKey(name: 'personal_summary')
  DashboardPersonalSummary? get personalSummary;
  @override
  List<DashboardNotification> get notifications;

  /// Create a copy of DashboardActivityResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardActivityResponseImplCopyWith<_$DashboardActivityResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DashboardActivityItem _$DashboardActivityItemFromJson(
  Map<String, dynamic> json,
) {
  return _DashboardActivityItem.fromJson(json);
}

/// @nodoc
mixin _$DashboardActivityItem {
  String get type => throw _privateConstructorUsedError;
  String? get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_id')
  String? get shopId => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_name')
  String? get shopName => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  @JsonKey(name: 'actor_name')
  String? get actorName => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;

  /// Serializes this DashboardActivityItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardActivityItemCopyWith<DashboardActivityItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardActivityItemCopyWith<$Res> {
  factory $DashboardActivityItemCopyWith(
    DashboardActivityItem value,
    $Res Function(DashboardActivityItem) then,
  ) = _$DashboardActivityItemCopyWithImpl<$Res, DashboardActivityItem>;
  @useResult
  $Res call({
    String type,
    String? timestamp,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'shop_name') String? shopName,
    String? title,
    String? body,
    @JsonKey(name: 'actor_name') String? actorName,
    double? rating,
  });
}

/// @nodoc
class _$DashboardActivityItemCopyWithImpl<
  $Res,
  $Val extends DashboardActivityItem
>
    implements $DashboardActivityItemCopyWith<$Res> {
  _$DashboardActivityItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? timestamp = freezed,
    Object? shopId = freezed,
    Object? shopName = freezed,
    Object? title = freezed,
    Object? body = freezed,
    Object? actorName = freezed,
    Object? rating = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopName: freezed == shopName
                ? _value.shopName
                : shopName // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            body: freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String?,
            actorName: freezed == actorName
                ? _value.actorName
                : actorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardActivityItemImplCopyWith<$Res>
    implements $DashboardActivityItemCopyWith<$Res> {
  factory _$$DashboardActivityItemImplCopyWith(
    _$DashboardActivityItemImpl value,
    $Res Function(_$DashboardActivityItemImpl) then,
  ) = __$$DashboardActivityItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String? timestamp,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'shop_name') String? shopName,
    String? title,
    String? body,
    @JsonKey(name: 'actor_name') String? actorName,
    double? rating,
  });
}

/// @nodoc
class __$$DashboardActivityItemImplCopyWithImpl<$Res>
    extends
        _$DashboardActivityItemCopyWithImpl<$Res, _$DashboardActivityItemImpl>
    implements _$$DashboardActivityItemImplCopyWith<$Res> {
  __$$DashboardActivityItemImplCopyWithImpl(
    _$DashboardActivityItemImpl _value,
    $Res Function(_$DashboardActivityItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? timestamp = freezed,
    Object? shopId = freezed,
    Object? shopName = freezed,
    Object? title = freezed,
    Object? body = freezed,
    Object? actorName = freezed,
    Object? rating = freezed,
  }) {
    return _then(
      _$DashboardActivityItemImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopName: freezed == shopName
            ? _value.shopName
            : shopName // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        body: freezed == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String?,
        actorName: freezed == actorName
            ? _value.actorName
            : actorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardActivityItemImpl implements _DashboardActivityItem {
  const _$DashboardActivityItemImpl({
    required this.type,
    this.timestamp,
    @JsonKey(name: 'shop_id') this.shopId,
    @JsonKey(name: 'shop_name') this.shopName,
    this.title,
    this.body,
    @JsonKey(name: 'actor_name') this.actorName,
    this.rating,
  });

  factory _$DashboardActivityItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardActivityItemImplFromJson(json);

  @override
  final String type;
  @override
  final String? timestamp;
  @override
  @JsonKey(name: 'shop_id')
  final String? shopId;
  @override
  @JsonKey(name: 'shop_name')
  final String? shopName;
  @override
  final String? title;
  @override
  final String? body;
  @override
  @JsonKey(name: 'actor_name')
  final String? actorName;
  @override
  final double? rating;

  @override
  String toString() {
    return 'DashboardActivityItem(type: $type, timestamp: $timestamp, shopId: $shopId, shopName: $shopName, title: $title, body: $body, actorName: $actorName, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardActivityItemImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.actorName, actorName) ||
                other.actorName == actorName) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    timestamp,
    shopId,
    shopName,
    title,
    body,
    actorName,
    rating,
  );

  /// Create a copy of DashboardActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardActivityItemImplCopyWith<_$DashboardActivityItemImpl>
  get copyWith =>
      __$$DashboardActivityItemImplCopyWithImpl<_$DashboardActivityItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardActivityItemImplToJson(this);
  }
}

abstract class _DashboardActivityItem implements DashboardActivityItem {
  const factory _DashboardActivityItem({
    required final String type,
    final String? timestamp,
    @JsonKey(name: 'shop_id') final String? shopId,
    @JsonKey(name: 'shop_name') final String? shopName,
    final String? title,
    final String? body,
    @JsonKey(name: 'actor_name') final String? actorName,
    final double? rating,
  }) = _$DashboardActivityItemImpl;

  factory _DashboardActivityItem.fromJson(Map<String, dynamic> json) =
      _$DashboardActivityItemImpl.fromJson;

  @override
  String get type;
  @override
  String? get timestamp;
  @override
  @JsonKey(name: 'shop_id')
  String? get shopId;
  @override
  @JsonKey(name: 'shop_name')
  String? get shopName;
  @override
  String? get title;
  @override
  String? get body;
  @override
  @JsonKey(name: 'actor_name')
  String? get actorName;
  @override
  double? get rating;

  /// Create a copy of DashboardActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardActivityItemImplCopyWith<_$DashboardActivityItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DashboardAggregate _$DashboardAggregateFromJson(Map<String, dynamic> json) {
  return _DashboardAggregate.fromJson(json);
}

/// @nodoc
mixin _$DashboardAggregate {
  @JsonKey(name: 'shop_count')
  int get shopCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_count')
  int get eventCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_count')
  int get memberCount => throw _privateConstructorUsedError;

  /// Serializes this DashboardAggregate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardAggregate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardAggregateCopyWith<DashboardAggregate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardAggregateCopyWith<$Res> {
  factory $DashboardAggregateCopyWith(
    DashboardAggregate value,
    $Res Function(DashboardAggregate) then,
  ) = _$DashboardAggregateCopyWithImpl<$Res, DashboardAggregate>;
  @useResult
  $Res call({
    @JsonKey(name: 'shop_count') int shopCount,
    @JsonKey(name: 'review_count') int reviewCount,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'event_count') int eventCount,
    @JsonKey(name: 'member_count') int memberCount,
  });
}

/// @nodoc
class _$DashboardAggregateCopyWithImpl<$Res, $Val extends DashboardAggregate>
    implements $DashboardAggregateCopyWith<$Res> {
  _$DashboardAggregateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardAggregate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shopCount = null,
    Object? reviewCount = null,
    Object? averageRating = freezed,
    Object? eventCount = null,
    Object? memberCount = null,
  }) {
    return _then(
      _value.copyWith(
            shopCount: null == shopCount
                ? _value.shopCount
                : shopCount // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            eventCount: null == eventCount
                ? _value.eventCount
                : eventCount // ignore: cast_nullable_to_non_nullable
                      as int,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardAggregateImplCopyWith<$Res>
    implements $DashboardAggregateCopyWith<$Res> {
  factory _$$DashboardAggregateImplCopyWith(
    _$DashboardAggregateImpl value,
    $Res Function(_$DashboardAggregateImpl) then,
  ) = __$$DashboardAggregateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'shop_count') int shopCount,
    @JsonKey(name: 'review_count') int reviewCount,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'event_count') int eventCount,
    @JsonKey(name: 'member_count') int memberCount,
  });
}

/// @nodoc
class __$$DashboardAggregateImplCopyWithImpl<$Res>
    extends _$DashboardAggregateCopyWithImpl<$Res, _$DashboardAggregateImpl>
    implements _$$DashboardAggregateImplCopyWith<$Res> {
  __$$DashboardAggregateImplCopyWithImpl(
    _$DashboardAggregateImpl _value,
    $Res Function(_$DashboardAggregateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardAggregate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shopCount = null,
    Object? reviewCount = null,
    Object? averageRating = freezed,
    Object? eventCount = null,
    Object? memberCount = null,
  }) {
    return _then(
      _$DashboardAggregateImpl(
        shopCount: null == shopCount
            ? _value.shopCount
            : shopCount // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        eventCount: null == eventCount
            ? _value.eventCount
            : eventCount // ignore: cast_nullable_to_non_nullable
                  as int,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardAggregateImpl implements _DashboardAggregate {
  const _$DashboardAggregateImpl({
    @JsonKey(name: 'shop_count') this.shopCount = 0,
    @JsonKey(name: 'review_count') this.reviewCount = 0,
    @JsonKey(name: 'average_rating') this.averageRating,
    @JsonKey(name: 'event_count') this.eventCount = 0,
    @JsonKey(name: 'member_count') this.memberCount = 0,
  });

  factory _$DashboardAggregateImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardAggregateImplFromJson(json);

  @override
  @JsonKey(name: 'shop_count')
  final int shopCount;
  @override
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @override
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @override
  @JsonKey(name: 'event_count')
  final int eventCount;
  @override
  @JsonKey(name: 'member_count')
  final int memberCount;

  @override
  String toString() {
    return 'DashboardAggregate(shopCount: $shopCount, reviewCount: $reviewCount, averageRating: $averageRating, eventCount: $eventCount, memberCount: $memberCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardAggregateImpl &&
            (identical(other.shopCount, shopCount) ||
                other.shopCount == shopCount) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.eventCount, eventCount) ||
                other.eventCount == eventCount) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    shopCount,
    reviewCount,
    averageRating,
    eventCount,
    memberCount,
  );

  /// Create a copy of DashboardAggregate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardAggregateImplCopyWith<_$DashboardAggregateImpl> get copyWith =>
      __$$DashboardAggregateImplCopyWithImpl<_$DashboardAggregateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardAggregateImplToJson(this);
  }
}

abstract class _DashboardAggregate implements DashboardAggregate {
  const factory _DashboardAggregate({
    @JsonKey(name: 'shop_count') final int shopCount,
    @JsonKey(name: 'review_count') final int reviewCount,
    @JsonKey(name: 'average_rating') final double? averageRating,
    @JsonKey(name: 'event_count') final int eventCount,
    @JsonKey(name: 'member_count') final int memberCount,
  }) = _$DashboardAggregateImpl;

  factory _DashboardAggregate.fromJson(Map<String, dynamic> json) =
      _$DashboardAggregateImpl.fromJson;

  @override
  @JsonKey(name: 'shop_count')
  int get shopCount;
  @override
  @JsonKey(name: 'review_count')
  int get reviewCount;
  @override
  @JsonKey(name: 'average_rating')
  double? get averageRating;
  @override
  @JsonKey(name: 'event_count')
  int get eventCount;
  @override
  @JsonKey(name: 'member_count')
  int get memberCount;

  /// Create a copy of DashboardAggregate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardAggregateImplCopyWith<_$DashboardAggregateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TopShopItem _$TopShopItemFromJson(Map<String, dynamic> json) {
  return _TopShopItem.fromJson(json);
}

/// @nodoc
mixin _$TopShopItem {
  @JsonKey(name: 'shop_id')
  String get shopId => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_name')
  String get shopName => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int get reviewCount => throw _privateConstructorUsedError;

  /// Serializes this TopShopItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopShopItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopShopItemCopyWith<TopShopItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopShopItemCopyWith<$Res> {
  factory $TopShopItemCopyWith(
    TopShopItem value,
    $Res Function(TopShopItem) then,
  ) = _$TopShopItemCopyWithImpl<$Res, TopShopItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'shop_id') String shopId,
    @JsonKey(name: 'shop_name') String shopName,
    String? city,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'review_count') int reviewCount,
  });
}

/// @nodoc
class _$TopShopItemCopyWithImpl<$Res, $Val extends TopShopItem>
    implements $TopShopItemCopyWith<$Res> {
  _$TopShopItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopShopItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shopId = null,
    Object? shopName = null,
    Object? city = freezed,
    Object? averageRating = freezed,
    Object? reviewCount = null,
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
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopShopItemImplCopyWith<$Res>
    implements $TopShopItemCopyWith<$Res> {
  factory _$$TopShopItemImplCopyWith(
    _$TopShopItemImpl value,
    $Res Function(_$TopShopItemImpl) then,
  ) = __$$TopShopItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'shop_id') String shopId,
    @JsonKey(name: 'shop_name') String shopName,
    String? city,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'review_count') int reviewCount,
  });
}

/// @nodoc
class __$$TopShopItemImplCopyWithImpl<$Res>
    extends _$TopShopItemCopyWithImpl<$Res, _$TopShopItemImpl>
    implements _$$TopShopItemImplCopyWith<$Res> {
  __$$TopShopItemImplCopyWithImpl(
    _$TopShopItemImpl _value,
    $Res Function(_$TopShopItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopShopItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shopId = null,
    Object? shopName = null,
    Object? city = freezed,
    Object? averageRating = freezed,
    Object? reviewCount = null,
  }) {
    return _then(
      _$TopShopItemImpl(
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
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopShopItemImpl implements _TopShopItem {
  const _$TopShopItemImpl({
    @JsonKey(name: 'shop_id') required this.shopId,
    @JsonKey(name: 'shop_name') required this.shopName,
    this.city,
    @JsonKey(name: 'average_rating') this.averageRating,
    @JsonKey(name: 'review_count') this.reviewCount = 0,
  });

  factory _$TopShopItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopShopItemImplFromJson(json);

  @override
  @JsonKey(name: 'shop_id')
  final String shopId;
  @override
  @JsonKey(name: 'shop_name')
  final String shopName;
  @override
  final String? city;
  @override
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @override
  @JsonKey(name: 'review_count')
  final int reviewCount;

  @override
  String toString() {
    return 'TopShopItem(shopId: $shopId, shopName: $shopName, city: $city, averageRating: $averageRating, reviewCount: $reviewCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopShopItemImpl &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    shopId,
    shopName,
    city,
    averageRating,
    reviewCount,
  );

  /// Create a copy of TopShopItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopShopItemImplCopyWith<_$TopShopItemImpl> get copyWith =>
      __$$TopShopItemImplCopyWithImpl<_$TopShopItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopShopItemImplToJson(this);
  }
}

abstract class _TopShopItem implements TopShopItem {
  const factory _TopShopItem({
    @JsonKey(name: 'shop_id') required final String shopId,
    @JsonKey(name: 'shop_name') required final String shopName,
    final String? city,
    @JsonKey(name: 'average_rating') final double? averageRating,
    @JsonKey(name: 'review_count') final int reviewCount,
  }) = _$TopShopItemImpl;

  factory _TopShopItem.fromJson(Map<String, dynamic> json) =
      _$TopShopItemImpl.fromJson;

  @override
  @JsonKey(name: 'shop_id')
  String get shopId;
  @override
  @JsonKey(name: 'shop_name')
  String get shopName;
  @override
  String? get city;
  @override
  @JsonKey(name: 'average_rating')
  double? get averageRating;
  @override
  @JsonKey(name: 'review_count')
  int get reviewCount;

  /// Create a copy of TopShopItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopShopItemImplCopyWith<_$TopShopItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpcomingEventItem _$UpcomingEventItemFromJson(Map<String, dynamic> json) {
  return _UpcomingEventItem.fromJson(json);
}

/// @nodoc
mixin _$UpcomingEventItem {
  @JsonKey(name: 'event_id')
  String get eventId => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_name')
  String get eventName => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_date')
  String? get eventDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_id')
  String? get shopId => throw _privateConstructorUsedError;
  @JsonKey(name: 'shop_name')
  String? get shopName => throw _privateConstructorUsedError;

  /// Serializes this UpcomingEventItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpcomingEventItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpcomingEventItemCopyWith<UpcomingEventItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpcomingEventItemCopyWith<$Res> {
  factory $UpcomingEventItemCopyWith(
    UpcomingEventItem value,
    $Res Function(UpcomingEventItem) then,
  ) = _$UpcomingEventItemCopyWithImpl<$Res, UpcomingEventItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    @JsonKey(name: 'event_name') String eventName,
    @JsonKey(name: 'event_date') String? eventDate,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'shop_name') String? shopName,
  });
}

/// @nodoc
class _$UpcomingEventItemCopyWithImpl<$Res, $Val extends UpcomingEventItem>
    implements $UpcomingEventItemCopyWith<$Res> {
  _$UpcomingEventItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpcomingEventItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? eventName = null,
    Object? eventDate = freezed,
    Object? shopId = freezed,
    Object? shopName = freezed,
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
            eventDate: freezed == eventDate
                ? _value.eventDate
                : eventDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopName: freezed == shopName
                ? _value.shopName
                : shopName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpcomingEventItemImplCopyWith<$Res>
    implements $UpcomingEventItemCopyWith<$Res> {
  factory _$$UpcomingEventItemImplCopyWith(
    _$UpcomingEventItemImpl value,
    $Res Function(_$UpcomingEventItemImpl) then,
  ) = __$$UpcomingEventItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'event_id') String eventId,
    @JsonKey(name: 'event_name') String eventName,
    @JsonKey(name: 'event_date') String? eventDate,
    @JsonKey(name: 'shop_id') String? shopId,
    @JsonKey(name: 'shop_name') String? shopName,
  });
}

/// @nodoc
class __$$UpcomingEventItemImplCopyWithImpl<$Res>
    extends _$UpcomingEventItemCopyWithImpl<$Res, _$UpcomingEventItemImpl>
    implements _$$UpcomingEventItemImplCopyWith<$Res> {
  __$$UpcomingEventItemImplCopyWithImpl(
    _$UpcomingEventItemImpl _value,
    $Res Function(_$UpcomingEventItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpcomingEventItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? eventName = null,
    Object? eventDate = freezed,
    Object? shopId = freezed,
    Object? shopName = freezed,
  }) {
    return _then(
      _$UpcomingEventItemImpl(
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventName: null == eventName
            ? _value.eventName
            : eventName // ignore: cast_nullable_to_non_nullable
                  as String,
        eventDate: freezed == eventDate
            ? _value.eventDate
            : eventDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopName: freezed == shopName
            ? _value.shopName
            : shopName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpcomingEventItemImpl implements _UpcomingEventItem {
  const _$UpcomingEventItemImpl({
    @JsonKey(name: 'event_id') required this.eventId,
    @JsonKey(name: 'event_name') required this.eventName,
    @JsonKey(name: 'event_date') this.eventDate,
    @JsonKey(name: 'shop_id') this.shopId,
    @JsonKey(name: 'shop_name') this.shopName,
  });

  factory _$UpcomingEventItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpcomingEventItemImplFromJson(json);

  @override
  @JsonKey(name: 'event_id')
  final String eventId;
  @override
  @JsonKey(name: 'event_name')
  final String eventName;
  @override
  @JsonKey(name: 'event_date')
  final String? eventDate;
  @override
  @JsonKey(name: 'shop_id')
  final String? shopId;
  @override
  @JsonKey(name: 'shop_name')
  final String? shopName;

  @override
  String toString() {
    return 'UpcomingEventItem(eventId: $eventId, eventName: $eventName, eventDate: $eventDate, shopId: $shopId, shopName: $shopName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpcomingEventItemImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, eventId, eventName, eventDate, shopId, shopName);

  /// Create a copy of UpcomingEventItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpcomingEventItemImplCopyWith<_$UpcomingEventItemImpl> get copyWith =>
      __$$UpcomingEventItemImplCopyWithImpl<_$UpcomingEventItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpcomingEventItemImplToJson(this);
  }
}

abstract class _UpcomingEventItem implements UpcomingEventItem {
  const factory _UpcomingEventItem({
    @JsonKey(name: 'event_id') required final String eventId,
    @JsonKey(name: 'event_name') required final String eventName,
    @JsonKey(name: 'event_date') final String? eventDate,
    @JsonKey(name: 'shop_id') final String? shopId,
    @JsonKey(name: 'shop_name') final String? shopName,
  }) = _$UpcomingEventItemImpl;

  factory _UpcomingEventItem.fromJson(Map<String, dynamic> json) =
      _$UpcomingEventItemImpl.fromJson;

  @override
  @JsonKey(name: 'event_id')
  String get eventId;
  @override
  @JsonKey(name: 'event_name')
  String get eventName;
  @override
  @JsonKey(name: 'event_date')
  String? get eventDate;
  @override
  @JsonKey(name: 'shop_id')
  String? get shopId;
  @override
  @JsonKey(name: 'shop_name')
  String? get shopName;

  /// Create a copy of UpcomingEventItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpcomingEventItemImplCopyWith<_$UpcomingEventItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardPersonalSummary _$DashboardPersonalSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _DashboardPersonalSummary.fromJson(json);
}

/// @nodoc
mixin _$DashboardPersonalSummary {
  @JsonKey(name: 'favourite_shops')
  int get favouriteShops => throw _privateConstructorUsedError;
  int get reservations => throw _privateConstructorUsedError;
  @JsonKey(name: 'reviews_written')
  int get reviewsWritten => throw _privateConstructorUsedError;

  /// Serializes this DashboardPersonalSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardPersonalSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardPersonalSummaryCopyWith<DashboardPersonalSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardPersonalSummaryCopyWith<$Res> {
  factory $DashboardPersonalSummaryCopyWith(
    DashboardPersonalSummary value,
    $Res Function(DashboardPersonalSummary) then,
  ) = _$DashboardPersonalSummaryCopyWithImpl<$Res, DashboardPersonalSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'favourite_shops') int favouriteShops,
    int reservations,
    @JsonKey(name: 'reviews_written') int reviewsWritten,
  });
}

/// @nodoc
class _$DashboardPersonalSummaryCopyWithImpl<
  $Res,
  $Val extends DashboardPersonalSummary
>
    implements $DashboardPersonalSummaryCopyWith<$Res> {
  _$DashboardPersonalSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardPersonalSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? favouriteShops = null,
    Object? reservations = null,
    Object? reviewsWritten = null,
  }) {
    return _then(
      _value.copyWith(
            favouriteShops: null == favouriteShops
                ? _value.favouriteShops
                : favouriteShops // ignore: cast_nullable_to_non_nullable
                      as int,
            reservations: null == reservations
                ? _value.reservations
                : reservations // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewsWritten: null == reviewsWritten
                ? _value.reviewsWritten
                : reviewsWritten // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardPersonalSummaryImplCopyWith<$Res>
    implements $DashboardPersonalSummaryCopyWith<$Res> {
  factory _$$DashboardPersonalSummaryImplCopyWith(
    _$DashboardPersonalSummaryImpl value,
    $Res Function(_$DashboardPersonalSummaryImpl) then,
  ) = __$$DashboardPersonalSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'favourite_shops') int favouriteShops,
    int reservations,
    @JsonKey(name: 'reviews_written') int reviewsWritten,
  });
}

/// @nodoc
class __$$DashboardPersonalSummaryImplCopyWithImpl<$Res>
    extends
        _$DashboardPersonalSummaryCopyWithImpl<
          $Res,
          _$DashboardPersonalSummaryImpl
        >
    implements _$$DashboardPersonalSummaryImplCopyWith<$Res> {
  __$$DashboardPersonalSummaryImplCopyWithImpl(
    _$DashboardPersonalSummaryImpl _value,
    $Res Function(_$DashboardPersonalSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardPersonalSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? favouriteShops = null,
    Object? reservations = null,
    Object? reviewsWritten = null,
  }) {
    return _then(
      _$DashboardPersonalSummaryImpl(
        favouriteShops: null == favouriteShops
            ? _value.favouriteShops
            : favouriteShops // ignore: cast_nullable_to_non_nullable
                  as int,
        reservations: null == reservations
            ? _value.reservations
            : reservations // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewsWritten: null == reviewsWritten
            ? _value.reviewsWritten
            : reviewsWritten // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardPersonalSummaryImpl implements _DashboardPersonalSummary {
  const _$DashboardPersonalSummaryImpl({
    @JsonKey(name: 'favourite_shops') this.favouriteShops = 0,
    this.reservations = 0,
    @JsonKey(name: 'reviews_written') this.reviewsWritten = 0,
  });

  factory _$DashboardPersonalSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardPersonalSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'favourite_shops')
  final int favouriteShops;
  @override
  @JsonKey()
  final int reservations;
  @override
  @JsonKey(name: 'reviews_written')
  final int reviewsWritten;

  @override
  String toString() {
    return 'DashboardPersonalSummary(favouriteShops: $favouriteShops, reservations: $reservations, reviewsWritten: $reviewsWritten)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardPersonalSummaryImpl &&
            (identical(other.favouriteShops, favouriteShops) ||
                other.favouriteShops == favouriteShops) &&
            (identical(other.reservations, reservations) ||
                other.reservations == reservations) &&
            (identical(other.reviewsWritten, reviewsWritten) ||
                other.reviewsWritten == reviewsWritten));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, favouriteShops, reservations, reviewsWritten);

  /// Create a copy of DashboardPersonalSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardPersonalSummaryImplCopyWith<_$DashboardPersonalSummaryImpl>
  get copyWith =>
      __$$DashboardPersonalSummaryImplCopyWithImpl<
        _$DashboardPersonalSummaryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardPersonalSummaryImplToJson(this);
  }
}

abstract class _DashboardPersonalSummary implements DashboardPersonalSummary {
  const factory _DashboardPersonalSummary({
    @JsonKey(name: 'favourite_shops') final int favouriteShops,
    final int reservations,
    @JsonKey(name: 'reviews_written') final int reviewsWritten,
  }) = _$DashboardPersonalSummaryImpl;

  factory _DashboardPersonalSummary.fromJson(Map<String, dynamic> json) =
      _$DashboardPersonalSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'favourite_shops')
  int get favouriteShops;
  @override
  int get reservations;
  @override
  @JsonKey(name: 'reviews_written')
  int get reviewsWritten;

  /// Create a copy of DashboardPersonalSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardPersonalSummaryImplCopyWith<_$DashboardPersonalSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DashboardNotification _$DashboardNotificationFromJson(
  Map<String, dynamic> json,
) {
  return _DashboardNotification.fromJson(json);
}

/// @nodoc
mixin _$DashboardNotification {
  String get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  String? get link => throw _privateConstructorUsedError;

  /// Serializes this DashboardNotification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardNotificationCopyWith<DashboardNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardNotificationCopyWith<$Res> {
  factory $DashboardNotificationCopyWith(
    DashboardNotification value,
    $Res Function(DashboardNotification) then,
  ) = _$DashboardNotificationCopyWithImpl<$Res, DashboardNotification>;
  @useResult
  $Res call({String type, String message, int count, String? link});
}

/// @nodoc
class _$DashboardNotificationCopyWithImpl<
  $Res,
  $Val extends DashboardNotification
>
    implements $DashboardNotificationCopyWith<$Res> {
  _$DashboardNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? count = null,
    Object? link = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            link: freezed == link
                ? _value.link
                : link // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardNotificationImplCopyWith<$Res>
    implements $DashboardNotificationCopyWith<$Res> {
  factory _$$DashboardNotificationImplCopyWith(
    _$DashboardNotificationImpl value,
    $Res Function(_$DashboardNotificationImpl) then,
  ) = __$$DashboardNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String message, int count, String? link});
}

/// @nodoc
class __$$DashboardNotificationImplCopyWithImpl<$Res>
    extends
        _$DashboardNotificationCopyWithImpl<$Res, _$DashboardNotificationImpl>
    implements _$$DashboardNotificationImplCopyWith<$Res> {
  __$$DashboardNotificationImplCopyWithImpl(
    _$DashboardNotificationImpl _value,
    $Res Function(_$DashboardNotificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
    Object? count = null,
    Object? link = freezed,
  }) {
    return _then(
      _$DashboardNotificationImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        link: freezed == link
            ? _value.link
            : link // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardNotificationImpl implements _DashboardNotification {
  const _$DashboardNotificationImpl({
    required this.type,
    required this.message,
    this.count = 0,
    this.link,
  });

  factory _$DashboardNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardNotificationImplFromJson(json);

  @override
  final String type;
  @override
  final String message;
  @override
  @JsonKey()
  final int count;
  @override
  final String? link;

  @override
  String toString() {
    return 'DashboardNotification(type: $type, message: $message, count: $count, link: $link)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardNotificationImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.link, link) || other.link == link));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, message, count, link);

  /// Create a copy of DashboardNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardNotificationImplCopyWith<_$DashboardNotificationImpl>
  get copyWith =>
      __$$DashboardNotificationImplCopyWithImpl<_$DashboardNotificationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardNotificationImplToJson(this);
  }
}

abstract class _DashboardNotification implements DashboardNotification {
  const factory _DashboardNotification({
    required final String type,
    required final String message,
    final int count,
    final String? link,
  }) = _$DashboardNotificationImpl;

  factory _DashboardNotification.fromJson(Map<String, dynamic> json) =
      _$DashboardNotificationImpl.fromJson;

  @override
  String get type;
  @override
  String get message;
  @override
  int get count;
  @override
  String? get link;

  /// Create a copy of DashboardNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardNotificationImplCopyWith<_$DashboardNotificationImpl>
  get copyWith => throw _privateConstructorUsedError;
}
