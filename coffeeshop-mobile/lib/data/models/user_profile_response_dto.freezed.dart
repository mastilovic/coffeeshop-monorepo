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
  @JsonKey(name: 'user_type')
  String get userType => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'user_type') String userType,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
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
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
    @JsonKey(name: 'user_type') String userType,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
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
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
    @JsonKey(name: 'user_type') required this.userType,
    @JsonKey(name: 'is_active') required this.isActive,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

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
  @JsonKey(name: 'user_type')
  final String userType;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserProfileResponseDto(id: $id, name: $name, username: $username, email: $email, userType: $userType, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
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
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
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
    isActive,
    createdAt,
    updatedAt,
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
    @JsonKey(name: 'user_type') required final String userType,
    @JsonKey(name: 'is_active') required final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
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
  @JsonKey(name: 'user_type')
  String get userType;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of UserProfileResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileResponseDtoImplCopyWith<_$UserProfileResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
