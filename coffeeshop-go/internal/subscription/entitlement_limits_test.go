package subscription_test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
	"gorm.io/gorm"
)

func seedTables(t *testing.T, db *gorm.DB, shopID string, count int) {
	t.Helper()
	for i := 1; i <= count; i++ {
		id := fmt.Sprintf("33333333-3333-3333-3333-%012d", i)
		if err := db.Exec(
			`INSERT INTO tables (id, number, capacity, shop_id) VALUES (?, ?, 4, ?)`,
			id, i, shopID,
		).Error; err != nil {
			t.Fatalf("seed table %d: %v", i, err)
		}
	}
}

func seedEmployees(t *testing.T, db *gorm.DB, shopID string, count int) {
	t.Helper()
	for i := 1; i <= count; i++ {
		userID := fmt.Sprintf("44444444-4444-4444-4444-%012d", i)
		linkID := fmt.Sprintf("emp-%03d", i)
		if err := db.Exec(
			`INSERT INTO users (id, name, username, email, password, user_type) VALUES (?, ?, ?, ?, 'hash', 'SHOP_OWNER')`,
			userID, fmt.Sprintf("Employee %d", i), fmt.Sprintf("emp%d", i), fmt.Sprintf("emp%d@test.com", i),
		).Error; err != nil {
			t.Fatalf("seed employee user %d: %v", i, err)
		}
		if err := db.Exec(
			`INSERT INTO user_shop (id, user_id, shop_id, relationship_type) VALUES (?, ?, ?, ?)`,
			linkID, userID, shopID, model.RelationshipTypeEmployee,
		).Error; err != nil {
			t.Fatalf("seed employee link %d: %v", i, err)
		}
	}
}

func seedShopSubscriptions(t *testing.T, db *gorm.DB, ownerID string, shopIDs []string) {
	t.Helper()
	rows := make([]model.ShopSubscription, len(shopIDs))
	for i, shopID := range shopIDs {
		rows[i] = model.ShopSubscription{
			ShopID:      shopID,
			OwnerUserID: ownerID,
			IsBaseShop:  i == 0,
		}
	}
	if err := db.Create(&rows).Error; err != nil {
		t.Fatalf("seed shop subscriptions: %v", err)
	}
}

func seedEventUsage(t *testing.T, db *gorm.DB, shopID string, eventsCreated int) {
	t.Helper()
	period := currentMonthPeriodStart()
	usage := model.ShopUsage{
		ShopID:        shopID,
		PeriodStart:   period,
		EventsCreated: eventsCreated,
	}
	if err := db.Create(&usage).Error; err != nil {
		t.Fatalf("seed shop usage: %v", err)
	}
}

func currentMonthPeriodStart() time.Time {
	now := time.Now().UTC()
	return time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
}

func TestEntitlementService_CheckLimit(t *testing.T) {
	ctx := context.Background()

	t.Run("starter at 15 tables is at cap", func(t *testing.T) {
		db, svc := setupEntitlementTest(t)
		seedTables(t, db, starterShopID, 15)

		used, max, ok, hint := svc.CheckLimit(ctx, mustParseUUID(t, starterOwnerID), mustParseUUID(t, starterShopID), subscription.LimitTables, false)
		if ok {
			t.Fatal("expected ok=false at table cap")
		}
		if used != 15 || max != 15 {
			t.Errorf("used=%d max=%d, want 15/15", used, max)
		}
		if hint == nil || hint.RequiredPlan == nil || *hint.RequiredPlan != model.PlanTierGrowth {
			t.Errorf("expected Growth upgrade hint, got %+v", hint)
		}
	})

	t.Run("starter 16th table is over cap", func(t *testing.T) {
		db, svc := setupEntitlementTest(t)
		seedTables(t, db, starterShopID, 16)

		used, max, ok, _ := svc.CheckLimit(ctx, mustParseUUID(t, starterOwnerID), mustParseUUID(t, starterShopID), subscription.LimitTables, false)
		if ok {
			t.Fatal("expected ok=false over table cap")
		}
		if used != 16 || max != 15 {
			t.Errorf("used=%d max=%d, want 16/15", used, max)
		}
	})

	t.Run("pro unlimited tables always ok", func(t *testing.T) {
		db, svc := setupEntitlementTest(t)
		seedTables(t, db, proShopID, 25)

		used, max, ok, hint := svc.CheckLimit(ctx, mustParseUUID(t, proOwnerID), mustParseUUID(t, proShopID), subscription.LimitTables, false)
		if !ok {
			t.Fatalf("expected ok=true for pro unlimited tables, used=%d max=%d hint=%+v", used, max, hint)
		}
		if max != -1 {
			t.Errorf("max=%d, want -1 unlimited sentinel", max)
		}
		if used != 25 {
			t.Errorf("used=%d, want 25", used)
		}
	})

	t.Run("growth at 5 events blocks 6th", func(t *testing.T) {
		db, svc := setupEntitlementTest(t)
		seedEventUsage(t, db, growthShopID, 5)

		used, max, ok, _ := svc.CheckLimit(ctx, mustParseUUID(t, growthOwnerID), mustParseUUID(t, growthShopID), subscription.LimitEvents, false)
		if ok {
			t.Fatal("expected ok=false at event cap")
		}
		if used != 5 || max != 5 {
			t.Errorf("used=%d max=%d, want 5/5", used, max)
		}
	})

	t.Run("growth 4th employee fails", func(t *testing.T) {
		db, svc := setupEntitlementTest(t)
		seedEmployees(t, db, growthShopID, 3)

		used, max, ok, _ := svc.CheckLimit(ctx, mustParseUUID(t, growthOwnerID), mustParseUUID(t, growthShopID), subscription.LimitEmployees, false)
		if ok {
			t.Fatal("expected ok=false at employee cap")
		}
		if used != 3 || max != 3 {
			t.Errorf("used=%d max=%d, want 3/3", used, max)
		}
	})

	t.Run("starter 2nd shop fails", func(t *testing.T) {
		extraShopID := "22222222-2222-2222-2222-222222222299"
		db, svc := setupEntitlementTest(t)
		if err := db.Exec(`INSERT INTO shop (id, name) VALUES (?, ?)`, extraShopID, "Extra Shop").Error; err != nil {
			t.Fatalf("seed extra shop: %v", err)
		}
		seedShopSubscriptions(t, db, starterOwnerID, []string{starterShopID, extraShopID})

		used, max, ok, hint := svc.CheckLimit(ctx, mustParseUUID(t, starterOwnerID), mustParseUUID(t, starterShopID), subscription.LimitShops, false)
		if ok {
			t.Fatal("expected ok=false for starter second shop")
		}
		if used != 2 || max != 1 {
			t.Errorf("used=%d max=%d, want 2/1", used, max)
		}
		if hint == nil || hint.RequiredPlan == nil || *hint.RequiredPlan != model.PlanTierGrowth {
			t.Errorf("expected Growth upgrade hint, got %+v", hint)
		}
	})

	t.Run("admin bypass is unlimited", func(t *testing.T) {
		_, svc := setupEntitlementTest(t)

		used, max, ok, hint := svc.CheckLimit(ctx, mustParseUUID(t, starterOwnerID), mustParseUUID(t, starterShopID), subscription.LimitTables, true)
		if !ok || max != -1 || hint != nil {
			t.Fatalf("admin bypass: ok=%v max=%d hint=%+v, want ok=true max=-1 hint=nil", ok, max, hint)
		}
		if used != 0 {
			t.Errorf("admin bypass used=%d, want 0", used)
		}
	})
}
