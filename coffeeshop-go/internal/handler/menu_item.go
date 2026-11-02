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

type MenuItemHandler struct {
	db         *gorm.DB
	authorizer *auth.ShopAuthorizer
}

func NewMenuItemHandler(db *gorm.DB, authorizer *auth.ShopAuthorizer) *MenuItemHandler {
	return &MenuItemHandler{db: db, authorizer: authorizer}
}

func (h *MenuItemHandler) authorizeByMenuID(ctx context.Context, menuID string) error {
	var menu model.Menu
	if err := h.db.WithContext(ctx).First(&menu, "id = ?", menuID).Error; err != nil {
		return apperror.NotFound("Menu not found")
	}
	return h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(ctx, menu.ShopID)
}

func (h *MenuItemHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	var items []model.MenuItem
	if err := h.db.WithContext(r.Context()).Find(&items).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch menu items"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(items)
}

func (h *MenuItemHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var item model.MenuItem
	if err := h.db.WithContext(r.Context()).First(&item, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Menu item not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(item)
}

func (h *MenuItemHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req model.MenuItem
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	if err := h.authorizeByMenuID(r.Context(), req.MenuID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	req.ID = uuid.New().String()
	if err := h.db.WithContext(r.Context()).Create(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create menu item"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(req)
}

func (h *MenuItemHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var existing model.MenuItem
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Menu item not found"))
		return
	}

	if err := h.authorizeByMenuID(r.Context(), existing.MenuID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req model.MenuItem
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	req.ID = id
	if err := h.db.WithContext(r.Context()).Save(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update menu item"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(req)
}

func (h *MenuItemHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var existing model.MenuItem
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Menu item not found"))
		return
	}

	if err := h.authorizeByMenuID(r.Context(), existing.MenuID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	result := h.db.WithContext(r.Context()).Delete(&model.MenuItem{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete menu item"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Menu item not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
