package handler

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
	"gorm.io/gorm"
)

type LoyaltyPlanHandler struct {
	db             *gorm.DB
	currentUserSvc *auth.CurrentUserService
	authorizer     *auth.ShopAuthorizer
	entitlements   *subscription.EntitlementService
}

func NewLoyaltyPlanHandler(db *gorm.DB, currentUserSvc *auth.CurrentUserService, authorizer *auth.ShopAuthorizer, entitlements *subscription.EntitlementService) *LoyaltyPlanHandler {
	return &LoyaltyPlanHandler{db: db, currentUserSvc: currentUserSvc, authorizer: authorizer, entitlements: entitlements}
}

func (h *LoyaltyPlanHandler) authorizeByPlanID(ctx context.Context, planID string) error {
	var shop model.Shop
	err := h.db.WithContext(ctx).Where("loyalty_plan_id = ?", planID).First(&shop).Error
	if err != nil {
		// Plan not linked to a shop — only admins may modify orphan plans.
		return h.authorizer.RequireAdmin(ctx)
	}
	return h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(ctx, shop.ID)
}

func (h *LoyaltyPlanHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	var plans []model.LoyaltyPlan
	if err := h.db.WithContext(r.Context()).Find(&plans).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch loyalty plans"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(plans)
}

func (h *LoyaltyPlanHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var plan model.LoyaltyPlan
	if err := h.db.WithContext(r.Context()).First(&plan, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Loyalty plan not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(plan)
}

func (h *LoyaltyPlanHandler) Create(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	// No shop context on create — shop owners and admins may create plans.
	if err := h.authorizer.RequireCanCreateShop(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req model.LoyaltyPlan
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	if !h.requireLoyaltyFeature(w, r, user, loyaltyFeatureForType(req.Type)) {
		return
	}

	req.ID = uuid.New().String()
	if err := h.db.WithContext(r.Context()).Create(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create loyalty plan"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(req)
}

func (h *LoyaltyPlanHandler) Update(w http.ResponseWriter, r *http.Request) {
	if _, err := h.currentUserSvc.RequireCurrentUser(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

	id := chi.URLParam(r, "id")
	var existing model.LoyaltyPlan
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Loyalty plan not found"))
		return
	}

	if err := h.authorizeByPlanID(r.Context(), id); err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req model.LoyaltyPlan
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	req.ID = id
	if err := h.db.WithContext(r.Context()).Save(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update loyalty plan"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(req)
}

func (h *LoyaltyPlanHandler) Delete(w http.ResponseWriter, r *http.Request) {
	if _, err := h.currentUserSvc.RequireCurrentUser(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

	id := chi.URLParam(r, "id")
	var existing model.LoyaltyPlan
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Loyalty plan not found"))
		return
	}

	if err := h.authorizeByPlanID(r.Context(), id); err != nil {
		apperror.WriteError(w, err)
		return
	}

	result := h.db.WithContext(r.Context()).Delete(&model.LoyaltyPlan{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete loyalty plan"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Loyalty plan not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func loyaltyFeatureForType(planType model.LoyaltyPlanType) subscription.Feature {
	switch planType {
	case model.LoyaltyPlanTypePremium, model.LoyaltyPlanTypeVIP:
		return subscription.FeatureLoyaltyPremium
	default:
		return subscription.FeatureLoyaltyBasic
	}
}

func (h *LoyaltyPlanHandler) requireLoyaltyFeature(w http.ResponseWriter, r *http.Request, user *auth.User, feature subscription.Feature) bool {
	userID, err := uuid.Parse(user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Invalid user ID"))
		return false
	}

	isAdmin := h.authorizer.IsAdmin(r.Context())
	if shopID, err := h.firstOwnedShopID(r.Context(), user.ID); err == nil {
		return subscription.RequireFeature(w, r, h.entitlements, userID, shopID, isAdmin, feature)
	}

	if isAdmin {
		return true
	}

	entitlements, err := h.entitlements.ResolveEntitlements(r.Context(), userID, false)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to resolve entitlements"))
		return false
	}
	if entitlements[feature] {
		return true
	}

	message := fmt.Sprintf("Feature %q is not included in your current plan", feature)
	apperror.WriteError(w, apperror.PaymentRequired(apperror.PaymentRequiredPayload{Message: message}))
	return false
}

func (h *LoyaltyPlanHandler) firstOwnedShopID(ctx context.Context, userID string) (uuid.UUID, error) {
	var link model.UserShop
	err := h.db.WithContext(ctx).
		Where("user_id = ? AND relationship_type = ?", userID, model.RelationshipTypeOwner).
		First(&link).Error
	if err != nil {
		return uuid.UUID{}, err
	}
	return uuid.Parse(link.ShopID)
}
