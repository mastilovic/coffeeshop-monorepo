// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserUpdateRequest _$UserUpdateRequestFromJson(Map<String, dynamic> json) {
  return _UserUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$UserUpdateRequest {
  String get name => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_type')
  String get userType => throw _privateConstructorUsedError;

  /// Serializes this UserUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserUpdateRequestCopyWith<UserUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserUpdateRequestCopyWith<$Res> {
  factory $UserUpdateRequestCopyWith(
    UserUpdateRequest value,
    $Res Function(UserUpdateRequest) then,
  ) = _$UserUpdateRequestCopyWithImpl<$Res, UserUpdateRequest>;
  @useResult
  $Res call({
    String name,
    String? username,
    String? email,
    String? password,
    @JsonKey(name: 'user_type') String userType,
  });
}

/// @nodoc
class _$UserUpdateRequestCopyWithImpl<$Res, $Val extends UserUpdateRequest>
    implements $UserUpdateRequestCopyWith<$Res> {
  _$UserUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? username = freezed,
    Object? email = freezed,
    Object? password = freezed,
    Object? userType = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$UserUpdateRequestImplCopyWith<$Res>
    implements $UserUpdateRequestCopyWith<$Res> {
  factory _$$UserUpdateRequestImplCopyWith(
    _$UserUpdateRequestImpl value,
    $Res Function(_$UserUpdateRequestImpl) then,
  ) = __$$UserUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? username,
    String? email,
    String? password,
    @JsonKey(name: 'user_type') String userType,
  });
}

/// @nodoc
class __$$UserUpdateRequestImplCopyWithImpl<$Res>
    extends _$UserUpdateRequestCopyWithImpl<$Res, _$UserUpdateRequestImpl>
    implements _$$UserUpdateRequestImplCopyWith<$Res> {
  __$$UserUpdateRequestImplCopyWithImpl(
    _$UserUpdateRequestImpl _value,
    $Res Function(_$UserUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? username = freezed,
    Object? email = freezed,
    Object? password = freezed,
    Object? userType = null,
  }) {
    return _then(
      _$UserUpdateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$UserUpdateRequestImpl implements _UserUpdateRequest {
  const _$UserUpdateRequestImpl({
    required this.name,
    this.username,
    this.email,
    this.password,
    @JsonKey(name: 'user_type') required this.userType,
  });

  factory _$UserUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserUpdateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? username;
  @override
  final String? email;
  @override
  final String? password;
  @override
  @JsonKey(name: 'user_type')
  final String userType;

  @override
  String toString() {
    return 'UserUpdateRequest(name: $name, username: $username, email: $email, password: $password, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserUpdateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.userType, userType) ||
                other.userType == userType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, username, email, password, userType);

  /// Create a copy of UserUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserUpdateRequestImplCopyWith<_$UserUpdateRequestImpl> get copyWith =>
      __$$UserUpdateRequestImplCopyWithImpl<_$UserUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserUpdateRequestImplToJson(this);
  }
}

abstract class _UserUpdateRequest implements UserUpdateRequest {
  const factory _UserUpdateRequest({
    required final String name,
    final String? username,
    final String? email,
    final String? password,
    @JsonKey(name: 'user_type') required final String userType,
  }) = _$UserUpdateRequestImpl;

  factory _UserUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$UserUpdateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get username;
  @override
  String? get email;
  @override
  String? get password;
  @override
  @JsonKey(name: 'user_type')
  String get userType;

  /// Create a copy of UserUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserUpdateRequestImplCopyWith<_$UserUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
