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
  });
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
          )
          as $Val,
    );
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
  });
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
  }) : _favouriteShops = favouriteShops;

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
  String toString() {
    return 'UserProfileResponseDto(id: $id, name: $name, username: $username, email: $email, userType: $userType, favouriteShops: $favouriteShops)';
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
            ));
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

  /// Create a copy of UserProfileResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileResponseDtoImplCopyWith<_$UserProfileResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
