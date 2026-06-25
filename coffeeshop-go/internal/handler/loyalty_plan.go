package handler

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type LoyaltyPlanHandler struct {
	db             *gorm.DB
	currentUserSvc *auth.CurrentUserService
	authorizer     *auth.ShopAuthorizer
}

func NewLoyaltyPlanHandler(db *gorm.DB, currentUserSvc *auth.CurrentUserService, authorizer *auth.ShopAuthorizer) *LoyaltyPlanHandler {
	return &LoyaltyPlanHandler{db: db, currentUserSvc: currentUserSvc, authorizer: authorizer}
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
	if _, err := h.currentUserSvc.RequireCurrentUser(r.Context()); err != nil {
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
