package subscription

import (
	"context"
	"fmt"

	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/repository"
)

const defaultAnnualMonthsCharged = 12

type PricingService struct {
	subRepo *repository.SubscriptionRepository
}

func NewPricingService(subRepo *repository.SubscriptionRepository) *PricingService {
	return &PricingService{subRepo: subRepo}
}

type QuoteRequest struct {
	PlanMode        model.PlanMode
	PlanTier        *model.PlanTier
	Features        []string
	ShopCount       int
	BillingInterval model.BillingInterval
}

type QuoteLineItem struct {
	Key         string `json:"key"`
	Label       string `json:"label"`
	AmountCents int    `json:"amountCents"`
}

type QuoteBreakdown struct {
	BaseMonthlyCents     int             `json:"baseMonthlyCents"`
	ExtraShopsCents      int             `json:"extraShopsCents"`
	FeaturesMonthlyCents int             `json:"featuresMonthlyCents"`
	MonthlyTotalCents    int             `json:"monthlyTotalCents"`
	AnnualTotalCents     int             `json:"annualTotalCents"`
	AnnualMonthsCharged  int             `json:"annualMonthsCharged"`
	LineItems            []QuoteLineItem `json:"lineItems"`
}

func (s *PricingService) Quote(ctx context.Context, req QuoteRequest) (*QuoteBreakdown, error) {
	if req.ShopCount < 1 {
		return nil, fmt.Errorf("shop count must be at least 1")
	}

	tierCatalog, err := s.loadTierCatalog(ctx)
	if err != nil {
		return nil, err
	}

	growthTier, ok := tierCatalog[model.PlanTierGrowth]
	if !ok {
		return nil, fmt.Errorf("growth tier not found in catalog")
	}

	var (
		baseCents        int
		featuresCents    int
		extraShopPrice   *int
		annualMonths     int
		lineItems        []QuoteLineItem
	)

	switch req.PlanMode {
	case model.PlanModePreset:
		if req.PlanTier == nil {
			return nil, fmt.Errorf("plan tier required for PRESET mode")
		}
		tier, ok := tierCatalog[*req.PlanTier]
		if !ok {
			return nil, fmt.Errorf("unknown plan tier: %s", *req.PlanTier)
		}
		baseCents = tier.BasePriceMonthlyCents
		extraShopPrice = tier.ExtraShopPriceCents
		annualMonths = tier.AnnualMonthsCharged
		if baseCents > 0 {
			lineItems = append(lineItems, QuoteLineItem{
				Key:         "base_plan",
				Label:       tier.DisplayName,
				AmountCents: baseCents,
			})
		}

	case model.PlanModeCustom:
		featuresCents, lineItems, err = s.sumCustomFeatures(ctx, req.Features)
		if err != nil {
			return nil, err
		}
		extraShopPrice = growthTier.ExtraShopPriceCents
		annualMonths = growthTier.AnnualMonthsCharged

	default:
		return nil, fmt.Errorf("unknown plan mode: %s", req.PlanMode)
	}

	if annualMonths <= 0 {
		annualMonths = defaultAnnualMonthsCharged
	}

	extraShops := max(0, req.ShopCount-1)
	extraShopUnit := 0
	if extraShopPrice != nil {
		extraShopUnit = *extraShopPrice
	}
	extraShopsCents := extraShops * extraShopUnit
	if extraShopsCents > 0 {
		lineItems = append(lineItems, QuoteLineItem{
			Key:         "extra_shops",
			Label:       fmt.Sprintf("Extra shops (%d)", extraShops),
			AmountCents: extraShopsCents,
		})
	}

	monthlyTotal := baseCents + featuresCents + extraShopsCents

	return &QuoteBreakdown{
		BaseMonthlyCents:     baseCents,
		ExtraShopsCents:      extraShopsCents,
		FeaturesMonthlyCents: featuresCents,
		MonthlyTotalCents:    monthlyTotal,
		AnnualTotalCents:     monthlyTotal * annualMonths,
		AnnualMonthsCharged:  annualMonths,
		LineItems:            lineItems,
	}, nil
}

func (s *PricingService) ComputeLockedMonthlyAmountCents(ctx context.Context, req QuoteRequest) (int, error) {
	breakdown, err := s.Quote(ctx, req)
	if err != nil {
		return 0, err
	}
	return breakdown.MonthlyTotalCents, nil
}

func (s *PricingService) loadTierCatalog(ctx context.Context) (map[model.PlanTier]model.PlanTierCatalog, error) {
	tiers, err := s.subRepo.ListPlanTiers(ctx)
	if err != nil {
		return nil, err
	}
	catalog := make(map[model.PlanTier]model.PlanTierCatalog, len(tiers))
	for _, tier := range tiers {
		catalog[tier.Tier] = tier
	}
	return catalog, nil
}

func (s *PricingService) sumCustomFeatures(ctx context.Context, featureKeys []string) (int, []QuoteLineItem, error) {
	if len(featureKeys) == 0 {
		return 0, nil, nil
	}

	catalog, err := s.subRepo.ListFeatures(ctx)
	if err != nil {
		return 0, nil, err
	}
	byKey := make(map[string]model.FeatureCatalog, len(catalog))
	for _, feature := range catalog {
		byKey[feature.FeatureKey] = feature
	}

	var (
		total     int
		lineItems []QuoteLineItem
	)
	for _, key := range featureKeys {
		feature, ok := byKey[key]
		if !ok {
			return 0, nil, fmt.Errorf("unknown feature: %s", key)
		}
		total += feature.MonthlyPriceCents
		lineItems = append(lineItems, QuoteLineItem{
			Key:         feature.FeatureKey,
			Label:       feature.DisplayName,
			AmountCents: feature.MonthlyPriceCents,
		})
	}
	return total, lineItems, nil
}
