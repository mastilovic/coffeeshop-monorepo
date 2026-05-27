package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func testDB(t *testing.T) *gorm.DB {
	t.Helper()
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		t.Fatalf("failed to open test db: %v", err)
	}
	return db
}

func TestHealthReady(t *testing.T) {
	db := testDB(t)
	r := setupRouter(db)

	req := httptest.NewRequest(http.MethodGet, "/health/ready", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
}

func TestHealthLive(t *testing.T) {
	db := testDB(t)
	r := setupRouter(db)

	req := httptest.NewRequest(http.MethodGet, "/health/live", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
}

func TestPublicGetDoesNotRequireAuth(t *testing.T) {
	db := testDB(t)
	r := setupRouter(db)

	req := httptest.NewRequest(http.MethodGet, "/api/v2/shop/some-id", nil)
	req.Header.Set("Authorization", "Bearer invalid-garbage-token")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	// Public GETs should NOT return 401 even with invalid Bearer
	if w.Code == http.StatusUnauthorized {
		t.Error("public GET should not return 401 with invalid bearer")
	}
}

func TestProtectedPostRequiresAuth(t *testing.T) {
	db := testDB(t)
	r := setupRouter(db)

	req := httptest.NewRequest(http.MethodPost, "/api/v2/shop", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for protected POST without token, got %d", w.Code)
	}
}

func TestProfileRequiresAuth(t *testing.T) {
	db := testDB(t)
	r := setupRouter(db)

	req := httptest.NewRequest(http.MethodGet, "/api/v2/profile", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for GET /api/v2/profile without token, got %d", w.Code)
	}
}

func TestReservationRequestRequiresAuth(t *testing.T) {
	db := testDB(t)
	r := setupRouter(db)

	req := httptest.NewRequest(http.MethodGet, "/api/v2/reservation-request", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for GET /api/v2/reservation-request without token, got %d", w.Code)
	}
}

func TestShopMineRequiresAuth(t *testing.T) {
	db := testDB(t)
	r := setupRouter(db)

	req := httptest.NewRequest(http.MethodGet, "/api/v2/shop/mine", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for GET /api/v2/shop/mine without token, got %d", w.Code)
	}
}

func TestAuthEndpointsArePublic(t *testing.T) {
	db := testDB(t)
	r := setupRouter(db)

	endpoints := []string{
		"/api/v2/auth/login",
		"/api/v2/auth/register",
		"/api/v2/auth/refresh",
		"/api/v2/auth/logout",
	}

	for _, path := range endpoints {
		req := httptest.NewRequest(http.MethodPost, path, nil)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		if w.Code == http.StatusUnauthorized {
			t.Errorf("expected non-401 for POST %s, got 401", path)
		}
	}
}
