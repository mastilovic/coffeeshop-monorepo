package subscription_test

import (
	"context"
	"testing"

	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/repository"
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
	"github.com/mastilovic/coffeeshop-go/internal/testutil"
)

func setupPricingTest(t *testing.T) *subscription.PricingService {
	t.Helper()

	db := testutil.SetupTestDB(t)
	subRepo := repository.NewSubscriptionRepository(db)
	seedFullSubscriptionCatalog(t, db)
	return subscription.NewPricingService(subRepo)
}

func TestPricingService_GrowthPresetWithExtraShops(t *testing.T) {
	svc := setupPricingTest(t)
	ctx := context.Background()
	tier := model.PlanTierGrowth

	quote, err := svc.Quote(ctx, subscription.QuoteRequest{
		PlanMode:        model.PlanModePreset,
		PlanTier:        &tier,
		ShopCount:       3,
		BillingInterval: model.BillingIntervalMonthly,
	})
	if err != nil {
		t.Fatalf("Quote: %v", err)
	}

	if quote.BaseMonthlyCents != 2900 {
		t.Errorf("BaseMonthlyCents=%d, want 2900", quote.BaseMonthlyCents)
	}
	if quote.ExtraShopsCents != 3000 {
		t.Errorf("ExtraShopsCents=%d, want 3000 (2 × €15)", quote.ExtraShopsCents)
	}
	if quote.MonthlyTotalCents != 5900 {
		t.Errorf("MonthlyTotalCents=%d, want 5900 (€29 + 2×€15)", quote.MonthlyTotalCents)
	}
	if quote.FeaturesMonthlyCents != 0 {
		t.Errorf("FeaturesMonthlyCents=%d, want 0 for preset", quote.FeaturesMonthlyCents)
	}
}

func TestPricingService_CustomThreeFeatureSum(t *testing.T) {
	svc := setupPricingTest(t)
	ctx := context.Background()

	quote, err := svc.Quote(ctx, subscription.QuoteRequest{
		PlanMode: model.PlanModeCustom,
		Features: []string{
			"reservation_manage", // €8
			"event_create",       // €10
			"analytics",          // €15
		},
		ShopCount:       1,
		BillingInterval: model.BillingIntervalMonthly,
	})
	if err != nil {
		t.Fatalf("Quote: %v", err)
	}

	wantFeatures := 800 + 1000 + 1500
	if quote.FeaturesMonthlyCents != wantFeatures {
		t.Errorf("FeaturesMonthlyCents=%d, want %d", quote.FeaturesMonthlyCents, wantFeatures)
	}
	if quote.BaseMonthlyCents != 0 {
		t.Errorf("BaseMonthlyCents=%d, want 0 for custom", quote.BaseMonthlyCents)
	}
	if quote.MonthlyTotalCents != wantFeatures {
		t.Errorf("MonthlyTotalCents=%d, want %d", quote.MonthlyTotalCents, wantFeatures)
	}
	if len(quote.LineItems) != 3 {
		t.Fatalf("expected 3 feature line items, got %d", len(quote.LineItems))
	}
}

func TestPricingService_AnnualDiscount(t *testing.T) {
	svc := setupPricingTest(t)
	ctx := context.Background()
	tier := model.PlanTierGrowth

	quote, err := svc.Quote(ctx, subscription.QuoteRequest{
		PlanMode:        model.PlanModePreset,
		PlanTier:        &tier,
		ShopCount:       1,
		BillingInterval: model.BillingIntervalAnnual,
	})
	if err != nil {
		t.Fatalf("Quote: %v", err)
	}

	if quote.AnnualMonthsCharged != 10 {
		t.Errorf("AnnualMonthsCharged=%d, want 10", quote.AnnualMonthsCharged)
	}
	if quote.MonthlyTotalCents != 2900 {
		t.Errorf("MonthlyTotalCents=%d, want 2900", quote.MonthlyTotalCents)
	}
	if quote.AnnualTotalCents != 29000 {
		t.Errorf("AnnualTotalCents=%d, want 29000 (monthly × 10)", quote.AnnualTotalCents)
	}
}

func TestPricingService_StarterFree(t *testing.T) {
	svc := setupPricingTest(t)
	ctx := context.Background()
	tier := model.PlanTierStarter

	quote, err := svc.Quote(ctx, subscription.QuoteRequest{
		PlanMode:        model.PlanModePreset,
		PlanTier:        &tier,
		ShopCount:       1,
		BillingInterval: model.BillingIntervalMonthly,
	})
	if err != nil {
		t.Fatalf("Quote: %v", err)
	}

	if quote.MonthlyTotalCents != 0 {
		t.Errorf("MonthlyTotalCents=%d, want 0 for Starter", quote.MonthlyTotalCents)
	}
	if quote.BaseMonthlyCents != 0 {
		t.Errorf("BaseMonthlyCents=%d, want 0", quote.BaseMonthlyCents)
	}
	if quote.ExtraShopsCents != 0 {
		t.Errorf("ExtraShopsCents=%d, want 0 (Starter has no extra shop price)", quote.ExtraShopsCents)
	}
}

func TestPricingService_ProWithExtraShops(t *testing.T) {
	svc := setupPricingTest(t)
	ctx := context.Background()
	tier := model.PlanTierPro

	quote, err := svc.Quote(ctx, subscription.QuoteRequest{
		PlanMode:        model.PlanModePreset,
		PlanTier:        &tier,
		ShopCount:       4,
		BillingInterval: model.BillingIntervalMonthly,
	})
	if err != nil {
		t.Fatalf("Quote: %v", err)
	}

	if quote.BaseMonthlyCents != 7900 {
		t.Errorf("BaseMonthlyCents=%d, want 7900", quote.BaseMonthlyCents)
	}
	if quote.ExtraShopsCents != 3000 {
		t.Errorf("ExtraShopsCents=%d, want 3000 (3 × €10)", quote.ExtraShopsCents)
	}
	if quote.MonthlyTotalCents != 10900 {
		t.Errorf("MonthlyTotalCents=%d, want 10900 (€79 + 3×€10)", quote.MonthlyTotalCents)
	}
}

func TestPricingService_CustomUsesGrowthExtraShopDefaults(t *testing.T) {
	svc := setupPricingTest(t)
	ctx := context.Background()

	quote, err := svc.Quote(ctx, subscription.QuoteRequest{
		PlanMode: model.PlanModeCustom,
		Features: []string{"community_post"},
		ShopCount:       2,
		BillingInterval: model.BillingIntervalAnnual,
	})
	if err != nil {
		t.Fatalf("Quote: %v", err)
	}

	if quote.FeaturesMonthlyCents != 500 {
		t.Errorf("FeaturesMonthlyCents=%d, want 500", quote.FeaturesMonthlyCents)
	}
	if quote.ExtraShopsCents != 1500 {
		t.Errorf("ExtraShopsCents=%d, want 1500 (Growth default €15)", quote.ExtraShopsCents)
	}
	if quote.AnnualMonthsCharged != 10 {
		t.Errorf("AnnualMonthsCharged=%d, want 10 (Growth default)", quote.AnnualMonthsCharged)
	}
	if quote.MonthlyTotalCents != 2000 {
		t.Errorf("MonthlyTotalCents=%d, want 2000", quote.MonthlyTotalCents)
	}
	if quote.AnnualTotalCents != 20000 {
		t.Errorf("AnnualTotalCents=%d, want 20000", quote.AnnualTotalCents)
	}
}

func TestPricingService_ComputeLockedMonthlyAmountCents(t *testing.T) {
	svc := setupPricingTest(t)
	ctx := context.Background()
	tier := model.PlanTierGrowth

	req := subscription.QuoteRequest{
		PlanMode:        model.PlanModePreset,
		PlanTier:        &tier,
		ShopCount:       3,
		BillingInterval: model.BillingIntervalMonthly,
	}

	locked, err := svc.ComputeLockedMonthlyAmountCents(ctx, req)
	if err != nil {
		t.Fatalf("ComputeLockedMonthlyAmountCents: %v", err)
	}
	if locked != 5900 {
		t.Errorf("locked amount=%d, want 5900", locked)
	}

	quote, err := svc.Quote(ctx, req)
	if err != nil {
		t.Fatalf("Quote: %v", err)
	}
	if locked != quote.MonthlyTotalCents {
		t.Errorf("locked amount %d != MonthlyTotalCents %d", locked, quote.MonthlyTotalCents)
	}
}
