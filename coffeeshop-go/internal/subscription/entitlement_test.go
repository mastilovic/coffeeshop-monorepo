package subscription_test

import (
	"context"
	"testing"

	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/repository"
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
	"github.com/mastilovic/coffeeshop-go/internal/testutil"
	"gorm.io/gorm"
)

const (
	starterOwnerID  = "11111111-1111-1111-1111-111111111101"
	growthOwnerID   = "11111111-1111-1111-1111-111111111102"
	proOwnerID      = "11111111-1111-1111-1111-111111111103"
	customOwnerID   = "11111111-1111-1111-1111-111111111104"
	employeeUserID  = "11111111-1111-1111-1111-111111111105"
	starterShopID   = "22222222-2222-2222-2222-222222222201"
	growthShopID    = "22222222-2222-2222-2222-222222222202"
	proShopID       = "22222222-2222-2222-2222-222222222203"
	customShopID    = "22222222-2222-2222-2222-222222222204"
	employeeShopID  = "22222222-2222-2222-2222-222222222205"
)

func setupEntitlementTest(t *testing.T) (*gorm.DB, *subscription.EntitlementService) {
	t.Helper()

	db := testutil.SetupTestDB(t)
	subRepo := repository.NewSubscriptionRepository(db)
	svc := subscription.NewEntitlementService(db, subRepo)

	seedUsersAndShops(t, db)
	seedFullSubscriptionCatalog(t, db)
	seedOwnerSubscriptions(t, db)

	return db, svc
}

func seedUsersAndShops(t *testing.T, db *gorm.DB) {
	t.Helper()

	users := []struct {
		id, name, username, email string
	}{
		{starterOwnerID, "Starter Owner", "starter-owner", "starter@test.com"},
		{growthOwnerID, "Growth Owner", "growth-owner", "growth@test.com"},
		{proOwnerID, "Pro Owner", "pro-owner", "pro@test.com"},
		{customOwnerID, "Custom Owner", "custom-owner", "custom@test.com"},
		{employeeUserID, "Employee", "employee", "employee@test.com"},
	}
	for _, u := range users {
		db.Exec(`INSERT INTO users (id, name, username, email, password, user_type) VALUES (?, ?, ?, ?, 'hash', 'SHOP_OWNER')`,
			u.id, u.name, u.username, u.email)
	}

	shops := []struct{ id, name string }{
		{starterShopID, "Starter Shop"},
		{growthShopID, "Growth Shop"},
		{proShopID, "Pro Shop"},
		{customShopID, "Custom Shop"},
		{employeeShopID, "Employee Shop"},
	}
	for _, s := range shops {
		db.Exec(`INSERT INTO shop (id, name) VALUES (?, ?)`, s.id, s.name)
	}

	links := []model.UserShop{
		{ID: "us-01", UserID: starterOwnerID, ShopID: starterShopID, RelationshipType: model.RelationshipTypeOwner},
		{ID: "us-02", UserID: growthOwnerID, ShopID: growthShopID, RelationshipType: model.RelationshipTypeOwner},
		{ID: "us-03", UserID: proOwnerID, ShopID: proShopID, RelationshipType: model.RelationshipTypeOwner},
		{ID: "us-04", UserID: customOwnerID, ShopID: customShopID, RelationshipType: model.RelationshipTypeOwner},
		{ID: "us-05", UserID: growthOwnerID, ShopID: employeeShopID, RelationshipType: model.RelationshipTypeOwner},
		{ID: "us-06", UserID: employeeUserID, ShopID: employeeShopID, RelationshipType: model.RelationshipTypeEmployee},
	}
	if err := db.Create(&links).Error; err != nil {
		t.Fatalf("seed user_shop links: %v", err)
	}
}

func seedFullSubscriptionCatalog(t *testing.T, db *gorm.DB) {
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
		{FeatureKey: "reservation_manage", DisplayName: "Reservation management", MonthlyPriceCents: 800, SortOrder: 10, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "event_create", DisplayName: "Events", MonthlyPriceCents: 1000, LimitType: strPtr("monthly_per_shop"), LimitValue: intPtr(5), SortOrder: 20, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "employee_assign", DisplayName: "Employees", MonthlyPriceCents: 600, LimitType: strPtr("per_shop"), LimitValue: intPtr(3), SortOrder: 30, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "community_post", DisplayName: "Community posts", MonthlyPriceCents: 500, SortOrder: 40, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "loyalty_basic", DisplayName: "Loyalty (Basic)", MonthlyPriceCents: 1200, SortOrder: 50, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "loyalty_premium", DisplayName: "Loyalty (Premium/VIP)", MonthlyPriceCents: 2000, SortOrder: 60, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "review_moderate", DisplayName: "Review moderation", MonthlyPriceCents: 400, SortOrder: 70, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "dashboard_notifications", DisplayName: "Dashboard notifications", MonthlyPriceCents: 300, SortOrder: 80, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "analytics", DisplayName: "Analytics", MonthlyPriceCents: 1500, SortOrder: 90, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "unlimited_tables", DisplayName: "Unlimited tables", MonthlyPriceCents: 500, LimitType: strPtr("max_per_shop"), LimitValue: intPtr(15), SortOrder: 100, IsActive: true, IsSelectableCustom: true},
		{FeatureKey: "unlimited_menus", DisplayName: "Unlimited menus", MonthlyPriceCents: 500, LimitType: strPtr("max_per_shop"), LimitValue: intPtr(1), SortOrder: 110, IsActive: true, IsSelectableCustom: true},
	}
	if err := db.Create(&features).Error; err != nil {
		t.Fatalf("seed features: %v", err)
	}

	mappings := []model.PlanTierFeature{
		// Starter: no paid features
		{Tier: model.PlanTierStarter, FeatureKey: "reservation_manage", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "event_create", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "employee_assign", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "community_post", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "loyalty_basic", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "loyalty_premium", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "review_moderate", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "dashboard_notifications", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "analytics", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "unlimited_tables", Included: false},
		{Tier: model.PlanTierStarter, FeatureKey: "unlimited_menus", Included: false},

		// Growth: operations bundle without analytics or premium loyalty
		{Tier: model.PlanTierGrowth, FeatureKey: "reservation_manage", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "event_create", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "employee_assign", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "community_post", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "loyalty_basic", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "loyalty_premium", Included: false},
		{Tier: model.PlanTierGrowth, FeatureKey: "review_moderate", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "dashboard_notifications", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "analytics", Included: false},
		{Tier: model.PlanTierGrowth, FeatureKey: "unlimited_tables", Included: true},
		{Tier: model.PlanTierGrowth, FeatureKey: "unlimited_menus", Included: true},

		// Pro: all features
		{Tier: model.PlanTierPro, FeatureKey: "reservation_manage", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "event_create", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "employee_assign", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "community_post", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "loyalty_basic", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "loyalty_premium", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "review_moderate", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "dashboard_notifications", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "analytics", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "unlimited_tables", Included: true},
		{Tier: model.PlanTierPro, FeatureKey: "unlimited_menus", Included: true},
	}
	if err := db.Create(&mappings).Error; err != nil {
		t.Fatalf("seed tier features: %v", err)
	}
}

func seedOwnerSubscriptions(t *testing.T, db *gorm.DB) {
	t.Helper()

	starterTier := model.PlanTierStarter
	growthTier := model.PlanTierGrowth
	proTier := model.PlanTierPro
	interval := model.BillingIntervalMonthly

	subs := []model.OwnerSubscription{
		{UserID: starterOwnerID, PlanMode: model.PlanModePreset, PlanTier: &starterTier, Status: model.SubscriptionStatusActive, BillingInterval: &interval},
		{UserID: growthOwnerID, PlanMode: model.PlanModePreset, PlanTier: &growthTier, Status: model.SubscriptionStatusActive, BillingInterval: &interval},
		{UserID: proOwnerID, PlanMode: model.PlanModePreset, PlanTier: &proTier, Status: model.SubscriptionStatusActive, BillingInterval: &interval},
		{UserID: customOwnerID, PlanMode: model.PlanModeCustom, Status: model.SubscriptionStatusActive},
	}
	if err := db.Create(&subs).Error; err != nil {
		t.Fatalf("seed owner subscriptions: %v", err)
	}

	customFeatures := []model.OwnerSubscriptionFeature{
		{UserID: customOwnerID, FeatureKey: "reservation_manage"},
		{UserID: customOwnerID, FeatureKey: "analytics"},
	}
	if err := db.Create(&customFeatures).Error; err != nil {
		t.Fatalf("seed custom features: %v", err)
	}
}

func intPtr(v int) *int { return &v }

func strPtr(v string) *string { return &v }

func mustParseUUID(t *testing.T, s string) uuid.UUID {
	t.Helper()
	id, err := uuid.Parse(s)
	if err != nil {
		t.Fatalf("parse uuid %q: %v", s, err)
	}
	return id
}

func TestEntitlementService_ResolveEntitlements(t *testing.T) {
	_, svc := setupEntitlementTest(t)
	ctx := context.Background()

	tests := []struct {
		name     string
		ownerID  string
		isAdmin  bool
		expected map[subscription.Feature]bool
	}{
		{
			name:    "starter owner has no paid features",
			ownerID: starterOwnerID,
			expected: map[subscription.Feature]bool{
				subscription.FeatureReservationManage:         false,
				subscription.FeatureEventCreate:               false,
				subscription.FeatureEmployeeAssign:            false,
				subscription.FeatureCommunityPost:             false,
				subscription.FeatureLoyaltyBasic:              false,
				subscription.FeatureLoyaltyPremium:            false,
				subscription.FeatureReviewModerate:            false,
				subscription.FeatureDashboardNotifications:    false,
				subscription.FeatureAnalytics:                 false,
				subscription.FeatureUnlimitedTables:           false,
				subscription.FeatureUnlimitedMenus:              false,
			},
		},
		{
			name:    "growth owner has operations bundle without analytics",
			ownerID: growthOwnerID,
			expected: map[subscription.Feature]bool{
				subscription.FeatureReservationManage:         true,
				subscription.FeatureEventCreate:               true,
				subscription.FeatureEmployeeAssign:            true,
				subscription.FeatureCommunityPost:             true,
				subscription.FeatureLoyaltyBasic:              true,
				subscription.FeatureLoyaltyPremium:            false,
				subscription.FeatureReviewModerate:            true,
				subscription.FeatureDashboardNotifications:    true,
				subscription.FeatureAnalytics:                 false,
				subscription.FeatureUnlimitedTables:           true,
				subscription.FeatureUnlimitedMenus:              true,
			},
		},
		{
			name:    "pro owner has all features",
			ownerID: proOwnerID,
			expected: map[subscription.Feature]bool{
				subscription.FeatureReservationManage:         true,
				subscription.FeatureEventCreate:               true,
				subscription.FeatureEmployeeAssign:            true,
				subscription.FeatureCommunityPost:             true,
				subscription.FeatureLoyaltyBasic:              true,
				subscription.FeatureLoyaltyPremium:            true,
				subscription.FeatureReviewModerate:            true,
				subscription.FeatureDashboardNotifications:    true,
				subscription.FeatureAnalytics:                 true,
				subscription.FeatureUnlimitedTables:           true,
				subscription.FeatureUnlimitedMenus:              true,
			},
		},
		{
			name:    "custom plan exposes only selected features",
			ownerID: customOwnerID,
			expected: map[subscription.Feature]bool{
				subscription.FeatureReservationManage:         true,
				subscription.FeatureEventCreate:               false,
				subscription.FeatureEmployeeAssign:            false,
				subscription.FeatureCommunityPost:             false,
				subscription.FeatureLoyaltyBasic:              false,
				subscription.FeatureLoyaltyPremium:            false,
				subscription.FeatureReviewModerate:            false,
				subscription.FeatureDashboardNotifications:    false,
				subscription.FeatureAnalytics:                 true,
				subscription.FeatureUnlimitedTables:           false,
				subscription.FeatureUnlimitedMenus:              false,
			},
		},
		{
			name:    "admin bypass grants all features",
			ownerID: starterOwnerID,
			isAdmin: true,
			expected: map[subscription.Feature]bool{
				subscription.FeatureReservationManage:         true,
				subscription.FeatureEventCreate:               true,
				subscription.FeatureEmployeeAssign:            true,
				subscription.FeatureCommunityPost:             true,
				subscription.FeatureLoyaltyBasic:              true,
				subscription.FeatureLoyaltyPremium:            true,
				subscription.FeatureReviewModerate:            true,
				subscription.FeatureDashboardNotifications:    true,
				subscription.FeatureAnalytics:                 true,
				subscription.FeatureUnlimitedTables:           true,
				subscription.FeatureUnlimitedMenus:              true,
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := svc.ResolveEntitlements(ctx, mustParseUUID(t, tt.ownerID), tt.isAdmin)
			if err != nil {
				t.Fatalf("ResolveEntitlements: %v", err)
			}
			for feature, want := range tt.expected {
				if got[feature] != want {
					t.Errorf("feature %s: got %v, want %v", feature, got[feature], want)
				}
			}
		})
	}
}

func TestEntitlementService_CanUse(t *testing.T) {
	_, svc := setupEntitlementTest(t)
	ctx := context.Background()

	tests := []struct {
		name      string
		userID    string
		shopID    string
		feature   subscription.Feature
		isAdmin   bool
		wantAllow bool
		wantHint  bool
		wantTier  *model.PlanTier
	}{
		{
			name:      "starter owner cannot manage reservations",
			userID:    starterOwnerID,
			shopID:    starterShopID,
			feature:   subscription.FeatureReservationManage,
			wantAllow: false,
			wantHint:  true,
			wantTier:  planTierPtr(model.PlanTierGrowth),
		},
		{
			name:      "growth owner can manage reservations",
			userID:    growthOwnerID,
			shopID:    growthShopID,
			feature:   subscription.FeatureReservationManage,
			wantAllow: true,
		},
		{
			name:      "growth owner cannot access analytics",
			userID:    growthOwnerID,
			shopID:    growthShopID,
			feature:   subscription.FeatureAnalytics,
			wantAllow: false,
			wantHint:  true,
			wantTier:  planTierPtr(model.PlanTierPro),
		},
		{
			name:      "pro owner can access analytics",
			userID:    proOwnerID,
			shopID:    proShopID,
			feature:   subscription.FeatureAnalytics,
			wantAllow: true,
		},
		{
			name:      "custom owner has selected feature only",
			userID:    customOwnerID,
			shopID:    customShopID,
			feature:   subscription.FeatureAnalytics,
			wantAllow: true,
		},
		{
			name:      "custom owner lacks unselected feature",
			userID:    customOwnerID,
			shopID:    customShopID,
			feature:   subscription.FeatureEventCreate,
			wantAllow: false,
			wantHint:  true,
			wantTier:  planTierPtr(model.PlanTierGrowth),
		},
		{
			name:      "admin bypass allows feature regardless of plan",
			userID:    starterOwnerID,
			shopID:    starterShopID,
			feature:   subscription.FeatureEventCreate,
			isAdmin:   true,
			wantAllow: true,
		},
		{
			name:      "employee inherits growth owner entitlements",
			userID:    employeeUserID,
			shopID:    employeeShopID,
			feature:   subscription.FeatureEventCreate,
			wantAllow: true,
		},
		{
			name:      "employee inherits owner denial for analytics",
			userID:    employeeUserID,
			shopID:    employeeShopID,
			feature:   subscription.FeatureAnalytics,
			wantAllow: false,
			wantHint:  true,
			wantTier:  planTierPtr(model.PlanTierPro),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			allowed, hint := svc.CanUse(ctx, mustParseUUID(t, tt.userID), mustParseUUID(t, tt.shopID), tt.feature, tt.isAdmin)
			if allowed != tt.wantAllow {
				t.Fatalf("CanUse allowed=%v, want %v (hint=%+v)", allowed, tt.wantAllow, hint)
			}
			if tt.wantHint {
				if hint == nil {
					t.Fatal("expected upgrade hint, got nil")
				}
				if len(hint.RequiredFeatures) != 1 || hint.RequiredFeatures[0] != tt.feature {
					t.Errorf("unexpected required features: %+v", hint.RequiredFeatures)
				}
				if tt.wantTier != nil {
					if hint.RequiredPlan == nil {
						t.Fatal("expected required plan in hint")
					}
					if *hint.RequiredPlan != *tt.wantTier {
						t.Errorf("required plan=%s, want %s", *hint.RequiredPlan, *tt.wantTier)
					}
				}
			} else if hint != nil {
				t.Errorf("unexpected upgrade hint: %+v", hint)
			}
		})
	}
}

func planTierPtr(tier model.PlanTier) *model.PlanTier {
	return &tier
}
