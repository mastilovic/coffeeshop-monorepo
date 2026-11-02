package apperror_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/mastilovic/coffeeshop-go/internal/apperror"
)

func TestWriteError_PaymentRequired(t *testing.T) {
	growth := "GROWTH"
	used := 15
	max := 15
	limit := "tables"

	err := apperror.PaymentRequired(apperror.PaymentRequiredPayload{
		Message:          "You have reached the tables limit for your current plan",
		RequiredPlan:     &growth,
		RequiredFeatures: []string{"event_create"},
		Limit:            &limit,
		Used:             &used,
		Max:              &max,
	})

	w := httptest.NewRecorder()
	apperror.WriteError(w, err)

	if w.Code != http.StatusPaymentRequired {
		t.Fatalf("status code = %d, want %d", w.Code, http.StatusPaymentRequired)
	}

	var body map[string]interface{}
	if decodeErr := json.Unmarshal(w.Body.Bytes(), &body); decodeErr != nil {
		t.Fatalf("decode response: %v", decodeErr)
	}

	assertStringField(t, body, "message", "You have reached the tables limit for your current plan")
	assertStringField(t, body, "requiredPlan", "GROWTH")
	assertStringField(t, body, "limit", "tables")
	assertFloatField(t, body, "used", 15)
	assertFloatField(t, body, "max", 15)

	features, ok := body["requiredFeatures"].([]interface{})
	if !ok {
		t.Fatalf("requiredFeatures type = %T, want []interface{}", body["requiredFeatures"])
	}
	if len(features) != 1 || features[0] != "event_create" {
		t.Fatalf("requiredFeatures = %#v, want [event_create]", features)
	}
}

func TestWriteError_PaymentRequiredOmitsEmptyFields(t *testing.T) {
	err := apperror.PaymentRequired(apperror.PaymentRequiredPayload{
		Message: "Upgrade required",
	})

	w := httptest.NewRecorder()
	apperror.WriteError(w, err)

	var body map[string]interface{}
	if decodeErr := json.Unmarshal(w.Body.Bytes(), &body); decodeErr != nil {
		t.Fatalf("decode response: %v", decodeErr)
	}

	if _, ok := body["requiredPlan"]; ok {
		t.Fatal("expected requiredPlan to be omitted")
	}
	if _, ok := body["requiredFeatures"]; ok {
		t.Fatal("expected requiredFeatures to be omitted")
	}
	if _, ok := body["limit"]; ok {
		t.Fatal("expected limit to be omitted")
	}
	if _, ok := body["used"]; ok {
		t.Fatal("expected used to be omitted")
	}
	if _, ok := body["max"]; ok {
		t.Fatal("expected max to be omitted")
	}
}

func assertStringField(t *testing.T, body map[string]interface{}, key, want string) {
	t.Helper()
	got, ok := body[key].(string)
	if !ok {
		t.Fatalf("%s type = %T, want string", key, body[key])
	}
	if got != want {
		t.Fatalf("%s = %q, want %q", key, got, want)
	}
}

func assertFloatField(t *testing.T, body map[string]interface{}, key string, want float64) {
	t.Helper()
	got, ok := body[key].(float64)
	if !ok {
		t.Fatalf("%s type = %T, want float64", key, body[key])
	}
	if got != want {
		t.Fatalf("%s = %v, want %v", key, got, want)
	}
}
