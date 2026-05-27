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

type RoleHandler struct {
	db *gorm.DB
}

func NewRoleHandler(db *gorm.DB) *RoleHandler {
	return &RoleHandler{db: db}
}

func (h *RoleHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	var roles []model.Role
	if err := h.db.WithContext(r.Context()).Find(&roles).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch roles"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(roles)
}

func (h *RoleHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var role model.Role
	if err := h.db.WithContext(r.Context()).First(&role, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Role not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(role)
}

func (h *RoleHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req model.Role
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	req.ID = uuid.New().String()
	if err := h.db.WithContext(r.Context()).Create(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create role"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(req)
}

func (h *RoleHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var existing model.Role
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Role not found"))
		return
	}
	var req model.Role
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	req.ID = id
	if err := h.db.WithContext(r.Context()).Save(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update role"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(req)
}

func (h *RoleHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	result := h.db.WithContext(r.Context()).Delete(&model.Role{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete role"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Role not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
