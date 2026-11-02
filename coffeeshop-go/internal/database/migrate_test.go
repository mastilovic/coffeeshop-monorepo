package database

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/lib/pq"
	tcpostgres "github.com/testcontainers/testcontainers-go/modules/postgres"
)

const (
	testOwner1ID    = "11111111-1111-1111-1111-111111111101"
	testOwner2ID    = "11111111-1111-1111-1111-111111111102"
	testCustomerID  = "11111111-1111-1111-1111-111111111103"
	testAdminID     = "11111111-1111-1111-1111-111111111104"
	testOwner1ShopA = "22222222-2222-2222-2222-222222222201"
	testOwner1ShopB = "22222222-2222-2222-2222-222222222202"
	testOwner2Shop  = "22222222-2222-2222-2222-222222222203"
	testUserShop1A  = "33333333-3333-3333-3333-333333333301"
	testUserShop1B  = "33333333-3333-3333-3333-333333333302"
	testUserShop2   = "33333333-3333-3333-3333-333333333303"
)

func TestOwnerSubscriptionsMigration_UpAndDown(t *testing.T) {
	ctx := context.Background()
	connStr := startPostgres(t, ctx)
	migrationsPath := migrationsDir(t)

	if err := runMigrationsTo(connStr, migrationsPath, 2); err != nil {
		t.Fatalf("migrate up to v2: %v", err)
	}

	db := openDB(t, connStr)
	defer db.Close()

	assertSeedRowCounts(t, db)
	assertTierFeatureMatrix(t, db)
	assertSubscriptionTablesExist(t, db)

	if err := runMigrationsTo(connStr, migrationsPath, 1); err != nil {
		t.Fatalf("migrate down to v1: %v", err)
	}

	assertCatalogTablesDropped(t, db)

	if err := runMigrationsTo(connStr, migrationsPath, 2); err != nil {
		t.Fatalf("migrate up to v2 again: %v", err)
	}
	assertSeedRowCounts(t, db)
}

func startPostgres(t *testing.T, ctx context.Context) string {
	t.Helper()

	container, err := tcpostgres.Run(ctx,
		"postgres:18-alpine",
		tcpostgres.WithDatabase("coffeeshop_test"),
		tcpostgres.WithUsername("test"),
		tcpostgres.WithPassword("test"),
		tcpostgres.BasicWaitStrategies(),
	)
	if err != nil {
		t.Skipf("postgres testcontainer unavailable: %v", err)
	}
	t.Cleanup(func() {
		_ = container.Terminate(ctx)
	})

	connStr, err := container.ConnectionString(ctx, "sslmode=disable")
	if err != nil {
		t.Fatalf("connection string: %v", err)
	}
	return connStr
}

func migrationsDir(t *testing.T) string {
	t.Helper()
	_, filename, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller failed")
	}
	return filepath.Join(filepath.Dir(filename), "..", "..", "migrations")
}

func runMigrationsTo(databaseURL, migrationsPath string, version uint) error {
	source := fmt.Sprintf("file://%s", migrationsPath)
	m, err := migrate.New(source, databaseURL)
	if err != nil {
		return fmt.Errorf("create migrate instance: %w", err)
	}
	defer m.Close()

	if err := m.Migrate(version); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return fmt.Errorf("migrate to version %d: %w", version, err)
	}
	return nil
}

func openDB(t *testing.T, connStr string) *sql.DB {
	t.Helper()
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	if err := db.Ping(); err != nil {
		t.Fatalf("ping db: %v", err)
	}
	return db
}

func assertSeedRowCounts(t *testing.T, db *sql.DB) {
	t.Helper()

	var tierCount, featureCount, mappingCount int
	if err := db.QueryRow(`SELECT COUNT(*) FROM plan_tier_catalog`).Scan(&tierCount); err != nil {
		t.Fatalf("count tiers: %v", err)
	}
	if err := db.QueryRow(`SELECT COUNT(*) FROM feature_catalog`).Scan(&featureCount); err != nil {
		t.Fatalf("count features: %v", err)
	}
	if err := db.QueryRow(`SELECT COUNT(*) FROM plan_tier_features`).Scan(&mappingCount); err != nil {
		t.Fatalf("count tier-feature mappings: %v", err)
	}

	if tierCount != 3 {
		t.Errorf("expected 3 tiers, got %d", tierCount)
	}
	if featureCount != 11 {
		t.Errorf("expected 11 features, got %d", featureCount)
	}
	if mappingCount != 33 {
		t.Errorf("expected 33 tier-feature mappings, got %d", mappingCount)
	}
}

var expectedTierFeatures = map[string]map[string]bool{
	"STARTER": {
		"reservation_manage":      false,
		"event_create":            false,
		"employee_assign":         false,
		"community_post":          false,
		"loyalty_basic":           false,
		"loyalty_premium":         false,
		"review_moderate":         false,
		"dashboard_notifications": false,
		"analytics":               false,
		"unlimited_tables":        false,
		"unlimited_menus":         false,
	},
	"GROWTH": {
		"reservation_manage":      true,
		"event_create":            true,
		"employee_assign":         true,
		"community_post":          true,
		"loyalty_basic":           true,
		"loyalty_premium":         false,
		"review_moderate":         true,
		"dashboard_notifications": true,
		"analytics":               false,
		"unlimited_tables":        true,
		"unlimited_menus":         true,
	},
	"PRO": {
		"reservation_manage":      true,
		"event_create":            true,
		"employee_assign":         true,
		"community_post":          true,
		"loyalty_basic":           true,
		"loyalty_premium":         true,
		"review_moderate":         true,
		"dashboard_notifications": true,
		"analytics":               true,
		"unlimited_tables":        true,
		"unlimited_menus":         true,
	},
}

func assertTierFeatureMatrix(t *testing.T, db *sql.DB) {
	t.Helper()

	rows, err := db.Query(`SELECT tier, feature_key, included FROM plan_tier_features ORDER BY tier, feature_key`)
	if err != nil {
		t.Fatalf("query tier-feature matrix: %v", err)
	}
	defer rows.Close()

	actual := make(map[string]map[string]bool)
	for rows.Next() {
		var tier, featureKey string
		var included bool
		if err := rows.Scan(&tier, &featureKey, &included); err != nil {
			t.Fatalf("scan tier-feature row: %v", err)
		}
		if actual[tier] == nil {
			actual[tier] = make(map[string]bool)
		}
		actual[tier][featureKey] = included
	}
	if err := rows.Err(); err != nil {
		t.Fatalf("iterate tier-feature rows: %v", err)
	}

	for tier, features := range expectedTierFeatures {
		for featureKey, wantIncluded := range features {
			gotIncluded, ok := actual[tier][featureKey]
			if !ok {
				t.Errorf("missing mapping for tier=%s feature=%s", tier, featureKey)
				continue
			}
			if gotIncluded != wantIncluded {
				t.Errorf("tier=%s feature=%s: want included=%v, got %v", tier, featureKey, wantIncluded, gotIncluded)
			}
		}
	}
}

func assertCatalogTablesDropped(t *testing.T, db *sql.DB) {
	t.Helper()

	tables := []string{
		"shop_usage",
		"shop_subscription",
		"owner_subscription_features",
		"owner_subscription",
		"plan_tier_features",
		"feature_catalog",
		"plan_tier_catalog",
	}
	for _, table := range tables {
		var exists bool
		err := db.QueryRow(`
			SELECT EXISTS (
				SELECT 1 FROM information_schema.tables
				WHERE table_schema = 'public' AND table_name = $1
			)`, table).Scan(&exists)
		if err != nil {
			t.Fatalf("check table %s exists: %v", table, err)
		}
		if exists {
			t.Errorf("expected table %s to be dropped after down migration", table)
		}
	}
}

func TestOwnerSubscriptionsMigration_GrandfatherExistingOwners(t *testing.T) {
	ctx := context.Background()
	connStr := startPostgres(t, ctx)
	migrationsPath := migrationsDir(t)

	if err := runMigrationsTo(connStr, migrationsPath, 1); err != nil {
		t.Fatalf("migrate up to v1: %v", err)
	}

	db := openDB(t, connStr)
	defer db.Close()

	seedGrandfatherTestData(t, db)

	if err := runMigrationsTo(connStr, migrationsPath, 2); err != nil {
		t.Fatalf("migrate up to v2: %v", err)
	}

	assertGrandfatheredOwnerSubscriptions(t, db)
	assertGrandfatheredShopSubscriptions(t, db)
	assertSubscriptionTableConstraints(t, db)
}

func seedGrandfatherTestData(t *testing.T, db *sql.DB) {
	t.Helper()

	users := []struct {
		id       string
		name     string
		username string
		email    string
		userType string
	}{
		{testOwner1ID, "Owner One", "owner-one", "owner-one@test.com", "SHOP_OWNER"},
		{testOwner2ID, "Owner Two", "owner-two", "owner-two@test.com", "SHOP_OWNER"},
		{testCustomerID, "Customer", "customer", "customer@test.com", "CUSTOMER"},
		{testAdminID, "Admin", "admin", "admin@test.com", "ADMIN"},
	}
	for _, u := range users {
		_, err := db.Exec(`
			INSERT INTO users (id, name, username, email, password, user_type)
			VALUES ($1, $2, $3, $4, 'hash', $5)`,
			u.id, u.name, u.username, u.email, u.userType,
		)
		if err != nil {
			t.Fatalf("insert user %s: %v", u.id, err)
		}
	}

	shops := []struct {
		id   string
		name string
	}{
		{testOwner1ShopA, "Owner One Shop A"},
		{testOwner1ShopB, "Owner One Shop B"},
		{testOwner2Shop, "Owner Two Shop"},
	}
	for _, s := range shops {
		_, err := db.Exec(`INSERT INTO shop (id, name) VALUES ($1, $2)`, s.id, s.name)
		if err != nil {
			t.Fatalf("insert shop %s: %v", s.id, err)
		}
	}

	links := []struct {
		id               string
		userID           string
		shopID           string
		relationshipType string
	}{
		{testUserShop1A, testOwner1ID, testOwner1ShopA, "OWNER"},
		{testUserShop1B, testOwner1ID, testOwner1ShopB, "OWNER"},
		{testUserShop2, testOwner2ID, testOwner2Shop, "OWNER"},
	}
	for _, l := range links {
		_, err := db.Exec(`
			INSERT INTO user_shop (id, user_id, shop_id, relationship_type)
			VALUES ($1, $2, $3, $4)`,
			l.id, l.userID, l.shopID, l.relationshipType,
		)
		if err != nil {
			t.Fatalf("insert user_shop %s: %v", l.id, err)
		}
	}
}

func assertGrandfatheredOwnerSubscriptions(t *testing.T, db *sql.DB) {
	t.Helper()

	rows, err := db.Query(`
		SELECT user_id, plan_mode, plan_tier, status, billing_interval
		FROM owner_subscription
		ORDER BY user_id`)
	if err != nil {
		t.Fatalf("query owner_subscription: %v", err)
	}
	defer rows.Close()

	type ownerSub struct {
		userID           string
		planMode         string
		planTier         string
		status           string
		billingInterval  sql.NullString
	}
	var subs []ownerSub
	for rows.Next() {
		var s ownerSub
		if err := rows.Scan(&s.userID, &s.planMode, &s.planTier, &s.status, &s.billingInterval); err != nil {
			t.Fatalf("scan owner_subscription: %v", err)
		}
		subs = append(subs, s)
	}
	if err := rows.Err(); err != nil {
		t.Fatalf("iterate owner_subscription: %v", err)
	}

	if len(subs) != 2 {
		t.Fatalf("expected 2 grandfathered owner subscriptions, got %d", len(subs))
	}

	expected := map[string]ownerSub{
		testOwner1ID: {userID: testOwner1ID, planMode: "PRESET", planTier: "GROWTH", status: "active", billingInterval: sql.NullString{String: "monthly", Valid: true}},
		testOwner2ID: {userID: testOwner2ID, planMode: "PRESET", planTier: "GROWTH", status: "active", billingInterval: sql.NullString{String: "monthly", Valid: true}},
	}
	for _, got := range subs {
		want, ok := expected[got.userID]
		if !ok {
			t.Errorf("unexpected owner_subscription for user %s", got.userID)
			continue
		}
		if got.planMode != want.planMode || got.planTier != want.planTier || got.status != want.status || got.billingInterval != want.billingInterval {
			t.Errorf("user %s: want %+v, got %+v", got.userID, want, got)
		}
	}

	var customerCount int
	if err := db.QueryRow(`SELECT COUNT(*) FROM owner_subscription WHERE user_id = $1`, testCustomerID).Scan(&customerCount); err != nil {
		t.Fatalf("count customer subscription: %v", err)
	}
	if customerCount != 0 {
		t.Errorf("customer should not have owner_subscription, got %d rows", customerCount)
	}
}

func assertGrandfatheredShopSubscriptions(t *testing.T, db *sql.DB) {
	t.Helper()

	rows, err := db.Query(`
		SELECT shop_id, owner_user_id, is_base_shop
		FROM shop_subscription
		ORDER BY owner_user_id, shop_id`)
	if err != nil {
		t.Fatalf("query shop_subscription: %v", err)
	}
	defer rows.Close()

	type shopSub struct {
		shopID      string
		ownerUserID string
		isBaseShop  bool
	}
	var subs []shopSub
	for rows.Next() {
		var s shopSub
		if err := rows.Scan(&s.shopID, &s.ownerUserID, &s.isBaseShop); err != nil {
			t.Fatalf("scan shop_subscription: %v", err)
		}
		subs = append(subs, s)
	}
	if err := rows.Err(); err != nil {
		t.Fatalf("iterate shop_subscription: %v", err)
	}

	if len(subs) != 3 {
		t.Fatalf("expected 3 shop_subscription rows, got %d", len(subs))
	}

	expected := map[string]shopSub{
		testOwner1ShopA: {shopID: testOwner1ShopA, ownerUserID: testOwner1ID, isBaseShop: true},
		testOwner1ShopB: {shopID: testOwner1ShopB, ownerUserID: testOwner1ID, isBaseShop: false},
		testOwner2Shop:  {shopID: testOwner2Shop, ownerUserID: testOwner2ID, isBaseShop: true},
	}
	for _, got := range subs {
		want, ok := expected[got.shopID]
		if !ok {
			t.Errorf("unexpected shop_subscription for shop %s", got.shopID)
			continue
		}
		if got.ownerUserID != want.ownerUserID || got.isBaseShop != want.isBaseShop {
			t.Errorf("shop %s: want %+v, got %+v", got.shopID, want, got)
		}
	}
}

func assertSubscriptionTablesExist(t *testing.T, db *sql.DB) {
	t.Helper()

	tables := []string{
		"owner_subscription",
		"owner_subscription_features",
		"shop_subscription",
		"shop_usage",
	}
	for _, table := range tables {
		var exists bool
		err := db.QueryRow(`
			SELECT EXISTS (
				SELECT 1 FROM information_schema.tables
				WHERE table_schema = 'public' AND table_name = $1
			)`, table).Scan(&exists)
		if err != nil {
			t.Fatalf("check table %s exists: %v", table, err)
		}
		if !exists {
			t.Errorf("expected table %s to exist after up migration", table)
		}
	}
}

func assertSubscriptionTableConstraints(t *testing.T, db *sql.DB) {
	t.Helper()

	_, err := db.Exec(`
		INSERT INTO owner_subscription (user_id, plan_mode, plan_tier, status)
		VALUES ($1, 'INVALID', 'GROWTH', 'active')`, testCustomerID)
	if err == nil {
		t.Error("expected invalid plan_mode to violate CHECK constraint")
	}

	_, err = db.Exec(`
		INSERT INTO owner_subscription (user_id, plan_mode, plan_tier, status)
		VALUES ($1, 'PRESET', NULL, 'active')`, testCustomerID)
	if err == nil {
		t.Error("expected PRESET without plan_tier to violate CHECK constraint")
	}

	_, err = db.Exec(`
		INSERT INTO shop_usage (shop_id, period_start, events_created)
		VALUES ($1, '2026-07-01', 0)`, testOwner2Shop)
	if err != nil {
		t.Fatalf("insert shop_usage: %v", err)
	}

	_, err = db.Exec(`
		INSERT INTO shop_usage (shop_id, period_start, events_created)
		VALUES ($1, '2026-07-01', 1)`, testOwner2Shop)
	if err == nil {
		t.Error("expected duplicate shop_usage primary key to fail")
	}
}

func TestOwnerSubscriptionsMigration_TierPricingSeed(t *testing.T) {
	ctx := context.Background()
	connStr := startPostgres(t, ctx)
	migrationsPath := migrationsDir(t)

	if err := runMigrationsTo(connStr, migrationsPath, 2); err != nil {
		t.Fatalf("migrate up to v2: %v", err)
	}

	db := openDB(t, connStr)
	defer db.Close()

	type tierPricing struct {
		basePrice      int
		extraShopPrice sql.NullInt64
		annualMonths   int
	}
	expected := map[string]tierPricing{
		"STARTER": {basePrice: 0, extraShopPrice: sql.NullInt64{Valid: false}, annualMonths: 12},
		"GROWTH":  {basePrice: 2900, extraShopPrice: sql.NullInt64{Int64: 1500, Valid: true}, annualMonths: 10},
		"PRO":     {basePrice: 7900, extraShopPrice: sql.NullInt64{Int64: 1000, Valid: true}, annualMonths: 10},
	}

	rows, err := db.Query(`
		SELECT tier, base_price_monthly_cents, extra_shop_price_cents, annual_months_charged
		FROM plan_tier_catalog
		ORDER BY tier`)
	if err != nil {
		t.Fatalf("query tier pricing: %v", err)
	}
	defer rows.Close()

	for rows.Next() {
		var tier string
		var basePrice, annualMonths int
		var extraShopPrice sql.NullInt64
		if err := rows.Scan(&tier, &basePrice, &extraShopPrice, &annualMonths); err != nil {
			t.Fatalf("scan tier pricing: %v", err)
		}
		want, ok := expected[tier]
		if !ok {
			t.Errorf("unexpected tier %s", tier)
			continue
		}
		if basePrice != want.basePrice {
			t.Errorf("tier %s base price: want %d, got %d", tier, want.basePrice, basePrice)
		}
		if extraShopPrice != want.extraShopPrice {
			t.Errorf("tier %s extra shop price: want %v, got %v", tier, want.extraShopPrice, extraShopPrice)
		}
		if annualMonths != want.annualMonths {
			t.Errorf("tier %s annual months: want %d, got %d", tier, want.annualMonths, annualMonths)
		}
	}
	if err := rows.Err(); err != nil {
		t.Fatalf("iterate tier pricing rows: %v", err)
	}
}
