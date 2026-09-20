package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/config"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/testutil"
	"gorm.io/gorm"
)

type testHarness struct {
	router    http.Handler
	db        *gorm.DB
	jwtIssuer *testutil.TestJWTIssuer
}

func setupTestHarness(t *testing.T) *testHarness {
	t.Helper()
	db := testutil.SetupTestDB(t)
	jwtIssuer := testutil.NewTestJWTIssuer(t)

	cfg := config.Config{
		Port:                  8080,
		CORSAllowedOrigins:   "http://localhost:4200",
		KeycloakJWTIssuerURI: jwtIssuer.IssuerURI,
		KeycloakBaseURL:      "http://localhost:8080",
		KeycloakRealm:        "coffeeshop",
		KeycloakClientID:     "coffeeshop-backend",
		KeycloakClientSecret: "test-secret",
	}

	r := setupRouter(db, cfg)
	return &testHarness{router: r, db: db, jwtIssuer: jwtIssuer}
}

func (h *testHarness) createUser(t *testing.T, name, email, userType string) string {
	t.Helper()
	id := uuid.New().String()
	h.db.Exec(
		"INSERT INTO users (id, name, username, email, password, user_type, keycloak_subject) VALUES (?, ?, ?, ?, ?, ?, ?)",
		id, name, email[:len(email)-12], email, "hashed", userType, id,
	)
	return id
}

func (h *testHarness) tokenForUser(userID string, roles []string) string {
	return h.jwtIssuer.CreateToken(userID, roles)
}

func (h *testHarness) do(req *http.Request) *httptest.ResponseRecorder {
	w := httptest.NewRecorder()
	h.router.ServeHTTP(w, req)
	return w
}

func (h *testHarness) doJSON(method, path string, body interface{}, token string) *httptest.ResponseRecorder {
	var buf bytes.Buffer
	if body != nil {
		json.NewEncoder(&buf).Encode(body)
	}
	req := httptest.NewRequest(method, path, &buf)
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	return h.do(req)
}

// ===== API Security Tests (mirrors ApiSecurityIntegrationTest.java) =====

func TestPublicGetUsers_WithoutBearer_IsOk(t *testing.T) {
	h := setupTestHarness(t)
	w := h.doJSON(http.MethodGet, "/api/v2/user", nil, "")
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for public GET /user, got %d", w.Code)
	}
}

func TestPostUser_WithoutBearer_IsUnauthorized(t *testing.T) {
	h := setupTestHarness(t)
	body := map[string]interface{}{
		"name": "A", "username": "user_a", "email": "a@b.com",
		"password": "x", "userType": "CUSTOMER",
	}
	w := h.doJSON(http.MethodPost, "/api/v2/user", body, "")
	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for POST /user without bearer, got %d", w.Code)
	}
}

func TestPostUser_WithBearer_IsCreated(t *testing.T) {
	h := setupTestHarness(t)
	adminID := h.createUser(t, "Admin User", "admin-bearer@example.com", "ADMIN")
	token := h.tokenForUser(adminID, []string{"admin"})

	body := map[string]interface{}{
		"name": "B", "username": "user_b", "email": "b@b.com",
		"password": "x", "userType": "CUSTOMER",
	}
	w := h.doJSON(http.MethodPost, "/api/v2/user", body, token)
	if w.Code != http.StatusCreated {
		t.Errorf("expected 201 for POST /user with admin bearer, got %d; body: %s", w.Code, w.Body.String())
	}
}

func TestPostUser_WithNonAdminBearer_IsForbidden(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Bearer User", "bearer-user@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	body := map[string]interface{}{
		"name": "B", "username": "user_b", "email": "b@b.com",
		"password": "x", "userType": "CUSTOMER",
	}
	w := h.doJSON(http.MethodPost, "/api/v2/user", body, token)
	if w.Code != http.StatusForbidden {
		t.Errorf("expected 403 for POST /user with non-admin bearer, got %d; body: %s", w.Code, w.Body.String())
	}
}

func TestPublicGet_WithInvalidBearer_DoesNotReturn401(t *testing.T) {
	h := setupTestHarness(t)
	req := httptest.NewRequest(http.MethodGet, "/api/v2/shop/some-id", nil)
	req.Header.Set("Authorization", "Bearer invalid-garbage-token")
	w := h.do(req)
	if w.Code == http.StatusUnauthorized {
		t.Error("public GET should not return 401 with invalid bearer")
	}
}

// ===== Shop CRUD Tests =====

func TestShop_CreateAndGetByID(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Shop Owner", "shop-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	body := map[string]interface{}{
		"name": "Test Cafe", "address": "123 Main St",
		"city": "Beograd", "phoneNumber": "+381-11-1234567",
		"ownerUserId": ownerID,
	}
	w := h.doJSON(http.MethodPost, "/api/v2/shop", body, token)
	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d; body: %s", w.Code, w.Body.String())
	}

	var created map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &created)
	shopID := created["id"].(string)

	w = h.doJSON(http.MethodGet, "/api/v2/shop/"+shopID, nil, "")
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for GET shop by ID, got %d", w.Code)
	}
	var fetched map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &fetched)
	if fetched["name"] != "Test Cafe" {
		t.Errorf("expected name 'Test Cafe', got %v", fetched["name"])
	}
}

func TestShop_GetAllWithoutPage_ReturnsArray(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Array Owner", "array-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Array Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
	}, token)

	w := h.doJSON(http.MethodGet, "/api/v2/shop", nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var result []interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &result); err != nil {
		t.Fatalf("response is not a JSON array: %v", err)
	}
}

// ===== Shop Paginated Search Tests (mirrors ShopSearchPaginationIntegrationTest.java) =====

func TestShop_PaginatedSearch_ReturnsSizeValidation(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Size Validation Owner", "size-valid@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	w := h.doJSON(http.MethodGet, "/api/v2/shop?page=0&size=12", nil, token)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for invalid page size 12, got %d", w.Code)
	}
}

func TestShop_PaginatedSearch_ReturnsPageResponse(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)
	ownerID := h.createUser(t, "Page Owner", "page-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	growthTier := model.PlanTierGrowth
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &growthTier)

	for i := 0; i < 3; i++ {
		h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
			"name": fmt.Sprintf("PageShop %d", i), "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		}, token)
	}

	w := h.doJSON(http.MethodGet, "/api/v2/shop?q=pageshop&page=0&size=10", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var page map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &page)
	if page["totalElements"].(float64) != 3 {
		t.Errorf("expected totalElements=3, got %v", page["totalElements"])
	}
	if page["size"].(float64) != 10 {
		t.Errorf("expected size=10, got %v", page["size"])
	}
}

func TestShop_PaginatedSearch_FiltersByCity(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)
	ownerID := h.createUser(t, "City Filter Owner", "city-filter@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	growthTier := model.PlanTierGrowth
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &growthTier)

	h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Apatin Shop", "address": "1 St", "city": "Apatin", "phoneNumber": "123",
	}, token)
	h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Beograd Shop", "address": "2 St", "city": "Beograd", "phoneNumber": "456",
	}, token)
	h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Another Apatin", "address": "3 St", "city": "Apatin", "phoneNumber": "789",
	}, token)

	w := h.doJSON(http.MethodGet, "/api/v2/shop?city=Apatin&page=0&size=10", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var page map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &page)
	if page["totalElements"].(float64) != 2 {
		t.Errorf("expected totalElements=2, got %v", page["totalElements"])
	}

	content := page["content"].([]interface{})
	for _, item := range content {
		shop := item.(map[string]interface{})
		if shop["city"] != "Apatin" {
			t.Errorf("expected city Apatin, got %v", shop["city"])
		}
	}
}

func TestShop_PaginatedSearch_FiltersByCityAndQuery(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "City Query Owner", "city-query@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Alpha Apatin", "address": "1 St", "city": "Apatin", "phoneNumber": "123",
	}, token)
	h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Beta Apatin", "address": "2 St", "city": "Apatin", "phoneNumber": "456",
	}, token)
	h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Alpha Beograd", "address": "3 St", "city": "Beograd", "phoneNumber": "789",
	}, token)

	w := h.doJSON(http.MethodGet, "/api/v2/shop?q=alpha&city=Apatin&page=0&size=10", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var page map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &page)
	if page["totalElements"].(float64) != 1 {
		t.Errorf("expected totalElements=1, got %v", page["totalElements"])
	}

	content := page["content"].([]interface{})
	if len(content) != 1 {
		t.Fatalf("expected 1 shop, got %d", len(content))
	}
	shop := content[0].(map[string]interface{})
	if shop["name"] != "Alpha Apatin" {
		t.Errorf("expected Alpha Apatin, got %v", shop["name"])
	}
}

// ===== Shop Mine Tests =====

func TestShop_Mine_RequiresAuth(t *testing.T) {
	h := setupTestHarness(t)
	w := h.doJSON(http.MethodGet, "/api/v2/shop/mine", nil, "")
	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401 for /shop/mine without token, got %d", w.Code)
	}
}

func TestShop_Mine_ReturnsOwnedShops(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Mine Owner", "mine-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "My Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, token)

	w := h.doJSON(http.MethodGet, "/api/v2/shop/mine", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var shops []map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &shops)
	if len(shops) != 1 {
		t.Errorf("expected 1 owned shop, got %d", len(shops))
	}
}

func TestShop_Mine_ReturnsEmptyForCustomer(t *testing.T) {
	h := setupTestHarness(t)
	customerID := h.createUser(t, "Mine Customer", "mine-customer@example.com", "CUSTOMER")
	token := h.tokenForUser(customerID, []string{"CUSTOMER"})

	w := h.doJSON(http.MethodGet, "/api/v2/shop/mine", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var shops []map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &shops)
	if len(shops) != 0 {
		t.Errorf("expected 0 owned shops for customer, got %d", len(shops))
	}
}

// ===== Shop Favourites Tests (mirrors ShopFavouriteIntegrationTest.java) =====

func TestShop_AddFavourite_RequiresAuth(t *testing.T) {
	h := setupTestHarness(t)
	w := h.doJSON(http.MethodPost, "/api/v2/shop/"+uuid.New().String()+"/favourite", nil, "")
	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401, got %d", w.Code)
	}
}

func TestShop_AddAndRemoveFavourite(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Fav Owner", "fav-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	customerID := h.createUser(t, "Fav Customer", "fav-customer@example.com", "CUSTOMER")
	customerToken := h.tokenForUser(customerID, []string{"CUSTOMER"})

	w := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Fav Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, ownerToken)
	var shop map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	w = h.doJSON(http.MethodPost, "/api/v2/shop/"+shopID+"/favourite", nil, customerToken)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for add favourite, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodDelete, "/api/v2/shop/"+shopID+"/favourite", nil, customerToken)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for remove favourite, got %d", w.Code)
	}
}

// ===== Event Tests (mirrors EventSearchIntegrationTest.java) =====

func TestEvent_CRUD(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Event Owner", "event-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	h.enableGrowthEventCreate(t, ownerID)

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Event Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, token)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	body := map[string]interface{}{
		"eventName": "Jazz Night", "eventDate": "2026-06-01",
		"description": "Live jazz", "shopId": shopID,
	}
	w := h.doJSON(http.MethodPost, "/api/v2/event", body, token)
	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d; body: %s", w.Code, w.Body.String())
	}
	var event map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &event)
	eventID := event["eventId"].(string)

	w = h.doJSON(http.MethodGet, "/api/v2/event/"+eventID, nil, "")
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for GET event, got %d", w.Code)
	}

	w = h.doJSON(http.MethodGet, "/api/v2/event?shopId="+shopID, nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200 for GET events by shopId, got %d", w.Code)
	}
	var events []map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &events)
	if len(events) != 1 {
		t.Errorf("expected 1 event, got %d", len(events))
	}
}

func TestEvent_PaginatedSearch(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "ESearch Owner", "esearch-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	h.enableGrowthEventCreate(t, ownerID)

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "SearchEvent Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, token)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "Jazz Night", "eventDate": "2026-06-01",
		"description": "Live jazz", "shopId": shopID,
	}, token)
	h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "Poetry Reading", "eventDate": "2026-06-15",
		"description": "Spoken word", "shopId": shopID,
	}, token)

	w := h.doJSON(http.MethodGet, "/api/v2/event?q=jazz&page=0&size=10", nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var page map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &page)
	if page["totalElements"].(float64) != 1 {
		t.Errorf("expected totalElements=1 for jazz search, got %v", page["totalElements"])
	}
}

func TestEvent_DateRangeFilter(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "DateRange Owner", "daterange@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	h.enableGrowthEventCreate(t, ownerID)

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "DateRange Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, token)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "DateRangeEarly", "eventDate": "2026-06-01",
		"description": "early", "shopId": shopID,
	}, token)
	h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "DateRangeLate", "eventDate": "2026-07-01",
		"description": "late", "shopId": shopID,
	}, token)

	w := h.doJSON(http.MethodGet, "/api/v2/event?q=daterange&dateFrom=2026-06-15&page=0&size=10", nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var page map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &page)
	if page["totalElements"].(float64) != 1 {
		t.Errorf("expected 1 event after dateFrom filter, got %v", page["totalElements"])
	}
}

func TestEvent_Create_GrowthOwner_AtMonthlyLimit_Returns402(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Growth Limit Owner", "growth-limit-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	h.enableGrowthEventCreate(t, ownerID)
	shopID := h.createShopForOwner(t, ownerID, ownerToken, "Growth Limit Shop")
	h.seedShopUsageEventsCreated(t, shopID, 5)

	w := h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "Over Limit Event", "eventDate": "2026-08-01",
		"description": "blocked", "shopId": shopID,
	}, ownerToken)
	if w.Code != http.StatusPaymentRequired {
		t.Fatalf("expected 402 for 6th event, got %d; body: %s", w.Code, w.Body.String())
	}

	var body map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &body)
	if body["used"].(float64) != 5 {
		t.Errorf("expected used=5, got %v", body["used"])
	}
	if body["max"].(float64) != 5 {
		t.Errorf("expected max=5, got %v", body["max"])
	}
}

func TestEvent_Create_ProOwner_Unlimited_Succeeds(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)
	ownerID := h.createUser(t, "Pro Event Owner", "pro-event-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	proTier := model.PlanTierPro
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &proTier)
	shopID := h.createShopForOwner(t, ownerID, ownerToken, "Pro Event Shop")

	for i := 1; i <= 6; i++ {
		w := h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
			"eventName": fmt.Sprintf("Pro Event %d", i), "eventDate": "2026-08-01",
			"description": "unlimited", "shopId": shopID,
		}, ownerToken)
		if w.Code != http.StatusCreated {
			t.Fatalf("event %d: expected 201, got %d; body: %s", i, w.Code, w.Body.String())
		}
	}
}

// ===== Review Tests =====

func TestReview_CRUDAndComments(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Review Owner", "review-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Review Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, token)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	reviewBody := map[string]interface{}{
		"title": "Great coffee", "description": "Amazing espresso",
		"rating": 5, "shopId": shopID, "userId": ownerID,
		"reviewDate": "2026-05-27", "commentsEnabled": true,
	}
	w := h.doJSON(http.MethodPost, "/api/v2/review", reviewBody, token)
	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201 for create review, got %d; body: %s", w.Code, w.Body.String())
	}
	var review map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &review)
	reviewID := review["id"].(string)

	commentBody := map[string]interface{}{
		"body": "I agree!", "userId": ownerID,
	}
	w = h.doJSON(http.MethodPost, "/api/v2/review/"+reviewID+"/comments", commentBody, token)
	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201 for create comment, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodGet, "/api/v2/review/"+reviewID+"/comments", nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var comments []map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &comments)
	if len(comments) != 1 {
		t.Errorf("expected 1 comment, got %d", len(comments))
	}
}

// ===== Reservation Request Workflow Tests (mirrors ReservationRequestIntegrationTest.java) =====

func TestReservationRequest_CreateAndAccept(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)
	ownerID := h.createUser(t, "RR Owner", "rr-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	growthTier := model.PlanTierGrowth
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &growthTier)
	customerID := h.createUser(t, "RR Customer", "rr-customer@example.com", "CUSTOMER")

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "RR Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, ownerToken)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	eventW := h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "RR Event", "eventDate": "2026-06-01",
		"description": "test", "shopId": shopID,
	}, ownerToken)
	var event map[string]interface{}
	json.Unmarshal(eventW.Body.Bytes(), &event)
	eventID := event["eventId"].(string)

	tableW := h.doJSON(http.MethodPost, "/api/v2/table", map[string]interface{}{
		"number": 1, "capacity": 6, "shopId": shopID,
	}, ownerToken)
	var table map[string]interface{}
	json.Unmarshal(tableW.Body.Bytes(), &table)
	tableID := table["id"].(string)

	requestW := h.doJSON(http.MethodPost, "/api/v2/reservation-request", map[string]interface{}{
		"userId": customerID, "shopId": shopID, "eventId": eventID, "partySize": 4,
	}, ownerToken)
	if requestW.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d; body: %s", requestW.Code, requestW.Body.String())
	}
	var request map[string]interface{}
	json.Unmarshal(requestW.Body.Bytes(), &request)
	if request["status"] != "PENDING" {
		t.Errorf("expected status PENDING, got %v", request["status"])
	}
	requestID := request["id"].(string)

	acceptW := h.doJSON(http.MethodPost, "/api/v2/reservation-request/"+requestID+"/accept", map[string]interface{}{
		"tableId": tableID,
	}, ownerToken)
	if acceptW.Code != http.StatusOK {
		t.Fatalf("expected 200 for accept, got %d; body: %s", acceptW.Code, acceptW.Body.String())
	}
	var accepted map[string]interface{}
	json.Unmarshal(acceptW.Body.Bytes(), &accepted)
	if accepted["status"] != "ACCEPTED" {
		t.Errorf("expected status ACCEPTED, got %v", accepted["status"])
	}
}

func TestReservationRequest_CreateAndDeny(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)
	ownerID := h.createUser(t, "Deny Owner", "deny-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	growthTier := model.PlanTierGrowth
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &growthTier)
	customerID := h.createUser(t, "Deny Customer", "deny-customer@example.com", "CUSTOMER")

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Deny Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, ownerToken)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	eventW := h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "Deny Event", "eventDate": "2026-06-01",
		"description": "test", "shopId": shopID,
	}, ownerToken)
	var event map[string]interface{}
	json.Unmarshal(eventW.Body.Bytes(), &event)
	eventID := event["eventId"].(string)

	requestW := h.doJSON(http.MethodPost, "/api/v2/reservation-request", map[string]interface{}{
		"userId": customerID, "shopId": shopID, "eventId": eventID, "partySize": 2,
	}, ownerToken)
	var request map[string]interface{}
	json.Unmarshal(requestW.Body.Bytes(), &request)
	requestID := request["id"].(string)

	denyW := h.doJSON(http.MethodPost, "/api/v2/reservation-request/"+requestID+"/deny", nil, ownerToken)
	if denyW.Code != http.StatusOK {
		t.Fatalf("expected 200 for deny, got %d; body: %s", denyW.Code, denyW.Body.String())
	}
	var denied map[string]interface{}
	json.Unmarshal(denyW.Body.Bytes(), &denied)
	if denied["status"] != "DENIED" {
		t.Errorf("expected status DENIED, got %v", denied["status"])
	}
}

func TestReservationRequest_ListRequiresAuth(t *testing.T) {
	h := setupTestHarness(t)
	w := h.doJSON(http.MethodGet, "/api/v2/reservation-request", nil, "")
	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401, got %d", w.Code)
	}
}

// ===== Role CRUD Tests =====

func TestRole_CRUD(t *testing.T) {
	h := setupTestHarness(t)
	adminID := h.createUser(t, "Role Admin", "role-admin@example.com", "ADMIN")
	token := h.tokenForUser(adminID, []string{"admin"})

	w := h.doJSON(http.MethodPost, "/api/v2/role", map[string]interface{}{
		"name": "Test Role", "type": "USER",
	}, token)
	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d; body: %s", w.Code, w.Body.String())
	}
	var role map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &role)
	roleID := role["id"].(string)

	w = h.doJSON(http.MethodGet, "/api/v2/role/"+roleID, nil, "")
	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}

	w = h.doJSON(http.MethodGet, "/api/v2/role", nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var roles []map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &roles)
	if len(roles) != 1 {
		t.Errorf("expected 1 role, got %d", len(roles))
	}

	w = h.doJSON(http.MethodPut, "/api/v2/role/"+roleID, map[string]interface{}{
		"name": "Updated Role", "type": "ADMIN",
	}, token)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200 for update, got %d", w.Code)
	}

	req := httptest.NewRequest(http.MethodDelete, "/api/v2/role/"+roleID, nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w = h.do(req)
	if w.Code != http.StatusNoContent {
		t.Errorf("expected 204 for delete, got %d", w.Code)
	}
}

// ===== Reference Data Tests =====

func TestReference_SerbiaCities(t *testing.T) {
	h := setupTestHarness(t)
	w := h.doJSON(http.MethodGet, "/api/v2/reference/serbia-cities", nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var cities []interface{}
	json.Unmarshal(w.Body.Bytes(), &cities)
	if len(cities) == 0 {
		t.Error("expected non-empty cities list")
	}
}

func TestReference_SerbiaCities_Search(t *testing.T) {
	h := setupTestHarness(t)
	w := h.doJSON(http.MethodGet, "/api/v2/reference/serbia-cities?q=beograd", nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}
	var cities []interface{}
	json.Unmarshal(w.Body.Bytes(), &cities)
	if len(cities) == 0 {
		t.Error("expected at least one city matching 'beograd'")
	}
}

// ===== Auth Endpoints Tests =====

func TestAuth_LoginEndpoint_IsPublic(t *testing.T) {
	h := setupTestHarness(t)
	endpoints := []string{
		"/api/v2/auth/login",
		"/api/v2/auth/register",
		"/api/v2/auth/refresh",
		"/api/v2/auth/logout",
	}
	for _, path := range endpoints {
		w := h.doJSON(http.MethodPost, path, nil, "")
		if w.Code == http.StatusUnauthorized {
			t.Errorf("expected non-401 for POST %s, got 401", path)
		}
	}
}

// ===== Profile Tests =====

func TestProfile_RequiresAuth(t *testing.T) {
	h := setupTestHarness(t)
	w := h.doJSON(http.MethodGet, "/api/v2/profile", nil, "")
	if w.Code != http.StatusUnauthorized {
		t.Errorf("expected 401, got %d", w.Code)
	}
}

func TestProfile_WithValidToken_ReturnsUser(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Profile User", "profile-user@example.com", "CUSTOMER")
	token := h.tokenForUser(ownerID, []string{"CUSTOMER"})

	w := h.doJSON(http.MethodGet, "/api/v2/profile", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var profile map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &profile)
	if profile["id"] != ownerID {
		t.Errorf("expected profile id=%s, got %v", ownerID, profile["id"])
	}
	if _, ok := profile["favouriteShops"]; !ok {
		t.Error("expected favouriteShops in profile response")
	}
	if _, ok := profile["reviews"]; !ok {
		t.Error("expected reviews in profile response")
	}
	if _, ok := profile["reservations"]; !ok {
		t.Error("expected reservations in profile response")
	}
	if _, ok := profile["subscription"]; ok {
		t.Error("expected no subscription block for CUSTOMER profile")
	}
	if _, ok := profile["entitlements"]; ok {
		t.Error("expected no entitlements block for CUSTOMER profile")
	}
	if _, ok := profile["limits"]; ok {
		t.Error("expected no limits block for CUSTOMER profile")
	}
}

func TestProfile_Admin_NoSubscriptionFields(t *testing.T) {
	h := setupTestHarness(t)
	adminID := h.createUser(t, "Admin Profile", "admin-profile@example.com", "ADMIN")
	token := h.tokenForUser(adminID, []string{"admin"})

	w := h.doJSON(http.MethodGet, "/api/v2/profile", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var profile map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &profile)
	for _, field := range []string{"subscription", "entitlements", "limits"} {
		if _, ok := profile[field]; ok {
			t.Errorf("expected no %s block for ADMIN profile", field)
		}
	}
}

func TestProfile_GrowthOwner_IncludesEntitlements(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	ownerID := h.createUser(t, "Growth Profile Owner", "growth-profile@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	growthTier := model.PlanTierGrowth
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &growthTier)

	h.createShopForOwner(t, ownerID, token, "Growth Profile Shop")

	w := h.doJSON(http.MethodGet, "/api/v2/profile", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var profile map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &profile)

	sub, ok := profile["subscription"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected subscription block, got %v", profile["subscription"])
	}
	if sub["planMode"] != "PRESET" {
		t.Errorf("expected planMode PRESET, got %v", sub["planMode"])
	}
	if sub["planTier"] != "GROWTH" {
		t.Errorf("expected planTier GROWTH, got %v", sub["planTier"])
	}
	if sub["status"] != "active" {
		t.Errorf("expected status active, got %v", sub["status"])
	}

	entitlements, ok := profile["entitlements"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected entitlements block, got %v", profile["entitlements"])
	}
	for _, feature := range []string{
		"reservation_manage", "event_create", "employee_assign", "community_post",
		"loyalty_basic", "review_moderate", "dashboard_notifications",
		"unlimited_tables", "unlimited_menus",
	} {
		if entitlements[feature] != true {
			t.Errorf("expected entitlement %s=true, got %v", feature, entitlements[feature])
		}
	}
	for _, feature := range []string{"loyalty_premium", "analytics"} {
		if entitlements[feature] != false {
			t.Errorf("expected entitlement %s=false, got %v", feature, entitlements[feature])
		}
	}

	limits, ok := profile["limits"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected limits block, got %v", profile["limits"])
	}
	tables, ok := limits["tables"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected tables limit, got %v", limits["tables"])
	}
	if tables["max"].(float64) != -1 {
		t.Errorf("expected unlimited tables max=-1 for Growth, got %v", tables["max"])
	}
}

func TestProfile_StarterOwner_IncludesLimits(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	ownerID := h.createUser(t, "Starter Profile Owner", "starter-profile@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	starterTier := model.PlanTierStarter
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &starterTier)

	shopID := h.createShopForOwner(t, ownerID, token, "Starter Profile Shop")

	for i := 1; i <= 2; i++ {
		h.db.Exec(
			"INSERT INTO tables (id, number, capacity, shop_id) VALUES (?, ?, 4, ?)",
			uuid.New().String(), i, shopID,
		)
	}

	w := h.doJSON(http.MethodGet, "/api/v2/profile", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var profile map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &profile)

	limits, ok := profile["limits"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected limits block, got %v", profile["limits"])
	}
	tables, ok := limits["tables"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected tables limit, got %v", limits["tables"])
	}
	if tables["max"].(float64) != 15 {
		t.Errorf("expected tables max=15 for Starter, got %v", tables["max"])
	}
	if tables["used"].(float64) != 2 {
		t.Errorf("expected tables used=2, got %v", tables["used"])
	}

	menus, ok := limits["menus"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected menus limit, got %v", limits["menus"])
	}
	if menus["max"].(float64) != 1 {
		t.Errorf("expected menus max=1 for Starter, got %v", menus["max"])
	}

	shops, ok := limits["shops"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected shops limit, got %v", limits["shops"])
	}
	if shops["max"].(float64) != 1 {
		t.Errorf("expected shops max=1 for Starter, got %v", shops["max"])
	}
	if shops["used"].(float64) != 1 {
		t.Errorf("expected shops used=1, got %v", shops["used"])
	}

	entitlements, ok := profile["entitlements"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected entitlements block, got %v", profile["entitlements"])
	}
	if entitlements["reservation_manage"] != false {
		t.Errorf("expected reservation_manage=false for Starter, got %v", entitlements["reservation_manage"])
	}
}

func TestSubscriptionCatalog_ReturnsSeededTiersAndFeatures(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	ownerID := h.createUser(t, "Catalog Owner", "catalog-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	w := h.doJSON(http.MethodGet, "/api/v2/subscription/catalog", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var catalog map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &catalog)

	tiers, ok := catalog["tiers"].([]interface{})
	if !ok || len(tiers) != 3 {
		t.Fatalf("expected 3 tiers, got %v", catalog["tiers"])
	}

	growthFound := false
	for _, tier := range tiers {
		entry, ok := tier.(map[string]interface{})
		if !ok {
			continue
		}
		if entry["tier"] == "GROWTH" {
			growthFound = true
			if entry["basePriceMonthlyCents"].(float64) != 2900 {
				t.Errorf("expected Growth base price 2900, got %v", entry["basePriceMonthlyCents"])
			}
			included, ok := entry["includedFeatures"].([]interface{})
			if !ok || len(included) < 8 {
				t.Errorf("expected Growth included features, got %v", entry["includedFeatures"])
			}
		}
	}
	if !growthFound {
		t.Error("expected GROWTH tier in catalog")
	}

	features, ok := catalog["features"].([]interface{})
	if !ok || len(features) != 11 {
		t.Fatalf("expected 11 features, got %v", catalog["features"])
	}
}

func TestSubscriptionQuote_GrowthPresetWithExtraShops(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	ownerID := h.createUser(t, "Quote Growth Owner", "quote-growth@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	body := map[string]interface{}{
		"planMode": "PRESET", "planTier": "GROWTH", "shopCount": 3, "billingInterval": "monthly",
	}
	w := h.doJSON(http.MethodPost, "/api/v2/subscription/quote", body, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var quote map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &quote)
	if quote["monthlyTotalCents"].(float64) != 5900 {
		t.Errorf("expected monthlyTotalCents=5900, got %v", quote["monthlyTotalCents"])
	}
	if quote["extraShopsCents"].(float64) != 3000 {
		t.Errorf("expected extraShopsCents=3000, got %v", quote["extraShopsCents"])
	}
}

func TestSubscriptionQuote_CustomThreeFeatureAnnual(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	ownerID := h.createUser(t, "Quote Custom Owner", "quote-custom@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	body := map[string]interface{}{
		"planMode": "CUSTOM",
		"features": []string{"reservation_manage", "event_create", "analytics"},
		"shopCount":       1,
		"billingInterval": "annual",
	}
	w := h.doJSON(http.MethodPost, "/api/v2/subscription/quote", body, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var quote map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &quote)
	if quote["featuresMonthlyCents"].(float64) != 3300 {
		t.Errorf("expected featuresMonthlyCents=3300, got %v", quote["featuresMonthlyCents"])
	}
	if quote["annualTotalCents"].(float64) != 33000 {
		t.Errorf("expected annualTotalCents=33000, got %v", quote["annualTotalCents"])
	}
	if quote["annualMonthsCharged"].(float64) != 10 {
		t.Errorf("expected annualMonthsCharged=10, got %v", quote["annualMonthsCharged"])
	}
}

func TestSubscriptionMe_GrowthOwner(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	ownerID := h.createUser(t, "Me Growth Owner", "me-growth@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	growthTier := model.PlanTierGrowth
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &growthTier)

	h.createShopForOwner(t, ownerID, token, "Me Growth Shop")

	w := h.doJSON(http.MethodGet, "/api/v2/subscription/me", nil, token)
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	var me map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &me)
	if me["planMode"] != "PRESET" {
		t.Errorf("expected planMode PRESET, got %v", me["planMode"])
	}
	if me["planTier"] != "GROWTH" {
		t.Errorf("expected planTier GROWTH, got %v", me["planTier"])
	}
	if me["shopsUsed"].(float64) != 1 {
		t.Errorf("expected shopsUsed=1, got %v", me["shopsUsed"])
	}

	renewal, ok := me["renewalQuote"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected renewalQuote, got %v", me["renewalQuote"])
	}
	if renewal["monthlyTotalCents"].(float64) != 2900 {
		t.Errorf("expected renewal monthlyTotalCents=2900, got %v", renewal["monthlyTotalCents"])
	}

	entitlements, ok := me["entitlements"].(map[string]interface{})
	if !ok {
		t.Fatalf("expected entitlements, got %v", me["entitlements"])
	}
	if entitlements["event_create"] != true {
		t.Errorf("expected event_create entitlement, got %v", entitlements["event_create"])
	}
}

func TestSubscriptionPlanChange_StarterToGrowth_UpdatesProfileEntitlements(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	ownerID := h.createUser(t, "Plan Change Owner", "plan-change@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	starterTier := model.PlanTierStarter
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &starterTier)

	h.createShopForOwner(t, ownerID, token, "Plan Change Shop")

	beforeW := h.doJSON(http.MethodGet, "/api/v2/profile", nil, token)
	if beforeW.Code != http.StatusOK {
		t.Fatalf("profile before: expected 200, got %d; body: %s", beforeW.Code, beforeW.Body.String())
	}
	var beforeProfile map[string]interface{}
	json.Unmarshal(beforeW.Body.Bytes(), &beforeProfile)
	beforeEntitlements := beforeProfile["entitlements"].(map[string]interface{})
	if beforeEntitlements["event_create"] != false {
		t.Fatalf("expected event_create=false before upgrade, got %v", beforeEntitlements["event_create"])
	}

	body := map[string]interface{}{
		"planMode": "PRESET", "planTier": "GROWTH", "billingInterval": "monthly",
	}
	planW := h.doJSON(http.MethodPut, "/api/v2/subscription/plan", body, token)
	if planW.Code != http.StatusOK {
		t.Fatalf("plan change: expected 200, got %d; body: %s", planW.Code, planW.Body.String())
	}

	var planResp map[string]interface{}
	json.Unmarshal(planW.Body.Bytes(), &planResp)
	if planResp["planTier"] != "GROWTH" {
		t.Errorf("expected planTier GROWTH after change, got %v", planResp["planTier"])
	}
	if planResp["lockedMonthlyAmountCents"].(float64) != 2900 {
		t.Errorf("expected lockedMonthlyAmountCents=2900, got %v", planResp["lockedMonthlyAmountCents"])
	}

	afterW := h.doJSON(http.MethodGet, "/api/v2/profile", nil, token)
	if afterW.Code != http.StatusOK {
		t.Fatalf("profile after: expected 200, got %d; body: %s", afterW.Code, afterW.Body.String())
	}
	var afterProfile map[string]interface{}
	json.Unmarshal(afterW.Body.Bytes(), &afterProfile)
	afterEntitlements := afterProfile["entitlements"].(map[string]interface{})
	if afterEntitlements["event_create"] != true {
		t.Errorf("expected event_create=true after upgrade, got %v", afterEntitlements["event_create"])
	}
	if afterEntitlements["reservation_manage"] != true {
		t.Errorf("expected reservation_manage=true after upgrade, got %v", afterEntitlements["reservation_manage"])
	}

	sub := afterProfile["subscription"].(map[string]interface{})
	if sub["planTier"] != "GROWTH" {
		t.Errorf("expected profile planTier GROWTH, got %v", sub["planTier"])
	}
}

func TestShopFavourite_AddAndRemove_UpdatesProfileAndResponse(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Fav Owner", "fav-owner@example.com", "SHOP_OWNER")
	customerID := h.createUser(t, "Fav Customer", "fav-customer@example.com", "CUSTOMER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	customerToken := h.tokenForUser(customerID, []string{"CUSTOMER"})

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Favourite Test Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, ownerToken)
	if shopW.Code != http.StatusCreated {
		t.Fatalf("create shop: expected 201, got %d; body: %s", shopW.Code, shopW.Body.String())
	}
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	favW := h.doJSON(http.MethodPost, "/api/v2/shop/"+shopID+"/favourite", nil, customerToken)
	if favW.Code != http.StatusOK {
		t.Fatalf("add favourite: expected 200, got %d; body: %s", favW.Code, favW.Body.String())
	}
	var favShop map[string]interface{}
	json.Unmarshal(favW.Body.Bytes(), &favShop)
	if favShop["favouriteByCurrentUser"] != true {
		t.Errorf("expected favouriteByCurrentUser=true, got %v", favShop["favouriteByCurrentUser"])
	}

	profileW := h.doJSON(http.MethodGet, "/api/v2/profile", nil, customerToken)
	if profileW.Code != http.StatusOK {
		t.Fatalf("profile: expected 200, got %d; body: %s", profileW.Code, profileW.Body.String())
	}
	var profile map[string]interface{}
	json.Unmarshal(profileW.Body.Bytes(), &profile)
	favouriteShops, ok := profile["favouriteShops"].([]interface{})
	if !ok || len(favouriteShops) != 1 {
		t.Fatalf("expected 1 favourite shop in profile, got %v", profile["favouriteShops"])
	}
	if favouriteShops[0].(map[string]interface{})["id"] != shopID {
		t.Errorf("expected favourite shop id=%s, got %v", shopID, favouriteShops[0].(map[string]interface{})["id"])
	}

	removeW := h.doJSON(http.MethodDelete, "/api/v2/shop/"+shopID+"/favourite", nil, customerToken)
	if removeW.Code != http.StatusOK {
		t.Fatalf("remove favourite: expected 200, got %d; body: %s", removeW.Code, removeW.Body.String())
	}
	var unfavShop map[string]interface{}
	json.Unmarshal(removeW.Body.Bytes(), &unfavShop)
	if unfavShop["favouriteByCurrentUser"] != false {
		t.Errorf("expected favouriteByCurrentUser=false, got %v", unfavShop["favouriteByCurrentUser"])
	}

	profileW2 := h.doJSON(http.MethodGet, "/api/v2/profile", nil, customerToken)
	json.Unmarshal(profileW2.Body.Bytes(), &profile)
	favouriteShops2, ok := profile["favouriteShops"].([]interface{})
	if !ok || len(favouriteShops2) != 0 {
		t.Errorf("expected empty favouriteShops after remove, got %v", profile["favouriteShops"])
	}

	// Idempotent: second add should still return 200 without duplicating rows.
	favW2 := h.doJSON(http.MethodPost, "/api/v2/shop/"+shopID+"/favourite", nil, customerToken)
	if favW2.Code != http.StatusOK {
		t.Fatalf("second add favourite: expected 200, got %d; body: %s", favW2.Code, favW2.Body.String())
	}
	profileW3 := h.doJSON(http.MethodGet, "/api/v2/profile", nil, customerToken)
	json.Unmarshal(profileW3.Body.Bytes(), &profile)
	favouriteShops3, ok := profile["favouriteShops"].([]interface{})
	if !ok || len(favouriteShops3) != 1 {
		t.Errorf("expected exactly 1 favourite shop after idempotent add, got %v", profile["favouriteShops"])
	}
}

func TestShopFavourite_OwnerCannotFavouriteOwnShop(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Self Fav Owner", "self-fav-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Owner Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, ownerToken)
	if shopW.Code != http.StatusCreated {
		t.Fatalf("create shop: expected 201, got %d", shopW.Code)
	}
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	favW := h.doJSON(http.MethodPost, "/api/v2/shop/"+shopID+"/favourite", nil, ownerToken)
	if favW.Code != http.StatusConflict {
		t.Errorf("expected 409 when owner favourites own shop, got %d; body: %s", favW.Code, favW.Body.String())
	}
}

// ===== Table CRUD Tests =====

func TestTable_CRUD(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Table Owner", "table-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Table Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, token)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	w := h.doJSON(http.MethodPost, "/api/v2/table", map[string]interface{}{
		"number": 1, "capacity": 4, "shopId": shopID,
	}, token)
	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d; body: %s", w.Code, w.Body.String())
	}
	var table map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &table)
	tableID := table["id"].(string)

	w = h.doJSON(http.MethodGet, "/api/v2/table/"+tableID, nil, "")
	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
}

// ===== User CRUD Tests =====

func TestUser_CRUD_WithPagination(t *testing.T) {
	h := setupTestHarness(t)
	adminID := h.createUser(t, "Admin User", "admin-user@example.com", "ADMIN")
	token := h.tokenForUser(adminID, []string{"admin"})

	for i := 0; i < 3; i++ {
		h.doJSON(http.MethodPost, "/api/v2/user", map[string]interface{}{
			"name": fmt.Sprintf("User%d", i), "username": fmt.Sprintf("user%d", i),
			"email": fmt.Sprintf("user%d@example.com", i), "password": "pass", "userType": "CUSTOMER",
		}, token)
	}

	w := h.doJSON(http.MethodGet, "/api/v2/user?q=user&page=0&size=10", nil, "")
	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var page map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &page)
	totalElements := page["totalElements"].(float64)
	if totalElements < 3 {
		t.Errorf("expected at least 3 users, got %v", totalElements)
	}
}

// ===== Reservation Tests =====

func TestReservation_CRUD(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Reservation Owner", "reservation-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	customerID := h.createUser(t, "Reservation Guest", "reservation-guest@example.com", "CUSTOMER")

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Reservation Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, token)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	tableW := h.doJSON(http.MethodPost, "/api/v2/table", map[string]interface{}{
		"number": 1, "capacity": 4, "shopId": shopID,
	}, token)
	var table map[string]interface{}
	json.Unmarshal(tableW.Body.Bytes(), &table)
	tableID := table["id"].(string)

	w := h.doJSON(http.MethodPost, "/api/v2/reservation", map[string]interface{}{
		"userId": customerID, "shopId": shopID, "tableId": tableID, "partySize": 2,
	}, token)
	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d; body: %s", w.Code, w.Body.String())
	}
	var reservation map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &reservation)
	reservationID := reservation["id"].(string)

	w = h.doJSON(http.MethodGet, "/api/v2/reservation/"+reservationID, nil, "")
	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
}

// ===== Community Tests =====

func TestCommunity_GetPosts(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Community Owner", "community-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": "Community Shop", "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, token)
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	w := h.doJSON(http.MethodGet, "/api/v2/shop/"+shopID+"/community/posts?page=0&size=10", nil, "")
	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
}

// ===== Shop Staff Authorization Tests =====

func (h *testHarness) seedSubscriptionCatalog(t *testing.T) {
	t.Helper()

	tiers := []model.PlanTierCatalog{
		{Tier: model.PlanTierStarter, DisplayName: "Starter", BasePriceMonthlyCents: 0, AnnualMonthsCharged: 12, IsActive: true},
		{Tier: model.PlanTierGrowth, DisplayName: "Growth", BasePriceMonthlyCents: 2900, ExtraShopPriceCents: intPtr(1500), AnnualMonthsCharged: 10, IsActive: true},
		{Tier: model.PlanTierPro, DisplayName: "Pro", BasePriceMonthlyCents: 7900, ExtraShopPriceCents: intPtr(1000), AnnualMonthsCharged: 10, IsActive: true},
	}
	if err := h.db.Create(&tiers).Error; err != nil {
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
	if err := h.db.Create(&features).Error; err != nil {
		t.Fatalf("seed features: %v", err)
	}

	mappings := []model.PlanTierFeature{
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
	if err := h.db.Create(&mappings).Error; err != nil {
		t.Fatalf("seed tier features: %v", err)
	}
}

func (h *testHarness) enableGrowthEventCreate(t *testing.T, ownerID string) {
	t.Helper()
	h.seedSubscriptionCatalog(t)
	growthTier := model.PlanTierGrowth
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &growthTier)
}

func (h *testHarness) seedShopUsageEventsCreated(t *testing.T, shopID string, count int) {
	t.Helper()
	now := time.Now().UTC()
	period := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
	if err := h.db.Exec(
		"INSERT INTO shop_usage (shop_id, period_start, events_created) VALUES (?, ?, ?)",
		shopID, period, count,
	).Error; err != nil {
		t.Fatalf("seed shop_usage events_created: %v", err)
	}
}

func (h *testHarness) createOwnerSubscription(t *testing.T, ownerID string, planMode model.PlanMode, planTier *model.PlanTier) {
	t.Helper()
	interval := model.BillingIntervalMonthly
	sub := model.OwnerSubscription{
		UserID:          ownerID,
		PlanMode:        planMode,
		PlanTier:        planTier,
		Status:          model.SubscriptionStatusActive,
		BillingInterval: &interval,
	}
	if err := h.db.Create(&sub).Error; err != nil {
		t.Fatalf("create owner subscription: %v", err)
	}
}

func (h *testHarness) createShopSubscription(t *testing.T, ownerID, shopID string, isBase bool) {
	t.Helper()
	row := model.ShopSubscription{
		ShopID:      shopID,
		OwnerUserID: ownerID,
		IsBaseShop:  isBase,
	}
	if err := h.db.Create(&row).Error; err != nil {
		t.Fatalf("create shop subscription: %v", err)
	}
}

func intPtr(v int) *int { return &v }

func strPtr(v string) *string { return &v }

// createShopForOwner creates a shop owned by ownerID and returns its ID.
func (h *testHarness) createShopForOwner(t *testing.T, ownerID, ownerToken, name string) string {
	t.Helper()
	w := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": name, "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, ownerToken)
	if w.Code != http.StatusCreated {
		t.Fatalf("create shop: expected 201, got %d; body: %s", w.Code, w.Body.String())
	}
	var shop map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &shop)
	return shop["id"].(string)
}

func (h *testHarness) createReviewForShop(t *testing.T, userID, token, shopID string) string {
	t.Helper()
	w := h.doJSON(http.MethodPost, "/api/v2/review", map[string]interface{}{
		"title": "Test review", "description": "Nice place",
		"rating": 5, "shopId": shopID, "commentsEnabled": true,
	}, token)
	if w.Code != http.StatusCreated {
		t.Fatalf("create review: expected 201, got %d; body: %s", w.Code, w.Body.String())
	}
	var review map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &review)
	return review["id"].(string)
}

func (h *testHarness) createPendingReservationRequest(t *testing.T, ownerID, ownerToken, customerID, shopName, eventName string) (requestID, tableID string) {
	t.Helper()

	shopW := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
		"name": shopName, "address": "1 St", "city": "Beograd", "phoneNumber": "123",
		"ownerUserId": ownerID,
	}, ownerToken)
	if shopW.Code != http.StatusCreated {
		t.Fatalf("create shop: expected 201, got %d; body: %s", shopW.Code, shopW.Body.String())
	}
	var shop map[string]interface{}
	json.Unmarshal(shopW.Body.Bytes(), &shop)
	shopID := shop["id"].(string)

	eventID := uuid.New().String()
	if err := h.db.Exec(
		"INSERT INTO event (event_id, event_name, event_date, description, shop_id) VALUES (?, ?, ?, ?, ?)",
		eventID, eventName, "2026-06-01", "test", shopID,
	).Error; err != nil {
		t.Fatalf("seed event: %v", err)
	}

	tableW := h.doJSON(http.MethodPost, "/api/v2/table", map[string]interface{}{
		"number": 1, "capacity": 6, "shopId": shopID,
	}, ownerToken)
	if tableW.Code != http.StatusCreated {
		t.Fatalf("create table: expected 201, got %d; body: %s", tableW.Code, tableW.Body.String())
	}
	var table map[string]interface{}
	json.Unmarshal(tableW.Body.Bytes(), &table)
	tableID = table["id"].(string)

	requestW := h.doJSON(http.MethodPost, "/api/v2/reservation-request", map[string]interface{}{
		"userId": customerID, "shopId": shopID, "eventId": eventID, "partySize": 4,
	}, ownerToken)
	if requestW.Code != http.StatusCreated {
		t.Fatalf("create reservation request: expected 201, got %d; body: %s", requestW.Code, requestW.Body.String())
	}
	var request map[string]interface{}
	json.Unmarshal(requestW.Body.Bytes(), &request)
	return request["id"].(string), tableID
}

// ===== Subscription Gate Test Matrix (Phase 15) =====

type gatePlanKind string

const (
	gatePlanStarter gatePlanKind = "starter"
	gatePlanGrowth  gatePlanKind = "growth"
	gatePlanPro     gatePlanKind = "pro"
	gatePlanCustom  gatePlanKind = "custom"
	gatePlanAdmin   gatePlanKind = "admin"
)

type gatePlan struct {
	kind     gatePlanKind
	features []string
}

func (h *testHarness) applyGatePlan(t *testing.T, ownerID string, plan gatePlan) {
	t.Helper()
	switch plan.kind {
	case gatePlanStarter:
		tier := model.PlanTierStarter
		h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &tier)
	case gatePlanGrowth:
		tier := model.PlanTierGrowth
		h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &tier)
	case gatePlanPro:
		tier := model.PlanTierPro
		h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &tier)
	case gatePlanCustom:
		h.createCustomOwnerSubscription(t, ownerID, plan.features)
	case gatePlanAdmin:
		tier := model.PlanTierStarter
		h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &tier)
	default:
		t.Fatalf("unknown gate plan kind: %s", plan.kind)
	}
}

func (h *testHarness) createCustomOwnerSubscription(t *testing.T, ownerID string, features []string) {
	t.Helper()
	h.createOwnerSubscription(t, ownerID, model.PlanModeCustom, nil)
	for _, featureKey := range features {
		row := model.OwnerSubscriptionFeature{UserID: ownerID, FeatureKey: featureKey}
		if err := h.db.Create(&row).Error; err != nil {
			t.Fatalf("create custom feature %s: %v", featureKey, err)
		}
	}
}

func (h *testHarness) gateToken(t *testing.T, ownerID string, plan gatePlan, suffix string) string {
	t.Helper()
	if plan.kind == gatePlanAdmin {
		adminID := h.createUser(t, "Gate Admin "+suffix, "gate-admin-"+suffix+"@example.com", "ADMIN")
		return h.tokenForUser(adminID, []string{"admin"})
	}
	return h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
}

func (h *testHarness) seedTablesForShop(t *testing.T, shopID string, count int) {
	t.Helper()
	for i := 1; i <= count; i++ {
		if err := h.db.Exec(
			"INSERT INTO tables (id, number, capacity, shop_id) VALUES (?, ?, 4, ?)",
			uuid.New().String(), i, shopID,
		).Error; err != nil {
			t.Fatalf("seed table %d: %v", i, err)
		}
	}
}

func (h *testHarness) seedEmployeesForShop(t *testing.T, ownerToken, shopID string, count int) {
	t.Helper()
	for i := 1; i <= count; i++ {
		employeeID := h.createUser(t, fmt.Sprintf("Gate Employee %d", i), fmt.Sprintf("gate-employee-%d@example.com", i), "SHOP_OWNER")
		w := h.doJSON(http.MethodPost, "/api/v2/shop-employees", map[string]interface{}{
			"shopId": shopID, "userId": employeeID,
		}, ownerToken)
		if w.Code != http.StatusCreated {
			t.Fatalf("seed employee %d: expected 201, got %d; body: %s", i, w.Code, w.Body.String())
		}
	}
}

func TestSubscriptionGates_ReservationAccept(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		wantStatus int
	}{
		{"starter_blocked", gatePlan{kind: gatePlanStarter}, http.StatusPaymentRequired},
		{"growth_allowed", gatePlan{kind: gatePlanGrowth}, http.StatusOK},
		{"custom_with_feature", gatePlan{kind: gatePlanCustom, features: []string{"reservation_manage"}}, http.StatusOK},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom}, http.StatusPaymentRequired},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, http.StatusOK},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-res-accept-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			customerID := h.createUser(t, "Gate Customer", "gate-res-accept-customer-"+tc.name+"@example.com", "CUSTOMER")
			requestID, tableID := h.createPendingReservationRequest(t, ownerID, ownerToken, customerID, "Gate Shop", "Gate Event")

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/reservation-request/"+requestID+"/accept", map[string]interface{}{
				"tableId": tableID,
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
		})
	}
}

func TestSubscriptionGates_EventCreate(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		wantStatus int
	}{
		{"starter_blocked", gatePlan{kind: gatePlanStarter}, http.StatusPaymentRequired},
		{"growth_allowed", gatePlan{kind: gatePlanGrowth}, http.StatusCreated},
		{"custom_with_feature", gatePlan{kind: gatePlanCustom, features: []string{"event_create"}}, http.StatusCreated},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom}, http.StatusPaymentRequired},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, http.StatusCreated},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-event-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			shopID := h.createShopForOwner(t, ownerID, ownerToken, "Gate Event Shop")

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
				"eventName": "Gate Event", "eventDate": "2026-08-01",
				"description": "test", "shopId": shopID,
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
		})
	}
}

func TestSubscriptionGates_EmployeeAssign(t *testing.T) {
	cases := []struct {
		name          string
		plan          gatePlan
		seedEmployees int
		wantStatus    int
		wantLimit     string
	}{
		{"starter_blocked", gatePlan{kind: gatePlanStarter}, 0, http.StatusPaymentRequired, ""},
		{"growth_allowed", gatePlan{kind: gatePlanGrowth}, 0, http.StatusCreated, ""},
		{"growth_at_employee_cap", gatePlan{kind: gatePlanGrowth}, 3, http.StatusPaymentRequired, "employees"},
		{"custom_with_feature", gatePlan{kind: gatePlanCustom, features: []string{"employee_assign"}}, 0, http.StatusCreated, ""},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom}, 0, http.StatusPaymentRequired, ""},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, 0, http.StatusCreated, ""},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-employee-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			shopID := h.createShopForOwner(t, ownerID, ownerToken, "Gate Employee Shop")
			if tc.seedEmployees > 0 {
				h.seedEmployeesForShop(t, ownerToken, shopID, tc.seedEmployees)
			}

			employeeID := h.createUser(t, "Gate Employee Target", "gate-employee-target-"+tc.name+"@example.com", "SHOP_OWNER")
			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/shop-employees", map[string]interface{}{
				"shopId": shopID, "userId": employeeID,
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
			if tc.wantLimit != "" {
				var body map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &body)
				if body["limit"] != tc.wantLimit {
					t.Errorf("expected limit %q, got %v", tc.wantLimit, body["limit"])
				}
			}
		})
	}
}

func TestSubscriptionGates_CommunityAnnouncement(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		wantStatus int
	}{
		{"starter_blocked", gatePlan{kind: gatePlanStarter}, http.StatusPaymentRequired},
		{"growth_allowed", gatePlan{kind: gatePlanGrowth}, http.StatusCreated},
		{"custom_with_feature", gatePlan{kind: gatePlanCustom, features: []string{"community_post"}}, http.StatusCreated},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom}, http.StatusPaymentRequired},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, http.StatusCreated},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-community-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			shopID := h.createShopForOwner(t, ownerID, ownerToken, "Gate Community Shop")

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/shop/"+shopID+"/community/announcements", map[string]interface{}{
				"body": "Gate announcement",
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
		})
	}
}

func TestSubscriptionGates_LoyaltyPlanBasic(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		wantStatus int
	}{
		{"starter_blocked", gatePlan{kind: gatePlanStarter}, http.StatusPaymentRequired},
		{"growth_allowed", gatePlan{kind: gatePlanGrowth}, http.StatusCreated},
		{"custom_with_feature", gatePlan{kind: gatePlanCustom, features: []string{"loyalty_basic"}}, http.StatusCreated},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom}, http.StatusPaymentRequired},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, http.StatusCreated},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-loyalty-basic-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			h.createShopForOwner(t, ownerID, ownerToken, "Gate Loyalty Shop")

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/loyalty-plan", map[string]interface{}{
				"name": "Gate Basic Plan", "description": "Points", "type": "BASIC",
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
		})
	}
}

func TestSubscriptionGates_LoyaltyPlanPremium(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		wantStatus int
	}{
		{"starter_blocked", gatePlan{kind: gatePlanStarter}, http.StatusPaymentRequired},
		{"growth_blocked", gatePlan{kind: gatePlanGrowth}, http.StatusPaymentRequired},
		{"pro_allowed", gatePlan{kind: gatePlanPro}, http.StatusCreated},
		{"custom_with_feature", gatePlan{kind: gatePlanCustom, features: []string{"loyalty_premium"}}, http.StatusCreated},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom, features: []string{"loyalty_basic"}}, http.StatusPaymentRequired},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, http.StatusCreated},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-loyalty-premium-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			h.createShopForOwner(t, ownerID, ownerToken, "Gate Premium Loyalty Shop")

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/loyalty-plan", map[string]interface{}{
				"name": "Gate Premium Plan", "description": "VIP", "type": "PREMIUM",
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
		})
	}
}

func TestSubscriptionGates_TableCreate(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		seedTables int
		wantStatus int
		wantLimit  string
	}{
		{"starter_at_cap", gatePlan{kind: gatePlanStarter}, 15, http.StatusPaymentRequired, "tables"},
		{"growth_allowed", gatePlan{kind: gatePlanGrowth}, 0, http.StatusCreated, ""},
		{"custom_with_unlimited", gatePlan{kind: gatePlanCustom, features: []string{"unlimited_tables"}}, 15, http.StatusCreated, ""},
		{"custom_without_feature_at_cap", gatePlan{kind: gatePlanCustom}, 15, http.StatusPaymentRequired, "tables"},
		{"admin_bypass_at_cap", gatePlan{kind: gatePlanAdmin}, 15, http.StatusCreated, ""},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-table-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			shopID := h.createShopForOwner(t, ownerID, ownerToken, "Gate Table Shop")
			if tc.seedTables > 0 {
				h.seedTablesForShop(t, shopID, tc.seedTables)
			}

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/table", map[string]interface{}{
				"number": tc.seedTables + 1, "capacity": 4, "shopId": shopID,
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
			if tc.wantLimit != "" {
				var body map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &body)
				if body["limit"] != tc.wantLimit {
					t.Errorf("expected limit %q, got %v", tc.wantLimit, body["limit"])
				}
			}
		})
	}
}

func TestSubscriptionGates_MenuCreate(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		seedMenus  int
		wantStatus int
		wantLimit  string
	}{
		{"starter_second_menu", gatePlan{kind: gatePlanStarter}, 1, http.StatusPaymentRequired, "menus"},
		{"growth_allowed", gatePlan{kind: gatePlanGrowth}, 1, http.StatusCreated, ""},
		{"custom_with_unlimited", gatePlan{kind: gatePlanCustom, features: []string{"unlimited_menus"}}, 1, http.StatusCreated, ""},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom}, 1, http.StatusPaymentRequired, "menus"},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, 1, http.StatusCreated, ""},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-menu-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			shopID := h.createShopForOwner(t, ownerID, ownerToken, "Gate Menu Shop")

			for i := 0; i < tc.seedMenus; i++ {
				w := h.doJSON(http.MethodPost, "/api/v2/menu", map[string]interface{}{
					"label": fmt.Sprintf("Menu %d", i+1), "shopId": shopID, "current": i == 0,
				}, ownerToken)
				if w.Code != http.StatusCreated {
					t.Fatalf("seed menu %d: expected 201, got %d; body: %s", i+1, w.Code, w.Body.String())
				}
			}

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/menu", map[string]interface{}{
				"label": "Gate Menu", "shopId": shopID, "current": false,
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
			if tc.wantLimit != "" {
				var body map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &body)
				if body["limit"] != tc.wantLimit {
					t.Errorf("expected limit %q, got %v", tc.wantLimit, body["limit"])
				}
			}
		})
	}
}

func TestSubscriptionGates_ShopCreate(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		seedShops  int
		wantStatus int
		wantLimit  string
	}{
		{"starter_second_shop", gatePlan{kind: gatePlanStarter}, 1, http.StatusPaymentRequired, "shops"},
		{"growth_second_shop", gatePlan{kind: gatePlanGrowth}, 1, http.StatusCreated, ""},
		{"custom_second_shop", gatePlan{kind: gatePlanCustom, features: []string{"event_create"}}, 1, http.StatusCreated, ""},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, 1, http.StatusCreated, ""},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-shop-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			for i := 0; i < tc.seedShops; i++ {
				h.createShopForOwner(t, ownerID, ownerToken, fmt.Sprintf("Gate Shop %d", i+1))
			}

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodPost, "/api/v2/shop", map[string]interface{}{
				"name": "Gate Second Shop", "address": "2 St", "city": "Beograd", "phoneNumber": "456",
				"ownerUserId": ownerID,
			}, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
			if tc.wantLimit != "" {
				var body map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &body)
				if body["limit"] != tc.wantLimit {
					t.Errorf("expected limit %q, got %v", tc.wantLimit, body["limit"])
				}
			}
		})
	}
}

func TestSubscriptionGates_ReviewDelete(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		wantStatus int
	}{
		{"starter_blocked", gatePlan{kind: gatePlanStarter}, http.StatusPaymentRequired},
		{"growth_allowed", gatePlan{kind: gatePlanGrowth}, http.StatusNoContent},
		{"custom_with_feature", gatePlan{kind: gatePlanCustom, features: []string{"review_moderate"}}, http.StatusNoContent},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom}, http.StatusPaymentRequired},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, http.StatusNoContent},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Gate Owner", "gate-review-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			shopID := h.createShopForOwner(t, ownerID, ownerToken, "Gate Review Shop")
			reviewID := h.createReviewForShop(t, ownerID, ownerToken, shopID)

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodDelete, "/api/v2/review/"+reviewID, nil, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}
		})
	}
}

func TestSubscriptionGates_DashboardAnalytics(t *testing.T) {
	cases := []struct {
		name       string
		plan       gatePlan
		wantStatus int
		verifyData bool
	}{
		{"starter_blocked", gatePlan{kind: gatePlanStarter}, http.StatusPaymentRequired, false},
		{"growth_blocked", gatePlan{kind: gatePlanGrowth}, http.StatusPaymentRequired, false},
		{"pro_allowed", gatePlan{kind: gatePlanPro}, http.StatusOK, true},
		{"custom_with_feature", gatePlan{kind: gatePlanCustom, features: []string{"analytics"}}, http.StatusOK, true},
		{"custom_without_feature", gatePlan{kind: gatePlanCustom}, http.StatusPaymentRequired, false},
		{"admin_bypass", gatePlan{kind: gatePlanAdmin}, http.StatusOK, true},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			h := setupTestHarness(t)
			h.seedSubscriptionCatalog(t)
			ownerID := h.createUser(t, "Analytics Owner", "gate-analytics-owner-"+tc.name+"@example.com", "SHOP_OWNER")
			ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
			h.applyGatePlan(t, ownerID, tc.plan)
			shopID := h.createShopForOwner(t, ownerID, ownerToken, "Analytics Shop")

			if tc.verifyData {
				h.seedAnalyticsDataForShop(t, ownerID, ownerToken, shopID)
			}

			token := h.gateToken(t, ownerID, tc.plan, tc.name)
			w := h.doJSON(http.MethodGet, "/api/v2/dashboard/analytics", nil, token)
			if w.Code != tc.wantStatus {
				t.Fatalf("expected %d, got %d; body: %s", tc.wantStatus, w.Code, w.Body.String())
			}

			if tc.wantStatus == http.StatusPaymentRequired {
				var body map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &body)
				if body["requiredPlan"] != "PRO" {
					t.Errorf("expected requiredPlan PRO, got %v", body["requiredPlan"])
				}
				features, ok := body["requiredFeatures"].([]interface{})
				if !ok || len(features) == 0 || features[0] != "analytics" {
					t.Errorf("expected requiredFeatures to include analytics, got %v", body["requiredFeatures"])
				}
			}

			if tc.verifyData {
				var analytics map[string]interface{}
				json.Unmarshal(w.Body.Bytes(), &analytics)

				aggregate, ok := analytics["aggregate"].(map[string]interface{})
				if !ok {
					t.Fatalf("expected aggregate block, got %v", analytics["aggregate"])
				}
				if aggregate["shopCount"].(float64) != 1 {
					t.Errorf("expected shopCount 1, got %v", aggregate["shopCount"])
				}
				if aggregate["reviewCount"].(float64) != 2 {
					t.Errorf("expected reviewCount 2, got %v", aggregate["reviewCount"])
				}
				if aggregate["eventCount"].(float64) < 1 {
					t.Errorf("expected eventCount >= 1, got %v", aggregate["eventCount"])
				}
				if aggregate["reservationCount"].(float64) != 1 {
					t.Errorf("expected reservationCount 1, got %v", aggregate["reservationCount"])
				}
				if aggregate["pendingReservationRequestCount"].(float64) != 1 {
					t.Errorf("expected pendingReservationRequestCount 1, got %v", aggregate["pendingReservationRequestCount"])
				}
				if aggregate["averageRating"].(float64) != 4.5 {
					t.Errorf("expected averageRating 4.5, got %v", aggregate["averageRating"])
				}

				shops, ok := analytics["shops"].([]interface{})
				if !ok || len(shops) != 1 {
					t.Fatalf("expected 1 shop analytics row, got %v", analytics["shops"])
				}
				shopRow, ok := shops[0].(map[string]interface{})
				if !ok {
					t.Fatalf("expected shop analytics object, got %T", shops[0])
				}
				if shopRow["shopId"] != shopID {
					t.Errorf("expected shopId %s, got %v", shopID, shopRow["shopId"])
				}
				if shopRow["shopName"] != "Analytics Shop" {
					t.Errorf("expected shopName Analytics Shop, got %v", shopRow["shopName"])
				}
			}
		})
	}
}

func (h *testHarness) seedAnalyticsDataForShop(t *testing.T, ownerID, ownerToken, shopID string) {
	t.Helper()

	customerID := h.createUser(t, "Analytics Customer", "analytics-customer-"+shopID+"@example.com", "CUSTOMER")
	customerToken := h.tokenForUser(customerID, []string{"CUSTOMER"})

	w := h.doJSON(http.MethodPost, "/api/v2/review", map[string]interface{}{
		"title": "Great", "description": "Loved it", "rating": 4,
		"shopId": shopID, "commentsEnabled": true,
	}, customerToken)
	if w.Code != http.StatusCreated {
		t.Fatalf("seed review 1: expected 201, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodPost, "/api/v2/review", map[string]interface{}{
		"title": "Excellent", "description": "Five stars", "rating": 5,
		"shopId": shopID, "commentsEnabled": true,
	}, customerToken)
	if w.Code != http.StatusCreated {
		t.Fatalf("seed review 2: expected 201, got %d; body: %s", w.Code, w.Body.String())
	}

	eventID := uuid.New().String()
	if err := h.db.Exec(
		"INSERT INTO event (event_id, event_name, event_date, description, shop_id) VALUES (?, ?, ?, ?, ?)",
		eventID, "Analytics Event", "2026-08-01", "test", shopID,
	).Error; err != nil {
		t.Fatalf("seed event: %v", err)
	}

	tableID := uuid.New().String()
	if err := h.db.Exec(
		"INSERT INTO tables (id, number, capacity, shop_id) VALUES (?, ?, 4, ?)",
		tableID, 1, shopID,
	).Error; err != nil {
		t.Fatalf("seed table: %v", err)
	}

	reservationID := uuid.New().String()
	if err := h.db.Exec(
		`INSERT INTO reservations (id, party_size, user_id, shop_id, table_id, event_id)
		 VALUES (?, 4, ?, ?, ?, ?)`,
		reservationID, customerID, shopID, tableID, eventID,
	).Error; err != nil {
		t.Fatalf("seed reservation: %v", err)
	}

	requestID := uuid.New().String()
	if err := h.db.Exec(
		`INSERT INTO reservation_request (id, party_size, status, user_id, shop_id, event_id)
		 VALUES (?, 2, 'PENDING', ?, ?, ?)`,
		requestID, customerID, shopID, eventID,
	).Error; err != nil {
		t.Fatalf("seed reservation request: %v", err)
	}

	if err := h.db.Exec(
		`INSERT INTO community_post (id, body, created_at, type, pinned, author_id, shop_id)
		 VALUES (?, 'Hello members', '2026-07-01', 'POST', false, ?, ?)`,
		uuid.New().String(), ownerID, shopID,
	).Error; err != nil {
		t.Fatalf("seed community post: %v", err)
	}

	_ = ownerToken
}

func TestShopStaffAuthz_CustomerCannotManageShopResources(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Authz Owner", "authz-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	customerID := h.createUser(t, "Authz Customer", "authz-customer@example.com", "CUSTOMER")
	customerToken := h.tokenForUser(customerID, []string{"CUSTOMER"})

	shopID := h.createShopForOwner(t, ownerID, ownerToken, "Authz Shop")

	menuW := h.doJSON(http.MethodPost, "/api/v2/menu", map[string]interface{}{
		"shopId": shopID,
	}, ownerToken)
	if menuW.Code != http.StatusCreated {
		t.Fatalf("owner create menu: expected 201, got %d; body: %s", menuW.Code, menuW.Body.String())
	}
	var menu map[string]interface{}
	json.Unmarshal(menuW.Body.Bytes(), &menu)
	menuID := menu["id"].(string)

	cases := []struct {
		name   string
		method string
		path   string
		body   map[string]interface{}
	}{
		{"create table", http.MethodPost, "/api/v2/table", map[string]interface{}{
			"number": 9, "capacity": 4, "shopId": shopID,
		}},
		{"create menu", http.MethodPost, "/api/v2/menu", map[string]interface{}{
			"shopId": shopID,
		}},
		{"create menu item", http.MethodPost, "/api/v2/menu-item", map[string]interface{}{
			"name": "Latte", "price": 3.5, "priceCurrency": "EUR", "itemType": "DRINK", "menuId": menuID,
		}},
		{"create event", http.MethodPost, "/api/v2/event", map[string]interface{}{
			"eventName": "Blocked Event", "eventDate": "2026-08-01", "description": "x", "shopId": shopID,
		}},
		{"create announcement", http.MethodPost, "/api/v2/shop/" + shopID + "/community/announcements", map[string]interface{}{
			"body": "Blocked announcement",
		}},
		{"assign employee", http.MethodPost, "/api/v2/shop-employees", map[string]interface{}{
			"shopId": shopID, "userId": customerID,
		}},
	}
	for _, tc := range cases {
		w := h.doJSON(tc.method, tc.path, tc.body, customerToken)
		if w.Code != http.StatusForbidden {
			t.Errorf("%s: expected 403 for customer, got %d; body: %s", tc.name, w.Code, w.Body.String())
			continue
		}
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		if msg, _ := resp["message"].(string); msg == "" {
			t.Errorf("%s: expected error message in 403 body, got: %s", tc.name, w.Body.String())
		}
	}
}

func TestShopStaffAuthz_EmployeeCanManageContentButNotEmployeesOrShop(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Emp Authz Owner", "emp-authz-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	h.enableGrowthEventCreate(t, ownerID)
	employeeID := h.createUser(t, "Emp Authz Employee", "emp-authz-emp@example.com", "SHOP_OWNER")
	employeeToken := h.tokenForUser(employeeID, []string{"SHOP_OWNER"})
	otherID := h.createUser(t, "Emp Authz Other", "emp-authz-other@example.com", "CUSTOMER")

	shopID := h.createShopForOwner(t, ownerID, ownerToken, "Emp Authz Shop")

	assignW := h.doJSON(http.MethodPost, "/api/v2/shop-employees", map[string]interface{}{
		"shopId": shopID, "userId": employeeID,
	}, ownerToken)
	if assignW.Code != http.StatusCreated {
		t.Fatalf("owner assign employee: expected 201, got %d; body: %s", assignW.Code, assignW.Body.String())
	}

	// Employees can manage shop content.
	w := h.doJSON(http.MethodPost, "/api/v2/table", map[string]interface{}{
		"number": 5, "capacity": 2, "shopId": shopID,
	}, employeeToken)
	if w.Code != http.StatusCreated {
		t.Errorf("employee create table: expected 201, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodPost, "/api/v2/menu", map[string]interface{}{
		"shopId": shopID,
	}, employeeToken)
	if w.Code != http.StatusCreated {
		t.Errorf("employee create menu: expected 201, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "Emp Event", "eventDate": "2026-08-01", "description": "x", "shopId": shopID,
	}, employeeToken)
	if w.Code != http.StatusCreated {
		t.Errorf("employee create event: expected 201, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodPost, "/api/v2/shop/"+shopID+"/community/announcements", map[string]interface{}{
		"body": "Employee announcement",
	}, employeeToken)
	if w.Code != http.StatusCreated {
		t.Errorf("employee create announcement: expected 201, got %d; body: %s", w.Code, w.Body.String())
	}

	// Employees cannot manage employees or delete the shop.
	w = h.doJSON(http.MethodPost, "/api/v2/shop-employees", map[string]interface{}{
		"shopId": shopID, "userId": otherID,
	}, employeeToken)
	if w.Code != http.StatusForbidden {
		t.Errorf("employee assign employee: expected 403, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodDelete, "/api/v2/shop-employees", map[string]interface{}{
		"shopId": shopID, "userId": employeeID,
	}, employeeToken)
	if w.Code != http.StatusForbidden {
		t.Errorf("employee remove employee: expected 403, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodDelete, "/api/v2/shop/"+shopID, nil, employeeToken)
	if w.Code != http.StatusForbidden {
		t.Errorf("employee delete shop: expected 403, got %d; body: %s", w.Code, w.Body.String())
	}
}

func TestEvent_CreateWithoutShopID_IsBadRequest(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "NoShop Owner", "noshop-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	w := h.doJSON(http.MethodPost, "/api/v2/event", map[string]interface{}{
		"eventName": "Orphan Event", "eventDate": "2026-08-01", "description": "x",
	}, token)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400 for event create without shopId, got %d; body: %s", w.Code, w.Body.String())
	}
}

func TestEvent_ShoplessEvent_OnlyAdminCanModify(t *testing.T) {
	h := setupTestHarness(t)
	ownerID := h.createUser(t, "Legacy Owner", "legacy-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	adminID := h.createUser(t, "Legacy Admin", "legacy-admin@example.com", "ADMIN")
	adminToken := h.tokenForUser(adminID, []string{"admin"})

	// Seed a legacy event without a shop directly in the DB.
	eventID := uuid.New().String()
	h.db.Exec(
		"INSERT INTO event (event_id, event_name, event_date, description, shop_id) VALUES (?, ?, ?, ?, NULL)",
		eventID, "Legacy Event", "2026-08-01", "legacy",
	)

	updateBody := map[string]interface{}{
		"eventName": "Renamed", "eventDate": "2026-08-02", "description": "y",
	}

	w := h.doJSON(http.MethodPut, "/api/v2/event/"+eventID, updateBody, ownerToken)
	if w.Code != http.StatusForbidden {
		t.Errorf("non-admin update shopless event: expected 403, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodDelete, "/api/v2/event/"+eventID, nil, ownerToken)
	if w.Code != http.StatusForbidden {
		t.Errorf("non-admin delete shopless event: expected 403, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodPut, "/api/v2/event/"+eventID, updateBody, adminToken)
	if w.Code != http.StatusOK {
		t.Errorf("admin update shopless event: expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodDelete, "/api/v2/event/"+eventID, nil, adminToken)
	if w.Code != http.StatusNoContent {
		t.Errorf("admin delete shopless event: expected 204, got %d; body: %s", w.Code, w.Body.String())
	}
}

// ===== Admin Subscription API Tests =====

func TestAdminSubscription_NonAdminForbidden(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	ownerID := h.createUser(t, "Admin Sub Owner", "admin-sub-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	endpoints := []struct {
		method string
		path   string
		body   interface{}
	}{
		{http.MethodGet, "/api/v2/admin/subscription/tiers", nil},
		{http.MethodPut, "/api/v2/admin/subscription/tiers", map[string]interface{}{
			"tiers": []map[string]interface{}{{"tier": "GROWTH", "basePriceMonthlyCents": 3000, "annualMonthsCharged": 10, "isActive": true}},
		}},
		{http.MethodGet, "/api/v2/admin/subscription/features", nil},
		{http.MethodPut, "/api/v2/admin/subscription/features", map[string]interface{}{
			"features": []map[string]interface{}{{"featureKey": "event_create", "monthlyPriceCents": 1100, "isSelectableCustom": true, "isActive": true}},
		}},
		{http.MethodGet, "/api/v2/admin/subscription/owners?page=0", nil},
		{http.MethodPut, "/api/v2/admin/subscription/owners/" + ownerID, map[string]interface{}{
			"planMode": "PRESET", "planTier": "GROWTH", "billingInterval": "monthly",
		}},
	}

	for _, ep := range endpoints {
		w := h.doJSON(ep.method, ep.path, ep.body, ownerToken)
		if w.Code != http.StatusForbidden {
			t.Errorf("%s %s: expected 403 for non-admin, got %d; body: %s", ep.method, ep.path, w.Code, w.Body.String())
		}
	}
}

func TestAdminSubscription_PriceChangeReflectedInQuote(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	adminID := h.createUser(t, "Pricing Admin", "pricing-admin@example.com", "ADMIN")
	adminToken := h.tokenForUser(adminID, []string{"admin"})

	ownerID := h.createUser(t, "Pricing Owner", "pricing-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	quoteBody := map[string]interface{}{
		"planMode": "PRESET", "planTier": "GROWTH", "shopCount": 1, "billingInterval": "monthly",
	}
	w := h.doJSON(http.MethodPost, "/api/v2/subscription/quote", quoteBody, ownerToken)
	if w.Code != http.StatusOK {
		t.Fatalf("initial quote: expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var beforeQuote map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &beforeQuote)
	if beforeQuote["monthlyTotalCents"].(float64) != 2900 {
		t.Fatalf("expected initial monthlyTotalCents=2900, got %v", beforeQuote["monthlyTotalCents"])
	}

	updateBody := map[string]interface{}{
		"tiers": []map[string]interface{}{
			{"tier": "GROWTH", "basePriceMonthlyCents": 3500, "extraShopPriceCents": 1500, "annualMonthsCharged": 10, "isActive": true},
		},
	}
	w = h.doJSON(http.MethodPut, "/api/v2/admin/subscription/tiers", updateBody, adminToken)
	if w.Code != http.StatusOK {
		t.Fatalf("admin update tiers: expected 200, got %d; body: %s", w.Code, w.Body.String())
	}

	w = h.doJSON(http.MethodPost, "/api/v2/subscription/quote", quoteBody, ownerToken)
	if w.Code != http.StatusOK {
		t.Fatalf("quote after price change: expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var afterQuote map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &afterQuote)
	if afterQuote["monthlyTotalCents"].(float64) != 3500 {
		t.Errorf("expected monthlyTotalCents=3500 after admin price change, got %v", afterQuote["monthlyTotalCents"])
	}
}

func TestAdminSubscription_ListOwnersAndOverride(t *testing.T) {
	h := setupTestHarness(t)
	h.seedSubscriptionCatalog(t)

	adminID := h.createUser(t, "Owner List Admin", "owner-list-admin@example.com", "ADMIN")
	adminToken := h.tokenForUser(adminID, []string{"admin"})

	ownerID := h.createUser(t, "Owner List Target", "owner-list-target@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
	starterTier := model.PlanTierStarter
	h.createOwnerSubscription(t, ownerID, model.PlanModePreset, &starterTier)
	h.createShopForOwner(t, ownerID, ownerToken, "Owner List Shop")

	w := h.doJSON(http.MethodGet, "/api/v2/admin/subscription/owners?page=0", nil, adminToken)
	if w.Code != http.StatusOK {
		t.Fatalf("list owners: expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var page map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &page)
	content, ok := page["content"].([]interface{})
	if !ok || len(content) == 0 {
		t.Fatalf("expected owners page content, got %v", page["content"])
	}

	found := false
	for _, entry := range content {
		item, ok := entry.(map[string]interface{})
		if !ok {
			continue
		}
		if item["id"] == ownerID {
			found = true
			if item["planTier"] != "STARTER" {
				t.Errorf("expected planTier STARTER, got %v", item["planTier"])
			}
			if item["shopsUsed"].(float64) != 1 {
				t.Errorf("expected shopsUsed=1, got %v", item["shopsUsed"])
			}
		}
	}
	if !found {
		t.Error("expected target owner in paginated list")
	}

	overrideBody := map[string]interface{}{
		"planMode": "PRESET", "planTier": "PRO", "billingInterval": "monthly", "status": "active",
	}
	w = h.doJSON(http.MethodPut, "/api/v2/admin/subscription/owners/"+ownerID, overrideBody, adminToken)
	if w.Code != http.StatusOK {
		t.Fatalf("override owner plan: expected 200, got %d; body: %s", w.Code, w.Body.String())
	}
	var sub map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &sub)
	if sub["planTier"] != "PRO" {
		t.Errorf("expected planTier PRO after override, got %v", sub["planTier"])
	}
}

