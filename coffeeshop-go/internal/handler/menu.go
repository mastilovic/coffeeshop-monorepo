package handler

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type MenuHandler struct {
	db         *gorm.DB
	authorizer *auth.ShopAuthorizer
}

func NewMenuHandler(db *gorm.DB, authorizer *auth.ShopAuthorizer) *MenuHandler {
	return &MenuHandler{db: db, authorizer: authorizer}
}

func (h *MenuHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	var menus []model.Menu
	if err := h.db.WithContext(r.Context()).Find(&menus).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch menus"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(menus)
}

func (h *MenuHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var menu model.Menu
	if err := h.db.WithContext(r.Context()).First(&menu, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Menu not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(menu)
}

func (h *MenuHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req model.Menu
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), req.ShopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	req.ID = uuid.New().String()
	if err := h.db.WithContext(r.Context()).Create(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create menu"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(req)
}

func (h *MenuHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var existing model.Menu
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Menu not found"))
		return
	}

	if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), existing.ShopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req model.Menu
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	req.ID = id
	if err := h.db.WithContext(r.Context()).Save(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update menu"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(req)
}

func (h *MenuHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var existing model.Menu
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Menu not found"))
		return
	}

	if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), existing.ShopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	result := h.db.WithContext(r.Context()).Delete(&model.Menu{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete menu"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Menu not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
