// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CatalogTierDto _$CatalogTierDtoFromJson(Map<String, dynamic> json) {
  return _CatalogTierDto.fromJson(json);
}

/// @nodoc
mixin _$CatalogTierDto {
  String get tier => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  int get basePriceMonthlyCents => throw _privateConstructorUsedError;
  int? get extraShopPriceCents => throw _privateConstructorUsedError;
  int get annualMonthsCharged => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<String> get includedFeatures => throw _privateConstructorUsedError;

  /// Serializes this CatalogTierDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogTierDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogTierDtoCopyWith<CatalogTierDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogTierDtoCopyWith<$Res> {
  factory $CatalogTierDtoCopyWith(
    CatalogTierDto value,
    $Res Function(CatalogTierDto) then,
  ) = _$CatalogTierDtoCopyWithImpl<$Res, CatalogTierDto>;
  @useResult
  $Res call({
    String tier,
    String displayName,
    int basePriceMonthlyCents,
    int? extraShopPriceCents,
    int annualMonthsCharged,
    bool isActive,
    List<String> includedFeatures,
  });
}

/// @nodoc
class _$CatalogTierDtoCopyWithImpl<$Res, $Val extends CatalogTierDto>
    implements $CatalogTierDtoCopyWith<$Res> {
  _$CatalogTierDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogTierDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? displayName = null,
    Object? basePriceMonthlyCents = null,
    Object? extraShopPriceCents = freezed,
    Object? annualMonthsCharged = null,
    Object? isActive = null,
    Object? includedFeatures = null,
  }) {
    return _then(
      _value.copyWith(
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            basePriceMonthlyCents: null == basePriceMonthlyCents
                ? _value.basePriceMonthlyCents
                : basePriceMonthlyCents // ignore: cast_nullable_to_non_nullable
                      as int,
            extraShopPriceCents: freezed == extraShopPriceCents
                ? _value.extraShopPriceCents
                : extraShopPriceCents // ignore: cast_nullable_to_non_nullable
                      as int?,
            annualMonthsCharged: null == annualMonthsCharged
                ? _value.annualMonthsCharged
                : annualMonthsCharged // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            includedFeatures: null == includedFeatures
                ? _value.includedFeatures
                : includedFeatures // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CatalogTierDtoImplCopyWith<$Res>
    implements $CatalogTierDtoCopyWith<$Res> {
  factory _$$CatalogTierDtoImplCopyWith(
    _$CatalogTierDtoImpl value,
    $Res Function(_$CatalogTierDtoImpl) then,
  ) = __$$CatalogTierDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String tier,
    String displayName,
    int basePriceMonthlyCents,
    int? extraShopPriceCents,
    int annualMonthsCharged,
    bool isActive,
    List<String> includedFeatures,
  });
}

/// @nodoc
class __$$CatalogTierDtoImplCopyWithImpl<$Res>
    extends _$CatalogTierDtoCopyWithImpl<$Res, _$CatalogTierDtoImpl>
    implements _$$CatalogTierDtoImplCopyWith<$Res> {
  __$$CatalogTierDtoImplCopyWithImpl(
    _$CatalogTierDtoImpl _value,
    $Res Function(_$CatalogTierDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatalogTierDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? displayName = null,
    Object? basePriceMonthlyCents = null,
    Object? extraShopPriceCents = freezed,
    Object? annualMonthsCharged = null,
    Object? isActive = null,
    Object? includedFeatures = null,
  }) {
    return _then(
      _$CatalogTierDtoImpl(
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        basePriceMonthlyCents: null == basePriceMonthlyCents
            ? _value.basePriceMonthlyCents
            : basePriceMonthlyCents // ignore: cast_nullable_to_non_nullable
                  as int,
        extraShopPriceCents: freezed == extraShopPriceCents
            ? _value.extraShopPriceCents
            : extraShopPriceCents // ignore: cast_nullable_to_non_nullable
                  as int?,
        annualMonthsCharged: null == annualMonthsCharged
            ? _value.annualMonthsCharged
            : annualMonthsCharged // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        includedFeatures: null == includedFeatures
            ? _value._includedFeatures
            : includedFeatures // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogTierDtoImpl implements _CatalogTierDto {
  const _$CatalogTierDtoImpl({
    required this.tier,
    required this.displayName,
    required this.basePriceMonthlyCents,
    this.extraShopPriceCents,
    this.annualMonthsCharged = 12,
    this.isActive = true,
    final List<String> includedFeatures = const [],
  }) : _includedFeatures = includedFeatures;

  factory _$CatalogTierDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogTierDtoImplFromJson(json);

  @override
  final String tier;
  @override
  final String displayName;
  @override
  final int basePriceMonthlyCents;
  @override
  final int? extraShopPriceCents;
  @override
  @JsonKey()
  final int annualMonthsCharged;
  @override
  @JsonKey()
  final bool isActive;
  final List<String> _includedFeatures;
  @override
  @JsonKey()
  List<String> get includedFeatures {
    if (_includedFeatures is EqualUnmodifiableListView)
      return _includedFeatures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_includedFeatures);
  }

  @override
  String toString() {
    return 'CatalogTierDto(tier: $tier, displayName: $displayName, basePriceMonthlyCents: $basePriceMonthlyCents, extraShopPriceCents: $extraShopPriceCents, annualMonthsCharged: $annualMonthsCharged, isActive: $isActive, includedFeatures: $includedFeatures)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogTierDtoImpl &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.basePriceMonthlyCents, basePriceMonthlyCents) ||
                other.basePriceMonthlyCents == basePriceMonthlyCents) &&
            (identical(other.extraShopPriceCents, extraShopPriceCents) ||
                other.extraShopPriceCents == extraShopPriceCents) &&
            (identical(other.annualMonthsCharged, annualMonthsCharged) ||
                other.annualMonthsCharged == annualMonthsCharged) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(
              other._includedFeatures,
              _includedFeatures,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tier,
    displayName,
    basePriceMonthlyCents,
    extraShopPriceCents,
    annualMonthsCharged,
    isActive,
    const DeepCollectionEquality().hash(_includedFeatures),
  );

  /// Create a copy of CatalogTierDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogTierDtoImplCopyWith<_$CatalogTierDtoImpl> get copyWith =>
      __$$CatalogTierDtoImplCopyWithImpl<_$CatalogTierDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogTierDtoImplToJson(this);
  }
}

abstract class _CatalogTierDto implements CatalogTierDto {
  const factory _CatalogTierDto({
    required final String tier,
    required final String displayName,
    required final int basePriceMonthlyCents,
    final int? extraShopPriceCents,
    final int annualMonthsCharged,
    final bool isActive,
    final List<String> includedFeatures,
  }) = _$CatalogTierDtoImpl;

  factory _CatalogTierDto.fromJson(Map<String, dynamic> json) =
      _$CatalogTierDtoImpl.fromJson;

  @override
  String get tier;
  @override
  String get displayName;
  @override
  int get basePriceMonthlyCents;
  @override
  int? get extraShopPriceCents;
  @override
  int get annualMonthsCharged;
  @override
  bool get isActive;
  @override
  List<String> get includedFeatures;

  /// Create a copy of CatalogTierDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogTierDtoImplCopyWith<_$CatalogTierDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeatureCatalogItemDto _$FeatureCatalogItemDtoFromJson(
  Map<String, dynamic> json,
) {
  return _FeatureCatalogItemDto.fromJson(json);
}

/// @nodoc
mixin _$FeatureCatalogItemDto {
  String get featureKey => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get monthlyPriceCents => throw _privateConstructorUsedError;
  String? get limitType => throw _privateConstructorUsedError;
  int? get limitValue => throw _privateConstructorUsedError;
  bool get isSelectableCustom => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this FeatureCatalogItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeatureCatalogItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeatureCatalogItemDtoCopyWith<FeatureCatalogItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeatureCatalogItemDtoCopyWith<$Res> {
  factory $FeatureCatalogItemDtoCopyWith(
    FeatureCatalogItemDto value,
    $Res Function(FeatureCatalogItemDto) then,
  ) = _$FeatureCatalogItemDtoCopyWithImpl<$Res, FeatureCatalogItemDto>;
  @useResult
  $Res call({
    String featureKey,
    String displayName,
    String? description,
    int monthlyPriceCents,
    String? limitType,
    int? limitValue,
    bool isSelectableCustom,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$FeatureCatalogItemDtoCopyWithImpl<
  $Res,
  $Val extends FeatureCatalogItemDto
>
    implements $FeatureCatalogItemDtoCopyWith<$Res> {
  _$FeatureCatalogItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeatureCatalogItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? featureKey = null,
    Object? displayName = null,
    Object? description = freezed,
    Object? monthlyPriceCents = null,
    Object? limitType = freezed,
    Object? limitValue = freezed,
    Object? isSelectableCustom = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            featureKey: null == featureKey
                ? _value.featureKey
                : featureKey // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            monthlyPriceCents: null == monthlyPriceCents
                ? _value.monthlyPriceCents
                : monthlyPriceCents // ignore: cast_nullable_to_non_nullable
                      as int,
            limitType: freezed == limitType
                ? _value.limitType
                : limitType // ignore: cast_nullable_to_non_nullable
                      as String?,
            limitValue: freezed == limitValue
                ? _value.limitValue
                : limitValue // ignore: cast_nullable_to_non_nullable
                      as int?,
            isSelectableCustom: null == isSelectableCustom
                ? _value.isSelectableCustom
                : isSelectableCustom // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeatureCatalogItemDtoImplCopyWith<$Res>
    implements $FeatureCatalogItemDtoCopyWith<$Res> {
  factory _$$FeatureCatalogItemDtoImplCopyWith(
    _$FeatureCatalogItemDtoImpl value,
    $Res Function(_$FeatureCatalogItemDtoImpl) then,
  ) = __$$FeatureCatalogItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String featureKey,
    String displayName,
    String? description,
    int monthlyPriceCents,
    String? limitType,
    int? limitValue,
    bool isSelectableCustom,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$FeatureCatalogItemDtoImplCopyWithImpl<$Res>
    extends
        _$FeatureCatalogItemDtoCopyWithImpl<$Res, _$FeatureCatalogItemDtoImpl>
    implements _$$FeatureCatalogItemDtoImplCopyWith<$Res> {
  __$$FeatureCatalogItemDtoImplCopyWithImpl(
    _$FeatureCatalogItemDtoImpl _value,
    $Res Function(_$FeatureCatalogItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeatureCatalogItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? featureKey = null,
    Object? displayName = null,
    Object? description = freezed,
    Object? monthlyPriceCents = null,
    Object? limitType = freezed,
    Object? limitValue = freezed,
    Object? isSelectableCustom = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$FeatureCatalogItemDtoImpl(
        featureKey: null == featureKey
            ? _value.featureKey
            : featureKey // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        monthlyPriceCents: null == monthlyPriceCents
            ? _value.monthlyPriceCents
            : monthlyPriceCents // ignore: cast_nullable_to_non_nullable
                  as int,
        limitType: freezed == limitType
            ? _value.limitType
            : limitType // ignore: cast_nullable_to_non_nullable
                  as String?,
        limitValue: freezed == limitValue
            ? _value.limitValue
            : limitValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        isSelectableCustom: null == isSelectableCustom
            ? _value.isSelectableCustom
            : isSelectableCustom // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeatureCatalogItemDtoImpl implements _FeatureCatalogItemDto {
  const _$FeatureCatalogItemDtoImpl({
    required this.featureKey,
    required this.displayName,
    this.description,
    required this.monthlyPriceCents,
    this.limitType,
    this.limitValue,
    this.isSelectableCustom = true,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory _$FeatureCatalogItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeatureCatalogItemDtoImplFromJson(json);

  @override
  final String featureKey;
  @override
  final String displayName;
  @override
  final String? description;
  @override
  final int monthlyPriceCents;
  @override
  final String? limitType;
  @override
  final int? limitValue;
  @override
  @JsonKey()
  final bool isSelectableCustom;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'FeatureCatalogItemDto(featureKey: $featureKey, displayName: $displayName, description: $description, monthlyPriceCents: $monthlyPriceCents, limitType: $limitType, limitValue: $limitValue, isSelectableCustom: $isSelectableCustom, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeatureCatalogItemDtoImpl &&
            (identical(other.featureKey, featureKey) ||
                other.featureKey == featureKey) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.monthlyPriceCents, monthlyPriceCents) ||
                other.monthlyPriceCents == monthlyPriceCents) &&
            (identical(other.limitType, limitType) ||
                other.limitType == limitType) &&
            (identical(other.limitValue, limitValue) ||
                other.limitValue == limitValue) &&
            (identical(other.isSelectableCustom, isSelectableCustom) ||
                other.isSelectableCustom == isSelectableCustom) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    featureKey,
    displayName,
    description,
    monthlyPriceCents,
    limitType,
    limitValue,
    isSelectableCustom,
    sortOrder,
    isActive,
  );

  /// Create a copy of FeatureCatalogItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeatureCatalogItemDtoImplCopyWith<_$FeatureCatalogItemDtoImpl>
  get copyWith =>
      __$$FeatureCatalogItemDtoImplCopyWithImpl<_$FeatureCatalogItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FeatureCatalogItemDtoImplToJson(this);
  }
}

abstract class _FeatureCatalogItemDto implements FeatureCatalogItemDto {
  const factory _FeatureCatalogItemDto({
    required final String featureKey,
    required final String displayName,
    final String? description,
    required final int monthlyPriceCents,
    final String? limitType,
    final int? limitValue,
    final bool isSelectableCustom,
    final int sortOrder,
    final bool isActive,
  }) = _$FeatureCatalogItemDtoImpl;

  factory _FeatureCatalogItemDto.fromJson(Map<String, dynamic> json) =
      _$FeatureCatalogItemDtoImpl.fromJson;

  @override
  String get featureKey;
  @override
  String get displayName;
  @override
  String? get description;
  @override
  int get monthlyPriceCents;
  @override
  String? get limitType;
  @override
  int? get limitValue;
  @override
  bool get isSelectableCustom;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of FeatureCatalogItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeatureCatalogItemDtoImplCopyWith<_$FeatureCatalogItemDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CatalogResponseDto _$CatalogResponseDtoFromJson(Map<String, dynamic> json) {
  return _CatalogResponseDto.fromJson(json);
}

/// @nodoc
mixin _$CatalogResponseDto {
  List<CatalogTierDto> get tiers => throw _privateConstructorUsedError;
  List<FeatureCatalogItemDto> get features =>
      throw _privateConstructorUsedError;

  /// Serializes this CatalogResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogResponseDtoCopyWith<CatalogResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogResponseDtoCopyWith<$Res> {
  factory $CatalogResponseDtoCopyWith(
    CatalogResponseDto value,
    $Res Function(CatalogResponseDto) then,
  ) = _$CatalogResponseDtoCopyWithImpl<$Res, CatalogResponseDto>;
  @useResult
  $Res call({List<CatalogTierDto> tiers, List<FeatureCatalogItemDto> features});
}

/// @nodoc
class _$CatalogResponseDtoCopyWithImpl<$Res, $Val extends CatalogResponseDto>
    implements $CatalogResponseDtoCopyWith<$Res> {
  _$CatalogResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tiers = null, Object? features = null}) {
    return _then(
      _value.copyWith(
            tiers: null == tiers
                ? _value.tiers
                : tiers // ignore: cast_nullable_to_non_nullable
                      as List<CatalogTierDto>,
            features: null == features
                ? _value.features
                : features // ignore: cast_nullable_to_non_nullable
                      as List<FeatureCatalogItemDto>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CatalogResponseDtoImplCopyWith<$Res>
    implements $CatalogResponseDtoCopyWith<$Res> {
  factory _$$CatalogResponseDtoImplCopyWith(
    _$CatalogResponseDtoImpl value,
    $Res Function(_$CatalogResponseDtoImpl) then,
  ) = __$$CatalogResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CatalogTierDto> tiers, List<FeatureCatalogItemDto> features});
}

/// @nodoc
class __$$CatalogResponseDtoImplCopyWithImpl<$Res>
    extends _$CatalogResponseDtoCopyWithImpl<$Res, _$CatalogResponseDtoImpl>
    implements _$$CatalogResponseDtoImplCopyWith<$Res> {
  __$$CatalogResponseDtoImplCopyWithImpl(
    _$CatalogResponseDtoImpl _value,
    $Res Function(_$CatalogResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatalogResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tiers = null, Object? features = null}) {
    return _then(
      _$CatalogResponseDtoImpl(
        tiers: null == tiers
            ? _value._tiers
            : tiers // ignore: cast_nullable_to_non_nullable
                  as List<CatalogTierDto>,
        features: null == features
            ? _value._features
            : features // ignore: cast_nullable_to_non_nullable
                  as List<FeatureCatalogItemDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogResponseDtoImpl implements _CatalogResponseDto {
  const _$CatalogResponseDtoImpl({
    final List<CatalogTierDto> tiers = const [],
    final List<FeatureCatalogItemDto> features = const [],
  }) : _tiers = tiers,
       _features = features;

  factory _$CatalogResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogResponseDtoImplFromJson(json);

  final List<CatalogTierDto> _tiers;
  @override
  @JsonKey()
  List<CatalogTierDto> get tiers {
    if (_tiers is EqualUnmodifiableListView) return _tiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tiers);
  }

  final List<FeatureCatalogItemDto> _features;
  @override
  @JsonKey()
  List<FeatureCatalogItemDto> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  String toString() {
    return 'CatalogResponseDto(tiers: $tiers, features: $features)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogResponseDtoImpl &&
            const DeepCollectionEquality().equals(other._tiers, _tiers) &&
            const DeepCollectionEquality().equals(other._features, _features));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_tiers),
    const DeepCollectionEquality().hash(_features),
  );

  /// Create a copy of CatalogResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogResponseDtoImplCopyWith<_$CatalogResponseDtoImpl> get copyWith =>
      __$$CatalogResponseDtoImplCopyWithImpl<_$CatalogResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogResponseDtoImplToJson(this);
  }
}

abstract class _CatalogResponseDto implements CatalogResponseDto {
  const factory _CatalogResponseDto({
    final List<CatalogTierDto> tiers,
    final List<FeatureCatalogItemDto> features,
  }) = _$CatalogResponseDtoImpl;

  factory _CatalogResponseDto.fromJson(Map<String, dynamic> json) =
      _$CatalogResponseDtoImpl.fromJson;

  @override
  List<CatalogTierDto> get tiers;
  @override
  List<FeatureCatalogItemDto> get features;

  /// Create a copy of CatalogResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogResponseDtoImplCopyWith<_$CatalogResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuoteLineItemDto _$QuoteLineItemDtoFromJson(Map<String, dynamic> json) {
  return _QuoteLineItemDto.fromJson(json);
}

/// @nodoc
mixin _$QuoteLineItemDto {
  String get key => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  int get amountCents => throw _privateConstructorUsedError;

  /// Serializes this QuoteLineItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuoteLineItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuoteLineItemDtoCopyWith<QuoteLineItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteLineItemDtoCopyWith<$Res> {
  factory $QuoteLineItemDtoCopyWith(
    QuoteLineItemDto value,
    $Res Function(QuoteLineItemDto) then,
  ) = _$QuoteLineItemDtoCopyWithImpl<$Res, QuoteLineItemDto>;
  @useResult
  $Res call({String key, String label, int amountCents});
}

/// @nodoc
class _$QuoteLineItemDtoCopyWithImpl<$Res, $Val extends QuoteLineItemDto>
    implements $QuoteLineItemDtoCopyWith<$Res> {
  _$QuoteLineItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuoteLineItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? label = null,
    Object? amountCents = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            amountCents: null == amountCents
                ? _value.amountCents
                : amountCents // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuoteLineItemDtoImplCopyWith<$Res>
    implements $QuoteLineItemDtoCopyWith<$Res> {
  factory _$$QuoteLineItemDtoImplCopyWith(
    _$QuoteLineItemDtoImpl value,
    $Res Function(_$QuoteLineItemDtoImpl) then,
  ) = __$$QuoteLineItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String label, int amountCents});
}

/// @nodoc
class __$$QuoteLineItemDtoImplCopyWithImpl<$Res>
    extends _$QuoteLineItemDtoCopyWithImpl<$Res, _$QuoteLineItemDtoImpl>
    implements _$$QuoteLineItemDtoImplCopyWith<$Res> {
  __$$QuoteLineItemDtoImplCopyWithImpl(
    _$QuoteLineItemDtoImpl _value,
    $Res Function(_$QuoteLineItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuoteLineItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? label = null,
    Object? amountCents = null,
  }) {
    return _then(
      _$QuoteLineItemDtoImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        amountCents: null == amountCents
            ? _value.amountCents
            : amountCents // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuoteLineItemDtoImpl implements _QuoteLineItemDto {
  const _$QuoteLineItemDtoImpl({
    required this.key,
    required this.label,
    required this.amountCents,
  });

  factory _$QuoteLineItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteLineItemDtoImplFromJson(json);

  @override
  final String key;
  @override
  final String label;
  @override
  final int amountCents;

  @override
  String toString() {
    return 'QuoteLineItemDto(key: $key, label: $label, amountCents: $amountCents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteLineItemDtoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.amountCents, amountCents) ||
                other.amountCents == amountCents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, label, amountCents);

  /// Create a copy of QuoteLineItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteLineItemDtoImplCopyWith<_$QuoteLineItemDtoImpl> get copyWith =>
      __$$QuoteLineItemDtoImplCopyWithImpl<_$QuoteLineItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteLineItemDtoImplToJson(this);
  }
}

abstract class _QuoteLineItemDto implements QuoteLineItemDto {
  const factory _QuoteLineItemDto({
    required final String key,
    required final String label,
    required final int amountCents,
  }) = _$QuoteLineItemDtoImpl;

  factory _QuoteLineItemDto.fromJson(Map<String, dynamic> json) =
      _$QuoteLineItemDtoImpl.fromJson;

  @override
  String get key;
  @override
  String get label;
  @override
  int get amountCents;

  /// Create a copy of QuoteLineItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuoteLineItemDtoImplCopyWith<_$QuoteLineItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuoteBreakdownDto _$QuoteBreakdownDtoFromJson(Map<String, dynamic> json) {
  return _QuoteBreakdownDto.fromJson(json);
}

/// @nodoc
mixin _$QuoteBreakdownDto {
  int get baseMonthlyCents => throw _privateConstructorUsedError;
  int get extraShopsCents => throw _privateConstructorUsedError;
  int get featuresMonthlyCents => throw _privateConstructorUsedError;
  int get monthlyTotalCents => throw _privateConstructorUsedError;
  int get annualTotalCents => throw _privateConstructorUsedError;
  int get annualMonthsCharged => throw _privateConstructorUsedError;
  List<QuoteLineItemDto> get lineItems => throw _privateConstructorUsedError;

  /// Serializes this QuoteBreakdownDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuoteBreakdownDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuoteBreakdownDtoCopyWith<QuoteBreakdownDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteBreakdownDtoCopyWith<$Res> {
  factory $QuoteBreakdownDtoCopyWith(
    QuoteBreakdownDto value,
    $Res Function(QuoteBreakdownDto) then,
  ) = _$QuoteBreakdownDtoCopyWithImpl<$Res, QuoteBreakdownDto>;
  @useResult
  $Res call({
    int baseMonthlyCents,
    int extraShopsCents,
    int featuresMonthlyCents,
    int monthlyTotalCents,
    int annualTotalCents,
    int annualMonthsCharged,
    List<QuoteLineItemDto> lineItems,
  });
}

/// @nodoc
class _$QuoteBreakdownDtoCopyWithImpl<$Res, $Val extends QuoteBreakdownDto>
    implements $QuoteBreakdownDtoCopyWith<$Res> {
  _$QuoteBreakdownDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuoteBreakdownDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseMonthlyCents = null,
    Object? extraShopsCents = null,
    Object? featuresMonthlyCents = null,
    Object? monthlyTotalCents = null,
    Object? annualTotalCents = null,
    Object? annualMonthsCharged = null,
    Object? lineItems = null,
  }) {
    return _then(
      _value.copyWith(
            baseMonthlyCents: null == baseMonthlyCents
                ? _value.baseMonthlyCents
                : baseMonthlyCents // ignore: cast_nullable_to_non_nullable
                      as int,
            extraShopsCents: null == extraShopsCents
                ? _value.extraShopsCents
                : extraShopsCents // ignore: cast_nullable_to_non_nullable
                      as int,
            featuresMonthlyCents: null == featuresMonthlyCents
                ? _value.featuresMonthlyCents
                : featuresMonthlyCents // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyTotalCents: null == monthlyTotalCents
                ? _value.monthlyTotalCents
                : monthlyTotalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            annualTotalCents: null == annualTotalCents
                ? _value.annualTotalCents
                : annualTotalCents // ignore: cast_nullable_to_non_nullable
                      as int,
            annualMonthsCharged: null == annualMonthsCharged
                ? _value.annualMonthsCharged
                : annualMonthsCharged // ignore: cast_nullable_to_non_nullable
                      as int,
            lineItems: null == lineItems
                ? _value.lineItems
                : lineItems // ignore: cast_nullable_to_non_nullable
                      as List<QuoteLineItemDto>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuoteBreakdownDtoImplCopyWith<$Res>
    implements $QuoteBreakdownDtoCopyWith<$Res> {
  factory _$$QuoteBreakdownDtoImplCopyWith(
    _$QuoteBreakdownDtoImpl value,
    $Res Function(_$QuoteBreakdownDtoImpl) then,
  ) = __$$QuoteBreakdownDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int baseMonthlyCents,
    int extraShopsCents,
    int featuresMonthlyCents,
    int monthlyTotalCents,
    int annualTotalCents,
    int annualMonthsCharged,
    List<QuoteLineItemDto> lineItems,
  });
}

/// @nodoc
class __$$QuoteBreakdownDtoImplCopyWithImpl<$Res>
    extends _$QuoteBreakdownDtoCopyWithImpl<$Res, _$QuoteBreakdownDtoImpl>
    implements _$$QuoteBreakdownDtoImplCopyWith<$Res> {
  __$$QuoteBreakdownDtoImplCopyWithImpl(
    _$QuoteBreakdownDtoImpl _value,
    $Res Function(_$QuoteBreakdownDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuoteBreakdownDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseMonthlyCents = null,
    Object? extraShopsCents = null,
    Object? featuresMonthlyCents = null,
    Object? monthlyTotalCents = null,
    Object? annualTotalCents = null,
    Object? annualMonthsCharged = null,
    Object? lineItems = null,
  }) {
    return _then(
      _$QuoteBreakdownDtoImpl(
        baseMonthlyCents: null == baseMonthlyCents
            ? _value.baseMonthlyCents
            : baseMonthlyCents // ignore: cast_nullable_to_non_nullable
                  as int,
        extraShopsCents: null == extraShopsCents
            ? _value.extraShopsCents
            : extraShopsCents // ignore: cast_nullable_to_non_nullable
                  as int,
        featuresMonthlyCents: null == featuresMonthlyCents
            ? _value.featuresMonthlyCents
            : featuresMonthlyCents // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyTotalCents: null == monthlyTotalCents
            ? _value.monthlyTotalCents
            : monthlyTotalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        annualTotalCents: null == annualTotalCents
            ? _value.annualTotalCents
            : annualTotalCents // ignore: cast_nullable_to_non_nullable
                  as int,
        annualMonthsCharged: null == annualMonthsCharged
            ? _value.annualMonthsCharged
            : annualMonthsCharged // ignore: cast_nullable_to_non_nullable
                  as int,
        lineItems: null == lineItems
            ? _value._lineItems
            : lineItems // ignore: cast_nullable_to_non_nullable
                  as List<QuoteLineItemDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuoteBreakdownDtoImpl implements _QuoteBreakdownDto {
  const _$QuoteBreakdownDtoImpl({
    this.baseMonthlyCents = 0,
    this.extraShopsCents = 0,
    this.featuresMonthlyCents = 0,
    this.monthlyTotalCents = 0,
    this.annualTotalCents = 0,
    this.annualMonthsCharged = 12,
    final List<QuoteLineItemDto> lineItems = const [],
  }) : _lineItems = lineItems;

  factory _$QuoteBreakdownDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteBreakdownDtoImplFromJson(json);

  @override
  @JsonKey()
  final int baseMonthlyCents;
  @override
  @JsonKey()
  final int extraShopsCents;
  @override
  @JsonKey()
  final int featuresMonthlyCents;
  @override
  @JsonKey()
  final int monthlyTotalCents;
  @override
  @JsonKey()
  final int annualTotalCents;
  @override
  @JsonKey()
  final int annualMonthsCharged;
  final List<QuoteLineItemDto> _lineItems;
  @override
  @JsonKey()
  List<QuoteLineItemDto> get lineItems {
    if (_lineItems is EqualUnmodifiableListView) return _lineItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lineItems);
  }

  @override
  String toString() {
    return 'QuoteBreakdownDto(baseMonthlyCents: $baseMonthlyCents, extraShopsCents: $extraShopsCents, featuresMonthlyCents: $featuresMonthlyCents, monthlyTotalCents: $monthlyTotalCents, annualTotalCents: $annualTotalCents, annualMonthsCharged: $annualMonthsCharged, lineItems: $lineItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteBreakdownDtoImpl &&
            (identical(other.baseMonthlyCents, baseMonthlyCents) ||
                other.baseMonthlyCents == baseMonthlyCents) &&
            (identical(other.extraShopsCents, extraShopsCents) ||
                other.extraShopsCents == extraShopsCents) &&
            (identical(other.featuresMonthlyCents, featuresMonthlyCents) ||
                other.featuresMonthlyCents == featuresMonthlyCents) &&
            (identical(other.monthlyTotalCents, monthlyTotalCents) ||
                other.monthlyTotalCents == monthlyTotalCents) &&
            (identical(other.annualTotalCents, annualTotalCents) ||
                other.annualTotalCents == annualTotalCents) &&
            (identical(other.annualMonthsCharged, annualMonthsCharged) ||
                other.annualMonthsCharged == annualMonthsCharged) &&
            const DeepCollectionEquality().equals(
              other._lineItems,
              _lineItems,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    baseMonthlyCents,
    extraShopsCents,
    featuresMonthlyCents,
    monthlyTotalCents,
    annualTotalCents,
    annualMonthsCharged,
    const DeepCollectionEquality().hash(_lineItems),
  );

  /// Create a copy of QuoteBreakdownDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteBreakdownDtoImplCopyWith<_$QuoteBreakdownDtoImpl> get copyWith =>
      __$$QuoteBreakdownDtoImplCopyWithImpl<_$QuoteBreakdownDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteBreakdownDtoImplToJson(this);
  }
}

abstract class _QuoteBreakdownDto implements QuoteBreakdownDto {
  const factory _QuoteBreakdownDto({
    final int baseMonthlyCents,
    final int extraShopsCents,
    final int featuresMonthlyCents,
    final int monthlyTotalCents,
    final int annualTotalCents,
    final int annualMonthsCharged,
    final List<QuoteLineItemDto> lineItems,
  }) = _$QuoteBreakdownDtoImpl;

  factory _QuoteBreakdownDto.fromJson(Map<String, dynamic> json) =
      _$QuoteBreakdownDtoImpl.fromJson;

  @override
  int get baseMonthlyCents;
  @override
  int get extraShopsCents;
  @override
  int get featuresMonthlyCents;
  @override
  int get monthlyTotalCents;
  @override
  int get annualTotalCents;
  @override
  int get annualMonthsCharged;
  @override
  List<QuoteLineItemDto> get lineItems;

  /// Create a copy of QuoteBreakdownDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuoteBreakdownDtoImplCopyWith<_$QuoteBreakdownDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionMeResponseDto _$SubscriptionMeResponseDtoFromJson(
  Map<String, dynamic> json,
) {
  return _SubscriptionMeResponseDto.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionMeResponseDto {
  String get planMode => throw _privateConstructorUsedError;
  String? get planTier => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get billingInterval => throw _privateConstructorUsedError;
  List<String> get features => throw _privateConstructorUsedError;
  int get shopsIncluded => throw _privateConstructorUsedError;
  int get shopsUsed => throw _privateConstructorUsedError;
  String? get periodEnd => throw _privateConstructorUsedError;
  int get lockedMonthlyAmountCents => throw _privateConstructorUsedError;
  QuoteBreakdownDto? get renewalQuote => throw _privateConstructorUsedError;
  Map<String, bool> get entitlements => throw _privateConstructorUsedError;
  Map<String, dynamic> get limits => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionMeResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionMeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionMeResponseDtoCopyWith<SubscriptionMeResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionMeResponseDtoCopyWith<$Res> {
  factory $SubscriptionMeResponseDtoCopyWith(
    SubscriptionMeResponseDto value,
    $Res Function(SubscriptionMeResponseDto) then,
  ) = _$SubscriptionMeResponseDtoCopyWithImpl<$Res, SubscriptionMeResponseDto>;
  @useResult
  $Res call({
    String planMode,
    String? planTier,
    String status,
    String? billingInterval,
    List<String> features,
    int shopsIncluded,
    int shopsUsed,
    String? periodEnd,
    int lockedMonthlyAmountCents,
    QuoteBreakdownDto? renewalQuote,
    Map<String, bool> entitlements,
    Map<String, dynamic> limits,
  });

  $QuoteBreakdownDtoCopyWith<$Res>? get renewalQuote;
}

/// @nodoc
class _$SubscriptionMeResponseDtoCopyWithImpl<
  $Res,
  $Val extends SubscriptionMeResponseDto
>
    implements $SubscriptionMeResponseDtoCopyWith<$Res> {
  _$SubscriptionMeResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionMeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planMode = null,
    Object? planTier = freezed,
    Object? status = null,
    Object? billingInterval = freezed,
    Object? features = null,
    Object? shopsIncluded = null,
    Object? shopsUsed = null,
    Object? periodEnd = freezed,
    Object? lockedMonthlyAmountCents = null,
    Object? renewalQuote = freezed,
    Object? entitlements = null,
    Object? limits = null,
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
            billingInterval: freezed == billingInterval
                ? _value.billingInterval
                : billingInterval // ignore: cast_nullable_to_non_nullable
                      as String?,
            features: null == features
                ? _value.features
                : features // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
            lockedMonthlyAmountCents: null == lockedMonthlyAmountCents
                ? _value.lockedMonthlyAmountCents
                : lockedMonthlyAmountCents // ignore: cast_nullable_to_non_nullable
                      as int,
            renewalQuote: freezed == renewalQuote
                ? _value.renewalQuote
                : renewalQuote // ignore: cast_nullable_to_non_nullable
                      as QuoteBreakdownDto?,
            entitlements: null == entitlements
                ? _value.entitlements
                : entitlements // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
            limits: null == limits
                ? _value.limits
                : limits // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }

  /// Create a copy of SubscriptionMeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuoteBreakdownDtoCopyWith<$Res>? get renewalQuote {
    if (_value.renewalQuote == null) {
      return null;
    }

    return $QuoteBreakdownDtoCopyWith<$Res>(_value.renewalQuote!, (value) {
      return _then(_value.copyWith(renewalQuote: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubscriptionMeResponseDtoImplCopyWith<$Res>
    implements $SubscriptionMeResponseDtoCopyWith<$Res> {
  factory _$$SubscriptionMeResponseDtoImplCopyWith(
    _$SubscriptionMeResponseDtoImpl value,
    $Res Function(_$SubscriptionMeResponseDtoImpl) then,
  ) = __$$SubscriptionMeResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String planMode,
    String? planTier,
    String status,
    String? billingInterval,
    List<String> features,
    int shopsIncluded,
    int shopsUsed,
    String? periodEnd,
    int lockedMonthlyAmountCents,
    QuoteBreakdownDto? renewalQuote,
    Map<String, bool> entitlements,
    Map<String, dynamic> limits,
  });

  @override
  $QuoteBreakdownDtoCopyWith<$Res>? get renewalQuote;
}

/// @nodoc
class __$$SubscriptionMeResponseDtoImplCopyWithImpl<$Res>
    extends
        _$SubscriptionMeResponseDtoCopyWithImpl<
          $Res,
          _$SubscriptionMeResponseDtoImpl
        >
    implements _$$SubscriptionMeResponseDtoImplCopyWith<$Res> {
  __$$SubscriptionMeResponseDtoImplCopyWithImpl(
    _$SubscriptionMeResponseDtoImpl _value,
    $Res Function(_$SubscriptionMeResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionMeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planMode = null,
    Object? planTier = freezed,
    Object? status = null,
    Object? billingInterval = freezed,
    Object? features = null,
    Object? shopsIncluded = null,
    Object? shopsUsed = null,
    Object? periodEnd = freezed,
    Object? lockedMonthlyAmountCents = null,
    Object? renewalQuote = freezed,
    Object? entitlements = null,
    Object? limits = null,
  }) {
    return _then(
      _$SubscriptionMeResponseDtoImpl(
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
        billingInterval: freezed == billingInterval
            ? _value.billingInterval
            : billingInterval // ignore: cast_nullable_to_non_nullable
                  as String?,
        features: null == features
            ? _value._features
            : features // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
        lockedMonthlyAmountCents: null == lockedMonthlyAmountCents
            ? _value.lockedMonthlyAmountCents
            : lockedMonthlyAmountCents // ignore: cast_nullable_to_non_nullable
                  as int,
        renewalQuote: freezed == renewalQuote
            ? _value.renewalQuote
            : renewalQuote // ignore: cast_nullable_to_non_nullable
                  as QuoteBreakdownDto?,
        entitlements: null == entitlements
            ? _value._entitlements
            : entitlements // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
        limits: null == limits
            ? _value._limits
            : limits // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionMeResponseDtoImpl implements _SubscriptionMeResponseDto {
  const _$SubscriptionMeResponseDtoImpl({
    required this.planMode,
    this.planTier,
    required this.status,
    this.billingInterval,
    final List<String> features = const [],
    this.shopsIncluded = 1,
    this.shopsUsed = 0,
    this.periodEnd,
    this.lockedMonthlyAmountCents = 0,
    this.renewalQuote,
    final Map<String, bool> entitlements = const {},
    final Map<String, dynamic> limits = const {},
  }) : _features = features,
       _entitlements = entitlements,
       _limits = limits;

  factory _$SubscriptionMeResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionMeResponseDtoImplFromJson(json);

  @override
  final String planMode;
  @override
  final String? planTier;
  @override
  final String status;
  @override
  final String? billingInterval;
  final List<String> _features;
  @override
  @JsonKey()
  List<String> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

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
  final int lockedMonthlyAmountCents;
  @override
  final QuoteBreakdownDto? renewalQuote;
  final Map<String, bool> _entitlements;
  @override
  @JsonKey()
  Map<String, bool> get entitlements {
    if (_entitlements is EqualUnmodifiableMapView) return _entitlements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_entitlements);
  }

  final Map<String, dynamic> _limits;
  @override
  @JsonKey()
  Map<String, dynamic> get limits {
    if (_limits is EqualUnmodifiableMapView) return _limits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_limits);
  }

  @override
  String toString() {
    return 'SubscriptionMeResponseDto(planMode: $planMode, planTier: $planTier, status: $status, billingInterval: $billingInterval, features: $features, shopsIncluded: $shopsIncluded, shopsUsed: $shopsUsed, periodEnd: $periodEnd, lockedMonthlyAmountCents: $lockedMonthlyAmountCents, renewalQuote: $renewalQuote, entitlements: $entitlements, limits: $limits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionMeResponseDtoImpl &&
            (identical(other.planMode, planMode) ||
                other.planMode == planMode) &&
            (identical(other.planTier, planTier) ||
                other.planTier == planTier) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.billingInterval, billingInterval) ||
                other.billingInterval == billingInterval) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.shopsIncluded, shopsIncluded) ||
                other.shopsIncluded == shopsIncluded) &&
            (identical(other.shopsUsed, shopsUsed) ||
                other.shopsUsed == shopsUsed) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(
                  other.lockedMonthlyAmountCents,
                  lockedMonthlyAmountCents,
                ) ||
                other.lockedMonthlyAmountCents == lockedMonthlyAmountCents) &&
            (identical(other.renewalQuote, renewalQuote) ||
                other.renewalQuote == renewalQuote) &&
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
    planMode,
    planTier,
    status,
    billingInterval,
    const DeepCollectionEquality().hash(_features),
    shopsIncluded,
    shopsUsed,
    periodEnd,
    lockedMonthlyAmountCents,
    renewalQuote,
    const DeepCollectionEquality().hash(_entitlements),
    const DeepCollectionEquality().hash(_limits),
  );

  /// Create a copy of SubscriptionMeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionMeResponseDtoImplCopyWith<_$SubscriptionMeResponseDtoImpl>
  get copyWith =>
      __$$SubscriptionMeResponseDtoImplCopyWithImpl<
        _$SubscriptionMeResponseDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionMeResponseDtoImplToJson(this);
  }
}

abstract class _SubscriptionMeResponseDto implements SubscriptionMeResponseDto {
  const factory _SubscriptionMeResponseDto({
    required final String planMode,
    final String? planTier,
    required final String status,
    final String? billingInterval,
    final List<String> features,
    final int shopsIncluded,
    final int shopsUsed,
    final String? periodEnd,
    final int lockedMonthlyAmountCents,
    final QuoteBreakdownDto? renewalQuote,
    final Map<String, bool> entitlements,
    final Map<String, dynamic> limits,
  }) = _$SubscriptionMeResponseDtoImpl;

  factory _SubscriptionMeResponseDto.fromJson(Map<String, dynamic> json) =
      _$SubscriptionMeResponseDtoImpl.fromJson;

  @override
  String get planMode;
  @override
  String? get planTier;
  @override
  String get status;
  @override
  String? get billingInterval;
  @override
  List<String> get features;
  @override
  int get shopsIncluded;
  @override
  int get shopsUsed;
  @override
  String? get periodEnd;
  @override
  int get lockedMonthlyAmountCents;
  @override
  QuoteBreakdownDto? get renewalQuote;
  @override
  Map<String, bool> get entitlements;
  @override
  Map<String, dynamic> get limits;

  /// Create a copy of SubscriptionMeResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionMeResponseDtoImplCopyWith<_$SubscriptionMeResponseDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
