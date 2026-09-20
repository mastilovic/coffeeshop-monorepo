// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_dto.freezed.dart';
part 'subscription_dto.g.dart';

@freezed
class CatalogTierDto with _$CatalogTierDto {
  const factory CatalogTierDto({
    required String tier,
    required String displayName,
    required int basePriceMonthlyCents,
    int? extraShopPriceCents,
    @Default(12) int annualMonthsCharged,
    @Default(true) bool isActive,
    @Default([]) List<String> includedFeatures,
  }) = _CatalogTierDto;

  factory CatalogTierDto.fromJson(Map<String, dynamic> json) =>
      _$CatalogTierDtoFromJson(json);
}

@freezed
class FeatureCatalogItemDto with _$FeatureCatalogItemDto {
  const factory FeatureCatalogItemDto({
    required String featureKey,
    required String displayName,
    String? description,
    required int monthlyPriceCents,
    String? limitType,
    int? limitValue,
    @Default(true) bool isSelectableCustom,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _FeatureCatalogItemDto;

  factory FeatureCatalogItemDto.fromJson(Map<String, dynamic> json) =>
      _$FeatureCatalogItemDtoFromJson(json);
}

@freezed
class CatalogResponseDto with _$CatalogResponseDto {
  const factory CatalogResponseDto({
    @Default([]) List<CatalogTierDto> tiers,
    @Default([]) List<FeatureCatalogItemDto> features,
  }) = _CatalogResponseDto;

  factory CatalogResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CatalogResponseDtoFromJson(json);
}

@freezed
class QuoteLineItemDto with _$QuoteLineItemDto {
  const factory QuoteLineItemDto({
    required String key,
    required String label,
    required int amountCents,
  }) = _QuoteLineItemDto;

  factory QuoteLineItemDto.fromJson(Map<String, dynamic> json) =>
      _$QuoteLineItemDtoFromJson(json);
}

@freezed
class QuoteBreakdownDto with _$QuoteBreakdownDto {
  const factory QuoteBreakdownDto({
    @Default(0) int baseMonthlyCents,
    @Default(0) int extraShopsCents,
    @Default(0) int featuresMonthlyCents,
    @Default(0) int monthlyTotalCents,
    @Default(0) int annualTotalCents,
    @Default(12) int annualMonthsCharged,
    @Default([]) List<QuoteLineItemDto> lineItems,
  }) = _QuoteBreakdownDto;

  factory QuoteBreakdownDto.fromJson(Map<String, dynamic> json) =>
      _$QuoteBreakdownDtoFromJson(json);
}

@freezed
class SubscriptionMeResponseDto with _$SubscriptionMeResponseDto {
  const factory SubscriptionMeResponseDto({
    required String planMode,
    String? planTier,
    required String status,
    String? billingInterval,
    @Default([]) List<String> features,
    @Default(1) int shopsIncluded,
    @Default(0) int shopsUsed,
    String? periodEnd,
    @Default(0) int lockedMonthlyAmountCents,
    QuoteBreakdownDto? renewalQuote,
    @Default({}) Map<String, bool> entitlements,
    @Default({}) Map<String, dynamic> limits,
  }) = _SubscriptionMeResponseDto;

  factory SubscriptionMeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionMeResponseDtoFromJson(json);
}

class QuoteRequestDto {
  const QuoteRequestDto({
    required this.planMode,
    this.planTier,
    this.features = const [],
    required this.shopCount,
    required this.billingInterval,
  });

  final String planMode;
  final String? planTier;
  final List<String> features;
  final int shopCount;
  final String billingInterval;

  Map<String, dynamic> toJson() => {
        'planMode': planMode,
        if (planTier != null) 'planTier': planTier,
        'features': features,
        'shopCount': shopCount,
        'billingInterval': billingInterval,
      };
}

class UpdatePlanRequestDto {
  const UpdatePlanRequestDto({
    required this.planMode,
    this.planTier,
    this.features = const [],
    required this.billingInterval,
  });

  final String planMode;
  final String? planTier;
  final List<String> features;
  final String billingInterval;

  Map<String, dynamic> toJson() => {
        'planMode': planMode,
        if (planTier != null) 'planTier': planTier,
        if (features.isNotEmpty) 'features': features,
        'billingInterval': billingInterval,
      };
}
