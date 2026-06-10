// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_list_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserListItemDto _$UserListItemDtoFromJson(Map<String, dynamic> json) {
  return _UserListItemDto.fromJson(json);
}

/// @nodoc
mixin _$UserListItemDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_type')
  String get userType => throw _privateConstructorUsedError;

  /// Serializes this UserListItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserListItemDtoCopyWith<UserListItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserListItemDtoCopyWith<$Res> {
  factory $UserListItemDtoCopyWith(
    UserListItemDto value,
    $Res Function(UserListItemDto) then,
  ) = _$UserListItemDtoCopyWithImpl<$Res, UserListItemDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String username,
    @JsonKey(name: 'user_type') String userType,
  });
}

/// @nodoc
class _$UserListItemDtoCopyWithImpl<$Res, $Val extends UserListItemDto>
    implements $UserListItemDtoCopyWith<$Res> {
  _$UserListItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = null,
    Object? userType = null,
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
            userType: null == userType
                ? _value.userType
                : userType // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserListItemDtoImplCopyWith<$Res>
    implements $UserListItemDtoCopyWith<$Res> {
  factory _$$UserListItemDtoImplCopyWith(
    _$UserListItemDtoImpl value,
    $Res Function(_$UserListItemDtoImpl) then,
  ) = __$$UserListItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String username,
    @JsonKey(name: 'user_type') String userType,
  });
}

/// @nodoc
class __$$UserListItemDtoImplCopyWithImpl<$Res>
    extends _$UserListItemDtoCopyWithImpl<$Res, _$UserListItemDtoImpl>
    implements _$$UserListItemDtoImplCopyWith<$Res> {
  __$$UserListItemDtoImplCopyWithImpl(
    _$UserListItemDtoImpl _value,
    $Res Function(_$UserListItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = null,
    Object? userType = null,
  }) {
    return _then(
      _$UserListItemDtoImpl(
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
        userType: null == userType
            ? _value.userType
            : userType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserListItemDtoImpl implements _UserListItemDto {
  const _$UserListItemDtoImpl({
    required this.id,
    required this.name,
    required this.username,
    @JsonKey(name: 'user_type') required this.userType,
  });

  factory _$UserListItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserListItemDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String username;
  @override
  @JsonKey(name: 'user_type')
  final String userType;

  @override
  String toString() {
    return 'UserListItemDto(id: $id, name: $name, username: $username, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserListItemDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.userType, userType) ||
                other.userType == userType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username, userType);

  /// Create a copy of UserListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserListItemDtoImplCopyWith<_$UserListItemDtoImpl> get copyWith =>
      __$$UserListItemDtoImplCopyWithImpl<_$UserListItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserListItemDtoImplToJson(this);
  }
}

abstract class _UserListItemDto implements UserListItemDto {
  const factory _UserListItemDto({
    required final String id,
    required final String name,
    required final String username,
    @JsonKey(name: 'user_type') required final String userType,
  }) = _$UserListItemDtoImpl;

  factory _UserListItemDto.fromJson(Map<String, dynamic> json) =
      _$UserListItemDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get username;
  @override
  @JsonKey(name: 'user_type')
  String get userType;

  /// Create a copy of UserListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserListItemDtoImplCopyWith<_$UserListItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
