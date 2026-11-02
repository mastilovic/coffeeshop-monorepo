package subscription_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
)

func TestRequireFeature_Allowed(t *testing.T) {
	_, svc := setupEntitlementTest(t)

	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/", nil)

	allowed := subscription.RequireFeature(
		w, r, svc,
		mustParseUUID(t, growthOwnerID),
		mustParseUUID(t, growthShopID),
		false,
		subscription.FeatureEventCreate,
	)

	if !allowed {
		t.Fatal("expected RequireFeature to allow growth owner")
	}
	if w.Code != 0 && w.Code != http.StatusOK {
		t.Fatalf("unexpected response written: status=%d body=%s", w.Code, w.Body.String())
	}
}

func TestRequireFeature_DeniedWrites402(t *testing.T) {
	_, svc := setupEntitlementTest(t)

	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/", nil)

	allowed := subscription.RequireFeature(
		w, r, svc,
		mustParseUUID(t, starterOwnerID),
		mustParseUUID(t, starterShopID),
		false,
		subscription.FeatureEventCreate,
	)

	if allowed {
		t.Fatal("expected RequireFeature to deny starter owner")
	}
	if w.Code != http.StatusPaymentRequired {
		t.Fatalf("status code = %d, want %d", w.Code, http.StatusPaymentRequired)
	}

	var body map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode response: %v", err)
	}

	if body["requiredPlan"] != string(model.PlanTierGrowth) {
		t.Fatalf("requiredPlan = %v, want %s", body["requiredPlan"], model.PlanTierGrowth)
	}

	features, ok := body["requiredFeatures"].([]interface{})
	if !ok || len(features) != 1 || features[0] != string(subscription.FeatureEventCreate) {
		t.Fatalf("requiredFeatures = %#v, want [%s]", body["requiredFeatures"], subscription.FeatureEventCreate)
	}
}

func TestRequireFeature_AdminBypass(t *testing.T) {
	_, svc := setupEntitlementTest(t)

	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/", nil)

	allowed := subscription.RequireFeature(
		w, r, svc,
		mustParseUUID(t, starterOwnerID),
		mustParseUUID(t, starterShopID),
		true,
		subscription.FeatureEventCreate,
	)

	if !allowed {
		t.Fatal("expected admin bypass to allow feature")
	}
}

func TestRequireLimit_DeniedWrites402(t *testing.T) {
	db, svc := setupEntitlementTest(t)
	seedTables(t, db, starterShopID, 15)

	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/", nil)

	allowed := subscription.RequireLimit(
		w, r, svc,
		mustParseUUID(t, starterOwnerID),
		mustParseUUID(t, starterShopID),
		subscription.LimitTables,
		false,
	)

	if allowed {
		t.Fatal("expected RequireLimit to deny at-cap starter owner")
	}
	if w.Code != http.StatusPaymentRequired {
		t.Fatalf("status code = %d, want %d", w.Code, http.StatusPaymentRequired)
	}

	var body map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode response: %v", err)
	}

	if body["limit"] != string(subscription.LimitTables) {
		t.Fatalf("limit = %v, want %s", body["limit"], subscription.LimitTables)
	}
	if body["used"] != float64(15) {
		t.Fatalf("used = %v, want 15", body["used"])
	}
	if body["max"] != float64(15) {
		t.Fatalf("max = %v, want 15", body["max"])
	}
	if body["requiredPlan"] != string(model.PlanTierGrowth) {
		t.Fatalf("requiredPlan = %v, want %s", body["requiredPlan"], model.PlanTierGrowth)
	}
}

func TestRequireLimit_AllowedUnderCap(t *testing.T) {
	_, svc := setupEntitlementTest(t)

	w := httptest.NewRecorder()
	r := httptest.NewRequest(http.MethodPost, "/", nil)

	allowed := subscription.RequireLimit(
		w, r, svc,
		mustParseUUID(t, starterOwnerID),
		mustParseUUID(t, starterShopID),
		subscription.LimitTables,
		false,
	)

	if !allowed {
		t.Fatalf("expected under-cap check to pass, body=%s", w.Body.String())
	}
}
