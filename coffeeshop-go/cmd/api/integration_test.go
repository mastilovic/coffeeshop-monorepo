package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/config"
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
	ownerID := h.createUser(t, "Bearer User", "bearer-user@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

	body := map[string]interface{}{
		"name": "B", "username": "user_b", "email": "b@b.com",
		"password": "x", "userType": "CUSTOMER",
	}
	w := h.doJSON(http.MethodPost, "/api/v2/user", body, token)
	if w.Code != http.StatusCreated {
		t.Errorf("expected 201 for POST /user with bearer, got %d; body: %s", w.Code, w.Body.String())
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
	ownerID := h.createUser(t, "Page Owner", "page-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

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
	ownerID := h.createUser(t, "RR Owner", "rr-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
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
	ownerID := h.createUser(t, "Deny Owner", "deny-owner@example.com", "SHOP_OWNER")
	ownerToken := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})
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
	ownerID := h.createUser(t, "Role Owner", "role-owner@example.com", "SHOP_OWNER")
	token := h.tokenForUser(ownerID, []string{"SHOP_OWNER"})

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
	token := h.tokenForUser(adminID, []string{"ADMIN"})

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

