package subscription

import (
	"fmt"
	"net/http"

	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
)

func RequireFeature(w http.ResponseWriter, r *http.Request, entSvc *EntitlementService, userID, shopID uuid.UUID, isAdmin bool, feature Feature) bool {
	allowed, hint := entSvc.CanUse(r.Context(), userID, shopID, feature, isAdmin)
	if allowed {
		return true
	}

	message := fmt.Sprintf("Feature %q is not included in your current plan", feature)
	apperror.WriteError(w, paymentRequiredFromHint(message, hint))
	return false
}

func RequireLimit(w http.ResponseWriter, r *http.Request, entSvc *EntitlementService, userID, shopID uuid.UUID, limit LimitType, isAdmin bool) bool {
	used, max, ok, hint := entSvc.CheckLimit(r.Context(), userID, shopID, limit, isAdmin)
	if ok {
		return true
	}

	limitStr := string(limit)
	message := fmt.Sprintf("You have reached the %s limit for your current plan", limit)
	payload := paymentRequiredPayloadFromHint(message, hint)
	payload.Limit = &limitStr
	payload.Used = &used
	payload.Max = &max
	apperror.WriteError(w, apperror.PaymentRequired(payload))
	return false
}

func paymentRequiredFromHint(message string, hint *UpgradeHint) *apperror.PaymentRequiredError {
	return apperror.PaymentRequired(paymentRequiredPayloadFromHint(message, hint))
}

func PaymentRequiredForFeature(feature Feature, hint *UpgradeHint) *apperror.PaymentRequiredError {
	message := fmt.Sprintf("Feature %q is not included in your current plan", feature)
	return paymentRequiredFromHint(message, hint)
}

func paymentRequiredPayloadFromHint(message string, hint *UpgradeHint) apperror.PaymentRequiredPayload {
	payload := apperror.PaymentRequiredPayload{Message: message}
	if hint == nil {
		return payload
	}

	if hint.RequiredPlan != nil {
		plan := string(*hint.RequiredPlan)
		payload.RequiredPlan = &plan
	}

	if len(hint.RequiredFeatures) > 0 {
		features := make([]string, len(hint.RequiredFeatures))
		for i, feature := range hint.RequiredFeatures {
			features[i] = string(feature)
		}
		payload.RequiredFeatures = features
	}

	return payload
}
