// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatalogTierDtoImpl _$$CatalogTierDtoImplFromJson(Map<String, dynamic> json) =>
    _$CatalogTierDtoImpl(
      tier: json['tier'] as String,
      displayName: json['displayName'] as String,
      basePriceMonthlyCents: (json['basePriceMonthlyCents'] as num).toInt(),
      extraShopPriceCents: (json['extraShopPriceCents'] as num?)?.toInt(),
      annualMonthsCharged: (json['annualMonthsCharged'] as num?)?.toInt() ?? 12,
      isActive: json['isActive'] as bool? ?? true,
      includedFeatures:
          (json['includedFeatures'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CatalogTierDtoImplToJson(
  _$CatalogTierDtoImpl instance,
) => <String, dynamic>{
  'tier': instance.tier,
  'displayName': instance.displayName,
  'basePriceMonthlyCents': instance.basePriceMonthlyCents,
  'extraShopPriceCents': instance.extraShopPriceCents,
  'annualMonthsCharged': instance.annualMonthsCharged,
  'isActive': instance.isActive,
  'includedFeatures': instance.includedFeatures,
};

_$FeatureCatalogItemDtoImpl _$$FeatureCatalogItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$FeatureCatalogItemDtoImpl(
  featureKey: json['featureKey'] as String,
  displayName: json['displayName'] as String,
  description: json['description'] as String?,
  monthlyPriceCents: (json['monthlyPriceCents'] as num).toInt(),
  limitType: json['limitType'] as String?,
  limitValue: (json['limitValue'] as num?)?.toInt(),
  isSelectableCustom: json['isSelectableCustom'] as bool? ?? true,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$FeatureCatalogItemDtoImplToJson(
  _$FeatureCatalogItemDtoImpl instance,
) => <String, dynamic>{
  'featureKey': instance.featureKey,
  'displayName': instance.displayName,
  'description': instance.description,
  'monthlyPriceCents': instance.monthlyPriceCents,
  'limitType': instance.limitType,
  'limitValue': instance.limitValue,
  'isSelectableCustom': instance.isSelectableCustom,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};

_$CatalogResponseDtoImpl _$$CatalogResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CatalogResponseDtoImpl(
  tiers:
      (json['tiers'] as List<dynamic>?)
          ?.map((e) => CatalogTierDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  features:
      (json['features'] as List<dynamic>?)
          ?.map(
            (e) => FeatureCatalogItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$CatalogResponseDtoImplToJson(
  _$CatalogResponseDtoImpl instance,
) => <String, dynamic>{'tiers': instance.tiers, 'features': instance.features};

_$QuoteLineItemDtoImpl _$$QuoteLineItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$QuoteLineItemDtoImpl(
  key: json['key'] as String,
  label: json['label'] as String,
  amountCents: (json['amountCents'] as num).toInt(),
);

Map<String, dynamic> _$$QuoteLineItemDtoImplToJson(
  _$QuoteLineItemDtoImpl instance,
) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'amountCents': instance.amountCents,
};

_$QuoteBreakdownDtoImpl _$$QuoteBreakdownDtoImplFromJson(
  Map<String, dynamic> json,
) => _$QuoteBreakdownDtoImpl(
  baseMonthlyCents: (json['baseMonthlyCents'] as num?)?.toInt() ?? 0,
  extraShopsCents: (json['extraShopsCents'] as num?)?.toInt() ?? 0,
  featuresMonthlyCents: (json['featuresMonthlyCents'] as num?)?.toInt() ?? 0,
  monthlyTotalCents: (json['monthlyTotalCents'] as num?)?.toInt() ?? 0,
  annualTotalCents: (json['annualTotalCents'] as num?)?.toInt() ?? 0,
  annualMonthsCharged: (json['annualMonthsCharged'] as num?)?.toInt() ?? 12,
  lineItems:
      (json['lineItems'] as List<dynamic>?)
          ?.map((e) => QuoteLineItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$QuoteBreakdownDtoImplToJson(
  _$QuoteBreakdownDtoImpl instance,
) => <String, dynamic>{
  'baseMonthlyCents': instance.baseMonthlyCents,
  'extraShopsCents': instance.extraShopsCents,
  'featuresMonthlyCents': instance.featuresMonthlyCents,
  'monthlyTotalCents': instance.monthlyTotalCents,
  'annualTotalCents': instance.annualTotalCents,
  'annualMonthsCharged': instance.annualMonthsCharged,
  'lineItems': instance.lineItems,
};

_$SubscriptionMeResponseDtoImpl _$$SubscriptionMeResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionMeResponseDtoImpl(
  planMode: json['planMode'] as String,
  planTier: json['planTier'] as String?,
  status: json['status'] as String,
  billingInterval: json['billingInterval'] as String?,
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  shopsIncluded: (json['shopsIncluded'] as num?)?.toInt() ?? 1,
  shopsUsed: (json['shopsUsed'] as num?)?.toInt() ?? 0,
  periodEnd: json['periodEnd'] as String?,
  lockedMonthlyAmountCents:
      (json['lockedMonthlyAmountCents'] as num?)?.toInt() ?? 0,
  renewalQuote: json['renewalQuote'] == null
      ? null
      : QuoteBreakdownDto.fromJson(
          json['renewalQuote'] as Map<String, dynamic>,
        ),
  entitlements:
      (json['entitlements'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  limits: json['limits'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$SubscriptionMeResponseDtoImplToJson(
  _$SubscriptionMeResponseDtoImpl instance,
) => <String, dynamic>{
  'planMode': instance.planMode,
  'planTier': instance.planTier,
  'status': instance.status,
  'billingInterval': instance.billingInterval,
  'features': instance.features,
  'shopsIncluded': instance.shopsIncluded,
  'shopsUsed': instance.shopsUsed,
  'periodEnd': instance.periodEnd,
  'lockedMonthlyAmountCents': instance.lockedMonthlyAmountCents,
  'renewalQuote': instance.renewalQuote,
  'entitlements': instance.entitlements,
  'limits': instance.limits,
};
