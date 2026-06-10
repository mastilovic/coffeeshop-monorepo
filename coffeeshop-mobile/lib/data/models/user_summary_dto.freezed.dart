// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserSummaryDto _$UserSummaryDtoFromJson(Map<String, dynamic> json) {
  return _UserSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$UserSummaryDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;

  /// Serializes this UserSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSummaryDtoCopyWith<UserSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSummaryDtoCopyWith<$Res> {
  factory $UserSummaryDtoCopyWith(
    UserSummaryDto value,
    $Res Function(UserSummaryDto) then,
  ) = _$UserSummaryDtoCopyWithImpl<$Res, UserSummaryDto>;
  @useResult
  $Res call({String id, String name, String? username});
}

/// @nodoc
class _$UserSummaryDtoCopyWithImpl<$Res, $Val extends UserSummaryDto>
    implements $UserSummaryDtoCopyWith<$Res> {
  _$UserSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = freezed,
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
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSummaryDtoImplCopyWith<$Res>
    implements $UserSummaryDtoCopyWith<$Res> {
  factory _$$UserSummaryDtoImplCopyWith(
    _$UserSummaryDtoImpl value,
    $Res Function(_$UserSummaryDtoImpl) then,
  ) = __$$UserSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? username});
}

/// @nodoc
class __$$UserSummaryDtoImplCopyWithImpl<$Res>
    extends _$UserSummaryDtoCopyWithImpl<$Res, _$UserSummaryDtoImpl>
    implements _$$UserSummaryDtoImplCopyWith<$Res> {
  __$$UserSummaryDtoImplCopyWithImpl(
    _$UserSummaryDtoImpl _value,
    $Res Function(_$UserSummaryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = freezed,
  }) {
    return _then(
      _$UserSummaryDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSummaryDtoImpl implements _UserSummaryDto {
  const _$UserSummaryDtoImpl({
    required this.id,
    required this.name,
    this.username,
  });

  factory _$UserSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? username;

  @override
  String toString() {
    return 'UserSummaryDto(id: $id, name: $name, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username);

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSummaryDtoImplCopyWith<_$UserSummaryDtoImpl> get copyWith =>
      __$$UserSummaryDtoImplCopyWithImpl<_$UserSummaryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSummaryDtoImplToJson(this);
  }
}

abstract class _UserSummaryDto implements UserSummaryDto {
  const factory _UserSummaryDto({
    required final String id,
    required final String name,
    final String? username,
  }) = _$UserSummaryDtoImpl;

  factory _UserSummaryDto.fromJson(Map<String, dynamic> json) =
      _$UserSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get username;

  /// Create a copy of UserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSummaryDtoImplCopyWith<_$UserSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
