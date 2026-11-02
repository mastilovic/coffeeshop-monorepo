package repository_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/repository"
	"github.com/mastilovic/coffeeshop-go/internal/testutil"
	"gorm.io/gorm"
)

const (
	testOwnerID  = "11111111-1111-1111-1111-111111111101"
	testShopID   = "22222222-2222-2222-2222-222222222201"
	testShopID2  = "22222222-2222-2222-2222-222222222202"
	testPeriod   = "2026-07-01"
)

func setupSubscriptionTest(t *testing.T) (*gorm.DB, *repository.SubscriptionRepository) {
	t.Helper()

	db := testutil.SetupTestDB(t)
	repo := repository.NewSubscriptionRepository(db)

	db.Exec(`INSERT INTO users (id, name, username, email, password, user_type) VALUES (?, 'Owner', 'owner', 'owner@test.com', 'hash', 'SHOP_OWNER')`, testOwnerID)
	db.Exec(`INSERT INTO shop (id, name) VALUES (?, 'Test Shop')`, testShopID)
	db.Exec(`INSERT INTO shop (id, name) VALUES (?, 'Second Shop')`, testShopID2)

	seedSubscriptionCatalog(t, db)

	return db, repo
}

func seedSubscriptionCatalog(t *testing.T, db *gorm.DB) {
	t.Helper()

	tiers := []model.PlanTierCatalog{
		{Tier: model.PlanTierStarter, DisplayName: "Starter", BasePriceMonthlyCents: 0, AnnualMonthsCharged: 12, IsActive: true},
		{Tier: model.PlanTierGrowth, DisplayName: "Growth", BasePriceMonthlyCents: 2900, ExtraShopPriceCents: intPtr(1500), AnnualMonthsCharged: 10, IsActive: true},
		{Tier: model.PlanTierPro, DisplayName: "Pro", BasePriceMonthlyCents: 7900, ExtraShopPriceCents: intPtr(1000), AnnualMonthsCharged: 10, IsActive: true},
	}
	if err := db.Create(&tiers).Error; err != nil {
		t.Fatalf("seed tiers: %v", err)
	}

	features := []model.FeatureCatalog{
		{FeatureKey: "event_create", DisplayName: "Events", MonthlyPriceCents: 1000, SortOrder: 20, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "reservation_manage", DisplayName: "Reservation management", MonthlyPriceCents: 800, SortOrder: 10, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "analytics", DisplayName: "Analytics", MonthlyPriceCents: 1500, SortOrder: 90, IsActive: true, IsSelectableCustom: true},
	}
	if err := db.Create(&features).Error; err != nil {
		t.Fatalf("seed features: %v", err)
	}

	mappings := []model.PlanTierFeature{
		{Tier: model.PlanTierGrowth, FeatureKey: "reservation_manage", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "event_create", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "analytics", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "reservation_manage", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "event_create", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "analytics", Included: false},
	}
	if err := db.Create(&mappings).Error; err != nil {
		t.Fatalf("seed tier features: %v", err)
	}
}

func intPtr(v int) *int { return &v }

func TestSubscriptionRepository_ListPlanTiers(t *testing.T) {
	_, repo := setupSubscriptionTest(t)
	ctx := context.Background()

	tiers, err := repo.ListPlanTiers(ctx)
	if err != nil {
		t.Fatalf("ListPlanTiers: %v", err)
	}
	if len(tiers) != 3 {
		t.Fatalf("expected 3 tiers, got %d", len(tiers))
	}
	if tiers[0].Tier != model.PlanTierGrowth {
		t.Errorf("expected tiers ordered by tier, got first=%s", tiers[0].Tier)
	}
}

func TestSubscriptionRepository_ListFeatures(t *testing.T) {
	_, repo := setupSubscriptionTest(t)
	ctx := context.Background()

	features, err := repo.ListFeatures(ctx)
	if err != nil {
		t.Fatalf("ListFeatures: %v", err)
	}
	if len(features) != 3 {
		t.Fatalf("expected 3 features, got %d", len(features))
	}
	if features[0].FeatureKey != "reservation_manage" {
		t.Errorf("expected sort_order ordering, got first=%s", features[0].FeatureKey)
	}
}

func TestSubscriptionRepository_ListPlanTierFeatures(t *testing.T) {
	_, repo := setupSubscriptionTest(t)
	ctx := context.Background()

	mappings, err := repo.ListPlanTierFeatures(ctx, model.PlanTierGrowth)
	if err != nil {
		t.Fatalf("ListPlanTierFeatures: %v", err)
	}
	if len(mappings) != 3 {
		t.Fatalf("expected 3 mappings for GROWTH, got %d", len(mappings))
	}

	byKey := make(map[string]bool, len(mappings))
	for _, m := range mappings {
		byKey[m.FeatureKey] = m.Included
	}
	if !byKey["reservation_manage"] || !byKey["event_create"] || byKey["analytics"] {
		t.Errorf("unexpected GROWTH feature matrix: %+v", byKey)
	}
}

func TestSubscriptionRepository_OwnerSubscriptionCRUD(t *testing.T) {
	_, repo := setupSubscriptionTest(t)
	ctx := context.Background()

	tier := model.PlanTierGrowth
	interval := model.BillingIntervalMonthly
	sub := &model.OwnerSubscription{
		UserID:          testOwnerID,
		PlanMode:        model.PlanModePreset,
		PlanTier:        &tier,
		Status:          model.SubscriptionStatusActive,
		BillingInterval: &interval,
	}

	if err := repo.CreateOwnerSubscription(ctx, sub); err != nil {
		t.Fatalf("CreateOwnerSubscription: %v", err)
	}

	got, err := repo.GetOwnerSubscription(ctx, testOwnerID)
	if err != nil {
		t.Fatalf("GetOwnerSubscription: %v", err)
	}
	if got.PlanMode != model.PlanModePreset || *got.PlanTier != model.PlanTierGrowth {
		t.Errorf("unexpected subscription after create: %+v", got)
	}

	got.Status = model.SubscriptionStatusTrialing
	locked := 2900
	got.LockedMonthlyAmountCents = &locked
	if err := repo.UpdateOwnerSubscription(ctx, got); err != nil {
		t.Fatalf("UpdateOwnerSubscription: %v", err)
	}

	updated, err := repo.GetOwnerSubscription(ctx, testOwnerID)
	if err != nil {
		t.Fatalf("GetOwnerSubscription after update: %v", err)
	}
	if updated.Status != model.SubscriptionStatusTrialing {
		t.Errorf("expected status trialing, got %s", updated.Status)
	}
	if updated.LockedMonthlyAmountCents == nil || *updated.LockedMonthlyAmountCents != 2900 {
		t.Errorf("expected locked amount 2900, got %+v", updated.LockedMonthlyAmountCents)
	}
}

func TestSubscriptionRepository_OwnerSubscriptionFeatures(t *testing.T) {
	_, repo := setupSubscriptionTest(t)
	ctx := context.Background()

	sub := &model.OwnerSubscription{
		UserID:   testOwnerID,
		PlanMode: model.PlanModeCustom,
		Status:   model.SubscriptionStatusActive,
	}
	if err := repo.CreateOwnerSubscription(ctx, sub); err != nil {
		t.Fatalf("CreateOwnerSubscription: %v", err)
	}

	if err := repo.SetOwnerSubscriptionFeatures(ctx, testOwnerID, []string{"event_create", "analytics"}); err != nil {
		t.Fatalf("SetOwnerSubscriptionFeatures: %v", err)
	}

	features, err := repo.GetOwnerSubscriptionFeatures(ctx, testOwnerID)
	if err != nil {
		t.Fatalf("GetOwnerSubscriptionFeatures: %v", err)
	}
	if len(features) != 2 {
		t.Fatalf("expected 2 features, got %d", len(features))
	}

	if err := repo.SetOwnerSubscriptionFeatures(ctx, testOwnerID, []string{"reservation_manage"}); err != nil {
		t.Fatalf("SetOwnerSubscriptionFeatures replace: %v", err)
	}

	features, err = repo.GetOwnerSubscriptionFeatures(ctx, testOwnerID)
	if err != nil {
		t.Fatalf("GetOwnerSubscriptionFeatures after replace: %v", err)
	}
	if len(features) != 1 || features[0].FeatureKey != "reservation_manage" {
		t.Errorf("expected single reservation_manage feature, got %+v", features)
	}

	if err := repo.SetOwnerSubscriptionFeatures(ctx, testOwnerID, nil); err != nil {
		t.Fatalf("SetOwnerSubscriptionFeatures clear: %v", err)
	}
	features, err = repo.GetOwnerSubscriptionFeatures(ctx, testOwnerID)
	if err != nil {
		t.Fatalf("GetOwnerSubscriptionFeatures after clear: %v", err)
	}
	if len(features) != 0 {
		t.Errorf("expected 0 features after clear, got %d", len(features))
	}
}

func TestSubscriptionRepository_ShopSubscription(t *testing.T) {
	db, repo := setupSubscriptionTest(t)
	ctx := context.Background()

	subs := []model.ShopSubscription{
		{ShopID: testShopID, OwnerUserID: testOwnerID, IsBaseShop: true},
		{ShopID: testShopID2, OwnerUserID: testOwnerID, IsBaseShop: false},
	}
	if err := db.Create(&subs).Error; err != nil {
		t.Fatalf("create shop subscriptions: %v", err)
	}

	byOwner, err := repo.ListShopSubscriptionsByOwner(ctx, testOwnerID)
	if err != nil {
		t.Fatalf("ListShopSubscriptionsByOwner: %v", err)
	}
	if len(byOwner) != 2 {
		t.Fatalf("expected 2 shop subscriptions, got %d", len(byOwner))
	}
	if !byOwner[0].IsBaseShop {
		t.Errorf("expected first shop to be base shop")
	}

	one, err := repo.GetShopSubscriptionByShopID(ctx, testShopID2)
	if err != nil {
		t.Fatalf("GetShopSubscriptionByShopID: %v", err)
	}
	if one.OwnerUserID != testOwnerID || one.IsBaseShop {
		t.Errorf("unexpected shop subscription: %+v", one)
	}
}

func TestSubscriptionRepository_ShopUsage(t *testing.T) {
	_, repo := setupSubscriptionTest(t)
	ctx := context.Background()
	period, _ := time.ParseInLocation("2006-01-02", testPeriod, time.UTC)

	_, err := repo.GetShopUsage(ctx, testShopID, period)
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		t.Fatalf("expected not found before increment, got %v", err)
	}

	usage, err := repo.IncrementEventsCreated(ctx, testShopID, period)
	if err != nil {
		t.Fatalf("IncrementEventsCreated first: %v", err)
	}
	if usage.EventsCreated != 1 {
		t.Errorf("expected events_created=1, got %d", usage.EventsCreated)
	}

	usage, err = repo.IncrementEventsCreated(ctx, testShopID, period)
	if err != nil {
		t.Fatalf("IncrementEventsCreated second: %v", err)
	}
	if usage.EventsCreated != 2 {
		t.Errorf("expected events_created=2, got %d", usage.EventsCreated)
	}

	got, err := repo.GetShopUsage(ctx, testShopID, period)
	if err != nil {
		t.Fatalf("GetShopUsage: %v", err)
	}
	if got.EventsCreated != 2 {
		t.Errorf("expected persisted events_created=2, got %d", got.EventsCreated)
	}
}
