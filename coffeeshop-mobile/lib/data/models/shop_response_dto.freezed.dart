// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShopResponseDto _$ShopResponseDtoFromJson(Map<String, dynamic> json) {
  return _ShopResponseDto.fromJson(json);
}

/// @nodoc
mixin _$ShopResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  double? get averageRating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  bool get favouriteByCurrentUser => throw _privateConstructorUsedError;
  List<Map<String, dynamic>>? get events => throw _privateConstructorUsedError;
  List<Map<String, dynamic>>? get tables => throw _privateConstructorUsedError;
  List<Map<String, dynamic>>? get reviews => throw _privateConstructorUsedError;
  List<Map<String, dynamic>>? get contacts =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get currentMenu => throw _privateConstructorUsedError;
  Map<String, dynamic>? get loyaltyPlan => throw _privateConstructorUsedError;

  /// Serializes this ShopResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopResponseDtoCopyWith<ShopResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopResponseDtoCopyWith<$Res> {
  factory $ShopResponseDtoCopyWith(
    ShopResponseDto value,
    $Res Function(ShopResponseDto) then,
  ) = _$ShopResponseDtoCopyWithImpl<$Res, ShopResponseDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    String city,
    String? phoneNumber,
    String? email,
    double? averageRating,
    int reviewCount,
    int memberCount,
    bool favouriteByCurrentUser,
    List<Map<String, dynamic>>? events,
    List<Map<String, dynamic>>? tables,
    List<Map<String, dynamic>>? reviews,
    List<Map<String, dynamic>>? contacts,
    Map<String, dynamic>? currentMenu,
    Map<String, dynamic>? loyaltyPlan,
  });
}

/// @nodoc
class _$ShopResponseDtoCopyWithImpl<$Res, $Val extends ShopResponseDto>
    implements $ShopResponseDtoCopyWith<$Res> {
  _$ShopResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? averageRating = freezed,
    Object? reviewCount = null,
    Object? memberCount = null,
    Object? favouriteByCurrentUser = null,
    Object? events = freezed,
    Object? tables = freezed,
    Object? reviews = freezed,
    Object? contacts = freezed,
    Object? currentMenu = freezed,
    Object? loyaltyPlan = freezed,
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
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
            favouriteByCurrentUser: null == favouriteByCurrentUser
                ? _value.favouriteByCurrentUser
                : favouriteByCurrentUser // ignore: cast_nullable_to_non_nullable
                      as bool,
            events: freezed == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>?,
            tables: freezed == tables
                ? _value.tables
                : tables // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>?,
            reviews: freezed == reviews
                ? _value.reviews
                : reviews // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>?,
            contacts: freezed == contacts
                ? _value.contacts
                : contacts // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>?,
            currentMenu: freezed == currentMenu
                ? _value.currentMenu
                : currentMenu // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            loyaltyPlan: freezed == loyaltyPlan
                ? _value.loyaltyPlan
                : loyaltyPlan // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShopResponseDtoImplCopyWith<$Res>
    implements $ShopResponseDtoCopyWith<$Res> {
  factory _$$ShopResponseDtoImplCopyWith(
    _$ShopResponseDtoImpl value,
    $Res Function(_$ShopResponseDtoImpl) then,
  ) = __$$ShopResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    String city,
    String? phoneNumber,
    String? email,
    double? averageRating,
    int reviewCount,
    int memberCount,
    bool favouriteByCurrentUser,
    List<Map<String, dynamic>>? events,
    List<Map<String, dynamic>>? tables,
    List<Map<String, dynamic>>? reviews,
    List<Map<String, dynamic>>? contacts,
    Map<String, dynamic>? currentMenu,
    Map<String, dynamic>? loyaltyPlan,
  });
}

/// @nodoc
class __$$ShopResponseDtoImplCopyWithImpl<$Res>
    extends _$ShopResponseDtoCopyWithImpl<$Res, _$ShopResponseDtoImpl>
    implements _$$ShopResponseDtoImplCopyWith<$Res> {
  __$$ShopResponseDtoImplCopyWithImpl(
    _$ShopResponseDtoImpl _value,
    $Res Function(_$ShopResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShopResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? averageRating = freezed,
    Object? reviewCount = null,
    Object? memberCount = null,
    Object? favouriteByCurrentUser = null,
    Object? events = freezed,
    Object? tables = freezed,
    Object? reviews = freezed,
    Object? contacts = freezed,
    Object? currentMenu = freezed,
    Object? loyaltyPlan = freezed,
  }) {
    return _then(
      _$ShopResponseDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
        favouriteByCurrentUser: null == favouriteByCurrentUser
            ? _value.favouriteByCurrentUser
            : favouriteByCurrentUser // ignore: cast_nullable_to_non_nullable
                  as bool,
        events: freezed == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>?,
        tables: freezed == tables
            ? _value._tables
            : tables // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>?,
        reviews: freezed == reviews
            ? _value._reviews
            : reviews // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>?,
        contacts: freezed == contacts
            ? _value._contacts
            : contacts // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>?,
        currentMenu: freezed == currentMenu
            ? _value._currentMenu
            : currentMenu // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        loyaltyPlan: freezed == loyaltyPlan
            ? _value._loyaltyPlan
            : loyaltyPlan // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopResponseDtoImpl implements _ShopResponseDto {
  const _$ShopResponseDtoImpl({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.phoneNumber,
    this.email,
    this.averageRating,
    this.reviewCount = 0,
    this.memberCount = 0,
    this.favouriteByCurrentUser = false,
    final List<Map<String, dynamic>>? events,
    final List<Map<String, dynamic>>? tables,
    final List<Map<String, dynamic>>? reviews,
    final List<Map<String, dynamic>>? contacts,
    final Map<String, dynamic>? currentMenu,
    final Map<String, dynamic>? loyaltyPlan,
  }) : _events = events,
       _tables = tables,
       _reviews = reviews,
       _contacts = contacts,
       _currentMenu = currentMenu,
       _loyaltyPlan = loyaltyPlan;

  factory _$ShopResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopResponseDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final String city;
  @override
  final String? phoneNumber;
  @override
  final String? email;
  @override
  final double? averageRating;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  @JsonKey()
  final int memberCount;
  @override
  @JsonKey()
  final bool favouriteByCurrentUser;
  final List<Map<String, dynamic>>? _events;
  @override
  List<Map<String, dynamic>>? get events {
    final value = _events;
    if (value == null) return null;
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Map<String, dynamic>>? _tables;
  @override
  List<Map<String, dynamic>>? get tables {
    final value = _tables;
    if (value == null) return null;
    if (_tables is EqualUnmodifiableListView) return _tables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Map<String, dynamic>>? _reviews;
  @override
  List<Map<String, dynamic>>? get reviews {
    final value = _reviews;
    if (value == null) return null;
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Map<String, dynamic>>? _contacts;
  @override
  List<Map<String, dynamic>>? get contacts {
    final value = _contacts;
    if (value == null) return null;
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _currentMenu;
  @override
  Map<String, dynamic>? get currentMenu {
    final value = _currentMenu;
    if (value == null) return null;
    if (_currentMenu is EqualUnmodifiableMapView) return _currentMenu;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _loyaltyPlan;
  @override
  Map<String, dynamic>? get loyaltyPlan {
    final value = _loyaltyPlan;
    if (value == null) return null;
    if (_loyaltyPlan is EqualUnmodifiableMapView) return _loyaltyPlan;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ShopResponseDto(id: $id, name: $name, address: $address, city: $city, phoneNumber: $phoneNumber, email: $email, averageRating: $averageRating, reviewCount: $reviewCount, memberCount: $memberCount, favouriteByCurrentUser: $favouriteByCurrentUser, events: $events, tables: $tables, reviews: $reviews, contacts: $contacts, currentMenu: $currentMenu, loyaltyPlan: $loyaltyPlan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.favouriteByCurrentUser, favouriteByCurrentUser) ||
                other.favouriteByCurrentUser == favouriteByCurrentUser) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            const DeepCollectionEquality().equals(other._tables, _tables) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            const DeepCollectionEquality().equals(
              other._currentMenu,
              _currentMenu,
            ) &&
            const DeepCollectionEquality().equals(
              other._loyaltyPlan,
              _loyaltyPlan,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    address,
    city,
    phoneNumber,
    email,
    averageRating,
    reviewCount,
    memberCount,
    favouriteByCurrentUser,
    const DeepCollectionEquality().hash(_events),
    const DeepCollectionEquality().hash(_tables),
    const DeepCollectionEquality().hash(_reviews),
    const DeepCollectionEquality().hash(_contacts),
    const DeepCollectionEquality().hash(_currentMenu),
    const DeepCollectionEquality().hash(_loyaltyPlan),
  );

  /// Create a copy of ShopResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopResponseDtoImplCopyWith<_$ShopResponseDtoImpl> get copyWith =>
      __$$ShopResponseDtoImplCopyWithImpl<_$ShopResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopResponseDtoImplToJson(this);
  }
}

abstract class _ShopResponseDto implements ShopResponseDto {
  const factory _ShopResponseDto({
    required final String id,
    required final String name,
    required final String address,
    required final String city,
    final String? phoneNumber,
    final String? email,
    final double? averageRating,
    final int reviewCount,
    final int memberCount,
    final bool favouriteByCurrentUser,
    final List<Map<String, dynamic>>? events,
    final List<Map<String, dynamic>>? tables,
    final List<Map<String, dynamic>>? reviews,
    final List<Map<String, dynamic>>? contacts,
    final Map<String, dynamic>? currentMenu,
    final Map<String, dynamic>? loyaltyPlan,
  }) = _$ShopResponseDtoImpl;

  factory _ShopResponseDto.fromJson(Map<String, dynamic> json) =
      _$ShopResponseDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  String get city;
  @override
  String? get phoneNumber;
  @override
  String? get email;
  @override
  double? get averageRating;
  @override
  int get reviewCount;
  @override
  int get memberCount;
  @override
  bool get favouriteByCurrentUser;
  @override
  List<Map<String, dynamic>>? get events;
  @override
  List<Map<String, dynamic>>? get tables;
  @override
  List<Map<String, dynamic>>? get reviews;
  @override
  List<Map<String, dynamic>>? get contacts;
  @override
  Map<String, dynamic>? get currentMenu;
  @override
  Map<String, dynamic>? get loyaltyPlan;

  /// Create a copy of ShopResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopResponseDtoImplCopyWith<_$ShopResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopSummaryDto _$ShopSummaryDtoFromJson(Map<String, dynamic> json) {
  return _ShopSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$ShopSummaryDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;

  /// Serializes this ShopSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopSummaryDtoCopyWith<ShopSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopSummaryDtoCopyWith<$Res> {
  factory $ShopSummaryDtoCopyWith(
    ShopSummaryDto value,
    $Res Function(ShopSummaryDto) then,
  ) = _$ShopSummaryDtoCopyWithImpl<$Res, ShopSummaryDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String? address,
    String? city,
    String? phoneNumber,
    String? email,
  });
}

/// @nodoc
class _$ShopSummaryDtoCopyWithImpl<$Res, $Val extends ShopSummaryDto>
    implements $ShopSummaryDtoCopyWith<$Res> {
  _$ShopSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = freezed,
    Object? city = freezed,
    Object? phoneNumber = freezed,
    Object? email = freezed,
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
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShopSummaryDtoImplCopyWith<$Res>
    implements $ShopSummaryDtoCopyWith<$Res> {
  factory _$$ShopSummaryDtoImplCopyWith(
    _$ShopSummaryDtoImpl value,
    $Res Function(_$ShopSummaryDtoImpl) then,
  ) = __$$ShopSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? address,
    String? city,
    String? phoneNumber,
    String? email,
  });
}

/// @nodoc
class __$$ShopSummaryDtoImplCopyWithImpl<$Res>
    extends _$ShopSummaryDtoCopyWithImpl<$Res, _$ShopSummaryDtoImpl>
    implements _$$ShopSummaryDtoImplCopyWith<$Res> {
  __$$ShopSummaryDtoImplCopyWithImpl(
    _$ShopSummaryDtoImpl _value,
    $Res Function(_$ShopSummaryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShopSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = freezed,
    Object? city = freezed,
    Object? phoneNumber = freezed,
    Object? email = freezed,
  }) {
    return _then(
      _$ShopSummaryDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopSummaryDtoImpl implements _ShopSummaryDto {
  const _$ShopSummaryDtoImpl({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.phoneNumber,
    this.email,
  });

  factory _$ShopSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? phoneNumber;
  @override
  final String? email;

  @override
  String toString() {
    return 'ShopSummaryDto(id: $id, name: $name, address: $address, city: $city, phoneNumber: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, address, city, phoneNumber, email);

  /// Create a copy of ShopSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopSummaryDtoImplCopyWith<_$ShopSummaryDtoImpl> get copyWith =>
      __$$ShopSummaryDtoImplCopyWithImpl<_$ShopSummaryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopSummaryDtoImplToJson(this);
  }
}

abstract class _ShopSummaryDto implements ShopSummaryDto {
  const factory _ShopSummaryDto({
    required final String id,
    required final String name,
    final String? address,
    final String? city,
    final String? phoneNumber,
    final String? email,
  }) = _$ShopSummaryDtoImpl;

  factory _ShopSummaryDto.fromJson(Map<String, dynamic> json) =
      _$ShopSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get phoneNumber;
  @override
  String? get email;

  /// Create a copy of ShopSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopSummaryDtoImplCopyWith<_$ShopSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopCreateRequest _$ShopCreateRequestFromJson(Map<String, dynamic> json) {
  return _ShopCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$ShopCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get ownerUserId => throw _privateConstructorUsedError;
  String? get loyaltyPlanId => throw _privateConstructorUsedError;

  /// Serializes this ShopCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopCreateRequestCopyWith<ShopCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopCreateRequestCopyWith<$Res> {
  factory $ShopCreateRequestCopyWith(
    ShopCreateRequest value,
    $Res Function(ShopCreateRequest) then,
  ) = _$ShopCreateRequestCopyWithImpl<$Res, ShopCreateRequest>;
  @useResult
  $Res call({
    String name,
    String address,
    String city,
    String? phoneNumber,
    String? email,
    String? ownerUserId,
    String? loyaltyPlanId,
  });
}

/// @nodoc
class _$ShopCreateRequestCopyWithImpl<$Res, $Val extends ShopCreateRequest>
    implements $ShopCreateRequestCopyWith<$Res> {
  _$ShopCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? ownerUserId = freezed,
    Object? loyaltyPlanId = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            ownerUserId: freezed == ownerUserId
                ? _value.ownerUserId
                : ownerUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            loyaltyPlanId: freezed == loyaltyPlanId
                ? _value.loyaltyPlanId
                : loyaltyPlanId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShopCreateRequestImplCopyWith<$Res>
    implements $ShopCreateRequestCopyWith<$Res> {
  factory _$$ShopCreateRequestImplCopyWith(
    _$ShopCreateRequestImpl value,
    $Res Function(_$ShopCreateRequestImpl) then,
  ) = __$$ShopCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String address,
    String city,
    String? phoneNumber,
    String? email,
    String? ownerUserId,
    String? loyaltyPlanId,
  });
}

/// @nodoc
class __$$ShopCreateRequestImplCopyWithImpl<$Res>
    extends _$ShopCreateRequestCopyWithImpl<$Res, _$ShopCreateRequestImpl>
    implements _$$ShopCreateRequestImplCopyWith<$Res> {
  __$$ShopCreateRequestImplCopyWithImpl(
    _$ShopCreateRequestImpl _value,
    $Res Function(_$ShopCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShopCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? ownerUserId = freezed,
    Object? loyaltyPlanId = freezed,
  }) {
    return _then(
      _$ShopCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        ownerUserId: freezed == ownerUserId
            ? _value.ownerUserId
            : ownerUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        loyaltyPlanId: freezed == loyaltyPlanId
            ? _value.loyaltyPlanId
            : loyaltyPlanId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopCreateRequestImpl implements _ShopCreateRequest {
  const _$ShopCreateRequestImpl({
    required this.name,
    required this.address,
    required this.city,
    this.phoneNumber,
    this.email,
    this.ownerUserId,
    this.loyaltyPlanId,
  });

  factory _$ShopCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String address;
  @override
  final String city;
  @override
  final String? phoneNumber;
  @override
  final String? email;
  @override
  final String? ownerUserId;
  @override
  final String? loyaltyPlanId;

  @override
  String toString() {
    return 'ShopCreateRequest(name: $name, address: $address, city: $city, phoneNumber: $phoneNumber, email: $email, ownerUserId: $ownerUserId, loyaltyPlanId: $loyaltyPlanId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.ownerUserId, ownerUserId) ||
                other.ownerUserId == ownerUserId) &&
            (identical(other.loyaltyPlanId, loyaltyPlanId) ||
                other.loyaltyPlanId == loyaltyPlanId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    address,
    city,
    phoneNumber,
    email,
    ownerUserId,
    loyaltyPlanId,
  );

  /// Create a copy of ShopCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopCreateRequestImplCopyWith<_$ShopCreateRequestImpl> get copyWith =>
      __$$ShopCreateRequestImplCopyWithImpl<_$ShopCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopCreateRequestImplToJson(this);
  }
}

abstract class _ShopCreateRequest implements ShopCreateRequest {
  const factory _ShopCreateRequest({
    required final String name,
    required final String address,
    required final String city,
    final String? phoneNumber,
    final String? email,
    final String? ownerUserId,
    final String? loyaltyPlanId,
  }) = _$ShopCreateRequestImpl;

  factory _ShopCreateRequest.fromJson(Map<String, dynamic> json) =
      _$ShopCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get address;
  @override
  String get city;
  @override
  String? get phoneNumber;
  @override
  String? get email;
  @override
  String? get ownerUserId;
  @override
  String? get loyaltyPlanId;

  /// Create a copy of ShopCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopCreateRequestImplCopyWith<_$ShopCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopUpdateRequest _$ShopUpdateRequestFromJson(Map<String, dynamic> json) {
  return _ShopUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ShopUpdateRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get newOwnerUserId => throw _privateConstructorUsedError;
  String? get loyaltyPlanId => throw _privateConstructorUsedError;

  /// Serializes this ShopUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopUpdateRequestCopyWith<ShopUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopUpdateRequestCopyWith<$Res> {
  factory $ShopUpdateRequestCopyWith(
    ShopUpdateRequest value,
    $Res Function(ShopUpdateRequest) then,
  ) = _$ShopUpdateRequestCopyWithImpl<$Res, ShopUpdateRequest>;
  @useResult
  $Res call({
    String? name,
    String? address,
    String? city,
    String? phoneNumber,
    String? email,
    String? newOwnerUserId,
    String? loyaltyPlanId,
  });
}

/// @nodoc
class _$ShopUpdateRequestCopyWithImpl<$Res, $Val extends ShopUpdateRequest>
    implements $ShopUpdateRequestCopyWith<$Res> {
  _$ShopUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? newOwnerUserId = freezed,
    Object? loyaltyPlanId = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            newOwnerUserId: freezed == newOwnerUserId
                ? _value.newOwnerUserId
                : newOwnerUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            loyaltyPlanId: freezed == loyaltyPlanId
                ? _value.loyaltyPlanId
                : loyaltyPlanId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShopUpdateRequestImplCopyWith<$Res>
    implements $ShopUpdateRequestCopyWith<$Res> {
  factory _$$ShopUpdateRequestImplCopyWith(
    _$ShopUpdateRequestImpl value,
    $Res Function(_$ShopUpdateRequestImpl) then,
  ) = __$$ShopUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? address,
    String? city,
    String? phoneNumber,
    String? email,
    String? newOwnerUserId,
    String? loyaltyPlanId,
  });
}

/// @nodoc
class __$$ShopUpdateRequestImplCopyWithImpl<$Res>
    extends _$ShopUpdateRequestCopyWithImpl<$Res, _$ShopUpdateRequestImpl>
    implements _$$ShopUpdateRequestImplCopyWith<$Res> {
  __$$ShopUpdateRequestImplCopyWithImpl(
    _$ShopUpdateRequestImpl _value,
    $Res Function(_$ShopUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShopUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? newOwnerUserId = freezed,
    Object? loyaltyPlanId = freezed,
  }) {
    return _then(
      _$ShopUpdateRequestImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        newOwnerUserId: freezed == newOwnerUserId
            ? _value.newOwnerUserId
            : newOwnerUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        loyaltyPlanId: freezed == loyaltyPlanId
            ? _value.loyaltyPlanId
            : loyaltyPlanId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopUpdateRequestImpl implements _ShopUpdateRequest {
  const _$ShopUpdateRequestImpl({
    this.name,
    this.address,
    this.city,
    this.phoneNumber,
    this.email,
    this.newOwnerUserId,
    this.loyaltyPlanId,
  });

  factory _$ShopUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopUpdateRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? phoneNumber;
  @override
  final String? email;
  @override
  final String? newOwnerUserId;
  @override
  final String? loyaltyPlanId;

  @override
  String toString() {
    return 'ShopUpdateRequest(name: $name, address: $address, city: $city, phoneNumber: $phoneNumber, email: $email, newOwnerUserId: $newOwnerUserId, loyaltyPlanId: $loyaltyPlanId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopUpdateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.newOwnerUserId, newOwnerUserId) ||
                other.newOwnerUserId == newOwnerUserId) &&
            (identical(other.loyaltyPlanId, loyaltyPlanId) ||
                other.loyaltyPlanId == loyaltyPlanId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    address,
    city,
    phoneNumber,
    email,
    newOwnerUserId,
    loyaltyPlanId,
  );

  /// Create a copy of ShopUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopUpdateRequestImplCopyWith<_$ShopUpdateRequestImpl> get copyWith =>
      __$$ShopUpdateRequestImplCopyWithImpl<_$ShopUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopUpdateRequestImplToJson(this);
  }
}

abstract class _ShopUpdateRequest implements ShopUpdateRequest {
  const factory _ShopUpdateRequest({
    final String? name,
    final String? address,
    final String? city,
    final String? phoneNumber,
    final String? email,
    final String? newOwnerUserId,
    final String? loyaltyPlanId,
  }) = _$ShopUpdateRequestImpl;

  factory _ShopUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$ShopUpdateRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get phoneNumber;
  @override
  String? get email;
  @override
  String? get newOwnerUserId;
  @override
  String? get loyaltyPlanId;

  /// Create a copy of ShopUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopUpdateRequestImplCopyWith<_$ShopUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopSearchParams _$ShopSearchParamsFromJson(Map<String, dynamic> json) {
  return _ShopSearchParams.fromJson(json);
}

/// @nodoc
mixin _$ShopSearchParams {
  String? get q => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;

  /// Serializes this ShopSearchParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopSearchParamsCopyWith<ShopSearchParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopSearchParamsCopyWith<$Res> {
  factory $ShopSearchParamsCopyWith(
    ShopSearchParams value,
    $Res Function(ShopSearchParams) then,
  ) = _$ShopSearchParamsCopyWithImpl<$Res, ShopSearchParams>;
  @useResult
  $Res call({String? q, int page, int size});
}

/// @nodoc
class _$ShopSearchParamsCopyWithImpl<$Res, $Val extends ShopSearchParams>
    implements $ShopSearchParamsCopyWith<$Res> {
  _$ShopSearchParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? q = freezed, Object? page = null, Object? size = null}) {
    return _then(
      _value.copyWith(
            q: freezed == q
                ? _value.q
                : q // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ShopSearchParamsImplCopyWith<$Res>
    implements $ShopSearchParamsCopyWith<$Res> {
  factory _$$ShopSearchParamsImplCopyWith(
    _$ShopSearchParamsImpl value,
    $Res Function(_$ShopSearchParamsImpl) then,
  ) = __$$ShopSearchParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? q, int page, int size});
}

/// @nodoc
class __$$ShopSearchParamsImplCopyWithImpl<$Res>
    extends _$ShopSearchParamsCopyWithImpl<$Res, _$ShopSearchParamsImpl>
    implements _$$ShopSearchParamsImplCopyWith<$Res> {
  __$$ShopSearchParamsImplCopyWithImpl(
    _$ShopSearchParamsImpl _value,
    $Res Function(_$ShopSearchParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShopSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? q = freezed, Object? page = null, Object? size = null}) {
    return _then(
      _$ShopSearchParamsImpl(
        q: freezed == q
            ? _value.q
            : q // ignore: cast_nullable_to_non_nullable
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
class _$ShopSearchParamsImpl implements _ShopSearchParams {
  const _$ShopSearchParamsImpl({this.q, this.page = 0, this.size = 20});

  factory _$ShopSearchParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopSearchParamsImplFromJson(json);

  @override
  final String? q;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int size;

  @override
  String toString() {
    return 'ShopSearchParams(q: $q, page: $page, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopSearchParamsImpl &&
            (identical(other.q, q) || other.q == q) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, q, page, size);

  /// Create a copy of ShopSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopSearchParamsImplCopyWith<_$ShopSearchParamsImpl> get copyWith =>
      __$$ShopSearchParamsImplCopyWithImpl<_$ShopSearchParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopSearchParamsImplToJson(this);
  }
}

abstract class _ShopSearchParams implements ShopSearchParams {
  const factory _ShopSearchParams({
    final String? q,
    final int page,
    final int size,
  }) = _$ShopSearchParamsImpl;

  factory _ShopSearchParams.fromJson(Map<String, dynamic> json) =
      _$ShopSearchParamsImpl.fromJson;

  @override
  String? get q;
  @override
  int get page;
  @override
  int get size;

  /// Create a copy of ShopSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopSearchParamsImplCopyWith<_$ShopSearchParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
