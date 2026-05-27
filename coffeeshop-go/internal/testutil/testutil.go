package testutil

import (
	"testing"

	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func SetupTestDB(t *testing.T) *gorm.DB {
	t.Helper()
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		t.Fatalf("failed to open test db: %v", err)
	}

	db.AutoMigrate(
		&model.Role{},
		&model.Contact{},
		&model.Table{},
		&model.LoyaltyPlan{},
		&model.Menu{},
		&model.MenuItem{},
		&model.Shop{},
		&model.UserShop{},
		&model.Event{},
		&model.Review{},
		&model.ReviewComment{},
		&model.CommunityPost{},
		&model.Reservation{},
		&model.ReservationRequest{},
	)

	db.Exec("CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, name TEXT, username TEXT, email TEXT, password TEXT, user_type TEXT, keycloak_subject TEXT)")

	return db
}
