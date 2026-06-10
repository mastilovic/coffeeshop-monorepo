// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PageResponseDto _$PageResponseDtoFromJson(Map<String, dynamic> json) {
  return _PageResponseDto.fromJson(json);
}

/// @nodoc
mixin _$PageResponseDto {
  List<Map<String, dynamic>> get content => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_elements')
  int get totalElements => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_pages')
  int get totalPages => throw _privateConstructorUsedError;

  /// Serializes this PageResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageResponseDtoCopyWith<PageResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageResponseDtoCopyWith<$Res> {
  factory $PageResponseDtoCopyWith(
    PageResponseDto value,
    $Res Function(PageResponseDto) then,
  ) = _$PageResponseDtoCopyWithImpl<$Res, PageResponseDto>;
  @useResult
  $Res call({
    List<Map<String, dynamic>> content,
    int page,
    int size,
    @JsonKey(name: 'total_elements') int totalElements,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class _$PageResponseDtoCopyWithImpl<$Res, $Val extends PageResponseDto>
    implements $PageResponseDtoCopyWith<$Res> {
  _$PageResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? page = null,
    Object? size = null,
    Object? totalElements = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            totalElements: null == totalElements
                ? _value.totalElements
                : totalElements // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PageResponseDtoImplCopyWith<$Res>
    implements $PageResponseDtoCopyWith<$Res> {
  factory _$$PageResponseDtoImplCopyWith(
    _$PageResponseDtoImpl value,
    $Res Function(_$PageResponseDtoImpl) then,
  ) = __$$PageResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Map<String, dynamic>> content,
    int page,
    int size,
    @JsonKey(name: 'total_elements') int totalElements,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class __$$PageResponseDtoImplCopyWithImpl<$Res>
    extends _$PageResponseDtoCopyWithImpl<$Res, _$PageResponseDtoImpl>
    implements _$$PageResponseDtoImplCopyWith<$Res> {
  __$$PageResponseDtoImplCopyWithImpl(
    _$PageResponseDtoImpl _value,
    $Res Function(_$PageResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PageResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? page = null,
    Object? size = null,
    Object? totalElements = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$PageResponseDtoImpl(
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        totalElements: null == totalElements
            ? _value.totalElements
            : totalElements // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PageResponseDtoImpl implements _PageResponseDto {
  const _$PageResponseDtoImpl({
    final List<Map<String, dynamic>> content = const [],
    required this.page,
    required this.size,
    @JsonKey(name: 'total_elements') required this.totalElements,
    @JsonKey(name: 'total_pages') required this.totalPages,
  }) : _content = content;

  factory _$PageResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageResponseDtoImplFromJson(json);

  final List<Map<String, dynamic>> _content;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get content {
    if (_content is EqualUnmodifiableListView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_content);
  }

  @override
  final int page;
  @override
  final int size;
  @override
  @JsonKey(name: 'total_elements')
  final int totalElements;
  @override
  @JsonKey(name: 'total_pages')
  final int totalPages;

  @override
  String toString() {
    return 'PageResponseDto(content: $content, page: $page, size: $size, totalElements: $totalElements, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageResponseDtoImpl &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_content),
    page,
    size,
    totalElements,
    totalPages,
  );

  /// Create a copy of PageResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageResponseDtoImplCopyWith<_$PageResponseDtoImpl> get copyWith =>
      __$$PageResponseDtoImplCopyWithImpl<_$PageResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PageResponseDtoImplToJson(this);
  }
}

abstract class _PageResponseDto implements PageResponseDto {
  const factory _PageResponseDto({
    final List<Map<String, dynamic>> content,
    required final int page,
    required final int size,
    @JsonKey(name: 'total_elements') required final int totalElements,
    @JsonKey(name: 'total_pages') required final int totalPages,
  }) = _$PageResponseDtoImpl;

  factory _PageResponseDto.fromJson(Map<String, dynamic> json) =
      _$PageResponseDtoImpl.fromJson;

  @override
  List<Map<String, dynamic>> get content;
  @override
  int get page;
  @override
  int get size;
  @override
  @JsonKey(name: 'total_elements')
  int get totalElements;
  @override
  @JsonKey(name: 'total_pages')
  int get totalPages;

  /// Create a copy of PageResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageResponseDtoImplCopyWith<_$PageResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
