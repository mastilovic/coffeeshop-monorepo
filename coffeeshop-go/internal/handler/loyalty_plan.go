package handler

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type LoyaltyPlanHandler struct {
	db *gorm.DB
}

func NewLoyaltyPlanHandler(db *gorm.DB) *LoyaltyPlanHandler {
	return &LoyaltyPlanHandler{db: db}
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
	id := chi.URLParam(r, "id")
	var existing model.LoyaltyPlan
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Loyalty plan not found"))
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
	id := chi.URLParam(r, "id")
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
